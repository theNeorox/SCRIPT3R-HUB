--[[
    SCRIPT3R HUB
    Configuration
]]

local Config = {}

Config.Name = "SCRIPT3R HUB"
Config.Version = "1.0.0"
Config.Author = "SCRIPT3R"

Config.UI = {
    Title = "SCRIPT3R HUB",
    Subtitle = "Your scripts. Your control.",
    ToggleKey = Enum.KeyCode.RightShift,
}

Config.Settings = {
    Notifications = true,
    SaveSettings = false,
    AutoLoadScripts = true,
}

Config.Categories = {
    "Main",
    "Combat",
    "Movement",
    "Visual",
    "Utility",
    "Misc",
}

return Config