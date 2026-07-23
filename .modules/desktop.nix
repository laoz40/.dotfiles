{ pkgs, ... }:

{
  targets.genericLinux.gpu.nvidia = {
    enable = true;
    version = "610.43.03";
    sha256 = "sha256-ReLUwTSiPDXlDyU6SqY+fl6NF+PRhdSgfIpY6WEu05I=";
  };

  nixpkgs.config = {
    allowUnfreePredicate = pkg: pkgs.lib.getName pkg == "nvidia-x11";
    nvidia.acceptLicense = true;
  };
}
