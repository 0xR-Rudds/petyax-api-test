-- PetyaX Premium - Working Version
print("🚀 Script started...")

-- Basic variables
local ScriptKey = script_key or ""
local API_URL = "http://127.0.0.1:5000"

print("🔑 Key received:", ScriptKey)

-- Super simple HWID
local function GenerateHWID()
    return "hwid_" .. tostring(tick())
end

local function Authenticate()
    if ScriptKey == "" then
        print("❌ ERROR: No script_key provided!")
        return false
    end
    
    -- Validate key format
    if not string.match(ScriptKey, "^PXL_%w+$") then
        print("❌ ERROR: Invalid key format!")
        return false
    end
    
    local hwid = GenerateHWID()
    print("🆔 Generated HWID:", hwid)
    
    -- Test API connection
    local api_url = API_URL .. "/verify?key=" .. ScriptKey .. "&hwid=" .. hwid
    print("🌐 Calling API:", api_url)
    
    local success, result = pcall(function()
        return game:HttpGet(api_url)
    end)
    
    if not success then
        print("❌ API Connection Failed:", result)
        return false
    end
    
    print("✅ API Response:", result)
    
    -- Parse JSON response
    local jsonSuccess, data = pcall(function()
        return game:GetService("HttpService"):JSONDecode(result)
    end)
    
    if not jsonSuccess then
        print("❌ JSON Parse Failed")
        return false
    end
    
    if data.success then
        print("🎉 AUTHENTICATION SUCCESS!")
        if data.first_time then
            print("🔒 First use - HWID locked!")
        end
        return true
    else
        print("❌ AUTH FAILED:", data.error)
        return false
    end
end

-- Main execution
print("🔐 Starting authentication...")
if Authenticate() then
    print("")
    print("✨✨✨ PetyaX Premium Activated! ✨✨✨")
    print("🎯 Loading premium features...")
    print("")
    
    -- YOUR ACTUAL SCRIPT FEATURES GO HERE
    
else
    print("")
    print("💥 PetyaX Failed to Load")
    print("📞 Contact support in Discord")
end
