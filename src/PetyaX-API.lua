-- PetyaX-API.lua - Main API File
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

-- Load Authentication
local authSuccess, authResult = pcall(function()
    return loadstring(game:HttpGet("https://raw.githubusercontent.com/0xR-Rudds/petyax-api-test/main/src/PetyaXAuth.lua"))()
end)

if authSuccess then
    getgenv().PetyaXAuth = authResult
    print("✅ Authentication loaded")
else
    warn("❌ Failed to load authentication: " .. tostring(authResult))
    getgenv().PetyaXAuth = {
        VerifyKey = function(key) return true, "Auth bypassed" end,
        IsVerified = function() return true end
    }
end

-- Load Aimbot Module
local aimbotSuccess, aimbotModule = pcall(function()
    return loadstring(game:HttpGet("https://raw.githubusercontent.com/0xR-Rudds/petyax-api-test/main/src/Aimbot.lua"))()
end)

if aimbotSuccess and aimbotModule then
    PetyaX.Aimbot = aimbotModule
    print("✅ Aimbot loaded successfully")
else
    warn("❌ Failed to load Aimbot")
    PetyaX.Aimbot = {
        Setup = function(config) return "Aimbot not available" end,
        Enable = function() end,
        Disable = function() end
    }
end

-- Load ESP Module
local espSuccess, espModule = pcall(function()
    return loadstring(game:HttpGet("https://raw.githubusercontent.com/0xR-Rudds/petyax-api-test/main/src/Esp.lua"))()
end)

if espSuccess and espModule then
    PetyaX.ESP = espModule
    print("✅ ESP loaded successfully")
else
    warn("❌ Failed to load ESP")
    PetyaX.ESP = {
        Setup = function(config) return "ESP not available" end,
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
    end,
    
    ReadString = function(address, length)
        local success, result = pcall(function()
            return readstring(address, length)
        end)
        return success and result or ""
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
    end,
    
    Text = function(text, position, color, size, outline, center)
        local textDraw = Drawing.new("Text")
        textDraw.Text = text or ""
        textDraw.Position = position or Vector2.new(0, 0)
        textDraw.Color = color or Color3.new(1, 1, 1)
        textDraw.Size = size or 16
        textDraw.Outline = outline or false
        textDraw.Center = center or false
        textDraw.Visible = true
        return textDraw
    end,
    
    Circle = function(position, radius, color, thickness, filled, numSides)
        local circle = Drawing.new("Circle")
        circle.Position = position or Vector2.new(0, 0)
        circle.Radius = radius or 50
        circle.Color = color or Color3.new(1, 1, 1)
        circle.Thickness = thickness or 1
        circle.Filled = filled or false
        circle.NumSides = numSides or 30
        circle.Visible = true
        return circle
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
    end,
    
    GetClosestPlayer = function()
        local closestPlayer = nil
        local closestDistance = math.huge
        local localCharacter = LocalPlayer.Character
        local localRoot = localCharacter and localCharacter:FindFirstChild("HumanoidRootPart")
        
        if not localRoot then return nil end
        
        for _, player in pairs(PetyaX.Entities.GetAlivePlayers()) do
            if player ~= LocalPlayer then
                local character = player.Character
                local rootPart = character and character:FindFirstChild("HumanoidRootPart")
                
                if rootPart then
                    local distance = (localRoot.Position - rootPart.Position).Magnitude
                    if distance < closestDistance then
                        closestDistance = distance
                        closestPlayer = player
                    end
                end
            end
        end
        
        return closestPlayer, closestDistance
    end
}

-- Camera Utilities
PetyaX.Camera = {
    WorldToViewport = function(position)
        return CurrentCamera:WorldToViewportPoint(position)
    end,
    
    ViewportToWorld = function(position, depth)
        return CurrentCamera:ViewportPointToRay(position.X, position.Y, depth or 0)
    end,
    
    ScreenToWorld = function(position)
        local mouse = UserInputService:GetMouseLocation()
        return CurrentCamera:ScreenPointToRay(mouse.X, mouse.Y)
    end
}

-- Crosshair System
PetyaX.Crosshair = {
    _enabled = false,
    _lines = {},
    
    Setup = function(self, config)
        self:Destroy()
        
        if not config or not config.Enabled then
            return "Crosshair disabled"
        end
        
        self._enabled = true
        
        local centerX = CurrentCamera.ViewportSize.X / 2
        local centerY = CurrentCamera.ViewportSize.Y / 2
        local size = config.Style and config.Style.Size or 14
        local color = config.Style and config.Style.Color or Color3.new(1, 1, 0)
        
        -- Horizontal line
        local horizontal = Drawing.new("Line")
        horizontal.From = Vector2.new(centerX - size, centerY)
        horizontal.To = Vector2.new(centerX + size, centerY)
        horizontal.Color = color
        horizontal.Thickness = 2
        horizontal.Visible = true
        table.insert(self._lines, horizontal)
        
        -- Vertical line
        local vertical = Drawing.new("Line")
        vertical.From = Vector2.new(centerX, centerY - size)
        vertical.To = Vector2.new(centerX, centerY + size)
        vertical.Color = color
        vertical.Thickness = 2
        vertical.Visible = true
        table.insert(self._lines, vertical)
        
        -- Center dot
        if config.Style and config.Style.CenterDot then
            local dot = Drawing.new("Circle")
            dot.Position = Vector2.new(centerX, centerY)
            dot.Radius = 2
            dot.Color = color
            dot.Thickness = 2
            dot.Filled = true
            dot.Visible = true
            table.insert(self._lines, dot)
        end
        
        return "Crosshair enabled"
    end,
    
    Destroy = function(self)
        for _, line in pairs(self._lines) do
            if line and typeof(line) == "table" then
                line:Remove()
            end
        end
        self._lines = {}
        self._enabled = false
    end
}

-- Utility Functions
PetyaX.Utils = {
    Round = function(num, decimalPlaces)
        local multiplier = 10^(decimalPlaces or 0)
        return math.floor(num * multiplier + 0.5) / multiplier
    end,
    
    TableToString = function(tbl)
        return HttpService:JSONEncode(tbl)
    end,
    
    StringToTable = function(str)
        return HttpService:JSONDecode(str)
    end,
    
    GetGameName = function()
        return game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId).Name
    end
}

-- API Information
PetyaX.Info = {
    Version = PetyaX._VERSION,
    Author = PetyaX._AUTHOR,
    License = PetyaX._LICENSE,
    Features = {
        "Aimbot System",
        "ESP System",
        "Memory Management",
        "Crosshair System",
        "Entity Utilities",
        "Drawing API"
    }
}

-- Initialize message
print("✅ PetyaX Premium " .. PetyaX._VERSION .. " loaded successfully!")
print("📋 Features: " .. table.concat(PetyaX.Info.Features, ", "))

return PetyaX
