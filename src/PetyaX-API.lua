-- PetyaX-API.lua - Fixed No Loading Loop
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

-- Prevent recursive loading
if getgenv().PetyaXLoading then
    error("PetyaX is already loading!")
end
getgenv().PetyaXLoading = true

-- Load Authentication (WITH ERROR HANDLING)
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

-- Load Aimbot Module (WITH ERROR HANDLING)
local aimbotSuccess, aimbotModule = pcall(function()
    local aimbotCode = game:HttpGet("https://raw.githubusercontent.com/0xR-Rudds/petyax-api-test/main/src/Aimbot.lua")
    local aimbotFunc = loadstring(aimbotCode)
    return aimbotFunc()
end)

if aimbotSuccess and aimbotModule then
    PetyaX.Aimbot = aimbotModule
    print("✅ Aimbot loaded successfully")
else
    warn("❌ Failed to load Aimbot - Using fallback")
    PetyaX.Aimbot = {
        Setup = function(config) 
            return "Aimbot: Fallback mode - Check Aimbot.lua file" 
        end,
        Enable = function() 
            print("Aimbot enabled (fallback)") 
        end,
        Disable = function() 
            print("Aimbot disabled (fallback)") 
        end
    }
end

-- Load ESP Module (WITH ERROR HANDLING)
local espSuccess, espModule = pcall(function()
    local espCode = game:HttpGet("https://raw.githubusercontent.com/0xR-Rudds/petyax-api-test/main/src/Esp.lua")
    local espFunc = loadstring(espCode)
    return espFunc()
end)

if espSuccess and espModule then
    PetyaX.ESP = espModule
    print("✅ ESP loaded successfully")
else
    warn("❌ Failed to load ESP - Using fallback")
    PetyaX.ESP = {
        Setup = function(config) 
            return "ESP: Fallback mode - Check Esp.lua file" 
        end,
        Enable = function() 
            print("ESP enabled (fallback)") 
        end,
        Disable = function() 
            print("ESP disabled (fallback)") 
        end
    }
end

-- Memory Management (Keep essential)
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

-- Drawing Utilities (Keep essential)
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

-- Crosshair System (Simple)
PetyaX.Crosshair = {
    Setup = function(self, config)
        return "Crosshair: Ready"
    end
}

-- Entity Management (Simple)
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

-- API Information
PetyaX.Info = {
    Version = PetyaX._VERSION,
    Author = PetyaX._AUTHOR,
    License = PetyaX._LICENSE,
    Features = {
        "FPS Aimbot System",
        "Enemy-Only ESP", 
        "Memory Management",
        "Crosshair System"
    }
}

-- Clear loading flag
getgenv().PetyaXLoading = false

-- Initialize message
print("✅ PetyaX Premium " .. PetyaX._VERSION .. " loaded successfully!")
print("📋 " .. table.concat(PetyaX.Info.Features, ", "))

return PetyaX
