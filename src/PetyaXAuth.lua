-- PetyaXAuth.lua - Fixed Version
local PetyaXAuth = {}

-- Configuration
local API_URL = "http://127.0.0.1:5000/verify"
local HWID = nil
local Verified = false
local LastCheck = 0
local CheckCooldown = 30 -- seconds

-- Generate HWID
function PetyaXAuth.GenerateHWID()
    if HWID then return HWID end
    
    local identifiers = ""
    
    -- Use multiple system identifiers for uniqueness
    local success, result = pcall(function()
        -- Game join time
        identifiers = identifiers .. tostring(tick())
        
        -- Player userId
        if game:GetService("Players").LocalPlayer then
            identifiers = identifiers .. tostring(game:GetService("Players").LocalPlayer.UserId)
        end
        
        -- Random component
        identifiers = identifiers .. tostring(math.random(10000, 99999))
    end)
    
    -- Create hash
    HWID = tostring(string.len(identifiers)) .. string.sub(identifiers, 1, 10)
    return HWID
end

-- Verify Key (FIXED - No infinite loop)
function PetyaXAuth.VerifyKey(Key)
    if Verified then
        return true, "Already verified"
    end
    
    -- Cooldown check
    if tick() - LastCheck < CheckCooldown then
        return false, "Please wait before verifying again"
    end
    
    LastCheck = tick()
    
    if not Key or Key == "" then
        return false, "No key provided"
    end
    
    -- Generate HWID if not exists
    local hwid = PetyaXAuth.GenerateHWID()
    
    -- Make API request
    local success, result = pcall(function()
        local url = API_URL .. "?key=" .. Key .. "&hwid=" .. hwid
        return game:HttpGet(url)
    end)
    
    if not success then
        return false, "API connection failed: " .. tostring(result)
    end
    
    -- Parse response
    local parseSuccess, responseData = pcall(function()
        return game:GetService("HttpService"):JSONDecode(result)
    end)
    
    if not parseSuccess then
        return false, "Invalid API response"
    end
    
    if responseData.success then
        Verified = true
        return true, responseData.message or "Verification successful"
    else
        return false, responseData.error or "Verification failed"
    end
end

-- Check if verified
function PetyaXAuth.IsVerified()
    return Verified
end

-- Get HWID
function PetyaXAuth.GetHWID()
    return PetyaXAuth.GenerateHWID()
end

-- Reset verification (for testing)
function PetyaXAuth.Reset()
    Verified = false
    LastCheck = 0
end

print("🔐 PetyaX Auth Loaded - HWID: " .. PetyaXAuth.GenerateHWID())

return PetyaXAuth
