-- PetyaX Premium Authentication System
-- Machine-based HWID (consistent per computer)

local PetyaX = {}
PetyaX.Version = "2.1.4"
PetyaX.ScriptKey = script_key or ""
PetyaX.API_URL = "http://127.0.0.1:5000"
PetyaX.IsAuthenticated = false

-- Machine-specific HWID (ignores user account and game)
function PetyaX:GenerateHWID()
    local identifiers = {}
    
    -- 1. Roblox Client ID (machine-specific, persists across accounts)
    local success, client_id = pcall(function()
        return game:GetService("RbxAnalyticsService"):GetClientId()
    end)
    
    if success and client_id then
        table.insert(identifiers, "machine_" .. client_id)
    end
    
    -- 2. Executor identifier (machine-specific)
    local success2, executor_name = pcall(function()
        if getexecutorname then
            return getexecutorname()
        end
        return nil
    end)
    
    if success2 and executor_name then
        table.insert(identifiers, "executor_" .. executor_name)
    end
    
    -- 3. System information (if available)
    local success3, system_info = pcall(function()
        if listfiles then
            return "has_file_access"
        end
        return "no_file_access"
    end)
    
    if success3 then
        table.insert(identifiers, system_info)
    end
    
    -- Combine machine identifiers
    if #identifiers > 0 then
        local hwid = table.concat(identifiers, "|")
        print("🖥️  Machine HWID:", hwid)
        return hwid
    else
        -- Ultimate fallback
        return "machine_fallback"
    end
end

-- Cache HWID for consistency
function PetyaX:GetCachedHWID()
    if not self.CachedHWID then
        self.CachedHWID = self:GenerateHWID()
    end
    return self.CachedHWID
end

-- Enhanced authentication
function PetyaX:Authenticate()
    self:ClearConsole()
    
    print("🔐 PetyaX Premium v" .. self.Version)
    print("═" .. string.rep("═", 50))
    
    -- Key validation
    if not self.ScriptKey or self.ScriptKey == "" then
        self:ShowError("NO LICENSE KEY", "Use !getloadstring in Discord to get your personalized loadstring.")
        return false
    end
    
    if not self.ScriptKey:match("^PXL_[A-Z0-9]{10}$") then
        self:ShowError("INVALID KEY", "Key format incorrect. Get valid key from Discord.")
        return false
    end
    
    print("🔑 License Key: " .. self.ScriptKey)
    print("🖥️  Detecting machine...")
    
    local hwid = self:GetCachedHWID()
    
    print("🌐 Contacting authentication server...")
    
    -- API call with timeout
    local success, result = pcall(function()
        return game:HttpGet(self.API_URL .. "/verify?key=" .. self.ScriptKey .. "&hwid=" .. hwid, true)
    end)
    
    if not success then
        self:ShowError("CONNECTION FAILED", "Cannot reach authentication server.\n\nPlease check:\n• Your internet connection\n• Server status in Discord\n• Firewall settings")
        return false
    end
    
    -- Parse response
    local jsonSuccess, data = pcall(function()
        return game:GetService("HttpService"):JSONDecode(result)
    end)
    
    if not jsonSuccess then
        self:ShowError("SERVER ERROR", "Invalid response from authentication server.")
        return false
    end
    
    -- Handle response
    if data.success then
        if data.first_time then
            print("🔒 HWID LOCKED: Key bound to this machine")
        else
            print("✅ HWID VERIFIED: Machine recognized")
        end
        
        self.IsAuthenticated = true
        return true
    else
        self:ShowError("AUTHENTICATION FAILED", 
            "Error: " .. (data.error or "Unknown error") .. 
            "\n\n📞 Support:\n" ..
            "1. Join our Discord\n" ..
            "2. Contact staff\n" ..
            "3. Use !reset_hwid if needed")
        return false
    end
end

-- Utility functions
function PetyaX:ClearConsole()
    if rconsoleclear then
        rconsoleclear()
    end
    if clearconsole then
        clearconsole()
    end
end

function PetyaX:ShowError(title, message)
    if rconsoleprint then
        rconsoleprint("@@RED@@")
        rconsoleprint("\n❌ " .. title .. "\n")
        rconsoleprint("@@WHITE@@")
        rconsoleprint(message .. "\n\n")
    else
        print("❌ " .. title)
        print(message)
    end
end

function PetyaX:ShowSuccess(message)
    if rconsoleprint then
        rconsoleprint("@@GREEN@@")
        rconsoleprint("✅ " .. message .. "\n")
        rconsoleprint("@@WHITE@@")
    else
        print("✅ " .. message)
    end
end

-- Load premium features
function PetyaX:LoadFeatures()
    print("🎯 Loading premium features...")
    print("─" .. string.rep("─", 50))
    
    -- Your features here - these will work for any user/game on this machine
    self:LoadAimbot()
    self:LoadESP() 
    self:LoadMiscTools()
    
    print("✨✨✨ PetyaX Premium Activated! ✨✨✨")
    print("💡 Features available for all users on this machine")
end

function PetyaX:LoadAimbot()
    print("🎯 Aimbot: Ready")
    -- Your aimbot code
end

function PetyaX:LoadESP()
    print("👁️ ESP: Ready")
    -- Your ESP code
end

function PetyaX:LoadMiscTools()
    print("🛠️ Tools: Ready")
    -- Your other tools
end

-- Main execution
print("🚀 Initializing PetyaX Premium...")
if PetyaX:Authenticate() then
    PetyaX:LoadFeatures()
    getgenv().PetyaX = PetyaX
else
    print("💥 Failed to initialize PetyaX Premium")
end

return PetyaX
