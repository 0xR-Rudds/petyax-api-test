-- PetyaX-API.lua - Fixed No Recursive Loading
local PetyaX = {
    _VERSION = "2.3.0",
    _AUTHOR = "PetyaX Premium", 
    _LICENSE = "Lifetime"
}

-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")
local LocalPlayer = Players.LocalPlayer
local CurrentCamera = workspace.CurrentCamera

print("🚀 Loading PetyaX Premium " .. PetyaX._VERSION)

-- Check if already loaded to prevent recursion
if getgenv().PetyaX then
    print("✅ PetyaX already loaded, returning existing instance")
    return getgenv().PetyaX
end

-- Load Authentication
local authSuccess, authResult = pcall(function()
    local authCode = game:HttpGet("https://raw.githubusercontent.com/0xR-Rudds/petyax-api-test/main/src/PetyaXAuth.lua")
    local authFunc = loadstring(authCode)
    return authFunc()
end)

if authSuccess and authResult then
    getgenv().PetyaXAuth = authResult
    print("✅ Authentication loaded")
else
    warn("❌ Failed to load authentication")
    getgenv().PetyaXAuth = {
        VerifyKey = function(key) 
            return true, "Auth bypassed - Development Mode"
        end,
        IsVerified = function() 
            return true 
        end
    }
end

-- Load Aimbot Module
local aimbotSuccess, aimbotModule = pcall(function()
    local aimbotCode = game:HttpGet("https://raw.githubusercontent.com/0xR-Rudds/petyax-api-test/main/src/Aimbot.lua")
    local aimbotFunc = loadstring(aimbotCode)
    return aimbotFunc()
end)

if aimbotSuccess and aimbotModule then
    PetyaX.Aimbot = aimbotModule
    print("✅ Aimbot loaded successfully")
else
    warn("❌ Failed to load Aimbot")
    PetyaX.Aimbot = {
        Setup = function(config) 
            return "Aimbot: Fallback mode" 
        end,
        Enable = function() end,
        Disable = function() end,
        GetTargetInfo = function() return "No target" end
    }
end

-- Load ESP Module
local espSuccess, espModule = pcall(function()
    local espCode = game:HttpGet("https://raw.githubusercontent.com/0xR-Rudds/petyax-api-test/main/src/Esp.lua")
    local espFunc = loadstring(espCode)
    return espFunc()
end)

if espSuccess and espModule then
    PetyaX.ESP = espModule
    print("✅ ESP loaded successfully")
else
    warn("❌ Failed to load ESP")
    PetyaX.ESP = {
        Setup = function(config) 
            return "ESP: Fallback mode" 
        end,
        Enable = function() end,
        Disable = function() end
    }
end

-- Memory Management
PetyaX.Memory = {
    Read = function(address, type)
        local success, result = pcall(function()
            return readmemory(address, type)
        end)
        return success and result or nil
    end,
    
    Write = function(address, value, type)
        local success, result = pcall(function()
            return writememory(address, value, type)
        end)
        return success
    end
}

-- Drawing Utilities
PetyaX.Drawing = {
    Line = function(from, to, color, thickness)
        local line = Drawing.new("Line")
        line.From = from
        line.To = to
        line.Color = color or Color3.new(1, 1, 1)
        line.Thickness = thickness or 1
        line.Visible = true
        return line
    end,
    
    Box = function(position, size, color, thickness, filled)
        local box = Drawing.new("Square")
        box.Position = position
        box.Size = size
        box.Color = color or Color3.new(1, 1, 1)
        box.Thickness = thickness or 1
        box.Filled = filled or false
        box.Visible = true
        return box
    end
}

-- Crosshair System
PetyaX.Crosshair = {
    Setup = function(self, config)
        return "Crosshair: Ready"
    end
}

-- Entity Management
PetyaX.Entities = {
    GetPlayers = function()
        return Players:GetPlayers()
    end,
    
    GetAlivePlayers = function()
        local alive = {}
        for _, player in pairs(Players:GetPlayers()) do
            if player.Character and player.Character:FindFirstChildOfClass("Humanoid") and player.Character:FindFirstChildOfClass("Humanoid").Health > 0 then
                table.insert(alive, player)
            end
        end
        return alive
    end
}

-- Utility Functions
PetyaX.Utils = {
    Round = function(num, decimalPlaces)
        local multiplier = 10^(decimalPlaces or 0)
        return math.floor(num * multiplier + 0.5) / multiplier
    end
}

-- API Information (FIXED CONCATENATION)
PetyaX.Info = {
    Version = PetyaX._VERSION,
    Author = PetyaX._AUTHOR,
    License = PetyaX._LICENSE,
    Features = "FPS Aimbot System, Enemy-Only ESP, Memory Management, Crosshair System"
}

-- Store in global to prevent re-loading
getgenv().PetyaX = PetyaX

-- Initialize message
print("✅ PetyaX Premium " .. PetyaX._VERSION .. " loaded successfully!")
print("📋 " .. PetyaX.Info.Features)

return PetyaX
