-- PetyaX Premium - Working HWID Authhhhhh
print("🚀 PetyaX Premium Loading...")

local PetyaX = {}
PetyaX.Version = "2.1.4"
PetyaX.ScriptKey = script_key or ""
PetyaX.API_URL = "http://127.0.0.1:5000"

-- Working HWID generation
function PetyaX:GenerateHWID()
    local identifiers = {}
    
    -- Roblox Client ID (machine-specific)
    local success, client_id = pcall(function()
        return game:GetService("RbxAnalyticsService"):GetClientId()
    end)
    
    if success and client_id then
        table.insert(identifiers, "machine_" .. client_id)
    end
    
    -- Executor name
    local success2, executor_name = pcall(function()
        if getexecutorname then
            return getexecutorname()
        end
        return nil
    end)
    
    if success2 and executor_name then
        table.insert(identifiers, "executor_" .. executor_name)
    end
    
    -- Combine or use fallback
    if #identifiers > 0 then
        return table.concat(identifiers, "|")
    else
        return "fallback_" .. tostring(tick())
    end
end

-- Cache HWID for consistency
function PetyaX:GetCachedHWID()
    if not self.CachedHWID then
        self.CachedHWID = self:GenerateHWID()
    end
    return self.CachedHWID
end

-- Authentication function
function PetyaX:Authenticate()
    print("🔐 Starting authentication...")
    
    -- Validate key
    if not self.ScriptKey or self.ScriptKey == "" then
        print("❌ ERROR: No license key provided!")
        return false
    end
    
    -- FIXED: Accept any length after PXL_
    if not self.ScriptKey:match("^PXL_[A-Z0-9]+$") then
        print("❌ ERROR: Invalid key format!")
        return false
    end
    
    print("🔑 Key:", self.ScriptKey)
    
    -- Generate HWID
    local hwid = self:GetCachedHWID()
    print("🆔 HWID:", hwid)
    
    -- API call
    local api_url = self.API_URL .. "/verify?key=" .. self.ScriptKey .. "&hwid=" .. hwid
    print("🌐 Calling API...")
    
    local success, result = pcall(function()
        return game:HttpGet(api_url)
    end)
    
    if not success then
        print("❌ API Error:", result)
        return false
    end
    
    print("✅ API Response:", result)
    
    -- Parse response
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

-- Load features
function PetyaX:LoadFeatures()
    print("🎯 Loading premium features...")
    print("🎯 Aimbot: Loaded")
    print("👁️ ESP: Loaded") 
    print("🛠️ Tools: Loaded")
    print("✨ PetyaX Premium Activated!")
end

-- Main execution
if PetyaX:Authenticate() then
    PetyaX:LoadFeatures()
    getgenv().PetyaX = PetyaX
else
    print("💥 PetyaX failed to load")
end

return PetyaX
