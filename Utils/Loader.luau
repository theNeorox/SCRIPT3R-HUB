--[[
    SCRIPT3R HUB
    Loader
]]

local Loader = {}

local function validateModule(module)
    if type(module) ~= "table" then
        return false, "O módulo retornou um valor inválido. Esperado tabela."
    end

    if type(module.Name) ~= "string" or module.Name == "" then
        return false, "O módulo não possui um Nome válido."
    end

    if module.Category ~= nil and type(module.Category) ~= "string" then
        return false, "A categoria do módulo deve ser uma string."
    end

    if module.Start ~= nil and type(module.Start) ~= "function" then
        return false, "Start deve ser uma função quando definido."
    end

    if module.Stop ~= nil and type(module.Stop) ~= "function" then
        return false, "Stop deve ser uma função quando definido."
    end

    return true
end

function Loader.Load(module)
    if not module then
        return nil, "Módulo nulo."
    end

    local success, result = xpcall(function()
        return require(module)
    end, debug.traceback)

    if not success then
        return nil, string.format("Falha ao executar require para %s: %s", tostring(module), tostring(result))
    end

    local valid, err = validateModule(result)
    if not valid then
        return nil, string.format("Modulo %s inválido: %s", tostring(module), tostring(err))
    end

    if not result.Category then
        result.Category = "Misc"
    end

    return result
end

function Loader.LoadFolder(folder)
    local modules = {}
    local errors = {}
    local seen = {}

    if not folder then
        return modules, errors
    end

    for _, object in ipairs(folder:GetChildren()) do
        if object:IsA("ModuleScript") then
            local module, err = Loader.Load(object)

            if module then
                local key = module.Name or object.Name

                if seen[key] then
                    warn("[SCRIPT3R] Módulo duplicado ignorado:", key)
                else
                    seen[key] = true
                    table.insert(modules, module)
                    print("[SCRIPT3R] Carregado:", key)
                end
            else
                table.insert(errors, {
                    Name = object.Name,
                    Error = tostring(err),
                })

                warn("[SCRIPT3R] Erro ao carregar:", object.Name, err)
            end
        end
    end

    return modules, errors
end

return Loader