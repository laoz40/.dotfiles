require("visuals")
require("windowrules")
require("keybinds")

-- Monitors

local function read_file(path)
	local file = io.open(path, "r")
	if not file then
		return nil
	end

	local content = file:read("*a")
	file:close()
	return content
end

local function output_is_connected(output)
	local status = read_file("/sys/class/drm/card0-" .. output .. "/status")
		or read_file("/sys/class/drm/card1-" .. output .. "/status")

	return status and status:match("connected") ~= nil
end

local function detect_main_monitor()
	if output_is_connected("eDP-1") then
		return "eDP-1"
	end

	if output_is_connected("DP-3") then
		return "DP-3"
	end

	return ""
end

local main_monitor = detect_main_monitor()
local other_monitor = "HDMI-A-1"
-- env for compatibility for now
hl.env("MONITOR", main_monitor)

hl.monitor({
	output = main_monitor,
	mode = "highrr",
	position = "auto",
	scale = 1,
})

-- TV (only when using laptop)
if main_monitor == "eDP-1" then
	hl.monitor({
		output = "HDMI-A-1",
		mode = "3840x2160@24",
		position = "auto",
		scale = 2,
	})
end

-- Fallback for any other connected monitors
hl.monitor({
	output = "",
	mode = "preferred",
	position = "auto",
	scale = 1,
})

hl.workspace_rule({ workspace = "1", monitor = main_monitor, default = true, persistent = true })
hl.workspace_rule({ workspace = "2", monitor = other_monitor, default = true, persistent = true })

-- Input

hl.config({
	input = {
		kb_layout = "us",
		follow_mouse = 1,

		sensitivity = 0,
		accel_profile = "flat",

		touchpad = {
			natural_scroll = true,
		},

		repeat_rate = 30,
		repeat_delay = 200,
	},
})

hl.device({
	name = "elan1200:00-04f3:30f7-touchpad",
	sensitivity = 0.75,
})

-- Autostart

local autostart = {
	-- Start waybar, then toggle it hidden.
	"bash -lc 'waybar & sleep 1 && killall -SIGUSR1 waybar'",

	-- hyprpaper, then get random wallpaper
	"hyprpaper",
	"sleep 1 && rofi_wallpaper.sh get_random",

	"hypridle",
	"hyprsunset",

	-- cliphist
	"wl-paste --type text --watch cliphist store",
	"wl-paste --type image --watch cliphist store",

	-- keyring
	"dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP HYPRLAND_INSTANCE_SIGNATURE MONITOR",
	"gnome-keyring-daemon --start --components=secrets",

}

local desktop_autostart = {
	"vesktop --start-minimized",
	"obsidian",
	"steam -silent",
}

hl.on("hyprland.start", function()
	for _, command in ipairs(autostart) do
		hl.exec_cmd(command)
	end

	if main_monitor == "DP-3" then
		for _, command in ipairs(desktop_autostart) do
			hl.exec_cmd(command)
		end
	end
end)

-- Environment variables

hl.env("HYPRSHOT_DIR", os.getenv("HOME") .. "/Pictures/Screenshots")
hl.env("PATH", os.getenv("HOME") .. "/.local/bin:/usr/local/bin:/usr/bin:/bin")

hl.env("XCURSOR_SIZE", "20")
hl.env("XCURSOR_THEME", "Bibata-Modern-Classic")
hl.env("HYPRCURSOR_SIZE", "20")
hl.env("HYPRCURSOR_THEME", "Bibata-Modern-Classic")

hl.env("QT_QPA_PLATFORMTHEME", "qt6ct")
hl.env("MOZ_ENABLE_WAYLAND", "1")

hl.env("LIBVA_DRIVER_NAME", "nvidia")
hl.env("__GLX_VENDOR_LIBRARY_NAME", "nvidia")
hl.env("XDG_SESSION_TYPE", "wayland")
hl.env("GBM_BACKEND", "nvidia-drm")

hl.on("hyprland.start", function()
	hl.exec_cmd("gsettings set org.gnome.desktop.interface cursor-theme 'Bibata-Modern-Classic'")
	hl.exec_cmd("gsettings set org.gnome.desktop.interface cursor-size 20")
	hl.exec_cmd('gsettings set org.gnome.desktop.interface color-scheme "prefer-dark"')
end)
