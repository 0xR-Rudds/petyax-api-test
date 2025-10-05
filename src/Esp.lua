-- PetyaX ESP - Complete Fixed Version
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local CurrentCamera = workspace.CurrentCamera

local PetyaXESP = {
    Enabled = false,
    
    Boxes = true,
    Tracers = true,
    Names = true,
    HealthBars = true,
    Distance = true,
    TeamCheck = true,
    
    TeamColor = Color3.fromRGB(0, 255, 0),
    EnemyColor = Color3.fromRGB(255, 0, 0),
    
    _drawings = {},
    _connections = {}
}

-- Create ESP for player
function PetyaXESP:CreateESP(player)
    if self._drawings[player] then return end
    
    local drawings = {
        Box = Drawing.new("Square"),
        Tracer = Drawing.new("Line"),
        Name = Drawing.new("Text")
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
    
    for player, drawings in pairs(self._drawings) do
        local character = player.Character
        local humanoid = character and character:FindFirstChildOfClass("Humanoid")
        local rootPart = character and character:FindFirstChild("HumanoidRootPart")
        
        if character and humanoid and humanoid.Health > 0 and rootPart then
            local isTeammate = self.TeamCheck and player.Team and localPlayer.Team and player.Team == localPlayer.Team
            local color = isTeammate and self.TeamColor or self.EnemyColor
            
            local screenPosition, onScreen = CurrentCamera:WorldToViewportPoint(rootPart.Position)
            
            if onScreen then
                -- Simple box around player
                local boxSize = Vector2.new(40, 60)
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
            else
                -- Hide if not on screen
                drawings.Box.Visible = false
                drawings.Tracer.Visible = false
                drawings.Name.Visible = false
            end
        else
            -- Hide if invalid
            drawings.Box.Visible = false
            drawings.Tracer.Visible = false
            drawings.Name.Visible = false
        end
    end
end

-- Setup function
function PetyaXESP:Setup(config)
    print("🔧 Configuring ESP...")
    
    if config.Boxes then self.Boxes = config.Boxes.Enabled end
    if config.Tracers then self.Tracers = config.Tracers.Enabled end
    if config.Names then self.Names = config.Names.Enabled end
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
        task.wait(1)
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
    
    print("🎯 ESP enabled")
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
    for player in pairs(self._drawings) do
        self:RemoveESP(player)
    end
    
    print("🎯 ESP disabled")
end

-- Cleanup
function PetyaXESP:Destroy()
    self:Disable()
end

return PetyaXESP
