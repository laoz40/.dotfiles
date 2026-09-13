# AppImage Integration Notes

Use this directory for manually downloaded AppImages.

## Goal

For each chosen AppImage, create a desktop launcher. Create a `~/.local/bin` command wrapper only if the user wants the app to be launched programmatically from scripts, keybinds, terminal commands, or config files.

## Files

- AppImages live in: `~/Applications/`
- Desktop files live in: `~/.local/share/applications/`
- Optional command wrappers live in: `~/.local/bin/`

## 1. Put the AppImage here

Example:

```sh
chmod +x ~/Applications/AppName-1.2.3-x86_64.AppImage
```

Keep the version in the filename so installed versions are easy to see.

## 2. Decide whether a bin wrapper is needed

Create a wrapper only if the app needs a stable command, for example:

- Hyprland keybind/autostart uses it
- Yazi or another config launches it
- terminal usage is desired
- scripts need to run it

Desktop files should always point directly at the AppImage, even if a wrapper also exists.

## 3. Optional: create a bin wrapper

Example for an app that needs a stable command:

```sh
cat > ~/.local/bin/appname <<'EOF'
#!/usr/bin/env bash
exec "$HOME/Applications/AppName-1.2.3-x86_64.AppImage" "$@"
EOF
chmod +x ~/.local/bin/appname
```

Then configs can use:

```sh
appname
```

When updating the AppImage, update the versioned path inside this wrapper.

## 4. Extract and install the icon

Prefer using the icon bundled inside the AppImage instead of searching online.

Extract the AppImage contents to a temporary directory:

```sh
rm -rf /tmp/appimage-extract
mkdir /tmp/appimage-extract
cd /tmp/appimage-extract
~/Applications/AppName-1.2.3-x86_64.AppImage --appimage-extract
```

Look for desktop files and icons:

```sh
find squashfs-root -maxdepth 4 \( -name '*.desktop' -o -name '*.png' -o -name '*.svg' \)
```

If an icon exists, install it into the user icon theme. Example for a PNG app icon:

```sh
install -Dm644 \
  /tmp/appimage-extract/squashfs-root/appname.png \
  ~/.local/share/icons/hicolor/256x256/apps/appname.png
```

Then use the icon name, without extension, in the desktop file:

```ini
Icon=appname
```

If the AppImage has no suitable icon, use an explicit icon path in the desktop file instead.

## 5. Create a desktop file

Desktop files should point directly to the versioned AppImage path, not to a wrapper command:

```ini
[Desktop Entry]
Name=AppName
Comment=Short description
Exec=/home/leoz/Applications/AppName-1.2.3-x86_64.AppImage %U
Terminal=false
Type=Application
Icon=appname
Categories=Utility;
StartupWMClass=appname
```

Save as:

```txt
~/.local/share/applications/appname.desktop
```

Then refresh desktop and icon databases if available:

```sh
update-desktop-database ~/.local/share/applications 2>/dev/null || true
gtk-update-icon-cache ~/.local/share/icons/hicolor 2>/dev/null || true
```

## 6. Updates

When downloading a new AppImage version:

1. put the new file in `~/Applications/`
2. `chmod +x` it
3. update the desktop file `Exec=` path to the new AppImage path/name
4. re-extract/reinstall the icon if the app icon changed
5. update the wrapper path if one exists
6. optionally keep or delete old versions

## Tailscale boot services

T3 Code and Paseo bind to the Tailscale IP (`100.66.137.3`) for remote access. At boot, `tailscaled` may not have assigned that address yet, which causes `EADDRNOTAVAIL` if the service starts too early.

Both user services use a shared wrapper at `~/.local/bin/wait-for-tailscale-exec`. It waits until the IP appears on `tailscale0`, then runs the real command.
Each service must use the wrapper in `ExecStart` and set `TAILSCALE_WAIT_HOST`:

**t3code.service**

```ini
Environment=T3CODE_HOST=100.66.137.3
Environment=T3CODE_PORT=3773
Environment=TAILSCALE_WAIT_HOST=100.66.137.3
ExecStart=%h/.local/bin/wait-for-tailscale-exec /home/leoz/.nvm/versions/node/v24.15.0/bin/node /home/leoz/.t3/runtime/service-launcher.mjs
```

**paseo.service**

```ini
Environment=TAILSCALE_WAIT_HOST=100.66.137.3
ExecStart=%h/.local/bin/wait-for-tailscale-exec %h/.nvm/versions/node/v24.15.0/bin/paseo daemon start --foreground --no-relay
```

After any command that rewrites a unit file (`t3 service update`, manual edits, etc.), re-apply the service-specific settings above, then:

```sh
systemctl --user daemon-reload
systemctl --user restart t3code.service paseo.service
```

The wrapper script itself is independent of app versions and does not need to change on AppImage or CLI updates.

## T3 Code

T3 Code has two installs that share `~/.t3` and should stay on the same version:

- **AppImage** (`~/Applications/T3-Code-*-x86_64.AppImage`)
- **CLI** (`t3` via nvm): powers `t3code.service` for always-on remote access over Tailscale

When updating the AppImage, also update the CLI and boot service:

```sh
/home/leoz/.nvm/versions/node/v24.15.0/bin/npm install -g t3@latest --prefix /home/leoz/.nvm/versions/node/v24.15.0
t3 service update
```

`t3 service update` rewrites `t3code.service`. Re-apply the **Tailscale boot services** t3code settings above, then reload and restart:

```sh
systemctl --user daemon-reload
systemctl --user restart t3code.service
```

Boot service listens on `100.66.137.3:3773`. The desktop AppImage uses `127.0.0.1:3773`. Same port number, different addresses — they do not conflict. Pin `T3CODE_PORT=3773` so the Tailscale URL does not change when the desktop app is open.

## Paseo

Paseo has two installs that share `~/.paseo` and should stay on the same version:

- **AppImage** (`~/Applications/Paseo-x86_64.AppImage`)
- **CLI** (`paseo` via nvm): powers `paseo.service` for always-on remote access over Tailscale

When updating the AppImage, also update the CLI:

```sh
/home/leoz/.nvm/versions/node/v24.15.0/bin/npm install -g @getpaseo/cli@latest --prefix /home/leoz/.nvm/versions/node/v24.15.0
```

If anything rewrites `~/.config/systemd/user/paseo.service`, re-apply the Tailscale wait wrapper settings from **Tailscale boot services** above, then:

```sh
systemctl --user daemon-reload
systemctl --user restart paseo.service
```
