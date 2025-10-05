local script_key = script_key or ""
if script_key == "" then return end

local API_URL = "http://127.0.0.1:5000"
local MAIN_SCRIPT_URL = "https://raw.githubusercontent.com/0xR-Rudds/petyax-api-test/main/src/main.lua"

local PetyaX = {}
PetyaX.ScriptKey = script_key
PetyaX.API_URL = API_URL
PetyaX.MainScriptURL = MAIN_SCRIPT_URL

function PetyaX:GenerateHWID()
    local client_id = game:GetService("RbxAnalyticsService"):GetClientId() or "unknown"
    local executor_name = getexecutorname and getexecutorname() or "unknown"
    return "machine_" .. client_id .. "|executor_" .. executor_name
end

function PetyaX:Authenticate()
    if not self.ScriptKey:match("PXL") then return false end
    
    local hwid = self:GenerateHWID()
    local success, result = pcall(function()
        return game:HttpGet(self.API_URL .. "/verify?key=" .. self.ScriptKey .. "&hwid=" .. hwid)
    end)
    
    if not success then return false end
    
    local jsonSuccess, data = pcall(function()
        return game:GetService("HttpService"):JSONDecode(result)
    end)
    
    if not jsonSuccess then return false end
    
    return data.success
end

function PetyaX:LoadMainScript()
    local success, error = pcall(function()
        local script_content = game:HttpGet(self.MainScriptURL)
        loadstring(script_content)()
    end)
    return success
end

if PetyaX:Authenticate() then
    PetyaX:LoadMainScript()
end
