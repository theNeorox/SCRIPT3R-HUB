--[[
    SCRIPT3R HUB
    GitHub Remote Loader / Bundle

    Uso no Roblox:
    loadstring(game:HttpGet("https://raw.githubusercontent.com/SEU_USUARIO/SEU_REPO/refs/heads/main/RemoteHub.lua"))()
]]

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

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
}
Theme.CornerRadius = Theme.Sizes.CornerRadius

local Utilities = {}

function Utilities:Trim(text)
    if type(text) ~= "string" then
        return ""
    end

    return text:match("^%s*(.-)%s*$")
end

function Utilities:Count(tbl)
    if type(tbl) ~= "table" then
        return 0
    end

    local count = 0
    for _ in pairs(tbl) do
        count += 1
    end
    return count
end

function Utilities:FindChild(parent, name)
    if not parent then
        return nil
    end

    return parent:FindFirstChild(name)
end

function Utilities:SafeCall(callback, ...)
    if type(callback) ~= "function" then
        return false, "Callback inválido."
    end

    return pcall(callback, ...)
end

local Components = {}

local function Corner(parent, radius)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, radius or Theme.CornerRadius)
    corner.Parent = parent
    return corner
end

local function Stroke(parent, color, thickness)
    local stroke = Instance.new("UIStroke")
    stroke.Color = color or Theme.Colors.Border
    stroke.Thickness = thickness or 1
    stroke.Transparency = 0.25
    stroke.Parent = parent
    return stroke
end

function Components:Label(parent, text, size)
    local label = Instance.new("TextLabel")
    label.Name = "Label"
    label.BackgroundTransparency = 1
    label.Size = size or UDim2.new(1, 0, 0, 24)
    label.Text = text or ""
    label.TextColor3 = Theme.Colors.Text
    label.Font = Theme.Fonts.Main
    label.TextSize = 14
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.TextYAlignment = Enum.TextYAlignment.Center
    label.Parent = parent
    return label
end

function Components:Paragraph(parent, text, size)
    local paragraph = Instance.new("TextLabel")
    paragraph.Name = "Paragraph"
    paragraph.BackgroundTransparency = 1
    paragraph.Size = size or UDim2.new(1, 0, 0, 42)
    paragraph.Text = text or ""
    paragraph.TextColor3 = Theme.Colors.SubText
    paragraph.Font = Theme.Fonts.Main
    paragraph.TextSize = 12
    paragraph.TextWrapped = true
    paragraph.TextXAlignment = Enum.TextXAlignment.Left
    paragraph.TextYAlignment = Enum.TextYAlignment.Top
    paragraph.Parent = parent
    return paragraph
end

function Components:Button(parent, text, callback)
    local button = Instance.new("TextButton")
    button.Name = "Button"
    button.Size = UDim2.new(1, 0, 0, 36)
    button.BackgroundColor3 = Theme.Colors.Tertiary
    button.Text = text or ""
    button.TextColor3 = Theme.Colors.Text
    button.Font = Theme.Fonts.Medium
    button.TextSize = 13
    button.AutoButtonColor = false
    Corner(button)
    Stroke(button)

    button.MouseEnter:Connect(function()
        button.BackgroundColor3 = Theme.Colors.Quaternary
    end)

    button.MouseLeave:Connect(function()
        button.BackgroundColor3 = Theme.Colors.Tertiary
    end)

    button.MouseButton1Click:Connect(function()
        if callback then
            callback()
        end
    end)

    button.Parent = parent
    return button
end

function Components:Toggle(parent, text, defaultValue, callback)
    local enabled = defaultValue == true

    local container = Instance.new("TextButton")
    container.Name = "Toggle"
    container.Size = UDim2.new(1, 0, 0, 32)
    container.BackgroundColor3 = Theme.Colors.Tertiary
    container.Text = ""
    container.AutoButtonColor = false
    Corner(container)
    Stroke(container)

    local label = Instance.new("TextLabel")
    label.BackgroundTransparency = 1
    label.Position = UDim2.new(0, 12, 0, 0)
    label.Size = UDim2.new(1, -52, 1, 0)
    label.Text = text or ""
    label.TextColor3 = Theme.Colors.Text
    label.Font = Theme.Fonts.Main
    label.TextSize = 13
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = container

    local track = Instance.new("Frame")
    track.Name = "Track"
    track.Size = UDim2.new(0, 42, 0, 20)
    track.Position = UDim2.new(1, -54, 0.5, -10)
    track.BackgroundColor3 = Theme.Colors.Border
    track.Parent = container
    Corner(track, 100)

    local knob = Instance.new("Frame")
    knob.Name = "Knob"
    knob.Size = UDim2.new(0, 14, 0, 14)
    knob.Position = UDim2.new(0, 4, 0.5, -7)
    knob.BackgroundColor3 = Theme.Colors.Text
    knob.Parent = track
    Corner(knob, 100)

    local function updateState()
        if enabled then
            track.BackgroundColor3 = Theme.Colors.Accent
            knob.Position = UDim2.new(0, 24, 0.5, -7)
        else
            track.BackgroundColor3 = Theme.Colors.Border
            knob.Position = UDim2.new(0, 4, 0.5, -7)
        end
    end

    container.MouseButton1Click:Connect(function()
        enabled = not enabled
        updateState()

        if callback then
            callback(enabled)
        end
    end)

    updateState()
    container.Parent = parent

    return {
        Instance = container,
        Set = function(_, value)
            enabled = value == true
            updateState()
        end,
        Get = function()
            return enabled
        end,
    }
end

function Components:Section(parent, text)
    local section = Instance.new("TextLabel")
    section.Name = "Section"
    section.BackgroundTransparency = 1
    section.Size = UDim2.new(1, 0, 0, 24)
    section.Text = text or ""
    section.TextColor3 = Theme.Colors.Accent
    section.Font = Theme.Fonts.Bold
    section.TextSize = 12
    section.TextXAlignment = Enum.TextXAlignment.Left
    section.Parent = parent
    return section
end

function Components:ScriptCard(parent, scriptData, enabled, callback)
    local card = Instance.new("Frame")
    card.Name = "ScriptCard"
    card.Size = UDim2.new(1, -10, 0, 92)
    card.BackgroundColor3 = Theme.Colors.Tertiary
    card.Parent = parent
    Corner(card)
    Stroke(card)

    local title = Instance.new("TextLabel")
    title.BackgroundTransparency = 1
    title.Position = UDim2.new(0, 14, 0, 12)
    title.Size = UDim2.new(1, -90, 0, 22)
    title.Text = scriptData.Name or "Unnamed"
    title.TextColor3 = Theme.Colors.Text
    title.Font = Theme.Fonts.Bold
    title.TextSize = 15
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = card

    local description = Instance.new("TextLabel")
    description.BackgroundTransparency = 1
    description.Position = UDim2.new(0, 14, 0, 35)
    description.Size = UDim2.new(1, -90, 0, 22)
    description.Text = scriptData.Description or "Sem descrição."
    description.TextColor3 = Theme.Colors.SubText
    description.Font = Theme.Fonts.Main
    description.TextSize = 12
    description.TextXAlignment = Enum.TextXAlignment.Left
    description.TextTruncate = Enum.TextTruncate.AtEnd
    description.Parent = card

    local category = Instance.new("TextLabel")
    category.BackgroundTransparency = 1
    category.Position = UDim2.new(0, 14, 0, 60)
    category.Size = UDim2.new(1, -90, 0, 20)
    category.Text = "Category: " .. (scriptData.Category or "Misc")
    category.TextColor3 = Theme.Colors.Accent
    category.Font = Theme.Fonts.Medium
    category.TextSize = 11
    category.TextXAlignment = Enum.TextXAlignment.Left
    category.Parent = card

    local toggleContainer = Instance.new("Frame")
    toggleContainer.Name = "ToggleContainer"
    toggleContainer.Size = UDim2.new(0, 72, 0, 28)
    toggleContainer.Position = UDim2.new(1, -82, 0.5, -14)
    toggleContainer.BackgroundTransparency = 1
    toggleContainer.Parent = card

    local toggle = Components:Toggle(toggleContainer, "", enabled, callback)
    toggle.Instance.Size = UDim2.new(1, 0, 1, 0)
    toggle.Instance.Position = UDim2.new(0, 0, 0, 0)

    return {
        Card = card,
        Toggle = toggle,
    }
end

local Notifications = {}
Notifications.__index = Notifications

function Notifications.new()
    local self = setmetatable({}, Notifications)

    local player = Players.LocalPlayer
    local playerGui = player and player:WaitForChild("PlayerGui") or nil

    self.Container = Instance.new("ScreenGui")
    self.Container.Name = "SCRIPT3R_Notifications"
    self.Container.ResetOnSpawn = false
    self.Container.IgnoreGuiInset = true
    self.Container.Parent = playerGui

    local holder = Instance.new("Frame")
    holder.Name = "Holder"
    holder.AnchorPoint = Vector2.new(1, 0)
    holder.Position = UDim2.new(1, -24, 0, 24)
    holder.Size = UDim2.new(0, 280, 0, 0)
    holder.BackgroundTransparency = 1
    holder.Parent = self.Container

    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0, 10)
    layout.HorizontalAlignment = Enum.HorizontalAlignment.Right
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Parent = holder

    self.Holder = holder
    return self
end

local function createNotificationNote(parent, message, color)
    local note = Instance.new("Frame")
    note.Name = "Notification"
    note.Size = UDim2.new(0, 260, 0, 54)
    note.BackgroundColor3 = Theme.Colors.Secondary
    note.Parent = parent

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 10)
    corner.Parent = note

    local bar = Instance.new("Frame")
    bar.Name = "AccentBar"
    bar.Size = UDim2.new(0, 4, 1, 0)
    bar.BackgroundColor3 = color
    bar.Parent = note

    local label = Instance.new("TextLabel")
    label.BackgroundTransparency = 1
    label.Position = UDim2.new(0, 14, 0, 0)
    label.Size = UDim2.new(1, -20, 1, 0)
    label.Text = message
    label.TextWrapped = true
    label.TextColor3 = Theme.Colors.Text
    label.Font = Theme.Fonts.Main
    label.TextSize = 12
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.TextYAlignment = Enum.TextYAlignment.Center
    label.Parent = note

    local stroke = Instance.new("UIStroke")
    stroke.Color = Theme.Colors.Border
    stroke.Transparency = 0.2
    stroke.Thickness = 1
    stroke.Parent = note

    return note
end

function Notifications:Push(message, kind)
    local color = {
        Info = Theme.Colors.Accent,
        Success = Theme.Colors.Success,
        Warning = Theme.Colors.Warning,
        Error = Theme.Colors.Error,
    }[kind] or Theme.Colors.Accent

    local note = createNotificationNote(self.Holder, tostring(message), color)
    note.Position = UDim2.new(1, 0, 0, 0)
    note.AnchorPoint = Vector2.new(1, 0)

    local tweenIn = TweenService:Create(note, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        Position = UDim2.new(1, -20, 0, 0),
    })
    tweenIn:Play()

    task.delay(3.3, function()
        local tweenOut = TweenService:Create(note, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
            Position = UDim2.new(1, 30, 0, 0),
            BackgroundTransparency = 1,
        })
        tweenOut:Play()

        task.delay(0.22, function()
            if note and note.Parent then
                note:Destroy()
            end
        end)
    end)

    return note
end

function Notifications:Info(message)
    self:Push(message, "Info")
end

function Notifications:Success(message)
    self:Push(message, "Success")
end

function Notifications:Warning(message)
    self:Push(message, "Warning")
end

function Notifications:Error(message)
    self:Push(message, "Error")
end

local Window = {}
Window.__index = Window

function Window.new(title)
    local self = setmetatable({}, Window)

    self.Tabs = {}
    self.TabOrder = {}
    self.ScriptCards = {}

    local player = Players.LocalPlayer
    local playerGui = player and player:WaitForChild("PlayerGui") or nil

    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "SCRIPT3R_HUB"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.IgnoreGuiInset = true
    ScreenGui.Parent = playerGui

    local Main = Instance.new("Frame")
    Main.Name = "Main"
    Main.Size = UDim2.new(0, Theme.Sizes.WindowWidth, 0, Theme.Sizes.WindowHeight)
    Main.Position = UDim2.new(0.5, -Theme.Sizes.WindowWidth / 2, 0.5, -Theme.Sizes.WindowHeight / 2)
    Main.BackgroundColor3 = Theme.Colors.Background
    Main.Parent = ScreenGui

    local MainCorner = Instance.new("UICorner")
    MainCorner.CornerRadius = UDim.new(0, Theme.CornerRadius)
    MainCorner.Parent = Main

    local MainStroke = Instance.new("UIStroke")
    MainStroke.Color = Theme.Colors.Border
    MainStroke.Thickness = 1
    MainStroke.Parent = Main

    local Header = Instance.new("Frame")
    Header.Name = "Header"
    Header.Size = UDim2.new(1, 0, 0, Theme.Sizes.HeaderHeight)
    Header.BackgroundColor3 = Theme.Colors.Secondary
    Header.Parent = Main

    local HeaderCorner = Instance.new("UICorner")
    HeaderCorner.CornerRadius = UDim.new(0, Theme.CornerRadius)
    HeaderCorner.Parent = Header

    local Title = Instance.new("TextLabel")
    Title.BackgroundTransparency = 1
    Title.Position = UDim2.new(0, 18, 0, 0)
    Title.Size = UDim2.new(1, -36, 1, 0)
    Title.Text = title or "SCRIPT3R HUB"
    Title.TextColor3 = Theme.Colors.Text
    Title.Font = Theme.Fonts.Bold
    Title.TextSize = 18
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.Parent = Header

    local Sidebar = Instance.new("Frame")
    Sidebar.Name = "Sidebar"
    Sidebar.Position = UDim2.new(0, 0, 0, Theme.Sizes.HeaderHeight)
    Sidebar.Size = UDim2.new(0, Theme.Sizes.SidebarWidth, 1, -Theme.Sizes.HeaderHeight)
    Sidebar.BackgroundColor3 = Theme.Colors.Secondary
    Sidebar.Parent = Main

    local SidebarLayout = Instance.new("UIListLayout")
    SidebarLayout.Padding = UDim.new(0, 10)
    SidebarLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    SidebarLayout.SortOrder = Enum.SortOrder.LayoutOrder
    SidebarLayout.Parent = Sidebar

    local Content = Instance.new("Frame")
    Content.Name = "Content"
    Content.Position = UDim2.new(0, Theme.Sizes.SidebarWidth, 0, Theme.Sizes.HeaderHeight)
    Content.Size = UDim2.new(1, -Theme.Sizes.SidebarWidth, 1, -Theme.Sizes.HeaderHeight)
    Content.BackgroundTransparency = 1
    Content.Parent = Main

    self.Gui = ScreenGui
    self.Main = Main
    self.Sidebar = Sidebar
    self.Content = Content
    self._dragging = false
    self._dragStart = nil
    self._startPosition = nil

    Header.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            self._dragging = true
            self._dragStart = input.Position
            self._startPosition = Main.Position
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if self._dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - self._dragStart
            Main.Position = UDim2.new(
                self._startPosition.X.Scale,
                self._startPosition.X.Offset + delta.X,
                self._startPosition.Y.Scale,
                self._startPosition.Y.Offset + delta.Y
            )
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            self._dragging = false
        end
    end)

    return self
end

function Window:AddTab(name)
    local normalizedName = tostring(name)

    if self.Tabs[normalizedName] then
        return self.Tabs[normalizedName].Page
    end

    local button = Instance.new("TextButton")
    button.Name = normalizedName
    button.Size = UDim2.new(1, -16, 0, 38)
    button.BackgroundColor3 = Theme.Colors.Tertiary
    button.Text = normalizedName
    button.TextColor3 = Theme.Colors.Text
    button.Font = Theme.Fonts.Medium
    button.TextSize = 13
    button.AutoButtonColor = false

    local buttonCorner = Instance.new("UICorner")
    buttonCorner.CornerRadius = UDim.new(0, 8)
    buttonCorner.Parent = button

    local buttonStroke = Instance.new("UIStroke")
    buttonStroke.Color = Theme.Colors.Border
    buttonStroke.Thickness = 1
    buttonStroke.Parent = button

    button.Parent = self.Sidebar

    local page = Instance.new("ScrollingFrame")
    page.Name = normalizedName
    page.Size = UDim2.new(1, -18, 1, -18)
    page.Position = UDim2.new(0, 12, 0, 12)
    page.BackgroundTransparency = 1
    page.BorderSizePixel = 0
    page.ScrollBarThickness = 4
    page.Visible = false
    page.Parent = self.Content

    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0, 10)
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Parent = page

    button.MouseButton1Click:Connect(function()
        self:SetActiveTab(normalizedName)
    end)

    local tab = {
        Name = normalizedName,
        Button = button,
        Page = page,
    }

    self.Tabs[normalizedName] = tab
    table.insert(self.TabOrder, tab)

    if #self.TabOrder == 1 then
        self:SetActiveTab(normalizedName)
    end

    return page
end

function Window:SetActiveTab(name)
    for _, tab in ipairs(self.TabOrder) do
        local isActive = tab.Name == name
        tab.Page.Visible = isActive
        tab.Button.BackgroundColor3 = isActive and Theme.Colors.Accent or Theme.Colors.Tertiary
        tab.Button.TextColor3 = Theme.Colors.Text
    end
end

function Window:Toggle()
    self.Main.Visible = not self.Main.Visible
end

function Window:Show()
    self.Main.Visible = true
end

function Window:Hide()
    self.Main.Visible = false
end

function Window:PopulateScripts(scripts, enabledMap, onToggle)
    local page = self.Tabs.SCRIPTS and self.Tabs.SCRIPTS.Page or self:AddTab("SCRIPTS")

    for _, child in ipairs(page:GetChildren()) do
        if child:IsA("GuiObject") then
            child:Destroy()
        end
    end

    if not scripts or #scripts == 0 then
        local empty = Components:Label(page, "Nenhum script carregado.", UDim2.new(1, -20, 0, 20))
        empty.TextColor3 = Theme.Colors.SubText
        return
    end

    for index, scriptData in ipairs(scripts) do
        local card = Components:ScriptCard(page, scriptData, enabledMap[scriptData.Name] == true, function(value)
            if onToggle then
                onToggle(scriptData.Name, value)
            end
        end)

        card.Card.LayoutOrder = index
        self.ScriptCards[scriptData.Name] = card
    end
end

local Hub = {}
Hub.__index = Hub

function Hub.new()
    local self = setmetatable({}, Hub)
    self.Name = Config.Name
    self.Version = Config.Version
    self.Author = Config.Author
    self.Scripts = {}
    self.Enabled = {}
    self.ScriptMap = {}
    self.Window = nil
    self.Notifications = nil
    self.Initialized = false
    self.ToggleConnection = nil
    return self
end

local function normalizeName(name)
    if type(name) ~= "string" then
        return nil
    end

    local cleaned = Utilities:Trim(name)
    return cleaned ~= "" and cleaned or nil
end

function Hub:HandleScriptError(scriptName, phase, err)
    local message = string.format("[%s] %s: %s", tostring(scriptName), tostring(phase), tostring(err))
    warn(message)

    if self.Notifications then
        self.Notifications:Error(message)
    end
end

function Hub:CreateUI()
    if self.Window then
        return self.Window
    end

    self.Window = Window.new(Config.UI.Title)
    self.Notifications = Notifications.new()

    local homePage = self.Window:AddTab("HOME")
    local scriptsPage = self.Window:AddTab("SCRIPTS")
    local settingsPage = self.Window:AddTab("SETTINGS")

    local homeTitle = Components:Label(homePage, Config.Name, UDim2.new(1, -20, 0, 28))
    homeTitle.TextSize = 22
    homeTitle.Font = Theme.Fonts.Bold

    local homeSubtitle = Components:Paragraph(homePage, Config.UI.Subtitle, UDim2.new(1, -20, 0, 36))
    homeSubtitle.Position = UDim2.new(0, 10, 0, 32)

    local homeStats = Instance.new("Frame")
    homeStats.Name = "Stats"
    homeStats.Size = UDim2.new(1, -20, 0, 90)
    homeStats.BackgroundColor3 = Theme.Colors.Tertiary
    homeStats.Parent = homePage
    local homeCorner = Instance.new("UICorner")
    homeCorner.CornerRadius = UDim.new(0, Theme.CornerRadius)
    homeCorner.Parent = homeStats

    local statLabel = Components:Label(homeStats, "Módulos registrados", UDim2.new(0.5, -10, 0, 18))
    statLabel.Position = UDim2.new(0, 12, 0, 18)
    statLabel.TextColor3 = Theme.Colors.SubText

    local countLabel = Components:Label(homeStats, tostring(Utilities:Count(self.Scripts)), UDim2.new(0.5, -10, 0, 32))
    countLabel.Position = UDim2.new(0, 12, 0, 38)
    countLabel.TextSize = 24
    countLabel.Font = Theme.Fonts.Bold

    local settingsSection = Components:Section(settingsPage, "Hub")
    settingsSection.Position = UDim2.new(0, 10, 0, 10)

    local notificationToggle = Components:Toggle(settingsPage, "Notificações", Config.Settings.Notifications, function(value)
        Config.Settings.Notifications = value
    end)
    notificationToggle.Instance.Position = UDim2.new(0, 10, 0, 32)

    local autoLoadToggle = Components:Toggle(settingsPage, "AutoLoad Scripts", Config.Settings.AutoLoadScripts, function(value)
        Config.Settings.AutoLoadScripts = value
    end)
    autoLoadToggle.Instance.Position = UDim2.new(0, 10, 0, 70)

    self.Window:PopulateScripts(self.Scripts, self.Enabled, function(scriptName, value)
        self:SetScriptState(scriptName, value)
    end)

    return self.Window
end

function Hub:BindToggleKey()
    if self.ToggleConnection then
        return
    end

    self.ToggleConnection = UserInputService.InputBegan:Connect(function(input, processed)
        if processed then
            return
        end

        if input.KeyCode == Config.UI.ToggleKey and self.Window then
            self.Window:Toggle()
        end
    end)
end

function Hub:RegisterScript(scriptData)
    assert(type(scriptData) == "table", "Hub:RegisterScript espera uma tabela.")

    local scriptName = normalizeName(scriptData.Name)
    assert(scriptName, "Hub:RegisterScript exige um Name válido.")

    if self.ScriptMap[scriptName] then
        return self.ScriptMap[scriptName]
    end

    scriptData.Name = scriptName
    scriptData.Category = scriptData.Category or "Misc"

    table.insert(self.Scripts, scriptData)
    self.ScriptMap[scriptName] = scriptData
    self.Enabled[scriptName] = false

    if self.Window then
        self.Window:PopulateScripts(self.Scripts, self.Enabled, function(name, value)
            self:SetScriptState(name, value)
        end)
    end

    print("[SCRIPT3R] Script registrado:", scriptName)
    return scriptData
end

function Hub:GetScript(scriptName)
    local name = normalizeName(scriptName)
    if not name then
        return nil
    end

    return self.ScriptMap[name]
end

function Hub:SetScriptState(scriptName, isEnabled)
    local scriptData = self:GetScript(scriptName)
    if not scriptData then
        return false
    end

    if isEnabled and not self.Enabled[scriptData.Name] then
        self:Enable(scriptData.Name)
        return true
    end

    if (not isEnabled) and self.Enabled[scriptData.Name] then
        self:Disable(scriptData.Name)
        return true
    end

    return self.Enabled[scriptData.Name] == true
end

function Hub:Enable(scriptName)
    local scriptData = self:GetScript(scriptName)
    if not scriptData then
        self:HandleScriptError(scriptName or "Unknown", "Enable", "Script não encontrado.")
        return false
    end

    if self.Enabled[scriptData.Name] then
        return true
    end

    local ok, err = xpcall(function()
        if scriptData.Start then
            scriptData.Start()
        end
    end, debug.traceback)

    if not ok then
        self:HandleScriptError(scriptData.Name, "Start", err)
        return false
    end

    self.Enabled[scriptData.Name] = true
    print("[SCRIPT3R] Ativado:", scriptData.Name)

    if self.Notifications and Config.Settings.Notifications then
        self.Notifications:Success(string.format("%s ativado", scriptData.Name))
    end

    if self.Window then
        self.Window:PopulateScripts(self.Scripts, self.Enabled, function(name, value)
            self:SetScriptState(name, value)
        end)
    end

    return true
end

function Hub:Disable(scriptName)
    local scriptData = self:GetScript(scriptName)
    if not scriptData then
        return false
    end

    if not self.Enabled[scriptData.Name] then
        return true
    end

    local ok, err = xpcall(function()
        if scriptData.Stop then
            scriptData.Stop()
        end
    end, debug.traceback)

    if not ok then
        self:HandleScriptError(scriptData.Name, "Stop", err)
    end

    self.Enabled[scriptData.Name] = false
    print("[SCRIPT3R] Desativado:", scriptData.Name)

    if self.Notifications and Config.Settings.Notifications then
        self.Notifications:Info(string.format("%s desativado", scriptData.Name))
    end

    if self.Window then
        self.Window:PopulateScripts(self.Scripts, self.Enabled, function(name, value)
            self:SetScriptState(name, value)
        end)
    end

    return true
end

function Hub:Toggle(scriptName)
    local scriptData = self:GetScript(scriptName)
    if not scriptData then
        return false
    end

    if self.Enabled[scriptData.Name] then
        return self:Disable(scriptData.Name)
    end

    return self:Enable(scriptData.Name)
end

function Hub:IsEnabled(scriptName)
    local scriptData = self:GetScript(scriptName)
    return scriptData and self.Enabled[scriptData.Name] == true or false
end

function Hub:AddScript(scriptData)
    return self:RegisterScript(scriptData)
end

function Hub:LoadScripts(scriptList)
    local list = scriptList or {
        {
            Name = "Example",
            Description = "Exemplo de script modular do SCRIPT3R HUB.",
            Category = "Utility",
            Start = function()
                print("[SCRIPT3R] Example started.")
            end,
            Stop = function()
                print("[SCRIPT3R] Example stopped.")
            end,
        },
    }

    for _, scriptData in ipairs(list) do
        self:RegisterScript(scriptData)
    end

    return self.Scripts
end

function Hub:Start()
    if self.Initialized then
        return self
    end

    self.Initialized = true
    self:CreateUI()
    self:BindToggleKey()

    if Config.Settings.AutoLoadScripts then
        self:LoadScripts()
    end

    return self
end

local HubInstance = Hub.new():Start()

print("======================================")
print("       " .. Config.Name)
print("       Version " .. Config.Version)
print("======================================")

return HubInstance
