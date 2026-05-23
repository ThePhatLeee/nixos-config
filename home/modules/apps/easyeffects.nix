{ ... }:

{
  # Runs EasyEffects as a PipeWire DSP service on login.
  # Default preset = XPS Internal; switch to Z407 preset when external speakers active.
  services.easyeffects = {
    enable = true;
  };
}
