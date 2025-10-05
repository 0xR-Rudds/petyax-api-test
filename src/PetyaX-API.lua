-- PetyaX-API: Premium Roblox Development Framework
-- Developed by Rudds (0xR)
-- Authentication Required

local PetyaX = {Version = "1.0.0"}

-- Authentication Check
local function Authenticate()
    local script_key = getgenv().script_key or ""
    
    if not script_key or script_key == "" then
        error("❌ PetyaX-API: No license key provided. Use: script_key = 'YOUR_PXL_KEY'")
    end
    
    if not script_key:match("^PXL_[A-Z0-9]+$") then
        error("❌ PetyaX-API: Invalid license key format")
    end
    
    -- Verify with authentication server
    local API_URL = "http://127.0.0.1:5000"
    local hwid = "machine_" .. game:GetService("RbxAnalyticsService"):GetClientId() .. "|executor_" .. (getexecutorname and getexecutorname() or "unknown")
    
    local success, result = pcall(function()
        return game:HttpGet(API_URL .. "/verify?key=" .. script_key .. "&hwid=" .. hwid)
    end)
    
    if not success then
        error("❌ PetyaX-API: Authentication server unavailable")
    end
    
    local jsonSuccess, data = pcall(function()
        return game:GetService("HttpService"):JSONDecode(result)
    end)
    
    if not jsonSuccess or not data.success then
        error("❌ PetyaX-API: Authentication failed - " .. (data.error or "Invalid key"))
    end
    
    return true
end

-- Perform authentication
local authSuccess, authError = pcall(Authenticate)
if not authSuccess then
    error(authError)
end

-- Loaded check
if getgenv().PetyaX then
    return getgenv().PetyaX
end

-- Load core modules
getgenv().AirHub = {}
loadstring(game:HttpGet("https://raw.githubusercontent.com/Exunys/AirHub/main/Modules/Aimbot.lua"))()
loadstring(game:HttpGet("https://raw.githubusercontent.com/Exunys/AirHub/main/Modules/Wall%20Hack.lua"))()

-- Transfer to namespace
PetyaX._Aimbot = getgenv().AirHub.Aimbot
PetyaX._WallHack = getgenv().AirHub.WallHack

-- Available body parts for targeting
PetyaX.BodyParts = {
    "Head", "HumanoidRootPart", "Torso", "Left Arm", "Right Arm", 
    "Left Leg", "Right Leg", "LeftHand", "RightHand", "LeftLowerArm",
    "RightLowerArm", "LeftUpperArm", "RightUpperArm", "LeftFoot", 
    "LeftLowerLeg", "UpperTorso", "LeftUpperLeg", "RightFoot", 
    "RightLowerLeg", "LowerTorso", "RightUpperLeg"
}

-- Aimbot API
PetyaX.Aimbot = {}

function PetyaX.Aimbot:Enable()
    PetyaX._Aimbot.Settings.Enabled = true
    return "🎯 Aimbot enabled"
end

function PetyaX.Aimbot:Disable()
    PetyaX._Aimbot.Settings.Enabled = false
    return "🎯 Aimbot disabled"
end

function PetyaX.Aimbot:SetTarget(partName)
    if table.find(PetyaX.BodyParts, partName) then
        PetyaX._Aimbot.Settings.LockPart = partName
        return "🎯 Target set to: " .. partName
    else
        return "❌ Invalid body part: " .. tostring(partName)
    end
end

function PetyaX.Aimbot:SetSensitivity(value)
    PetyaX._Aimbot.Settings.Sensitivity = math.clamp(value, 0, 1)
    return "🎯 Sensitivity set to: " .. value
end

function PetyaX.Aimbot:SetHotkey(key)
    PetyaX._Aimbot.Settings.TriggerKey = key
    return "🎯 Hotkey set to: " .. key
end

function PetyaX.Aimbot:SetFOV(options)
    if options.Enabled ~= nil then
        PetyaX._Aimbot.FOVSettings.Enabled = options.Enabled
    end
    if options.Size then
        PetyaX._Aimbot.FOVSettings.Amount = math.clamp(options.Size, 10, 300)
    end
    if options.Color then
        PetyaX._Aimbot.FOVSettings.Color = options.Color
    end
    if options.Visible ~= nil then
        PetyaX._Aimbot.FOVSettings.Visible = options.Visible
    end
    return "🎯 FOV configured"
end

function PetyaX.Aimbot:SetSafetyChecks(options)
    if options.TeamCheck ~= nil then
        PetyaX._Aimbot.Settings.TeamCheck = options.TeamCheck
    end
    if options.WallCheck ~= nil then
        PetyaX._Aimbot.Settings.WallCheck = options.WallCheck
    end
    if options.AliveCheck ~= nil then
        PetyaX._Aimbot.Settings.AliveCheck = options.AliveCheck
    end
    return "🎯 Safety checks updated"
end

function PetyaX.Aimbot:Setup(config)
    local results = {}
    
    if config.Enabled ~= nil then
        table.insert(results, self:Enable())
    end
    
    if config.Target then
        table.insert(results, self:SetTarget(config.Target))
    end
    
    if config.Sensitivity then
        table.insert(results, self:SetSensitivity(config.Sensitivity))
    end
    
    if config.Hotkey then
        table.insert(results, self:SetHotkey(config.Hotkey))
    end
    
    if config.FOV then
        table.insert(results, self:SetFOV(config.FOV))
    end
    
    if config.Safety then
        table.insert(results, self:SetSafetyChecks(config.Safety))
    end
    
    return results
end

-- ESP API
PetyaX.ESP = {}

function PetyaX.ESP:Enable()
    PetyaX._WallHack.Settings.Enabled = true
    return "👁️ ESP enabled"
end

function PetyaX.ESP:Disable()
    PetyaX._WallHack.Settings.Enabled = false
    return "👁️ ESP disabled"
end

function PetyaX.ESP:SetBoxes(options)
    if options.Enabled ~= nil then
        PetyaX._WallHack.Visuals.BoxSettings.Enabled = options.Enabled
    end
    if options.Color then
        PetyaX._WallHack.Visuals.BoxSettings.Color = options.Color
    end
    if options.Thickness then
        PetyaX._WallHack.Visuals.BoxSettings.Thickness = math.clamp(options.Thickness, 1, 5)
    end
    if options.Type then
        PetyaX._WallHack.Visuals.BoxSettings.Type = options.Type == "3D" and 1 or 2
    end
    return "👁️ Box ESP configured"
end

function PetyaX.ESP:SetTracers(options)
    if options.Enabled ~= nil then
        PetyaX._WallHack.Visuals.TracersSettings.Enabled = options.Enabled
    end
    if options.Color then
        PetyaX._WallHack.Visuals.TracersSettings.Color = options.Color
    end
    if options.Thickness then
        PetyaX._WallHack.Visuals.TracersSettings.Thickness = math.clamp(options.Thickness, 1, 5)
    end
    if options.From then
        local positions = {Bottom = 1, Center = 2, Mouse = 3}
        PetyaX._WallHack.Visuals.TracersSettings.Type = positions[options.From] or 1
    end
    return "👁️ Tracers configured"
end

function PetyaX.ESP:SetHealthBars(options)
    if options.Enabled ~= nil then
        PetyaX._WallHack.Visuals.HealthBarSettings.Enabled = options.Enabled
    end
    if options.Position then
        local positions = {Top = 1, Bottom = 2, Left = 3, Right = 4}
        PetyaX._WallHack.Visuals.HealthBarSettings.Type = positions[options.Position] or 3
    end
    return "👁️ Health bars configured"
end

function PetyaX.ESP:SetNames(options)
    if options.Enabled ~= nil then
        PetyaX._WallHack.Visuals.ESPSettings.DisplayName = options.Enabled
    end
    if options.Color then
        PetyaX._WallHack.Visuals.ESPSettings.TextColor = options.Color
    end
    if options.Size then
        PetyaX._WallHack.Visuals.ESPSettings.TextSize = math.clamp(options.Size, 8, 24)
    end
    return "👁️ Name ESP configured"
end

function PetyaX.ESP:SetChams(options)
    if options.Enabled ~= nil then
        PetyaX._WallHack.Visuals.ChamsSettings.Enabled = options.Enabled
    end
    if options.Color then
        PetyaX._WallHack.Visuals.ChamsSettings.Color = options.Color
    end
    if options.Filled ~= nil then
        PetyaX._WallHack.Visuals.ChamsSettings.Filled = options.Filled
    end
    return "👁️ Chams configured"
end

function PetyaX.ESP:Setup(config)
    local results = {}
    
    if config.Enabled ~= nil then
        table.insert(results, self:Enable())
    end
    
    if config.Boxes then
        table.insert(results, self:SetBoxes(config.Boxes))
    end
    
    if config.Tracers then
        table.insert(results, self:SetTracers(config.Tracers))
    end
    
    if config.HealthBars then
        table.insert(results, self:SetHealthBars(config.HealthBars))
    end
    
    if config.Names then
        table.insert(results, self:SetNames(config.Names))
    end
    
    if config.Chams then
        table.insert(results, self:SetChams(config.Chams))
    end
    
    return results
end

-- Crosshair API
PetyaX.Crosshair = {}

function PetyaX.Crosshair:Enable()
    PetyaX._WallHack.Crosshair.Settings.Enabled = true
    return "🎨 Crosshair enabled"
end

function PetyaX.Crosshair:Disable()
    PetyaX._WallHack.Crosshair.Settings.Enabled = false
    return "🎨 Crosshair disabled"
end

function PetyaX.Crosshair:SetStyle(options)
    if options.Size then
        PetyaX._WallHack.Crosshair.Settings.Size = math.clamp(options.Size, 8, 24)
    end
    if options.Thickness then
        PetyaX._WallHack.Crosshair.Settings.Thickness = math.clamp(options.Thickness, 1, 5)
    end
    if options.Color then
        PetyaX._WallHack.Crosshair.Settings.Color = options.Color
    end
    if options.Gap then
        PetyaX._WallHack.Crosshair.Settings.GapSize = math.clamp(options.Gap, 0, 20)
    end
    if options.CenterDot ~= nil then
        PetyaX._WallHack.Crosshair.Settings.CenterDot = options.CenterDot
    end
    return "🎨 Crosshair style updated"
end

function PetyaX.Crosshair:Setup(config)
    local results = {}
    
    if config.Enabled ~= nil then
        table.insert(results, self:Enable())
    end
    
    if config.Style then
        table.insert(results, self:SetStyle(config.Style))
    end
    
    return results
end

-- Utility Functions
function PetyaX:GetVersion()
    return self.Version
end

function PetyaX:GetBodyParts()
    return self.BodyParts
end

function PetyaX:ResetAll()
    PetyaX._Aimbot.Functions:ResetSettings()
    PetyaX._WallHack.Functions:ResetSettings()
    return "🔧 All settings reset"
end

-- Success message
print("✨ PetyaX-API v" .. PetyaX.Version .. " loaded successfully!")
print("🔑 Authenticated user with valid license")

-- Set global
getgenv().PetyaX = PetyaX

return PetyaX
