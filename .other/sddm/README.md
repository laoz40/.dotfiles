# Local Pixie theme

`pixie.patch` applies to the Qt 6 Pixie 3.0 files installed in `/usr/share/sddm/themes/pixie`. Build when installing on another machine, changing the QML patch, or testing it against an upstream update. The original is the build input, so the script never patches it in place:

```bash
stage=$(mktemp -d)
bash ~/.dotfiles/.other/sddm/build-pixie.sh "$stage"
sddm-greeter-qt6 --test-mode --theme "$stage"
```

Once the preview looks right, rebuild and install the theme with this standalone command. It creates and cleans up its own staging directory; it does not depend on the preview shell's `stage` variable. Rebuilding uses the current upstream files, patch, configuration, and wallpapers.

```bash
(
    set -e
    stage=$(mktemp -d)
    trap 'rm -rf -- "$stage"' EXIT
    bash ~/.dotfiles/.other/sddm/build-pixie.sh "${stage:?Missing staging directory}"
    sudo install -d /usr/share/sddm/themes/pixie-leo
    sudo cp -R -- "${stage:?Missing staging directory}/." /usr/share/sddm/themes/pixie-leo/
)
```

The install overwrites files included in the build, including `theme.conf.user`, but leaves other existing files in place.

For wallpaper and color changes, edit `/usr/share/sddm/themes/pixie-leo/theme.conf.user` directly. For a new wallpaper, copy the image into that copy's `assets/` directory and set `background=assets/<filename>`. To carry the change into future builds, update the tracked `theme.conf.user` and, if needed, the list of images copied by `build-pixie.sh`.

Set `Current=pixie-leo` under `[Theme]` in `/etc/sddm.conf.d/10-theme.conf`. Change it back to `Current=pixie` to use the original theme. The selection takes effect the next time SDDM starts. Restarting the SDDM service can end the current desktop session.
