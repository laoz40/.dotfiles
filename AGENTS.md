# Agent Notes

OS: Arch Linux
GPU: NVIDIA 3070

## Nix Home Manager

This dotfiles project is managed with the standalone Nix Home Manager flake in `flake.nix`. Programs and managed files are declared in `home.nix`.

Apply configuration changes with:

```bash
home-manager switch --flake ~/.dotfiles#leoz
```

Some application configs use out-of-store symlinks, so edits to those files take effect immediately. Other configs are copied into the Nix store and require another `home-manager switch`. New files must be declared in `home.nix` before Home Manager will install or link them into `$HOME`.

## Neovim

Using nvim 0.12+, which has native plugin manager vim.pack()

Remove plugins with command `lua vim.pack.del({"plugin.nvim"})`
This removes it from lock file. Simply deleting the vim.pack code in the config will not remove the plugins.

## Herdr

Herdr is a terminal multiplexer. It is essentially a tmux wrapper with AI agent session panel.

## Profiles

There are two different themes that can be switched between: Main and Minimal.
Minimal theme is adjustments to ghostty, hyprland, etc to reduce the transparency, blur, gaps and animations.
