-- PetyaXAuth.lua - ORIGINAL WORKING VERSION
local PetyaXAuth = {}

local API_URL = "http://127.0.0.1:5000/verify"
local HWID = nil

function PetyaXAuth.GenerateHWID()
    if HWID then return HWID end
    
    local identifiers = ""
    
    -- Get system identifiers
    local success, result = pcall(function()
        identifiers = identifiers .. tostring(tick())
        
        if game:GetService("Players").LocalPlayer then
            identifiers = identifiers .. tostring(game:GetService("Players").LocalPlayer.UserId)
        end
        
        identifiers = identifiers .. tostring(math.random(10000, 99999))
    end)
    
    HWID = tostring(string.len(identifiers)) .. string.sub(identifiers, 1, 10)
    return HWID
end

function PetyaXAuth.VerifyKey(Key)
    if not Key or Key == "" then
        return false, "No key provided"
    end
    
    local hwid = PetyaXAuth.GenerateHWID()
    
    local success, result = pcall(function()
        local url = API_URL .. "?key=" .. Key .. "&hwid=" .. hwid
        return game:HttpGet(url)
    end)
    
    if not success then
        return false, "API connection failed"
    end
    
    local parseSuccess, responseData = pcall(function()
        return game:GetService("HttpService"):JSONDecode(result)
    end)
    
    if not parseSuccess then
        return false, "Invalid API response"
    end
    
    if responseData.success then
        return true, responseData.message or "Verification successful"
    else
        return false, responseData.error or "Verification failed"
    end
end

return PetyaXAuth
