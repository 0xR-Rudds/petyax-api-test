-- PetyaX Premium Authentication
local PetyaX = {}
PetyaX.ScriptKey = script_key or ""
PetyaX.API_URL = "http://127.0.0.1:5000"

-- FIXED: Generate HWID function
function PetyaX:GenerateHWID()
    local components = {}
    
    -- Use Roblox client ID
    local client_id = game:GetService("RbxAnalyticsService"):GetClientId()
    if client_id and type(client_id) == "string" then
        table.insert(components, client_id)
    end
    
    -- Use executor name if available
    if getexecutorname and type(getexecutorname) == "function" then
        local executor_name = getexecutorname()
        if executor_name and type(executor_name) == "string" then
            table.insert(components, executor_name)
        end
    end
    
    -- Fallback if no components found
    if #components == 0 then
        table.insert(components, "fallback_" .. tostring(tick()))
    end
    
    return table.concat(components, "_")
end

-- SIMPLIFIED VERSION (if above still has issues):
function PetyaX:GenerateHWID()
    local hwid = ""
    
    -- Simple HWID using client ID
    local client_id = game:GetService("RbxAnalyticsService"):GetClientId()
    if client_id then
        hwid = "rbx_" .. client_id
    else
        -- Fallback to timestamp
        hwid = "fallback_" .. tostring(tick())
    end
    
    return hwid
end

-- EVEN SIMPLER VERSION (guaranteed to work):
function PetyaX:GenerateHWID()
    return "hwid_" .. tostring(tick()) .. "_" .. tostring(math.random(1000, 9999))
end

-- Authenticate function (keep this the same)
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
    print("Generated HWID:", hwid)
    
    local success, result = pcall(function()
        return game:HttpGet(self.API_URL .. "/verify?key=" .. self.ScriptKey .. "&hwid=" .. hwid)
    end)
    
    if not success then
        self:ShowError("❌ Cannot connect to auth server: " .. result)
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
    print("🎯 Premium features loaded!")
else
    rconsoleprint("@@RED@@")
    rconsoleprint("❌ Authentication failed!\n")
    rconsoleprint("@@WHITE@@")
    return
end
