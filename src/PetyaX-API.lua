-- PetyaX-API.lua - ORIGINAL WORKING VERSION
local PetyaX = {
    _VERSION = "2.1.4",
    _AUTHOR = "PetyaX Premium", 
    _LICENSE = "Lifetime"
}

-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local CurrentCamera = workspace.CurrentCamera

-- Authentication
getgenv().PetyaXAuth = loadstring(game:HttpGet("https://raw.githubusercontent.com/0xR-Rudds/petyax-api-test/refs/heads/main/src/PetyaXAuth.lua"))()

-- Load Aimbot Module
PetyaX.Aimbot = loadstring(game:HttpGet("https://raw.githubusercontent.com/0xR-Rudds/petyax-api-test/refs/heads/main/src/Aimbot.lua"))()

-- Load ESP Module  
PetyaX.ESP = loadstring(game:HttpGet("https://raw.githubusercontent.com/0xR-Rudds/petyax-api-test/refs/heads/main/src/Esp.lua"))()

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
    end
}

-- Crosshair System
PetyaX.Crosshair = {
    Setup = function(self, config)
        return "Crosshair configured"
    end
}

return PetyaX
