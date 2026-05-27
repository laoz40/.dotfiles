-- Window rules

local profile = require("profile")
local minimal = profile.is_minimal()
local app_opacity = "0.85 0.85 1.0"

local function with_app_opacity(rule)
  if not minimal then
    rule.opacity = app_opacity
  end

  return rule
end

-- Ignore maximize requests from all apps.
hl.window_rule({
  name = "suppress-maximize-events",
  match = { class = ".*" },
  suppress_event = "maximize",
})

-- Fix some dragging issues with XWayland.
hl.window_rule({
  name = "fix-xwayland-drags",
  match = {
    class = "^$",
    title = "^$",
    xwayland = true,
    float = true,
    fullscreen = false,
    pin = false,
  },
  no_focus = true,
})

hl.window_rule({
  name = "move-hyprland-run",
  match = { class = "hyprland-run" },
  move = { "20", "monitor_h-120" },
  float = true,
})

-- idle_inhibit rules.
hl.window_rule({
  match = { class = "^(.*celluloid.*)$|^(.*mpv.*)$|^(.*vlc.*)$" },
  idle_inhibit = "fullscreen",
})

hl.window_rule({
  match = { class = "^(.*[Ss]potify.*)$" },
  idle_inhibit = "fullscreen",
})

hl.window_rule({
  match = { class = "^(.*LibreWolf.*)$|^(.*floorp.*)$|^(.*brave-browser.*)$|^(.*firefox.*)$|^(.*chromium.*)$|^(.*zen.*)$|^(.*vivaldi.*)$" },
  idle_inhibit = "fullscreen",
})

hl.window_rule({
  name = "hyde_picture_in_picture",
  match = { title = "^([Pp]icture[-\\s]?[Ii]n[-\\s]?[Pp]icture)(.*)$" },
  tag = "+hyde_picture_in_picture",
  float = true,
  keep_aspect_ratio = true,
  move = { "monitor_w*0.73", "monitor_h*0.72" },
  size = { "monitor_w*0.25", "monitor_h*0.25" },
  pin = true,
})

hl.window_rule({
  name = "steam",
  match = {
    class = "steam",
    initial_title = "Steam",
  },
  workspace = "7 silent",
  no_initial_focus = true,
})

hl.window_rule(with_app_opacity({
  name = "spotify",
  match = { class = "^[Ss]potify$" },
  workspace = "2 silent",
}))

hl.window_rule(with_app_opacity({
  name = "discord",
  match = { class = "^(discord|vesktop|com.discordapp.Discord)$" },
  workspace = "8 silent",
  no_initial_focus = true,
}))

hl.window_rule({
  name = "floating-satty",
  match = { class = "^([Ss]atty|com\\.gabm\\.[Ss]atty)$" },
  float = true,
  center = true,
})

hl.window_rule({
  name = "floating-ghostty",
  match = { initial_class = "com.ghostty.float" },
  float = true,
  center = true,
  size = { "monitor_w*0.95", "monitor_h*0.9" },
})

hl.window_rule({
  name = "floating-obsidian",
  match = { initial_class = "obsidian" },
  float = true,
  center = true,
  size = { "monitor_w*0.95", "monitor_h*0.9" },
})

-- Layer rules

hl.layer_rule({
  name = "no_anim_for_selection",
  match = { namespace = "selection" },
  no_anim = true,
})

hl.layer_rule({
  name = "rofi",
  match = { namespace = "rofi" },
  animation = "slide bottom",
  blur = true,
})

hl.layer_rule({
  name = "dunst",
  match = { namespace = "notifications" },
  animation = "slide right",
})

hl.layer_rule({
  name = "waybar",
  match = { namespace = "waybar" },
  animation = "slide top",
  no_anim = false,
  blur = true,
  blur_popups = true,
  ignore_alpha = 0.4,
})
