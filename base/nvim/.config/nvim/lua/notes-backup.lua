-- Auto backup notes on Neovim exit (cross-platform)

local notes_dir = vim.fs.normalize(vim.fn.expand("~/Documents/Notes"))
local script_dir = notes_dir .. "/backup-script"
-- Limits how often backups can run.
local backup_cooldown_ms = 5 * 60 * 1000
local last_backup_at = 0

-- Checks whether the buffer is a notes markdown file.
local function is_notes_markdown(bufnr)
	-- Reads the buffer path.
	local file_path = vim.api.nvim_buf_get_name(bufnr)
	if file_path == "" or vim.fn.fnamemodify(file_path, ":e") ~= "md" then
		return false
	end
	file_path = vim.fs.normalize(vim.fn.fnamemodify(file_path, ":p"))

	-- Compares paths safely on Windows.
	local compare_notes_dir = notes_dir
	if vim.fn.has("win32") == 1 then
		file_path = file_path:lower()
		compare_notes_dir = compare_notes_dir:lower()
	end

	return file_path == compare_notes_dir or vim.startswith(file_path, compare_notes_dir .. "/")
end

-- Runs the backup script on file leave.
vim.api.nvim_create_autocmd("BufLeave", {
	pattern = "*.md",
	callback = function(args)
		-- Ignores files outside the notes folder.
		if not is_notes_markdown(args.buf) then
			return
		end

		-- Skips backups during the cooldown.
		local now = vim.uv.now()
		if now - last_backup_at < backup_cooldown_ms then
			return
		end

		last_backup_at = now

		local backup_cmd = {}

		-- Uses PowerShell on Windows.
		if vim.fn.has("win32") == 1 then
			backup_cmd = { "powershell", "-NoProfile", "-File", script_dir .. "\\backup_notes.ps1" }
		else
			-- Uses Bash everywhere else.
			backup_cmd = { "/bin/bash", script_dir .. "/backup_notes.sh" }
		end

		-- Starts the backup in the background.
		vim.fn.jobstart(backup_cmd, { detach = true })
	end,
})
