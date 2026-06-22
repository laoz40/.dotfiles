-- Keybindings

local mainMod = "ALT"

hl.bind(mainMod .. " + RETURN", hl.dsp.exec_cmd("ghostty"))
hl.bind(mainMod .. " + Q", hl.dsp.window.close())
hl.bind(mainMod .. " + F", hl.dsp.window.fullscreen({ mode = "fullscreen" }))
hl.bind(mainMod .. " + T", hl.dsp.window.float({ action = "toggle" }))

hl.bind(mainMod .. " + h", hl.dsp.layout("focus l"))
hl.bind(mainMod .. " + l", hl.dsp.layout("focus r"))
hl.bind(mainMod .. " + k", hl.dsp.focus({ direction = "u" }))
hl.bind(mainMod .. " + j", hl.dsp.focus({ direction = "d" }))

hl.bind(mainMod .. " + SHIFT + h", hl.dsp.window.move({ direction = "l" }))
hl.bind(mainMod .. " + SHIFT + l", hl.dsp.window.move({ direction = "r" }))
hl.bind(mainMod .. " + SHIFT + k", hl.dsp.window.move({ direction = "u" }))
hl.bind(mainMod .. " + SHIFT + j", hl.dsp.window.move({ direction = "d" }))

for workspace = 1, 10 do
	local number = tostring(workspace % 10)

	hl.bind(mainMod .. " + " .. number, hl.dsp.focus({ workspace = workspace }))
	hl.bind(mainMod .. " + SHIFT + " .. number, hl.dsp.window.move({ workspace = workspace, follow = true }))
end

hl.bind("ALT + SHIFT + A", hl.dsp.workspace.move({ monitor = "-1" }))
hl.bind("ALT + SHIFT + F", hl.dsp.workspace.move({ monitor = "+1" }))

-- Move/resize windows with SUPER + LMB/RMB and dragging.
hl.bind("SUPER + mouse:272", hl.dsp.window.drag(), { mouse = true })
hl.bind("SUPER + mouse:273", hl.dsp.window.resize(), { mouse = true })

-- Laptop multimedia keys for volume and LCD brightness.
local media_binds = {
	{ key = "XF86AudioRaiseVolume", cmd = "wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+" },
	{ key = "XF86AudioLowerVolume", cmd = "wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-" },
	{ key = "XF86AudioMute", cmd = "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle" },
	{ key = "XF86AudioMicMute", cmd = "wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle" },
	{ key = "XF86MonBrightnessUp", cmd = "brightnessctl -e4 -n2 set 5%+" },
	{ key = "XF86MonBrightnessDown", cmd = "brightnessctl -e4 -n2 set 5%-" },
}

for _, media in ipairs(media_binds) do
	hl.bind(media.key, hl.dsp.exec_cmd(media.cmd), { repeating = true, locked = true })
end

-- Requires playerctl.
hl.bind("XF86AudioNext", hl.dsp.exec_cmd("playerctl next"), { locked = true })
hl.bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPlay", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPrev", hl.dsp.exec_cmd("playerctl previous"), { locked = true })

-- Toggle mic mute.
hl.bind("CTRL + SUPER + M", hl.dsp.exec_cmd("toggle_mic.sh"))

-- Screenshots.
hl.bind("Print", hl.dsp.exec_cmd("hyprshot -m output -m $MONITOR"))
hl.bind("ALT + Print", hl.dsp.exec_cmd("hyprshot -m window"))
hl.bind("CTRL + SUPER + SHIFT + S", hl.dsp.exec_cmd("hyprshot -m region --raw | satty --filename -"))
hl.bind("SUPER + SHIFT + S", hl.dsp.exec_cmd("hyprshot -m region --clipboard-only"))

-- Image to text.
hl.bind("SUPER + SHIFT + T", hl.dsp.exec_cmd("ocr-screenshot.sh"))

-- Hyprpicker.
hl.bind("SUPER + C", hl.dsp.exec_cmd("hyprpicker -a"))

-- Waybar module launchers.
hl.bind("SUPER + SHIFT + A", hl.dsp.exec_cmd("pavucontrol"))
hl.bind("SUPER + SHIFT + N", hl.dsp.exec_cmd("networkmanager_dmenu"))

-- hyprwhspr - Toggle mode.
hl.bind(
	"SUPER + SHIFT + D",
	hl.dsp.exec_cmd("/usr/lib/hyprwhspr/config/hyprland/hyprwhspr-tray.sh record"),
	{ description = "Speech-to-text" }
)

-- Rofi.
hl.bind(mainMod .. " + SPACE", hl.dsp.exec_cmd("rofi -show drun"))
hl.bind("SUPER + period", hl.dsp.exec_cmd("rofi -show emoji"))
hl.bind("SUPER + P", hl.dsp.exec_cmd("rofi_power_menu.sh"))
hl.bind("SUPER + V", hl.dsp.exec_cmd("rofi_cliphist.sh"))
hl.bind("SUPER + T", hl.dsp.exec_cmd("~/.local/bin/rofi_waybar_timer/rofi_waybar_timer.sh"))
hl.bind("SUPER + M", hl.dsp.exec_cmd("rofi -show calc -modi calc -no-show-match -no-sort"))
hl.bind("SUPER + slash", hl.dsp.exec_cmd("rofi_cheat_sheet.sh"))
hl.bind("SUPER + D", hl.dsp.exec_cmd("rofi_define.sh"))
hl.bind("SUPER + W", hl.dsp.exec_cmd("rofi_wallpaper.sh"))
hl.bind("SUPER + SHIFT + W", hl.dsp.exec_cmd("rofi_wallpaper.sh get_random"))
hl.bind("CTRL + SUPER + ALT + P", hl.dsp.exec_cmd("passmenu-rofi.sh"))

-- Toggle waybar.
hl.bind(mainMod .. " + W", hl.dsp.exec_cmd("killall -SIGUSR1 waybar"))

-- Toggle Hyprland visual profile (main/minimal).
hl.bind("CTRL + SUPER + P", hl.dsp.exec_cmd("hypr-profile-toggle.sh"))

-- App shortcuts.
hl.bind("SUPER + N", function()
 	local obsidian = hl.get_window("class:obsidian")
 	if obsidian then
 		hl.dispatch(hl.dsp.focus({ window = obsidian }))
 	else
 		hl.exec_cmd("obsidian")
 	end
end)
hl.bind("SUPER + 1", hl.dsp.exec_cmd("zen-browser"))
hl.bind("SUPER + 2", hl.dsp.exec_cmd("flatpak run com.spotify.Client"))
hl.bind("SUPER + 7", hl.dsp.exec_cmd("steam"))
hl.bind("SUPER + 8", hl.dsp.exec_cmd("vesktop"))


-- File managers.
hl.bind("SUPER + E", hl.dsp.exec_cmd("ghostty -e yazi"))
hl.bind("SUPER + SHIFT + E", hl.dsp.exec_cmd("nautilus"))

-- Btop.
hl.bind("CTRL + SHIFT + escape", hl.dsp.exec_cmd("ghostty --class=com.ghostty.float -e btop"))
