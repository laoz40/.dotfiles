-- Auto backup notes on Neovim exit (cross-platform)
vim.api.nvim_create_autocmd("VimLeave", {
  pattern = "*.md",
  callback = function()
    local notes_dir = vim.fn.expand("~/Documents/Notes")
    local script_dir = notes_dir .. "/backup-script"
    
    local backup_cmd = {}

    if vim.fn.has("win32") == 1 then
      backup_cmd = { "powershell", "-NoProfile", "-File", script_dir .. "\\backup_notes.ps1" }
    else
      backup_cmd = { "/bin/bash", script_dir .. "/backup_notes.sh" }
    end

    vim.fn.jobstart(backup_cmd, { detach = true })
  end,
})
