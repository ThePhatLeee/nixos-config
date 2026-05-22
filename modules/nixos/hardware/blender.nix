{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    (blender.override { cudaSupport = true; })
    cudaPackages.cuda_cudart
    cudaPackages.cudnn
  ];
}
