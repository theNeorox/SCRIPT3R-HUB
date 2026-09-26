--[[
    SCRIPT3R HUB
    UI / Theme
]]

local Theme = {}

Theme.Colors = {
    Background = Color3.fromRGB(12, 12, 18),
    Secondary = Color3.fromRGB(19, 19, 25),
    Tertiary = Color3.fromRGB(27, 27, 34),
    Quaternary = Color3.fromRGB(35, 35, 45),

    Accent = Color3.fromRGB(162, 98, 255),
    AccentDark = Color3.fromRGB(118, 66, 180),

    Text = Color3.fromRGB(244, 244, 247),
    SubText = Color3.fromRGB(168, 168, 178),

    Success = Color3.fromRGB(83, 215, 135),
    Warning = Color3.fromRGB(236, 177, 81),
    Error = Color3.fromRGB(235, 92, 92),

    Border = Color3.fromRGB(52, 52, 64),
}

Theme.Fonts = {
    Main = Enum.Font.Gotham,
    Medium = Enum.Font.GothamMedium,
    Bold = Enum.Font.GothamBold,
}

Theme.Sizes = {
    WindowWidth = 720,
    WindowHeight = 500,
    SidebarWidth = 170,
    HeaderHeight = 60,
    CornerRadius = 12,
    Small = 12,
    Medium = 16,
    Large = 20,
}

Theme.CornerRadius = Theme.Sizes.CornerRadius

return Theme