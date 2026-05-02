local M = {}

-- notification helper function
local function notify(msg, level)
	vim.notify(msg, level or vim.log.levels.INFO, { title = "git-worktree" })
end

-- run a git command and split stdout into lines
local function git_lines(args)
	local result = vim.system(vim.list_extend({ "git" }, args), { text = true }):wait()
	if result.code ~= 0 then
		notify(vim.trim(result.stderr ~= "" and result.stderr or result.stdout), vim.log.levels.ERROR)
		return nil
	end
	return vim.split(result.stdout, "\n", { trimempty = true })
end

-- get existing worktrees for the picker
local function worktrees()
	local lines = git_lines({ "worktree", "list", "--porcelain" })
	if not lines then
		return {}
	end

	local items = {}
	local current = {}
	for _, line in ipairs(lines) do
		if line:match("^worktree ") then
			if current.path then
				items[#items + 1] = current
			end
			current = { path = line:gsub("^worktree ", "") }
		elseif line:match("^branch ") then
			current.branch = line:gsub("^branch refs/heads/", "")
		elseif line == "bare" then
			current.branch = "bare"
		elseif line == "detached" then
			current.branch = "detached"
		end
	end
	if current.path then
		items[#items + 1] = current
	end

	return vim.tbl_map(function(item)
		return {
			text = string.format("%s  %s", item.branch or "unknown", item.path),
			path = item.path,
			branch = item.branch,
		}
	end, items)
end

-- find the root of the current git repo
local function git_root()
	local result = vim.system({ "git", "rev-parse", "--show-toplevel" }, { text = true }):wait()
	if result.code ~= 0 then
		notify("Not inside a git repository", vim.log.levels.ERROR)
		return nil
	end
	return vim.trim(result.stdout)
end

-- convert a worktree path to an absolute path
local function absolute_path(root, path)
	return vim.fs.normalize(vim.fn.fnamemodify(path:sub(1, 1) == "/" and path or root .. "/" .. path, ":p"))
end

-- choose package manager based on lockfile
local function install_command(path)
	local locks = {
		{ "pnpm-lock.yaml", { "pnpm", "install" } },
		{ "package-lock.json", { "npm", "install" } },
		{ "bun.lock", { "bun", "install" } },
		{ "bun.lockb", { "bun", "install" } },
		{ "yarn.lock", { "yarn", "install" } },
	}

	for _, lock in ipairs(locks) do
		if vim.uv.fs_stat(path .. "/" .. lock[1]) then
			return lock[2]
		end
	end
end

-- run dependency install without blocking neovim
local function run_install(path)
	local cmd = install_command(path)
	if not cmd then
		notify("No lockfile found; skipping install")
		return
	end

	notify("Running " .. table.concat(cmd, " "))
	vim.system(cmd, { cwd = path, text = true }, function(result)
		vim.schedule(function()
			if result.code == 0 then
				notify("Install complete")
			else
				notify(vim.trim(result.stderr ~= "" and result.stderr or result.stdout), vim.log.levels.ERROR)
			end
		end)
	end)
end

-- switch neovim cwd and reopen the same file if possible
local function switch_to_path(path)
	local current_file = vim.api.nvim_buf_get_name(0)
	local old_root = git_root()

	vim.cmd.cd(vim.fn.fnameescape(path))
	vim.cmd.clearjumps()

	if old_root and current_file:sub(1, #old_root) == old_root then
		local relative_file = current_file:sub(#old_root + 2)
		local new_file = path .. "/" .. relative_file
		if vim.uv.fs_stat(new_file) then
			vim.cmd.edit(vim.fn.fnameescape(new_file))
			return
		end
	end

	vim.cmd.edit(".")
end

-- create a worktree, install deps, then switch to it
local function create_local_worktree(path, branch, upstream)
	local root = git_root()
	if not root then
		return
	end

	local args = { "git", "worktree", "add", "-b", branch, path }
	if upstream and upstream ~= "" then
		args[#args + 1] = upstream .. "/" .. branch
	end

	local result = vim.system(args, { cwd = root, text = true }):wait()
	if result.code ~= 0 then
		notify(vim.trim(result.stderr ~= "" and result.stderr or result.stdout), vim.log.levels.ERROR)
		return
	end

	local new_path = absolute_path(root, path)
	run_install(new_path)
	switch_to_path(new_path)
end

-- open picker to switch between worktrees
function M.switch()
	Snacks.picker.pick({
		title = "Git Worktrees",
		items = worktrees(),
		format = "text",
		confirm = function(picker, item)
			picker:close()
			if item then
				switch_to_path(item.path)
			end
		end,
	})
end

-- prompt for worktree details and create it
function M.create()
	vim.ui.input({ prompt = "Worktree path: " }, function(path)
		if not path or path == "" then
			return
		end
		vim.ui.input({ prompt = "Branch name: ", default = vim.fn.fnamemodify(path, ":t") }, function(branch)
			if not branch or branch == "" then
				return
			end
			vim.ui.input({ prompt = "Upstream remote (blank for new local branch): " }, function(upstream)
				if upstream == nil then
					return
				end
				create_local_worktree(path, branch, vim.trim(upstream))
			end)
		end)
	end)
end

return M
