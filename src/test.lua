-- PetyaX Premium Loader
print("🎯 PetyaX Script Loaded!")
print("🔑 Key:", script_key or "NO KEY PROVIDED")

if not script_key or script_key == "" then
    print("❌ ERROR: No script_key found!")
    print("💡 Get your loadstring from Discord using !getloadstring")
    return
end

if not script_key:match("^PXL_[A-Z0-9]+$") then
    print("❌ ERROR: Invalid key format!")
    return
end

print("🔄 Starting authentication...")

local API_URL = "http://127.0.0.1:5000"

-- Generate simple HWID
local hwid = "hwid_" .. tostring(tick())
print("🆔 HWID:", hwid)

-- Call API
local api_url = API_URL .. "/verify?key=" .. script_key .. "&hwid=" .. hwid
print("🌐 Calling:", api_url)

local success, result = pcall(function()
    return game:HttpGet(api_url)
end)

if not success then
    print("❌ API Connection Failed:", result)
    return
end

print("✅ API Response:", result)

-- Parse response
local jsonSuccess, data = pcall(function()
    return game:GetService("HttpService"):JSONDecode(result)
end)

if not jsonSuccess then
    print("❌ JSON Parse Failed")
    return
end

if data.success then
    print("🎉 AUTHENTICATION SUCCESS!")
    if data.first_time then
        print("🔒 HWID locked to this machine")
    end
    
    -- Load your features here
    print("🚀 Loading premium features...")
    print("🎯 Aimbot: Activated")
    print("👁️ ESP: Activated") 
    print("🛠️ Tools: Activated")
    
else
    print("❌ AUTH FAILED:", data.error or "Unknown error")
end
