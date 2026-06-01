# Agent Notes

This dotfiles project is managed with GNU Stow.

Most files edited in this repository are intended to be symlinked into `$HOME`. Changes to existing tracked files usually affect the live configuration immediately because the live files are symlinks back into this repo.

When adding new files, remember that they may not exist in the live `$HOME` location yet. New files need to be synced/stowed before they are available live, for example:

```bash
stow -R <package>
```

If Stow reports conflicts because existing live files are not owned by Stow, inspect the target paths before overwriting or deleting anything.
