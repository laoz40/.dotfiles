{ lib, stdenv, fetchurl, autoPatchelfHook, wrapGAppsHook4, gtk4, gtksourceview5
, poppler, fontconfig, gdk-pixbuf, glib, pango, cairo, graphene, gst_all_1
, adwaita-icon-theme, gvfs }:

stdenv.mkDerivation rec {
  pname = "strata-bin";
  version = "1.2.1";

  src = fetchurl {
    url = "https://github.com/lgse/strata/releases/download/v${version}/strata-${version}-x86_64-unknown-linux-gnu.tar.gz";
    hash = "sha256-pjcQzmJgeOzBBxBSI2gBeaRDe4y5+8401049QsgDMNA=";
  };

  nativeBuildInputs = [ autoPatchelfHook wrapGAppsHook4 ];
  buildInputs = [
    gtk4 gtksourceview5 poppler fontconfig gdk-pixbuf glib pango cairo graphene
    gst_all_1.gstreamer gst_all_1.gst-plugins-base gst_all_1.gst-plugins-good
    gst_all_1.gst-libav adwaita-icon-theme gvfs stdenv.cc.cc.lib
  ];

  installPhase = ''
    runHook preInstall
    install -Dm755 strata "$out/bin/strata"
    install -Dm644 io.github.lgse.Strata.desktop "$out/share/applications/io.github.lgse.Strata.desktop"
    substituteInPlace "$out/share/applications/io.github.lgse.Strata.desktop" \
      --replace-fail 'Exec=strata' "Exec=$out/bin/strata"
    install -Dm644 io.github.lgse.Strata.svg "$out/share/icons/hicolor/scalable/apps/io.github.lgse.Strata.svg"
    runHook postInstall
  '';

  meta = {
    description = "Keyboard-first file manager for Linux";
    homepage = "https://github.com/lgse/strata";
    license = lib.licenses.mit;
    platforms = [ "x86_64-linux" ];
    mainProgram = "strata";
  };
}
