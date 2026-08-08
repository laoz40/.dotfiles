{ pkgs, ... }:

{
  # Intel Iris Xe graphics use the host system's Mesa/Intel stack.
  # No NVIDIA driver configuration is needed.

  home.packages = with pkgs; [
    brightnessctl
    powertop
  ];
}
