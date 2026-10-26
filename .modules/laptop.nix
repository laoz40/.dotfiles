{ pkgs, ... }:

{
  # The desktop uses DMS notifications; the laptop needs its own daemon.
  services.dunst.enable = true;

  # Intel Iris Xe graphics use the host system's Mesa/Intel stack.
  # No NVIDIA driver configuration is needed.

  gtk.font = {
    name = "Adwaita Sans";
    size = 11;
  };

  dconf.settings."org/gnome/desktop/interface".font-name = "Adwaita Sans 11";

  home.packages = with pkgs; [
    waybar
    powertop
  ];
}
