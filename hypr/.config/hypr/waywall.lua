local waywall_windows = {}

local function is_waywall(window)
	return window.class:lower() == "waywall" or window.initial_class:lower() == "waywall"
end

local function set_mouse_sensitivity(sensitivity)
	hl.config({ input = { sensitivity = sensitivity } })
end

-- lower cursor speed inside mc
hl.on("window.open", function(window)
	if is_waywall(window) then
		waywall_windows[window.address] = true
		set_mouse_sensitivity(-0.75)
	end
end)

hl.on("window.close", function(window)
	if not waywall_windows[window.address] then
		return
	end

	waywall_windows[window.address] = nil
	if next(waywall_windows) == nil then
		set_mouse_sensitivity(0)
	end
end)
