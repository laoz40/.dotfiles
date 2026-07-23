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
}
