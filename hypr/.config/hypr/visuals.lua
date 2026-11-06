local profile = require("profile")

if profile.current == "minimal" then
  require("visuals.minimal")
elseif profile.current == "sharp" then
  require("visuals.sharp")
else
  require("visuals.main")
end
