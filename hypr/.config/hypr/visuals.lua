-- Look and feel

local profile = require("profile")
local minimal = profile.is_minimal()

hl.config({
  general = {
    gaps_in = minimal and 0 or 5,
    gaps_out = minimal and 0 or 7,

    border_size = minimal and 0 or 1,
    col = {
      active_border = "rgba(18,63,102,1)",
      inactive_border = "rgba(11,28,43,0.5)",
    },
    resize_on_border = true,
    extend_border_grab_area = minimal and 8 or 0,

    allow_tearing = false,

    layout = "scrolling",
  },

  master = {
    new_status = "slave",
    mfact = 0.5,
  },

  scrolling = {
    fullscreen_on_one_column = true,
    column_width = 1,
    wrap_focus = false,
  },

  misc = {
    force_default_wallpaper = minimal and 1 or 0,
    disable_hyprland_logo = true,

    middle_click_paste = false,
  },

  decoration = {
    rounding = minimal and 0 or 12,
    rounding_power = 2,
    active_opacity = 1,
    inactive_opacity = 1,

    shadow = {
      enabled = not minimal,
      range = 10,
      render_power = 2,
      color = "0x33000000",
    },

    blur = {
      enabled = not minimal,
      size = 3,
      passes = 3,
      new_optimizations = true,
      ignore_opacity = true,
      xray = true,
    },
  },

  animations = {
    enabled = not minimal,
  },
})

if minimal then
  return
end

-- Animations

hl.curve("water", { type = "bezier", points = { { 0.22, 0.9 }, { 0.36, 1.0 } } })
hl.curve("flow", { type = "bezier", points = { { 0.25, 0.1 }, { 0.25, 1.0 } } })
hl.curve("ripple", { type = "bezier", points = { { 0.33, 0.0 }, { 0.2, 1.0 } } })
hl.curve("stream", { type = "bezier", points = { { 0.4, 0.0 }, { 0.4, 1.0 } } })
hl.curve("cascade", { type = "bezier", points = { { 0.19, 1.0 }, { 0.22, 1.0 } } })
hl.curve("md3_standard", { type = "bezier", points = { { 0.2, 0 }, { 0, 1 } } })
hl.curve("md3_accel", { type = "bezier", points = { { 0.3, 0 }, { 0.8, 0.15 } } })
hl.curve("overshot", { type = "bezier", points = { { 0.05, 0.9 }, { 0.1, 1.05 } } })

hl.animation({ leaf = "windows", enabled = true, speed = 5, bezier = "water" })
hl.animation({ leaf = "windowsIn", enabled = true, speed = 5, bezier = "cascade" })
hl.animation({ leaf = "windowsOut", enabled = true, speed = 1, bezier = "stream" })
hl.animation({ leaf = "windowsMove", enabled = true, speed = 1, bezier = "flow" })
hl.animation({ leaf = "fade", enabled = true, speed = 2.4, bezier = "water" })
hl.animation({ leaf = "fadeIn", enabled = true, speed = 2.0, bezier = "cascade" })
hl.animation({ leaf = "fadeOut", enabled = true, speed = 1.8, bezier = "ripple" })
hl.animation({ leaf = "fadeDim", enabled = true, speed = 2.0, bezier = "water" })
hl.animation({ leaf = "fadeSwitch", enabled = true, speed = 1.4, bezier = "flow" })
hl.animation({ leaf = "layersIn", enabled = true, speed = 3, bezier = "overshot", style = "popin 80%" })
hl.animation({ leaf = "layersOut", enabled = true, speed = 3, bezier = "overshot", style = "popin 80%" })
hl.animation({ leaf = "layers", enabled = true, speed = 1.5, bezier = "md3_standard" })
hl.animation({ leaf = "workspaces", enabled = true, speed = 1, bezier = "flow" })
hl.animation({ leaf = "specialWorkspace", enabled = true, speed = 1, bezier = "flow", style = "slidevert" })
hl.animation({ leaf = "border", enabled = true, speed = 2.9, bezier = "water" })
hl.animation({ leaf = "borderangle", enabled = true, speed = 3.5, bezier = "flow" })
