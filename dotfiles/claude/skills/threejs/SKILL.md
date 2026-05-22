---
name: threejs
description: Use for any Three.js, WebGL, GLSL, shader, canvas 3D, WebGPU, React Three Fiber, or interactive 3D web work. Triggers on: Three.js, WebGL, shader, GLSL, scene, mesh, geometry, r3f, @react-three, canvas 3D, particle system, postprocessing.
---

# Three.js / WebGL / GLSL

Target: Awwwards SOTD quality. Every scene should have a clear visual concept.
No demo-scene filler. Every effect earns its GPU cost.

## Scene boilerplate (vanilla)
```js
import * as THREE from 'three'

const renderer = new THREE.WebGLRenderer({ antialias: true, alpha: true })
renderer.setPixelRatio(Math.min(window.devicePixelRatio, 2))
renderer.setSize(window.innerWidth, window.innerHeight)
renderer.toneMapping = THREE.ACESFilmicToneMapping
renderer.toneMappingExposure = 1
renderer.outputColorSpace = THREE.SRGBColorSpace
document.body.appendChild(renderer.domElement)

const scene  = new THREE.Scene()
const camera = new THREE.PerspectiveCamera(45, window.innerWidth / window.innerHeight, 0.1, 100)
camera.position.set(0, 0, 5)

window.addEventListener('resize', () => {
  camera.aspect = window.innerWidth / window.innerHeight
  camera.updateProjectionMatrix()
  renderer.setSize(window.innerWidth, window.innerHeight)
})

let raf
function tick() {
  raf = requestAnimationFrame(tick)
  renderer.render(scene, camera)
}
tick()

// cleanup
function destroy() {
  cancelAnimationFrame(raf)
  renderer.dispose()
  scene.traverse(obj => {
    if (obj.geometry) obj.geometry.dispose()
    if (obj.material) {
      if (Array.isArray(obj.material)) obj.material.forEach(m => m.dispose())
      else obj.material.dispose()
    }
  })
}
```

## React Three Fiber (preferred for React projects)
```jsx
import { Canvas, useFrame, useThree } from '@react-three/fiber'
import { Environment, Float, useGLTF, shaderMaterial } from '@react-three/drei'
import { extend } from '@react-three/fiber'
import { EffectComposer, Bloom, DepthOfField } from '@react-three/postprocessing'

// Custom shader material via drei's shaderMaterial
const WaveMaterial = shaderMaterial(
  { uTime: 0, uColor: new THREE.Color(0.2, 0.5, 1.0) },
  vertexShader,
  fragmentShader
)
extend({ WaveMaterial })

function Scene() {
  const ref = useRef()
  const { viewport } = useThree()

  useFrame(({ clock }) => {
    ref.current.uTime = clock.getElapsedTime()
  })

  return (
    <mesh>
      <planeGeometry args={[viewport.width, viewport.height, 64, 64]} />
      <waveMaterial ref={ref} />
    </mesh>
  )
}

export default function App() {
  return (
    <Canvas camera={{ position: [0, 0, 5], fov: 45 }} dpr={[1, 2]}>
      <Scene />
      <Environment preset="city" />
      <EffectComposer>
        <Bloom luminanceThreshold={0.9} intensity={1.5} />
      </EffectComposer>
    </Canvas>
  )
}
```

## GLSL shader patterns

### Vertex — displacement
```glsl
uniform float uTime;
uniform float uStrength;
varying vec2 vUv;
varying float vElevation;

// simplex noise (include as function or import via glsl-noise)
#include <noise>

void main() {
  vUv = uv;
  vec4 modelPos = modelMatrix * vec4(position, 1.0);

  float elevation = sin(modelPos.x * 3.0 + uTime) * 0.1
                  + sin(modelPos.z * 2.0 + uTime * 0.8) * 0.1;
  elevation += cnoise(vec3(modelPos.xz * 2.0, uTime * 0.3)) * uStrength;

  vElevation = elevation;
  modelPos.y += elevation;

  gl_Position = projectionMatrix * viewMatrix * modelPos;
}
```

### Fragment — gradient by elevation + fresnel
```glsl
uniform vec3 uColorLow;
uniform vec3 uColorHigh;
varying float vElevation;
varying vec2 vUv;

void main() {
  vec3 color = mix(uColorLow, uColorHigh, (vElevation + 0.1) * 5.0);

  // Fresnel — edge glow
  // Requires vNormal (world normal) and vViewDirection in vertex shader
  // float fresnel = pow(1.0 - dot(normalize(vNormal), normalize(vViewDirection)), 3.0);
  // color += fresnel * vec3(0.5, 0.8, 1.0);

  gl_FragColor = vec4(color, 1.0);
  #include <colorspace_fragment>  // required for correct output colorspace in three.js
}
```

### Inigo Quilez cosine palette (for procedural color)
```glsl
vec3 palette(float t, vec3 a, vec3 b, vec3 c, vec3 d) {
  return a + b * cos(6.28318 * (c * t + d));
}
// Usage: palette(uv.x, vec3(0.5), vec3(0.5), vec3(1.0), vec3(0.0, 0.33, 0.67))
```

### Curl noise for fluid-like particle motion
```glsl
// Returns a divergence-free (swirling) vector from simplex noise gradient
vec3 curlNoise(vec3 p) {
  const float e = 0.1;
  vec3 dx = vec3(e, 0.0, 0.0);
  vec3 dy = vec3(0.0, e, 0.0);
  vec3 dz = vec3(0.0, 0.0, e);

  float x = snoise(p + dy).z - snoise(p - dy).z
           - snoise(p + dz).y + snoise(p - dz).y;
  float y = snoise(p + dz).x - snoise(p - dz).x
           - snoise(p + dx).z + snoise(p - dx).z;
  float z = snoise(p + dx).y - snoise(p - dx).y
           - snoise(p + dy).x + snoise(p - dy).x;
  return normalize(vec3(x, y, z) / (2.0 * e));
}
```

## GPU performance rules
- `InstancedMesh` for any repeated geometry (particles, grass, crowds, grid elements)
- Merge static geometry with `mergeGeometries()` from `three/examples/jsm/utils/BufferGeometryUtils`
- Frustum culling on by default — don't disable unless you understand the cost
- Texture budget: compress with KTX2/Basis via `THREE.KTX2Loader`; max 2048×2048 per atlas
- Uniforms: update only what changed per frame, not the whole material
- `renderer.info.render` — check draw calls. >100 is a red flag for a "simple" scene
- Dispose everything on unmount/cleanup (geometry, material, texture, renderTarget)

## Particle systems
```js
const count = 50_000
const positions = new Float32Array(count * 3)
for (let i = 0; i < count; i++) {
  positions[i * 3]     = (Math.random() - 0.5) * 10
  positions[i * 3 + 1] = (Math.random() - 0.5) * 10
  positions[i * 3 + 2] = (Math.random() - 0.5) * 10
}

const geometry = new THREE.BufferGeometry()
geometry.setAttribute('position', new THREE.BufferAttribute(positions, 3))

const material = new THREE.ShaderMaterial({
  vertexShader,
  fragmentShader,
  uniforms: { uTime: { value: 0 }, uSize: { value: 2.0 * renderer.getPixelRatio() } },
  transparent: true,
  depthWrite: false,  // critical for transparent particles
  blending: THREE.AdditiveBlending,
})

const points = new THREE.Points(geometry, material)
scene.add(points)
```

## Post-processing (pmndrs/postprocessing — preferred over Three.js built-in)
```js
import { EffectComposer, RenderPass, UnrealBloomPass } from 'postprocessing'

const composer = new EffectComposer(renderer)
composer.addPass(new RenderPass(scene, camera))
composer.addPass(new UnrealBloomPass(new THREE.Vector2(w, h), 1.5, 0.4, 0.85))

// In RAF loop: composer.render() instead of renderer.render()
```

R3F equivalent: `@react-three/postprocessing` wrapping `postprocessing` library.

## Scroll-driven scenes (GSAP + R3F)
```jsx
import { useScroll } from '@react-three/drei'  // ScrollControls
import gsap from 'gsap'
import { ScrollTrigger } from 'gsap/ScrollTrigger'
gsap.registerPlugin(ScrollTrigger)

// Within R3F:
function ScrollScene() {
  const scroll = useScroll()
  const ref    = useRef()

  useFrame(() => {
    ref.current.rotation.y = scroll.offset * Math.PI * 2
    ref.current.position.z = -scroll.offset * 5
  })
}
```

## Awwwards effect cookbook

**Holographic / iridescent material**
```glsl
// Fragment: shift hue by view angle
float ior    = 1.45;
float fresnel = pow(1.0 - dot(vNormal, vViewDir), 3.0);
vec3  holo    = palette(fresnel + uTime * 0.1, ...);
gl_FragColor  = vec4(mix(baseColor, holo, fresnel), 1.0);
```

**Fluid simulation** — ping-pong render targets, velocity + density textures, Navier-Stokes in GLSL. Use `gpgpu` package or hand-roll with two `WebGLRenderTarget`.

**Morph targets** — `geometry.morphAttributes.position`, `mesh.morphTargetInfluences`. Animate with GSAP on influence array.

**Environment reflections** — `THREE.PMREMGenerator` + `THREE.RGBELoader` for HDR env maps. `MeshPhysicalMaterial` with `envMapIntensity`.

**DNA / ribbon** — `THREE.TubeGeometry` along a `THREE.CatmullRomCurve3`. Animate curve control points.

## WebGPU path (Three.js r170+)
```js
import WebGPURenderer from 'three/addons/renderers/common/WebGPURenderer.js'
const renderer = new WebGPURenderer({ antialias: true })
await renderer.init()
// TSL (Three Shading Language) replaces raw GLSL for WebGPU materials
import { color, vec2, uniform, sin, uv, time } from 'three/tsl'
```

## Common mistakes
- Forgetting `#include <colorspace_fragment>` → washed-out colors in Three.js r152+
- Not handling pixel ratio → blurry on retina (`setPixelRatio(Math.min(dpr, 2))`)
- `depthWrite: false` missing on transparent/additive materials → sorting artifacts
- Not cancelling `requestAnimationFrame` → memory leak on unmount
- Creating geometries/materials inside the RAF loop → allocation every frame
