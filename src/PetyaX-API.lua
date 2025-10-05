-- PetyaX-API.lua - Fixed with correct aimbot loading
local PetyaX = {
    _VERSION = "2.3.1",
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

-- Authentication
local authSuccess, authResult = pcall(function()
    return loadstring(game:HttpGet("https://raw.githubusercontent.com/0xR-Rudds/petyax-api-test/refs/heads/main/src/PetyaXAuth.lua"))()
end)

if authSuccess then
    getgenv().PetyaXAuth = authResult
    print("✅ Authentication loaded")
else
    warn("❌ Failed to load authentication: " .. tostring(authResult))
end

-- Load Aimbot Module (FIXED: Using correct Aimbot.lua URL)
local aimbotSuccess, aimbotModule = pcall(function()
    return loadstring(game:HttpGet("https://raw.githubusercontent.com/0xR-Rudds/petyax-api-test/main/src/Aimbot.lua"))()
end)

if aimbotSuccess then
    PetyaX.Aimbot = aimbotModule
    print("✅ FPS Aimbot loaded successfully")
else
    warn("❌ Failed to load Aimbot: " .. tostring(aimbotModule))
    -- Fallback empty aimbot
    PetyaX.Aimbot = {
        Setup = function(config) 
            return "Aimbot not available: " .. tostring(aimbotModule)
        end,
        Enable = function() print("Aimbot not loaded") end,
        Disable = function() print("Aimbot not loaded") end
    }
end

-- Load ESP Module
local espSuccess, espModule = pcall(function()
    return loadstring(game:HttpGet("https://raw.githubusercontent.com/0xR-Rudds/petyax-api-test/main/src/Esp.lua"))()
end)

if espSuccess then
    PetyaX.ESP = espModule
    print("✅ ESP loaded successfully")
else
    warn("❌ Failed to load ESP: " .. tostring(espModule))
    PetyaX.ESP = {
        Setup = function(config) 
            return "ESP not available" 
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
        return "Crosshair system ready"
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

print("✅ PetyaX Premium " .. PetyaX._VERSION .. " loaded successfully!")

return PetyaX
