{ pkgs, ... }:

let
  x11Libraries = with pkgs; [
    libx11
    libxcb
    libxt
    libxtst
    libxinerama
    libxkbcommon
  ];

  ninbot = pkgs.writeShellScriptBin "ninbot" ''
    export LD_LIBRARY_PATH=${pkgs.lib.makeLibraryPath x11Libraries}

    exec ${pkgs.jdk21}/bin/java \
      -Dswing.defaultlaf=javax.swing.plaf.metal.MetalLookAndFeel \
      -Dawt.useSystemAAFontSettings=on \
      -jar "$1"
  '';
in
{
  home.packages = with pkgs; [
    (prismlauncher.override {
      additionalLibs = x11Libraries;
    })
    waywall
    jemalloc
    jdk21
    ninbot
  ];

  home.file = {
    ".config/waywall/init.lua".source = ../waywall/.config/waywall/init.lua;
    ".config/waywall/extras.lua".source = ../waywall/.config/waywall/extras.lua;
    ".config/waywall/shaders" = {
      source = ../waywall/.config/waywall/shaders;
      recursive = true;
    };
    ".config/waywall/resources/stretched_overlay.png".source = ../waywall/.config/waywall/resources/stretched_overlay.png;
  };
}
