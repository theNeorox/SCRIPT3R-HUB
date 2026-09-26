--[[
    SCRIPT3R HUB
    UI / Window
]]

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")

local Theme = require(script.Parent.Theme)
local Components = require(script.Parent.Components)

local Player = Players.LocalPlayer or Players:GetPropertyChangedSignal("LocalPlayer") and Players.LocalPlayer
local PlayerGui = Player and Player:WaitForChild("PlayerGui") or nil

local Window = {}
Window.__index = Window

function Window.new(title)
    local self = setmetatable({}, Window)

    self.Tabs = {}
    self.TabOrder = {}
    self.ScriptCards = {}

    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "SCRIPT3R_HUB"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.IgnoreGuiInset = true
    ScreenGui.Parent = PlayerGui

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

return Window