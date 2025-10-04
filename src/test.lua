-- PetyaX Premium - Debug Version
print("=== 🚀 PetyaX Debug Mode ===")

local ScriptKey = script_key or ""
local API_URL = "http://127.0.0.1:5000"

print("1. 🔑 Key Analysis:")
print("   Key value: '" .. ScriptKey .. "'")
print("   Key exists: " .. tostring(ScriptKey ~= ""))
print("   Key length: " .. tostring(#ScriptKey))

-- Check key format
if ScriptKey:match("^PXL_[A-Z0-9]+$") then
    print("   ✅ Key format: VALID")
else
    print("   ❌ Key format: INVALID")
end

print("")
print("2. 🌐 API Connection Test:")

-- Simple HWID
local hwid = "debug_hwid_123"
print("   Using HWID: " .. hwid)

-- Build API URL
local api_url = API_URL .. "/verify?key=" .. ScriptKey .. "&hwid=" .. hwid
print("   API URL: " .. api_url)

print("")
print("3. 📡 Making API Request...")

local success, result = pcall(function()
    return game:HttpGet(api_url)
end)

if success then
    print("   ✅ API Request: SUCCESS")
    print("   Response: " .. result)
    
    -- Try to parse JSON
    local jsonSuccess, data = pcall(function()
        return game:GetService("HttpService"):JSONDecode(result)
    end)
    
    if jsonSuccess then
        print("   ✅ JSON Parse: SUCCESS")
        if data.success then
            print("   🎉 AUTHENTICATION: SUCCESS")
            if data.first_time then
                print("   🔒 HWID locked to this machine")
            end
        else
            print("   ❌ AUTHENTICATION: FAILED")
            print("   Error: " .. (data.error or "Unknown error"))
        end
    else
        print("   ❌ JSON Parse: FAILED")
        print("   Raw response: " .. result)
    end
else
    print("   ❌ API Request: FAILED")
    print("   Error: " .. result)
end

print("")
print("=== 🔍 Debug Complete ===")
