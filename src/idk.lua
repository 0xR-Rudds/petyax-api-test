-- PetyaX Premium Authentication System
-- Version 2.1.4 - Production Ready

local PetyaX = {}
PetyaX.Version = "2.1.4"
PetyaX.ScriptKey = script_key or ""
PetyaX.API_URL = "http://127.0.0.1:5000"
PetyaX.IsAuthenticated = false

-- Clear console for clean output
local function ClearConsole()
    if rconsoleclear then rconsoleclear() end
    if clearconsole then clearconsole() end
end

-- Machine-based HWID (consistent per computer)
function PetyaX:GenerateHWID()
    local identifiers = {}
    
    -- 1. Roblox Client ID (machine-specific)
    local success, client_id = pcall(function()
        return game:GetService("RbxAnalyticsService"):GetClientId()
    end)
    
    if success and client_id then
        table.insert(identifiers, "machine_" .. client_id)
    end
    
    -- 2. Executor identifier
    local success2, executor_name = pcall(function()
        if getexecutorname then
            return getexecutorname()
        end
        return nil
    end)
    
    if success2 and executor_name then
        table.insert(identifiers, "executor_" .. executor_name)
    end
    
    -- Combine identifiers or use fallback
    if #identifiers > 0 then
        return table.concat(identifiers, "|")
    else
        return "fallback_" .. tostring(tick())
    end
end

-- Cache HWID for session consistency
function PetyaX:GetCachedHWID()
    if not self.CachedHWID then
        self.CachedHWID = self:GenerateHWID()
    end
    return self.CachedHWID
end

-- Main authentication function
function PetyaX:Authenticate()
    ClearConsole()
    
    -- Print header
    if rconsoleprint then
        rconsoleprint("@@CYAN@@")
        rconsoleprint([[
        
🔐 PetyaX Premium v]] .. self.Version .. [[
═]] .. string.rep("═", 50) .. [[

]])
        rconsoleprint("@@WHITE@@")
    else
        print("🔐 PetyaX Premium v" .. self.Version)
        print("═" .. string.rep("═", 50))
    end
    
    -- Validate key
    if not self.ScriptKey or self.ScriptKey == "" then
        self:ShowError("NO LICENSE KEY", "Use !getloadstring in Discord to get your personalized loadstring.")
        return false
    end
    
    if not self.ScriptKey:match("^PXL_[A-Z0-9]{10}$") then
        self:ShowError("INVALID KEY FORMAT", "Key should be: PXL_ followed by 10 characters\nExample: PXL_ABCD123456")
        return false
    end
    
    print("🔑 License: " .. self.ScriptKey:sub(1, 8) .. "****")
    print("🖥️  Verifying machine...")
    
    local hwid = self:GetCachedHWID()
    
    -- API call
    local success, result = pcall(function()
        return game:HttpGet(self.API_URL .. "/verify?key=" .. self.ScriptKey .. "&hwid=" .. hwid, true)
    end)
    
    if not success then
        self:ShowError("CONNECTION FAILED", "Cannot reach authentication server.\n\nPlease check:\n• Internet connection\n• Server status in Discord")
        return false
    end
    
    -- Parse response
    local jsonSuccess, data = pcall(function()
        return game:GetService("HttpService"):JSONDecode(result)
    end)
    
    if not jsonSuccess then
        self:ShowError("SERVER ERROR", "Invalid response from server.")
        return false
    end
    
    -- Handle authentication result
    if data.success then
        if data.first_time then
            self:ShowSuccess("HWID LOCKED - Key bound to this machine")
        else
            self:ShowSuccess("MACHINE VERIFIED - Welcome back!")
        end
        self.IsAuthenticated = true
        return true
    else
        self:ShowError("AUTHENTICATION FAILED", 
            "Error: " .. (data.error or "Unknown") .. 
            "\n\n📞 Support:\n" ..
            "• Join our Discord\n" ..
            "• Contact staff\n" ..
            "• Use !reset_hwid if needed")
        return false
    end
end

-- UI Functions
function PetyaX:ShowError(title, message)
    if rconsoleprint then
        rconsoleprint("@@RED@@")
        rconsoleprint("❌ " .. title .. "\n")
        rconsoleprint("@@WHITE@@")
        rconsoleprint(message .. "\n\n")
    else
        warn("❌ " .. title)
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

-- Premium Features Loader
function PetyaX:LoadPremiumFeatures()
    print("\n🎯 Loading Premium Features...")
    print("─" .. string.rep("─", 50))
    
    -- Your features here
    self:LoadAimbot()
    self:LoadESP()
    self:LoadMiscTools()
    
    if rconsoleprint then
        rconsoleprint("@@GREEN@@")
        rconsoleprint([[

✨✨✨ PetyaX Premium Activated! ✨✨✨
🎮 Ready for any game & account on this machine

]])
        rconsoleprint("@@WHITE@@")
    else
        print("\n✨✨✨ PetyaX Premium Activated! ✨✨✨")
        print("🎮 Ready for any game & account on this machine")
    end
end

-- Feature placeholders (replace with your actual code)
function PetyaX:LoadAimbot()
    print("🎯 Aimbot System: Loaded")
    -- Your aimbot code
end

function PetyaX:LoadESP()
    print("👁️ ESP System: Loaded")
    -- Your ESP code
end

function PetyaX:LoadMiscTools()
    print("🛠️ Utility Tools: Loaded")
    -- Your other tools
end

-- Main Execution
if PetyaX:Authenticate() then
    PetyaX:LoadPremiumFeatures()
    getgenv().PetyaX = PetyaX
else
    if rconsoleprint then
        rconsoleprint("@@RED@@")
        rconsoleprint("💥 PetyaX Failed to Load\n")
        rconsoleprint("@@WHITE@@")
    else
        print("💥 PetyaX Failed to Load")
    end
end

return PetyaX
