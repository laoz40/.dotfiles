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
    version = "610.57.04";
    sha256 = "sha256-suk1xmuDuwDAyFe8jg7g/VLekoa0DJzB7sKafOfrEW0=";
  };

  nixpkgs.config = {
    allowUnfreePredicate = pkg: pkgs.lib.getName pkg == "nvidia-x11";
    nvidia.acceptLicense = true;
  };
}
