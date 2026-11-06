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
    version = "615.78.08";
    sha256 = "sha256-Pj9t3cLudnoIGFMAr3vjyyhuznZpjS3eNSRZl4LQf/4=";
  };

  nixpkgs.config = {
    allowUnfreePredicate = pkg: pkgs.lib.getName pkg == "nvidia-x11";
    nvidia.acceptLicense = true;
  };
}
