-- PetyaX-API.lua - Updated with FPS Aimbot
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

-- Load FPS Aimbot Module (REPLACED OLD AIMBOT)
local fpsAimbotSuccess, fpsAimbotModule = pcall(function()
    return loadstring(game:HttpGet("https://raw.githubusercontent.com/0xR-Rudds/petyax-api-test/refs/heads/main/src/FPSAimbot.lua"))()
end)

if fpsAimbotSuccess then
    PetyaX.Aimbot = fpsAimbotModule
    print("✅ FPS Aimbot loaded successfully")
else
    warn("❌ Failed to load FPS Aimbot: " .. tostring(fpsAimbotModule))
    -- Fallback empty aimbot
    PetyaX.Aimbot = {
        Setup = function(config) 
            return "FPS Aimbot not available" 
        end,
        Enable = function() end,
        Disable = function() end
    }
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
    PetyaX.ESP = {
        Setup = function(config) 
            return "ESP not available" 
        end, 
        Enable = function() end,
        Disable = function() end
    }
end

-- Memory Management (Keep for advanced features)
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

-- Drawing Utilities (Keep for ESP and visual features)
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

-- Entity Management (Enhanced for FPS games)
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
    end,
    
    -- New FPS-specific functions
    GetPlayersInFOV = function(fov, maxDistance)
        local playersInFOV = {}
        local camera = workspace.CurrentCamera
        local mousePos = UserInputService:GetMouseLocation()
        
        for _, player in pairs(PetyaX.Entities.GetAlivePlayers()) do
            if player ~= LocalPlayer and player.Character then
                local rootPart = player.Character:FindFirstChild("HumanoidRootPart")
                if rootPart then
                    local distance = (rootPart.Position - camera.CFrame.Position).Magnitude
                    if distance <= (maxDistance or 500) then
                        local screenPoint, onScreen = camera:WorldToViewportPoint(rootPart.Position)
                        if onScreen then
                            local screenDistance = (Vector2.new(screenPoint.X, screenPoint.Y) - mousePos).Magnitude
                            if screenDistance <= fov then
                                table.insert(playersInFOV, {
                                    Player = player,
                                    Distance = distance,
                                    ScreenDistance = screenDistance
                                })
                            end
                        end
                    end
                end
            end
        end
        
        -- Sort by screen distance (closest to crosshair first)
        table.sort(playersInFOV, function(a, b)
            return a.ScreenDistance < b.ScreenDistance
        end)
        
        return playersInFOV
    end
}

-- Camera Utilities (Enhanced for FPS aiming)
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
    end,
    
    -- New FPS functions
    GetCameraDirection = function()
        return CurrentCamera.CFrame.LookVector
    end,
    
    GetCrosshairPosition = function()
        local viewportSize = CurrentCamera.ViewportSize
        return Vector2.new(viewportSize.X / 2, viewportSize.Y / 2)
    end
}

-- Crosshair System (Enhanced for FPS)
PetyaX.Crosshair = {
    _enabled = false,
    _lines = {},
    _dot = nil,
    
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
        local thickness = config.Style and config.Style.Thickness or 2
        
        -- Horizontal line
        local horizontal = Drawing.new("Line")
        horizontal.From = Vector2.new(centerX - size, centerY)
        horizontal.To = Vector2.new(centerX + size, centerY)
        horizontal.Color = color
        horizontal.Thickness = thickness
        horizontal.Visible = true
        table.insert(self._lines, horizontal)
        
        -- Vertical line
        local vertical = Drawing.new("Line")
        vertical.From = Vector2.new(centerX, centerY - size)
        vertical.To = Vector2.new(centerX, centerY + size)
        vertical.Color = color
        vertical.Thickness = thickness
        vertical.Visible = true
        table.insert(self._lines, vertical)
        
        -- Center dot
        if config.Style and config.Style.CenterDot then
            self._dot = Drawing.new("Circle")
            self._dot.Position = Vector2.new(centerX, centerY)
            self._dot.Radius = config.Style.DotSize or 2
            self._dot.Color = color
            self._dot.Thickness = thickness
            self._dot.Filled = true
            self._dot.Visible = true
        end
        
        return "FPS Crosshair enabled"
    end,
    
    Destroy = function(self)
        for _, line in pairs(self._lines) do
            if line and typeof(line) == "table" then
                line:Remove()
            end
        end
        if self._dot then
            self._dot:Remove()
            self._dot = nil
        end
        self._lines = {}
        self._enabled = false
    end
}

-- Utility Functions (Enhanced)
PetyaX.Utils = {
    Round = function(num, decimalPlaces)
        local multiplier = 10^(decimalPlaces or 0)
        return math.floor(num * multiplier + 0.5) / multiplier
    end,
    
    Clamp = function(value, min, max)
        return math.max(min, math.min(max, value))
    end,
    
    Lerp = function(a, b, t)
        return a + (b - a) * t
    end,
    
    -- FPS-specific utilities
    CalculateDistance = function(position1, position2)
        return (position1 - position2).Magnitude
    end,
    
    IsInFOV = function(worldPosition, fov)
        local screenPoint, onScreen = CurrentCamera:WorldToViewportPoint(worldPosition)
        if not onScreen then return false end
        
        local crosshairPos = PetyaX.Camera.GetCrosshairPosition()
        local screenDistance = (Vector2.new(screenPoint.X, screenPoint.Y) - crosshairPos).Magnitude
        return screenDistance <= fov
    end
}

-- API Information (Updated)
PetyaX.Info = {
    Version = PetyaX._VERSION,
    Author = PetyaX._AUTHOR,
    License = PetyaX._LICENSE,
    Features = {
        "FPS Aimbot System",
        "Advanced ESP",
        "Memory Management", 
        "FPS Crosshair",
        "Entity Utilities",
        "Camera Controls",
        "Drawing API"
    }
}

-- Initialize message
print("✅ PetyaX Premium " .. PetyaX._VERSION .. " loaded successfully!")
print("🎯 Now featuring FPS Aimbot with sensitivity controls!")

return PetyaX
