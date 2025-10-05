-- PetyaX ESP Module 2025 - Modern & Professional
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local CurrentCamera = workspace.CurrentCamera

local PetyaXESP = {
    Enabled = false,
    _objects = {},
    _connections = {},
    _cache = {},
    
    -- Modern 2025 Configuration
    Config = {
        Boxes = {
            Enabled = true,
            Color = Color3.new(1, 0, 0),
            Thickness = 2,
            Filled = false,
            Transparency = 1
        },
        Tracers = {
            Enabled = true,
            Color = Color3.new(0, 1, 0),
            Thickness = 1,
            Origin = "Bottom" -- Bottom, Middle, Top
        },
        Names = {
            Enabled = true,
            Color = Color3.new(1, 1, 1),
            Size = 16,
            Outline = true,
            ShowDistance = true,
            ShowHealth = true
        },
        HealthBar = {
            Enabled = true,
            Width = 3,
            Background = Color3.new(0, 0, 0),
            LowHealth = Color3.new(1, 0, 0),
            HighHealth = Color3.new(0, 1, 0)
        },
        Weapon = {
            Enabled = true,
            Color = Color3.new(1, 1, 0),
            Size = 14,
            Outline = true
        },
        Chams = {
            Enabled = false,
            Color = Color3.new(1, 0, 0),
            Transparency = 0.5,
            Thickness = 1
        },
        Outlines = {
            Enabled = true,
            Color = Color3.new(1, 1, 1),
            Thickness = 1
        },
        Glow = {
            Enabled = false,
            Color = Color3.new(1, 0.5, 0),
            Intensity = 5
        }
    }
}

-- Modern color interpolation for health bars
function PetyaXESP:LerpColor(t, color1, color2)
    return Color3.new(
        color1.R + (color2.R - color1.R) * t,
        color1.G + (color2.G - color1.G) * t,
        color1.B + (color2.B - color1.B) * t
    )
end

-- Advanced box calculation with improved accuracy
function PetyaXESP:CalculateBoundingBox(character)
    if not character then return nil end
    
    local parts = {
        "Head", "Torso", "Left Arm", "Right Arm", "Left Leg", "Right Leg", "HumanoidRootPart"
    }
    
    local minX, minY, maxX, maxY = math.huge, math.huge, -math.huge, -math.huge
    local foundParts = 0
    
    for _, partName in pairs(parts) do
        local part = character:FindFirstChild(partName)
        if part and part:IsA("BasePart") then
            local screenPos, onScreen = CurrentCamera:WorldToViewportPoint(part.Position)
            if onScreen then
                local size = part.Size
                local scale = CurrentCamera.ViewportSize.X / (2 * math.tan(math.rad(CurrentCamera.FieldOfView / 2)))
                local screenSize = (size.Magnitude * scale) / (part.Position - CurrentCamera.CFrame.Position).Magnitude
                
                local x1 = screenPos.X - screenSize
                local y1 = screenPos.Y - screenSize
                local x2 = screenPos.X + screenSize
                local y2 = screenPos.Y + screenSize
                
                minX = math.min(minX, x1)
                minY = math.min(minY, y1)
                maxX = math.max(maxX, x2)
                maxY = math.max(maxY, y2)
                foundParts = foundParts + 1
            end
        end
    end
    
    if foundParts == 0 then return nil end
    
    return {
        Position = Vector2.new(minX, minY),
        Size = Vector2.new(maxX - minX, maxY - minY),
        Center = Vector2.new((minX + maxX) / 2, (minY + maxY) / 2)
    }
end

-- Modern player iteration with caching
function PetyaXESP:GetValidPlayers()
    local validPlayers = {}
    
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
            if humanoid and humanoid.Health > 0 then
                validPlayers[player] = {
                    Character = player.Character,
                    Humanoid = humanoid,
                    Team = player.Team
                }
            end
        end
    end
    
    return validPlayers
end

-- Advanced ESP object creation
function PetyaXESP:CreateESPObject(player)
    if self._objects[player] then return end
    
    local espObject = {
        Box = nil,
        Tracer = nil,
        Name = nil,
        HealthBar = nil,
        Weapon = nil,
        HealthBarBackground = nil,
        Outline = nil
    }
    
    -- Modern Box with outline
    if self.Config.Boxes.Enabled then
        espObject.Box = Drawing.new("Square")
        espObject.Box.Visible = false
        espObject.Box.Color = self.Config.Boxes.Color
        espObject.Box.Thickness = self.Config.Boxes.Thickness
        espObject.Box.Filled = self.Config.Boxes.Filled
        espObject.Box.Transparency = self.Config.Boxes.Transparency
        
        -- Box outline for better visibility
        if self.Config.Outlines.Enabled then
            espObject.Outline = Drawing.new("Square")
            espObject.Outline.Visible = false
            espObject.Outline.Color = self.Config.Outlines.Color
            espObject.Outline.Thickness = self.Config.Outlines.Thickness + 2
            espObject.Outline.Filled = false
            espObject.Outline.Transparency = 1
        end
    end
    
    -- Modern Tracer
    if self.Config.Tracers.Enabled then
        espObject.Tracer = Drawing.new("Line")
        espObject.Tracer.Visible = false
        espObject.Tracer.Color = self.Config.Tracers.Color
        espObject.Tracer.Thickness = self.Config.Tracers.Thickness
    end
    
    -- Advanced Name with distance and health
    if self.Config.Names.Enabled then
        espObject.Name = Drawing.new("Text")
        espObject.Name.Visible = false
        espObject.Name.Color = self.Config.Names.Color
        espObject.Name.Size = self.Config.Names.Size
        espObject.Name.Outline = self.Config.Names.Outline
        espObject.Name.Center = true
        espObject.Name.Font = 2 -- Bold font
    end
    
    -- Modern Health Bar with gradient
    if self.Config.HealthBar.Enabled then
        espObject.HealthBarBackground = Drawing.new("Square")
        espObject.HealthBarBackground.Visible = false
        espObject.HealthBarBackground.Color = self.Config.HealthBar.Background
        espObject.HealthBarBackground.Filled = true
        espObject.HealthBarBackground.Transparency = 0.5
        
        espObject.HealthBar = Drawing.new("Square")
        espObject.HealthBar.Visible = false
        espObject.HealthBar.Filled = true
        espObject.HealthBar.Transparency = 1
    end
    
    -- Weapon display
    if self.Config.Weapon.Enabled then
        espObject.Weapon = Drawing.new("Text")
        espObject.Weapon.Visible = false
        espObject.Weapon.Color = self.Config.Weapon.Color
        espObject.Weapon.Size = self.Config.Weapon.Size
        espObject.Weapon.Outline = self.Config.Weapon.Outline
        espObject.Weapon.Center = true
        espObject.Weapon.Font = 2
    end
    
    self._objects[player] = espObject
end

-- Modern ESP update with performance optimization
function PetyaXESP:UpdateESP()
    if not self.Enabled then return end
    
    local localPlayer = LocalPlayer
    local localCharacter = localPlayer.Character
    local localRoot = localCharacter and localCharacter:FindFirstChild("HumanoidRootPart")
    
    for player, data in pairs(self:GetValidPlayers()) do
        if not self._objects[player] then
            self:CreateESPObject(player)
        end
        
        local espObject = self._objects[player]
        local character = data.Character
        local humanoid = data.Humanoid
        
        if character and humanoid then
            local boundingBox = self:CalculateBoundingBox(character)
            
            if boundingBox then
                -- Update Box
                if espObject.Box then
                    espObject.Box.Position = boundingBox.Position
                    espObject.Box.Size = boundingBox.Size
                    espObject.Box.Visible = true
                    
                    -- Update outline
                    if espObject.Outline then
                        espObject.Outline.Position = boundingBox.Position - Vector2.new(2, 2)
                        espObject.Outline.Size = boundingBox.Size + Vector2.new(4, 4)
                        espObject.Outline.Visible = true
                    end
                end
                
                -- Update Tracer with modern origin points
                if espObject.Tracer then
                    local originY
                    if self.Config.Tracers.Origin == "Top" then
                        originY = 0
                    elseif self.Config.Tracers.Origin == "Middle" then
                        originY = CurrentCamera.ViewportSize.Y / 2
                    else -- Bottom
                        originY = CurrentCamera.ViewportSize.Y
                    end
                    
                    espObject.Tracer.From = Vector2.new(CurrentCamera.ViewportSize.X / 2, originY)
                    espObject.Tracer.To = Vector2.new(boundingBox.Center.X, boundingBox.Position.Y + boundingBox.Size.Y)
                    espObject.Tracer.Visible = true
                end
                
                -- Update Name with advanced info
                if espObject.Name then
                    local displayText = player.Name
                    
                    if self.Config.Names.ShowDistance and localRoot then
                        local rootPart = character:FindFirstChild("HumanoidRootPart")
                        if rootPart then
                            local distance = (localRoot.Position - rootPart.Position).Magnitude
                            displayText = displayText .. " [" .. math.floor(distance) .. "m]"
                        end
                    end
                    
                    if self.Config.Names.ShowHealth then
                        displayText = displayText .. " [" .. math.floor(humanoid.Health) .. " HP]"
                    end
                    
                    espObject.Name.Text = displayText
                    espObject.Name.Position = Vector2.new(boundingBox.Center.X, boundingBox.Position.Y - 20)
                    espObject.Name.Visible = true
                end
                
                -- Update Health Bar with gradient
                if espObject.HealthBar and espObject.HealthBarBackground then
                    local healthPercent = humanoid.Health / humanoid.MaxHealth
                    local healthBarHeight = boundingBox.Size.Y * healthPercent
                    local healthColor = self:LerpColor(healthPercent, self.Config.HealthBar.LowHealth, self.Config.HealthBar.HighHealth)
                    
                    espObject.HealthBarBackground.Position = Vector2.new(
                        boundingBox.Position.X - self.Config.HealthBar.Width - 2, 
                        boundingBox.Position.Y
                    )
                    espObject.HealthBarBackground.Size = Vector2.new(
                        self.Config.HealthBar.Width, 
                        boundingBox.Size.Y
                    )
                    espObject.HealthBarBackground.Visible = true
                    
                    espObject.HealthBar.Position = Vector2.new(
                        boundingBox.Position.X - self.Config.HealthBar.Width - 2,
                        boundingBox.Position.Y + (boundingBox.Size.Y - healthBarHeight)
                    )
                    espObject.HealthBar.Size = Vector2.new(self.Config.HealthBar.Width, healthBarHeight)
                    espObject.HealthBar.Color = healthColor
                    espObject.HealthBar.Visible = true
                end
                
                -- Update Weapon display
                if espObject.Weapon then
                    local tool = character:FindFirstChildOfClass("Tool")
                    local weaponName = tool and tool.Name or "Fists"
                    
                    espObject.Weapon.Text = weaponName
                    espObject.Weapon.Position = Vector2.new(boundingBox.Center.X, boundingBox.Position.Y + boundingBox.Size.Y + 5)
                    espObject.Weapon.Visible = true
                end
            else
                -- Hide all if not on screen
                for _, drawing in pairs(espObject) do
                    if drawing and typeof(drawing) == "table" and drawing.Visible ~= nil then
                        drawing.Visible = false
                    end
                end
            end
        else
            -- Hide all if player is invalid
            for _, drawing in pairs(espObject) do
                if drawing and typeof(drawing) == "table" and drawing.Visible ~= nil then
                    drawing.Visible = false
                end
            end
        end
    end
    
    -- Clean up players that left
    for player, espObject in pairs(self._objects) do
        if not Players:FindFirstChild(player.Name) then
            self:RemoveESPObject(player)
        end
    end
end

-- Clean removal of ESP objects
function PetyaXESP:RemoveESPObject(player)
    local espObject = self._objects[player]
    if espObject then
        for _, drawing in pairs(espObject) do
            if drawing and typeof(drawing) == "table" then
                drawing:Remove()
            end
        end
        self._objects[player] = nil
    end
end

-- Modern ESP control functions
function PetyaXESP:Enable()
    if self.Enabled then return end
    
    self.Enabled = true
    
    -- Start update loop
    self._connections.update = RunService.RenderStepped:Connect(function()
        self:UpdateESP()
    end)
    
    -- Player tracking
    self._connections.playerAdded = Players.PlayerAdded:Connect(function(player)
        task.wait(2)
        self:CreateESPObject(player)
    end)
    
    self._connections.playerRemoving = Players.PlayerRemoving:Connect(function(player)
        self:RemoveESPObject(player)
    end)
    
    -- Initialize existing players
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            self:CreateESPObject(player)
        end
    end
    
    print("🎯 Modern ESP 2025: ENABLED")
end

function PetyaXESP:Disable()
    if not self.Enabled then return end
    
    self.Enabled = false
    
    -- Disconnect all connections
    for _, connection in pairs(self._connections) do
        connection:Disconnect()
    end
    self._connections = {}
    
    -- Remove all drawings
    for player, espObject in pairs(self._objects) do
        self:RemoveESPObject(player)
    end
    self._objects = {}
    
    print("🎯 Modern ESP 2025: DISABLED")
end

-- Configuration setup
function PetyaXESP:Setup(config)
    if config then
        for category, settings in pairs(config) do
            if self.Config[category] then
                for key, value in pairs(settings) do
                    if self.Config[category][key] ~= nil then
                        self.Config[category][key] = value
                    end
                end
            end
        end
    end
    
    local results = {
        "🎯 Modern ESP 2025 Configuration:",
        "• Boxes: " .. (self.Config.Boxes.Enabled and "ENABLED" or "DISABLED"),
        "• Tracers: " .. (self.Config.Tracers.Enabled and "ENABLED" or "DISABLED"),
        "• Names: " .. (self.Config.Names.Enabled and "ENABLED" or "DISABLED"),
        "• Health Bars: " .. (self.Config.HealthBar.Enabled and "ENABLED" or "DISABLED"),
        "• Weapon Display: " .. (self.Config.Weapon.Enabled and "ENABLED" or "DISABLED"),
        "• Outlines: " .. (self.Config.Outlines.Enabled and "ENABLED" or "DISABLED")
    }
    
    return results
end

-- Cleanup
function PetyaXESP:Destroy()
    self:Disable()
end

return PetyaXESP
