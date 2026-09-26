--[[
    SCRIPT3R HUB
    Main Loader
]]

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")

local Config = require(script.Parent.Config)
local Loader = require(script.Parent.Utils.Loader)
local Utilities = require(script.Parent.Utils.Utilities)
local Theme = require(script.Parent.UI.Theme)
local Components = require(script.Parent.UI.Components)
local Window = require(script.Parent.UI.Window)
local NotificationsModule = require(script.Parent.UI.Notifications)

local Hub = {}
Hub.__index = Hub

Hub.Name = Config.Name
Hub.Version = Config.Version
Hub.Author = Config.Author
Hub.Scripts = {}
Hub.Enabled = {}
Hub.ScriptMap = {}
Hub.Window = nil
Hub.Notifications = nil
Hub.Initialized = false
Hub.ToggleConnection = nil

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
    self.Notifications = NotificationsModule.new()

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

    if isEnabled and not self.Enabled[scriptName] then
        self:Enable(scriptName)
        return true
    end

    if (not isEnabled) and self.Enabled[scriptName] then
        self:Disable(scriptName)
        return true
    end

    return self.Enabled[scriptName] == true
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

function Hub:LoadScripts(folder)
    local scriptFolder = folder or script.Parent.Scripts
    local modules, errors = Loader.LoadFolder(scriptFolder)

    for _, scriptData in ipairs(modules) do
        self:RegisterScript(scriptData)
    end

    for _, errorEntry in ipairs(errors) do
        self:HandleScriptError(errorEntry.Name, "Load", errorEntry.Error)
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

function Hub:Stop()
    if self.Window then
        self.Window:Hide()
    end

    return self
end

print("======================================")
print("       " .. Config.Name)
print("       Version " .. Config.Version)
print("======================================")

return Hub:Start()