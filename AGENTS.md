# Agent Notes

This dotfiles project is managed with GNU Stow.

Most files edited in this repository are intended to be symlinked into `$HOME`. Changes to existing tracked files usually affect the live configuration immediately because the live files are symlinks back into this repo.

When adding new files, remember that they may not exist in the live `$HOME` location yet. New files need to be synced/stowed before they are available live, for example:

```bash
stow -R <package>
```

If Stow reports conflicts because existing live files are not owned by Stow, inspect the target paths before overwriting or deleting anything.

## Neovim

Using nvim 0.12+, which has native plugin manager vim.pack()

Remove plugins with command `lua vim.pack.del({"plugin.nvim"})`
This removes it from lock file. Simply deleting the vim.pack code in the config will not remove the plugins.

## Herdr

Herdr is a terminal multiplexer. It is essentially a tmux wrapper with AI agent session panel.
