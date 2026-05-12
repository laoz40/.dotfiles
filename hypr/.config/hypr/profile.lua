local M = {}

local function read_first_line(path)
  local file = io.open(path, "r")
  if not file then
    return nil
  end

  local line = file:read("*l")
  file:close()
  return line
end

M.state_file = (os.getenv("XDG_CACHE_HOME") or (os.getenv("HOME") .. "/.cache")) .. "/hyprland-profile"
M.current = read_first_line(M.state_file) or os.getenv("HYPRLAND_PROFILE") or "main"

function M.is_minimal()
  return M.current == "minimal"
end

return M
