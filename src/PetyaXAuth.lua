print("🔐 Auth script loaded!")
local key = script_key or "NO_KEY"
print("Key received:", key)

if not key or key == "" then
    print("❌ No key provided")
    return
end

if not key:match("^PXL_") then
    print("❌ Invalid key format")
    return
end

print("🔄 Starting authentication...")

-- Generate HWID
local client_id = game:GetService("RbxAnalyticsService"):GetClientId() or "unknown"
local executor_name = getexecutorname and getexecutorname() or "unknown"
local hwid = "machine_" .. client_id .. "|executor_" .. executor_name

print("🆔 HWID:", hwid)

-- Call API
local api_url = "http://127.0.0.1:5000/verify?key=" .. key .. "&hwid=" .. hwid
print("🌐 Calling API...")

local success, result = pcall(function()
    return game:HttpGet(api_url)
end)

if not success then
    print("❌ API Error:", result)
    return
end

print("✅ API Response:", result)

-- Parse response
local jsonSuccess, data = pcall(function()
    return game:GetService("HttpService"):JSONDecode(result)
end)

if not jsonSuccess then
    print("❌ JSON Parse Error")
    return
end

if data.success then
    print("🎉 Authentication successful!")
    
    -- Load main script
    print("📦 Loading main script...")
    local main_url = "https://raw.githubusercontent.com/0xR-Rudds/petyax-api-test/main/src/main.lua"
    local loadSuccess, loadError = pcall(function()
        local main_script = game:HttpGet(main_url)
        loadstring(main_script)()
    end)
    
    if not loadSuccess then
        print("❌ Main script error:", loadError)
    end
else
    print("❌ Auth failed:", data.error or "Unknown error")
end
