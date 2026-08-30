# Agent Notes

## PC

OS: Arch Linux
GPU: NVIDIA 3070

## Laptop

OS: Arch Linux
GPU: Intel Iris Xe Graphics (Integrated)

## Nix Home Manager

This dotfiles project is managed with the standalone Nix Home Manager flake in `flake.nix`. Programs and managed files are declared in `home.nix`.

let user run:

```bash
home-manager switch --flake ~/.dotfiles#leoz@desktop
```

Some application configs use out-of-store symlinks, so edits to those files take effect immediately. Other configs are copied into the Nix store and require another `home-manager switch`. New files must be declared in `home.nix` before Home Manager will install or link them into `$HOME`.

### Updating packages

Package versions come from the flake inputs in `flake.nix`, pinned in `flake.lock`. To update:

```bash
nix flake update --flake ~/.dotfiles
```

### NVIDIA driver pin (PC)

`.modules/desktop.nix` pins the NVIDIA userspace driver (`targets.genericLinux.gpu.nvidia`). It must exactly match the kernel module version installed by pacman (`nvidia-open-dkms`), otherwise GL/Vulkan/CUDA apps fail with API mismatch errors.

After a `pacman -Syu` bumps an NVIDIA package:

1. Check new version: `pacman -Q nvidia-open-dkms`
2. Prefetch hash: `nix store prefetch-file https://download.nvidia.com/XFree86/Linux-x86_64/<ver>/NVIDIA-Linux-x86_64-<ver>.run`
3. Update `version` and `sha256` in `.modules/desktop.nix`, then run `home-manager switch` (see above)
4. Run the `sudo /nix/store/...-setup` command the switch prints to repoint `/run/opengl-driver`

If the `.run` URL 404s, NVIDIA hasn't published that version yet.

## Neovim

Using nvim 0.12+, which has native plugin manager vim.pack()

Remove plugins with command `lua vim.pack.del({"plugin.nvim"})`
This removes it from lock file. Simply deleting the vim.pack code in the config will not remove the plugins.

## Herdr

Herdr is a terminal multiplexer. It is essentially a tmux wrapper with AI agent session panel.

## Profiles

There are two different themes that can be switched between: Main and Minimal.
Minimal theme is adjustments to ghostty, hyprland, etc to reduce the transparency, blur, gaps and animations.
