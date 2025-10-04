-- PetyaX Premium Loader
-- Client-Side Script for Roblox Executor

local PetyaX = {}
PetyaX.Version = "2.1.4"
PetyaX.ScriptKey = script_key or ""
PetyaX.API_URL = "http://your-server-ip:5000"  -- Change to your server IP

-- Generate unique HWID from system
function PetyaX:GenerateHWID()
    local hwid_components = {}
    
    -- Use Roblox client ID (consistent per device)
    local client_id = game:GetService("RbxAnalyticsService"):GetClientId()
    if client_id then
        table.insert(hwid_components, client_id)
    end
    
    -- Use executor name if available
    if getexecutorname then
        table.insert(hwid_components, getexecutorname())
    end
    
    -- Combine components
    local hwid = table.concat(hwid_components, "_")
    return hwid
end

-- Authenticate with server
function PetyaX:Authenticate()
    if not self.ScriptKey or self.ScriptKey == "" then
        self:ShowError("❌ No license key provided!\n\nGet your key from our Discord:\n1. Join PetyaX Discord\n2. Purchase lifetime license\n3. Use !getloadstring command")
        return false
    end
    
    -- Validate key format
    if not self.ScriptKey:match("^PXL_%w+$") then
        self:ShowError("❌ Invalid key format!\n\nYour key should look like: PXL_ABCD123456\n\nGet your correct key from Discord using !getloadstring")
        return false
    end
    
    local hwid = self:GenerateHWID()
    
    -- Contact authentication server
    local success, result = pcall(function()
        local url = self.API_URL .. "/verify?key=" .. self.ScriptKey .. "&hwid=" .. hwid
        return game:HttpGet(url)
    end)
    
    if not success then
        self:ShowError("❌ Cannot connect to auth server!\n\nPlease check:\n• Your internet connection\n• Server status in Discord\n• Try again later")
        return false
    end
    
    local data = game:GetService("HttpService"):JSONDecode(result)
    
    if data.success then
        if data.first_time then
            print("🔒 HWID locked to your system!")
        end
        return true
    else
        self:ShowError("❌ Authentication Failed!\n\nError: " .. (data.error or "Unknown error") .. "\n\n📞 Join our Discord for support!")
        return false
    end
end

-- Show error message
function PetyaX:ShowError(message)
    rconsoleclear()
    rconsoleprint("@@RED@@")
    rconsoleprint("\n" .. message .. "\n\n")
    rconsoleprint("@@WHITE@@")
    
    -- Optional: Create in-game error GUI
    if syn and syn.protect_gui then
        self:CreateErrorGUI(message)
    end
end

-- Create error GUI
function PetyaX:CreateErrorGUI(message)
    local ScreenGui = Instance.new("ScreenGui")
    local Frame = Instance.new("Frame")
    local TextLabel = Instance.new("TextLabel")
    
    ScreenGui.Parent = game.CoreGui
    Frame.Parent = ScreenGui
    TextLabel.Parent = Frame
    
    -- Styling
    Frame.Size = UDim2.new(0, 400, 0, 150)
    Frame.Position = UDim2.new(0.5, -200, 0.5, -75)
    Frame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    Frame.BorderSizePixel = 0
    
    TextLabel.Size = UDim2.new(0.9, 0, 0.9, 0)
    TextLabel.Position = UDim2.new(0.05, 0, 0.05, 0)
    TextLabel.Text = message
    TextLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
    TextLabel.BackgroundTransparency = 1
    TextLabel.TextWrapped = true
    TextLabel.Font = Enum.Font.Gotham
    TextLabel.TextSize = 14
end

-- Load premium features after authentication
function PetyaX:LoadPremiumFeatures()
    rconsoleclear()
    rconsoleprint("@@GREEN@@")
    rconsoleprint([[
    
🎯 PetyaX Premium v]] .. self.Version .. [[ Loaded!
🔑 License Key: ]] .. self.ScriptKey:sub(1, 8) .. [[****
✅ Authentication Successful!
🛠️ Loading premium features...
    
    ]])
    rconsoleprint("@@WHITE@@")
    
    -- Your premium features here
    self:InitializeUI()
    self:LoadAimbot()
    self:LoadESP()
    self:LoadMiscFeatures()
end

function PetyaX:InitializeUI()
    print("🎨 Loading Premium UI...")
    -- Your UI code here
end

function PetyaX:LoadAimbot()
    print("🎯 Loading Aimbot...")
    -- Your aimbot code here
end

function PetyaX:LoadESP()
    print("👁️ Loading ESP...")
    -- Your ESP code here
end

function PetyaX:LoadMiscFeatures()
    print("⚡ Loading Misc Features...")
    -- Your other features here
end

-- Main execution
if PetyaX:Authenticate() then
    PetyaX:LoadPremiumFeatures()
    getgenv().PetyaX = PetyaX
else
    rconsoleprint("@@RED@@")
    rconsoleprint("❌ PetyaX failed to load!\n")
    rconsoleprint("@@WHITE@@")
end

return PetyaX