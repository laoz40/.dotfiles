hl.config({
  general = {
    gaps_in = 0,
    gaps_out = 0,

    border_size = 0,
    col = {
      active_border = "rgba(18,63,102,1)",
      inactive_border = "rgba(11,28,43,0.5)",
    },
    resize_on_border = true,
    extend_border_grab_area = 8,

    allow_tearing = false,

    layout = "scrolling",
  },

  master = {
    new_status = "slave",
    mfact = 0.5,
  },

  scrolling = {
    -- A lone column fills the workspace; other apps can share it side by side.
    fullscreen_on_one_column = true,
    column_width = 0.5,
    wrap_focus = false,
  },

  misc = {
    force_default_wallpaper = 1,
    disable_hyprland_logo = true,

    middle_click_paste = false,
  },

  decoration = {
    rounding = 0,
    rounding_power = 2,
    active_opacity = 1,
    inactive_opacity = 1,

    shadow = {
      enabled = false,
      range = 10,
      render_power = 2,
      color = "0x33000000",
    },

    blur = {
      enabled = false,
      size = 3,
      passes = 3,
      new_optimizations = true,
      ignore_opacity = true,
      xray = true,
    },
  },

  animations = {
    enabled = false,
  },
})
