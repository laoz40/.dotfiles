local profile = require("profile")

if profile.is_minimal() then
  require("visuals.minimal")
else
  require("visuals.main")
end
