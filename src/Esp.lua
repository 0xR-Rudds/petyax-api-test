-- PetyaX ESP - Complete Working Version (Based on AirHub)
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer
local CurrentCamera = Workspace.CurrentCamera

local PetyaXESP = {
    Enabled = false,
    
    -- Configuration
    Boxes = true,
    Tracers = true,
    Names = true,
    HealthBars = true,
    Distance = true,
    TeamCheck = true,
    
    -- Colors
    TeamColor = Color3.fromRGB(0, 255, 0),
    EnemyColor = Color3.fromRGB(255, 0, 0),
    
    -- Internal
    _drawings = {},
    _connections = {}
}

-- Create ESP for player
function PetyaXESP:CreateESP(player)
    if self._drawings[player] then return end
    
    local drawings = {
        Box = Drawing.new("Square"),
        Tracer = Drawing.new("Line"),
        Name = Drawing.new("Text"),
        HealthBar = Drawing.new("Square"),
        HealthBarBackground = Drawing.new("Square"),
        HealthText = Drawing.new("Text"),
        DistanceText = Drawing.new("Text")
    }
    
    -- Box
    drawings.Box.Thickness = 2
    drawings.Box.Filled = false
    drawings.Box.Visible = false
    
    -- Tracer
    drawings.Tracer.Thickness = 1
    drawings.Tracer.Visible = false
    
    -- Name
    drawings.Name.Size = 16
    drawings.Name.Outline = true
    drawings.Name.Center = true
    drawings.Name.Visible = false
    
    -- Health Bar
    drawings.HealthBar.Thickness = 1
    drawings.HealthBar.Filled = true
    drawings.HealthBar.Visible = false
    
    drawings.HealthBarBackground.Thickness = 1
    drawings.HealthBarBackground.Filled = true
    drawings.HealthBarBackground.Color = Color3.new(0, 0, 0)
    drawings.HealthBarBackground.Visible = false
    
    -- Health Text
    drawings.HealthText.Size = 14
    drawings.HealthText.Outline = true
    drawings.HealthText.Visible = false
    
    -- Distance Text
    drawings.DistanceText.Size = 14
    drawings.DistanceText.Outline = true
    drawings.DistanceText.Visible = false
    
    self._drawings[player] = drawings
end

-- Remove ESP for player
function PetyaXESP:RemoveESP(player)
    local drawings = self._drawings[player]
    if drawings then
        for _, drawing in pairs(drawings) do
            drawing:Remove()
        end
        self._drawings[player] = nil
    end
end

-- Update ESP
function PetyaXESP:UpdateESP()
    if not self.Enabled then return end
    
    local localPlayer = LocalPlayer
    local localCharacter = localPlayer.Character
    local localRoot = localCharacter and localCharacter:FindFirstChild("HumanoidRootPart")
    
    for player, drawings in pairs(self._drawings) do
        local character = player.Character
        local humanoid = character and character:FindFirstChildOfClass("Humanoid")
        local rootPart = character and character:FindFirstChild("HumanoidRootPart")
        
        if character and humanoid and humanoid.Health > 0 and rootPart then
            -- Team check
            local isTeammate = self.TeamCheck and player.Team == localPlayer.Team
            local color = isTeammate and self.TeamColor or self.EnemyColor
            
            -- Get screen position
            local screenPosition, onScreen = CurrentCamera:WorldToViewportPoint(rootPart.Position)
            
            if onScreen then
                -- Calculate box dimensions
                local boxSize = Vector2.new(50, 80)
                local boxPosition = Vector2.new(screenPosition.X - boxSize.X / 2, screenPosition.Y - boxSize.Y / 2)
                
                -- Update Box
                if self.Boxes then
                    drawings.Box.Size = boxSize
                    drawings.Box.Position = boxPosition
                    drawings.Box.Color = color
                    drawings.Box.Visible = true
                else
                    drawings.Box.Visible = false
                end
                
                -- Update Tracer
                if self.Tracers then
                    drawings.Tracer.From = Vector2.new(CurrentCamera.ViewportSize.X / 2, CurrentCamera.ViewportSize.Y)
                    drawings.Tracer.To = Vector2.new(screenPosition.X, screenPosition.Y)
                    drawings.Tracer.Color = color
                    drawings.Tracer.Visible = true
                else
                    drawings.Tracer.Visible = false
                end
                
                -- Update Name
                if self.Names then
                    drawings.Name.Text = player.Name
                    drawings.Name.Position = Vector2.new(screenPosition.X, boxPosition.Y - 20)
                    drawings.Name.Color = color
                    drawings.Name.Visible = true
                else
                    drawings.Name.Visible = false
                end
                
                -- Update Health Bar
                if self.HealthBars then
                    local healthPercent = humanoid.Health / humanoid.MaxHealth
                    local healthBarHeight = boxSize.Y * healthPercent
                    local healthBarColor = Color3.new(1 - healthPercent, healthPercent, 0)
                    
                    drawings.HealthBarBackground.Size = Vector2.new(3, boxSize.Y)
                    drawings.HealthBarBackground.Position = boxPosition - Vector2.new(6, 0)
                    drawings.HealthBarBackground.Visible = true
                    
                    drawings.HealthBar.Size = Vector2.new(3, healthBarHeight)
                    drawings.HealthBar.Position = drawings.HealthBarBackground.Position + Vector2.new(0, boxSize.Y - healthBarHeight)
                    drawings.HealthBar.Color = healthBarColor
                    drawings.HealthBar.Visible = true
                    
                    drawings.HealthText.Text = math.floor(humanoid.Health) .. " HP"
                    drawings.HealthText.Position = drawings.HealthBarBackground.Position - Vector2.new(0, 15)
                    drawings.HealthText.Color = healthBarColor
                    drawings.HealthText.Visible = true
                else
                    drawings.HealthBar.Visible = false
                    drawings.HealthBarBackground.Visible = false
                    drawings.HealthText.Visible = false
                end
                
                -- Update Distance
                if self.Distance and localRoot then
                    local distance = (localRoot.Position - rootPart.Position).Magnitude
                    drawings.DistanceText.Text = math.floor(distance) .. "m"
                    drawings.DistanceText.Position = Vector2.new(screenPosition.X, boxPosition.Y + boxSize.Y + 5)
                    drawings.DistanceText.Color = color
                    drawings.DistanceText.Visible = true
                else
                    drawings.DistanceText.Visible = false
                end
            else
                -- Hide all if not on screen
                for _, drawing in pairs(drawings) do
                    drawing.Visible = false
                end
            end
        else
            -- Hide all if player is invalid
            for _, drawing in pairs(drawings) do
                drawing.Visible = false
            end
        end
    end
end

-- Setup function
function PetyaXESP:Setup(config)
    if config.Boxes ~= nil then self.Boxes = config.Boxes.Enabled end
    if config.Tracers ~= nil then self.Tracers = config.Tracers.Enabled end
    if config.Names ~= nil then self.Names = config.Names.Enabled end
    if config.HealthBar ~= nil then self.HealthBars = config.HealthBar.Enabled end
    if config.Tracers and config.Tracers.Color then self.TeamColor = config.Tracers.Color end
    if config.Boxes and config.Boxes.Color then self.EnemyColor = config.Boxes.Color end
    
    return {"ESP configured successfully"}
end

-- Enable ESP
function PetyaXESP:Enable()
    if self.Enabled then return end
    
    self.Enabled = true
    
    -- Create ESP for existing players
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            self:CreateESP(player)
        end
    end
    
    -- Player added
    self._connections.playerAdded = Players.PlayerAdded:Connect(function(player)
        task.wait(2)
        self:CreateESP(player)
    end)
    
    -- Player removed
    self._connections.playerRemoving = Players.PlayerRemoving:Connect(function(player)
        self:RemoveESP(player)
    end)
    
    -- Update loop
    self._connections.update = RunService.RenderStepped:Connect(function()
        self:UpdateESP()
    end)
    
    print("🎯 ESP ENABLED")
end

-- Disable ESP
function PetyaXESP:Disable()
    if not self.Enabled then return end
    
    self.Enabled = false
    
    -- Disconnect connections
    for _, connection in pairs(self._connections) do
        connection:Disconnect()
    end
    self._connections = {}
    
    -- Remove all drawings
    for player, drawings in pairs(self._drawings) do
        self:RemoveESP(player)
    end
    self._drawings = {}
    
    print("🎯 ESP DISABLED")
end

-- Cleanup
function PetyaXESP:Destroy()
    self:Disable()
end

return PetyaXESP
