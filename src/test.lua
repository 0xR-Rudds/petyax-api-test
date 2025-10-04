-- PetyaX Premium Authentication
local PetyaX = {}
PetyaX.ScriptKey = script_key or ""
PetyaX.API_URL = "http://127.0.0.1:5000"

-- Generate HWID
function PetyaX:GenerateHWID()
    local components = {}
    local client_id = game:GetService("RbxAnalyticsService"):GetClientId()
    if client_id then table.insert(components, client_id) end
    if getexecutorname then table.insert(components, getexecutorname()) end
    return table.concat(components, "_")
end

-- Authenticate function
function PetyaX:Authenticate()
    if not self.ScriptKey or self.ScriptKey == "" then
        self:ShowError("❌ No license key provided! Use !getloadstring in Discord")
        return false
    end
    
    if not self.ScriptKey:match("^PXL_%w+$") then
        self:ShowError("❌ Invalid key format! Get correct key from Discord")
        return false
    end
    
    local hwid = self:GenerateHWID()
    
    local success, result = pcall(function()
        return game:HttpGet(self.API_URL .. "/verify?key=" .. self.ScriptKey .. "&hwid=" .. hwid)
    end)
    
    if not success then
        self:ShowError("❌ Cannot connect to auth server")
        return false
    end
    
    local data = game:GetService("HttpService"):JSONDecode(result)
    
    if data.success then
        if data.first_time then
            print("🔒 HWID locked to your system!")
        end
        return true
    else
        self:ShowError("❌ Auth Failed: " .. (data.error or "Unknown error"))
        return false
    end
end

function PetyaX:ShowError(message)
    rconsoleclear()
    rconsoleprint("@@RED@@")
    rconsoleprint("\n" .. message .. "\n\n")
    rconsoleprint("@@WHITE@@")
end

-- Main authentication check
if PetyaX:Authenticate() then
    rconsoleprint("@@GREEN@@")
    rconsoleprint("✅ PetyaX Authenticated! Loading features...\n")
    rconsoleprint("@@WHITE@@")
    
    -- YOUR EXISTING SCRIPT CODE GOES HERE
    -- Don't modify anything below - your current features
    print("🎯 Premium features loaded!")
else
    rconsoleprint("@@RED@@")
    rconsoleprint("❌ Authentication failed!\n")
    rconsoleprint("@@WHITE@@")
    return
end
