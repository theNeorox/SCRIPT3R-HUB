--[[
    SCRIPT3R HUB
    UI / Components
]]

local Components = {}

local Theme = require(script.Parent.Theme)

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

function Components:Divider(parent)
    local divider = Instance.new("Frame")
    divider.Name = "Divider"
    divider.Size = UDim2.new(1, 0, 0, 1)
    divider.BackgroundColor3 = Theme.Colors.Border
    divider.Parent = parent
    return divider
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

return Components