--Latest
print("🔐 Auth script loaded!")
local key = script_key or "NO_KEY"
print("Key received:", key)

if not key or key == "" then return end
if not key:match("^PXL_") then return end

print("🔄 Starting authentication...")

-- Generate HWID
local client_id = game:GetService("RbxAnalyticsService"):GetClientId() or "unknown"
local executor_name = getexecutorname and getexecutorname() or "unknown"
local hwid = "machine_" .. client_id .. "|executor_" .. executor_name

-- Call API
local api_url = "http://127.0.0.1:5000/verify?key=" .. key .. "&hwid=" .. hwid

local success, result = pcall(function()
    return game:HttpGet(api_url)
end)

if not success then 
    print("❌ API Error:", result)
    return 
end

local jsonSuccess, data = pcall(function()
    return game:GetService("HttpService"):JSONDecode(result)
end)

if not jsonSuccess then 
    print("❌ JSON Error")
    return 
end

if data.success then
    print("🎉 Authentication successful!")
    
    -- CORRECT MAIN SCRIPT URL
    local main_url = "https://raw.githubusercontent.com/0xR-Rudds/petyax-api-test/main/src/PetyaX-API.lua"
    print("📦 Loading main script: " .. main_url)
    
    local loadSuccess, content = pcall(function()
        return game:HttpGet(main_url)
    end)
    
    if loadSuccess then
        print("✅ Main script downloaded!")
        local execSuccess, execError = pcall(function()
            loadstring(content)()
        end)
        if execSuccess then
            print("✨ Main script executed successfully!")
        else
            print("❌ Main script execution error:", execError)
        end
    else
        print("❌ Failed to download main script:", content)
    end
else
    print("❌ Auth failed:", data.error)
end

