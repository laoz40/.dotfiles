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

## 4. Create a desktop file

Desktop files should point directly to the versioned AppImage path, not to a wrapper command:

```ini
[Desktop Entry]
Name=AppName
Comment=Short description
Exec=/home/leoz/Applications/AppName-1.2.3-x86_64.AppImage %U
Terminal=false
Type=Application
Icon=/path/to/icon.svg
Categories=Utility;
StartupWMClass=appname
```

Save as:

```txt
~/.local/share/applications/appname.desktop
```

Then refresh desktop database if available:

```sh
update-desktop-database ~/.local/share/applications 2>/dev/null || true
```

## 5. Updates

When downloading a new AppImage version:

1. put the new file in `~/Applications/`
2. `chmod +x` it
3. update the desktop file `Exec=` path to the new AppImage path/name
4. update the wrapper path if one exists
5. optionally keep or delete old versions

