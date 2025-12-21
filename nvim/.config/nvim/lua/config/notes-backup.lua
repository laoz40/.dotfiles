-- Auto backup notes on save (cross-platform)
vim.api.nvim_create_autocmd("BufWritePost", {
  pattern = "*.md",
  callback = function()
    local notes_dir = vim.fn.expand("~/Documents/Notes")
    local script_dir = notes_dir .. "/backup-script"
    local backup_cmd = {}

    if vim.fn.has("win32") == 1 then
      backup_cmd = { "powershell", "-NoProfile", "-ExecutionPolicy", "Bypass", "-File", script_dir .. "\\backup-notes.ps1" }
    else
      backup_cmd = { "bash", script_dir .. "/backup-notes.sh" }
    end

    vim.fn.jobstart(backup_cmd, {
      stdout_buffered = true,
      stderr_buffered = true,
      on_stdout = function(_, data)
        if data then
          print(table.concat(data, "\n"))
        end
      end,
      on_stderr = function(_, data)
        if data then
          print(table.concat(data, "\n"))
        end
      end,
    })
  end,
})
