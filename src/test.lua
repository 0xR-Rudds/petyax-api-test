-- PetyaX Premium - Auth Gateway
print("🚀 PetyaX Authentication Gateway...")

local PetyaX = {}
PetyaX.Version = "2.1.4"
PetyaX.ScriptKey = script_key or ""
PetyaX.API_URL = "http://127.0.0.1:5000"
PetyaX.MainScriptURL = "https://raw.githubusercontent.com/0xR-Rudds/petyax-api-test/refs/heads/main/src/idk.lua"

-- Working HWID generation
function PetyaX:GenerateHWID()
    local identifiers = {}
    
    local success, client_id = pcall(function()
        return game:GetService("RbxAnalyticsService"):GetClientId()
    end)
    
    if success and client_id then
        table.insert(identifiers, "machine_" .. client_id)
    end
    
    local success2, executor_name = pcall(function()
        if getexecutorname then
            return getexecutorname()
        end
        return nil
    end)
    
    if success2 and executor_name then
        table.insert(identifiers, "executor_" .. executor_name)
    end
    
    if #identifiers > 0 then
        return table.concat(identifiers, "|")
    else
        return "fallback_" .. tostring(tick())
    end
end

function PetyaX:GetCachedHWID()
    if not self.CachedHWID then
        self.CachedHWID = self:GenerateHWID()
    end
    return self.CachedHWID
end

-- Authentication function
function PetyaX:Authenticate()
    print("🔐 Verifying license...")
    
    if not self.ScriptKey or self.ScriptKey == "" then
        print("❌ ERROR: No license key provided!")
        return false
    end
    
    if not self.ScriptKey:match("^PXL_[A-Z0-9]+$") then
        print("❌ ERROR: Invalid key format!")
        return false
    end
    
    print("🔑 Key:", self.ScriptKey)
    
    local hwid = self:GetCachedHWID()
    print("🆔 HWID:", hwid)
    
    local api_url = self.API_URL .. "/verify?key=" .. self.ScriptKey .. "&hwid=" .. hwid
    print("🌐 Authenticating...")
    
    local success, result = pcall(function()
        return game:HttpGet(api_url)
    end)
    
    if not success then
        print("❌ API Error:", result)
        return false
    end
    
    local jsonSuccess, data = pcall(function()
        return game:GetService("HttpService"):JSONDecode(result)
    end)
    
    if not jsonSuccess then
        print("❌ JSON Parse Error")
        return false
    end
    
    if data.success then
        if data.first_time then
            print("🔒 HWID locked to this machine!")
        else
            print("✅ Machine verified!")
        end
        return true
    else
        print("❌ Auth failed:", data.error or "Unknown error")
        return false
    end
end

-- Load main script after authentication
function PetyaX:LoadMainScript()
    print("📦 Loading main script...")
    print("🔗 Source:", self.MainScriptURL)
    
    local success, content = pcall(function()
        return game:HttpGet(self.MainScriptURL)
    end)
    
    if not success then
        print("❌ Failed to load main script:", content)
        return false
    end
    
    print("✅ Main script loaded, executing...")
    
    local execSuccess, execError = pcall(function()
        loadstring(content)()
    end)
    
    if not execSuccess then
        print("❌ Main script execution failed:", execError)
        return false
    end
    
    print("✨ Main script executed successfully!")
    return true
end

-- Main execution
if PetyaX:Authenticate() then
    print("🎉 Authentication successful!")
    PetyaX:LoadMainScript()
else
    print("💥 Authentication failed - access denied")
end

return PetyaX
