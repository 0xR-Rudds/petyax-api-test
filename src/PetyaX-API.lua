-- PetyaX-API.lua - Fixed without auto-auth
local PetyaX = {
    _VERSION = "2.2.2",
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

-- Don't auto-load auth - let client handle it
PetyaX.Auth = {
    VerifyKey = function(key)
        return loadstring(game:HttpGet("https://raw.githubusercontent.com/0xR-Rudds/petyax-api-test/refs/heads/main/src/PetyaXAuth.lua"))().VerifyKey(key)
    end,
    IsVerified = function()
        return loadstring(game:HttpGet("https://raw.githubusercontent.com/0xR-Rudds/petyax-api-test/refs/heads/main/src/PetyaXAuth.lua"))().IsVerified()
    end
}

-- Load Aimbot Module
local aimbotSuccess, aimbotModule = pcall(function()
    return loadstring(game:HttpGet("https://raw.githubusercontent.com/0xR-Rudds/petyax-api-test/refs/heads/main/src/Aimbot.lua"))()
end)

if aimbotSuccess then
    PetyaX.Aimbot = aimbotModule
    print("✅ Aimbot loaded successfully")
else
    warn("❌ Failed to load Aimbot: " .. tostring(aimbotModule))
    PetyaX.Aimbot = {Setup = function() return "Aimbot not loaded" end}
end

-- Load ESP Module
local espSuccess, espModule = pcall(function()
    return loadstring(game:HttpGet("https://raw.githubusercontent.com/0xR-Rudds/petyax-api-test/refs/heads/main/src/Esp.lua"))()
end)

if espSuccess then
    PetyaX.ESP = espModule
    print("✅ ESP loaded successfully")
else
    warn("❌ Failed to load ESP: " .. tostring(espModule))
    PetyaX.ESP = {Setup = function() return "ESP not loaded" end, Enable = function() end}
end

-- Essential Utilities
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

PetyaX.Crosshair = {
    Setup = function(self, config)
        return "Crosshair system ready"
    end
}

print("✅ PetyaX Premium " .. PetyaX._VERSION .. " loaded successfully!")

return PetyaX
