---
name: blender-cli
description: Use for headless Blender renders, batch jobs, CUDA verification, scripted scene manipulation, render-farm patterns. Host has Blender with CUDA support enabled in modules/nixos/hardware/blender.nix for the RTX 3050 Ti. Auto-triggers on: blender, blender render, headless render, .blend, cycles, eevee, render farm, batch render.
---

# Blender CLI / Headless

The host has Blender with CUDA via `modules/nixos/hardware/blender.nix`:
```nix
(blender.override { cudaSupport = true; })
```

The RTX 3050 Ti has 4GB VRAM — fine for most stills, tight for heavy fluid/volumetrics.

## Verify CUDA is wired

```bash
blender -b --python-expr "
import bpy
prefs = bpy.context.preferences.addons['cycles'].preferences
prefs.compute_device_type = 'CUDA'
prefs.refresh_devices()
for d in prefs.devices:
    print(d.name, d.type, d.use)
"
```

Expected: at least one `NVIDIA GeForce RTX 3050 Ti CUDA True`. If missing → CUDA not picked up; recheck `nvidia-smi` and that you're outside a no-NVIDIA container.

## Single-image render

```bash
blender -b scene.blend -E CYCLES -t 0 \
  -o //renders/frame_#### -F PNG -x 1 \
  -f 1
```

Flags:
- `-b` background (no GUI)
- `-E CYCLES` or `-E BLENDER_EEVEE_NEXT` — engine
- `-t 0` use all CPU threads (Cycles falls back to CPU for tiles GPU doesn't take)
- `-o //path/name_####` output template; `#` = frame number digit
- `-F PNG` output format (PNG, OPEN_EXR, JPEG, etc.)
- `-x 1` always add extension
- `-f N` render single frame N

## Animation range

```bash
blender -b scene.blend -E CYCLES -t 0 \
  -o //renders/frame_#### -F PNG -x 1 \
  -s 1 -e 240 -j 1 -a
```

- `-s 1` start frame
- `-e 240` end frame
- `-j 1` frame step
- `-a` render animation

## Force CUDA before render (Python init)

```bash
blender -b scene.blend --python-expr "
import bpy
bpy.context.scene.cycles.device = 'GPU'
prefs = bpy.context.preferences.addons['cycles'].preferences
prefs.compute_device_type = 'CUDA'
for d in prefs.devices:
    d.use = d.type == 'CUDA'
" -f 1
```

Without this, a `.blend` file saved on CPU defaults to CPU even with CUDA available.

## Tile + sample tuning for 4GB VRAM

```python
# --python-expr or saved into scene
import bpy
s = bpy.context.scene
s.cycles.samples = 256
s.cycles.use_denoising = True
s.cycles.denoiser = 'OPTIX'         # uses tensor cores on RTX
s.cycles.tile_size = 1024            # smaller if you hit OOM
s.cycles.use_adaptive_sampling = True
s.cycles.adaptive_threshold = 0.01
```

For 4GB VRAM: if "out of memory" → drop tile to 512, lower texture cache, bake heavy modifiers to mesh before render.

## Batch — multiple files

```bash
for f in scenes/*.blend; do
  out="renders/$(basename "$f" .blend)_####"
  blender -b "$f" -E CYCLES -t 0 -o "//$out" -F PNG -x 1 -a
done
```

For parallel (CPU-bound, not GPU — GPU is serial per Blender process):
```bash
ls scenes/*.blend | xargs -P 1 -I {} blender -b {} -E CYCLES -o //renders/ -a
# P=1 because they all want the same GPU; sequential is correct
```

## Scripted scene manipulation

```bash
blender -b scene.blend --python script.py
```

```python
# script.py
import bpy, sys, os
out = os.environ.get('OUT', '//renders/out')
seed = int(os.environ.get('SEED', '42'))

bpy.context.scene.cycles.seed = seed
bpy.context.scene.render.filepath = out
bpy.ops.render.render(write_still=True)
```

Pass env vars:
```bash
OUT=//renders/v01 SEED=7 blender -b scene.blend --python script.py
```

## Common scripted ops

```python
# Toggle a collection visibility
bpy.data.collections['Background'].hide_render = False

# Change material parameter
mat = bpy.data.materials['Sky']
mat.node_tree.nodes['Sky Texture'].sun_elevation = 0.8

# Set resolution
r = bpy.context.scene.render
r.resolution_x = 3840
r.resolution_y = 2160
r.resolution_percentage = 100

# Set output format
r.image_settings.file_format = 'OPEN_EXR_MULTILAYER'
r.image_settings.exr_codec = 'ZIP'
r.image_settings.color_depth = '16'

# Animation export
r.fps = 24
bpy.context.scene.frame_start = 1
bpy.context.scene.frame_end = 240
```

## Render farm pattern (local "farm" across overnight)

```bash
#!/usr/bin/env bash
# render-overnight.sh — split animation across N batches with checkpoints
set -euo pipefail
FILE=$1
START=${2:-1}
END=${3:-240}
BATCH=${4:-30}

for ((s=START; s<=END; s+=BATCH)); do
  e=$((s + BATCH - 1))
  [ $e -gt $END ] && e=$END
  echo "==== $s..$e ===="
  blender -b "$FILE" -E CYCLES -t 0 -o "//renders/frame_####" -F PNG -x 1 -s $s -e $e -a
  echo "checkpoint: $e" > .render-checkpoint
done
```

Resume from checkpoint: `./render-overnight.sh scene.blend $(($(cat .render-checkpoint)+1)) 240 30`.

## Compose video from frames

```bash
ffmpeg -framerate 24 -i renders/frame_%04d.png \
  -c:v libx264 -pix_fmt yuv420p -crf 18 -preset slow \
  out.mp4
```

For lossless intermediates:
```bash
ffmpeg -framerate 24 -i renders/frame_%04d.png \
  -c:v ffv1 -level 3 out.mkv
```

## Eevee for fast turnarounds

Eevee Next (Blender 4.2+) is the default — closer to Cycles quality, GPU-rasterized. Use when:
- Iterating shading/lighting; final pass in Cycles
- Real-time motion previews
- VRAM-bound (Eevee uses less than Cycles GPU mode)

```bash
blender -b scene.blend -E BLENDER_EEVEE_NEXT -o //preview/####  -F PNG -x 1 -a
```

## Anti-patterns

- Rendering Cycles GPU with default tile size on 4GB → OOM mid-frame, restart loses progress
- `-t 1` "to free GPU" → Cycles GPU doesn't need CPU off, you just lose denoise speed
- Sample count 4096+ on every still → OptiX denoise from 128 samples is usually indistinguishable
- Not enabling adaptive sampling → fixed N samples on flat areas wastes hours
- Saving over the source .blend during a script run — always save-as if mutating
- Forgetting `-x 1` and ending up with extensionless files
