{ pkgs, ... }:

{
  programs.dank-material-shell = {
    enable = true;
    systemd.enable = false;
    enableVPN = false;
    enableDynamicTheming = false;
    enableAudioWavelength = false;
  };

  targets.genericLinux.gpu.nvidia = {
    enable = true;
    version = "620.70.06";
    sha256 = "sha256-KRGOOr0IwHVZvMo9nHYjjQOUkK8DYqLlvPy+cgSv1LE=";
  };

  nixpkgs.config = {
    allowUnfreePredicate = pkg: pkgs.lib.getName pkg == "nvidia-x11";
    nvidia.acceptLicense = true;
  };
}
