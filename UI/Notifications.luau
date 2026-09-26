--[[
    SCRIPT3R HUB
    UI / Notifications
]]

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")

local Theme = require(script.Parent.Theme)

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

local function createNotificationEntry(parent, message, color)
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

    local note = createNotificationEntry(self.Holder, tostring(message), color)
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

return Notifications