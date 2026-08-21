local waywall = require("waywall")

local function read_file(path)
    local file = assert(io.open(os.getenv("HOME") .. "/.config/waywall/" .. path, "r"))
    local contents = file:read("*a")
    file:close()
    return contents
end

local function make_mirror(options)
    local mirror

    if options.dst.scale then
        options.dst.w = options.src.w * options.dst.scale
        options.dst.h = options.src.h * options.dst.scale
    end

    return function(enabled)
        if enabled and not mirror then
            mirror = waywall.mirror(options)
        elseif not enabled and mirror then
            mirror:close()
            mirror = nil
        end
    end
end

local function make_text_mirror(options)
    options.shader = options.shader or "f3_text"

    local text = make_mirror(options)
    local offset = options.shadow_offset or 4
    local shadow = make_mirror({
        src = options.src,
        dst = {
            x = options.dst.x + offset,
            y = options.dst.y + offset,
            w = options.dst.w,
            h = options.dst.h,
        },
        shader = options.shadow_shader or "f3_text_shadow",
    })

    return function(enabled)
        text(enabled)
        shadow(enabled)
    end
end

return function(config)
    config.shaders = config.shaders or {}
    config.shaders.f3_text = {
        vertex = read_file("shaders/general.vert"),
        fragment = read_file("shaders/text.frag"),
    }
    config.shaders.f3_text_shadow = {
        vertex = read_file("shaders/general.vert"),
        fragment = read_file("shaders/text_shadow.frag"),
    }
    config.shaders.pie_text = {
        vertex = read_file("shaders/general.vert"),
        fragment = read_file("shaders/pie_text.frag"),
    }
    config.shaders.pie_text_shadow = {
        vertex = read_file("shaders/general.vert"),
        fragment = read_file("shaders/pie_text_shadow.frag"),
    }

    local f3_block = make_text_mirror({
        src = { x = 132, y = 400, w = 352, h = 36 },
        dst = { x = 132, y = 400, w = 352, h = 36 },
    })

    local glowdar = make_text_mirror({
        src = { x = 1868, y = 856, w = 44, h = 32 },
        dst = { x = 1634, y = 695, scale = 4 },
        shader = "pie_text",
        shadow_shader = "pie_text_shadow",
    })

    local function show_normal_mirrors(enabled)
        f3_block(enabled)
        glowdar(enabled)
    end

    local function update_mirrors()
        local width, height = waywall.active_res()
        local alternative =
            (width == 340 and height == 1080)
            or (width == 384 and height == 16384)
            or (width == 1920 and height == 300)

        show_normal_mirrors(not alternative)
    end

    for _, key in ipairs({ "*-T", "*-H", "*-M" }) do
        local action = config.actions[key]
        if action then
            config.actions[key] = function(...)
                local result = action(...)
                update_mirrors()
                return result
            end
        end
    end

    waywall.listen("load", update_mirrors)
end
