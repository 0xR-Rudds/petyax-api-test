-- PetyaX Premium - Fixed Version
local PetyaX = {}
PetyaX.ScriptKey = script_key or ""
PetyaX.API_URL = "http://127.0.0.1:5000"

-- Simple working HWID
function PetyaX:GenerateHWID()
    return "hwid_" .. tostring(tick())
end

function PetyaX:Authenticate()
    if not self.ScriptKey or self.ScriptKey == "" then
        print("❌ No license key provided!")
        return false
    end
    
    local hwid = self:GenerateHWID()
    print("🔑 Key:", self.ScriptKey)
    print("🆔 HWID:", hwid)
    
    local success, result = pcall(function()
        return game:HttpGet(self.API_URL .. "/verify?key=" .. self.ScriptKey .. "&hwid=" .. hwid)
    end)
    
    if not success then
        print("❌ API Error:", result)
        return false
    end
    
    print("✅ API Response:", result)
    local data = game:GetService("HttpService"):JSONDecode(result)
    
    if data.success then
        print("🎉 Authentication successful!")
        return true
    else
        print("❌ Auth failed:", data.error)
        return false
    end
end

-- Test authentication
if PetyaX:Authenticate() then
    print("🚀 Loading premium features...")
    -- Your features here
else
    print("💥 Failed to load")
end
