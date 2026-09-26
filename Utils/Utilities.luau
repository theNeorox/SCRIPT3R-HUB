--[[
    SCRIPT3R HUB
    Utilities
]]

local Utilities = {}

function Utilities:Find(tbl, value)
    if type(tbl) ~= "table" then
        return nil
    end

    for _, item in pairs(tbl) do
        if item == value then
            return item
        end
    end

    return nil
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

function Utilities:Trim(text)
    if type(text) ~= "string" then
        return ""
    end

    return text:match("^%s*(.-)%s*$")
end

function Utilities:StartsWith(text, prefix)
    if type(text) ~= "string" or type(prefix) ~= "string" then
        return false
    end

    return text:sub(1, #prefix) == prefix
end

function Utilities:EndsWith(text, suffix)
    if type(text) ~= "string" or type(suffix) ~= "string" then
        return false
    end

    if #suffix == 0 then
        return true
    end

    return text:sub(-#suffix) == suffix
end

function Utilities:Clamp(value, minimum, maximum)
    if value < minimum then
        return minimum
    end

    if value > maximum then
        return maximum
    end

    return value
end

function Utilities:Round(value, decimals)
    local power = 10 ^ (decimals or 0)
    return math.floor((value * power) + 0.5) / power
end

function Utilities:SafeDestroy(instance)
    if instance and typeof(instance) == "Instance" and instance.Destroy then
        instance:Destroy()
    end
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

function Utilities:Delay(seconds, callback)
    task.delay(seconds, function()
        local success, err = self:SafeCall(callback)

        if not success then
            warn("[SCRIPT3R] Delay callback falhou:", err)
        end
    end)
end

return Utilities