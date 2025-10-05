-- PetyaX ESP - Enemy Players Only (Fixed)
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local CurrentCamera = workspace.CurrentCamera

local PetyaXESP = {
    Enabled = false,
    
    -- ESP Components
    Boxes = true,
    Tracers = true,
    Names = true,
    HealthBars = true,
    Distance = true,
    
    -- Colors
    EnemyColor = Color3.fromRGB(255, 0, 0),
    
    -- Internal
    _drawings = {},
    _connections = {}
}

-- Create ESP for player (ENEMIES ONLY)
function PetyaXESP:CreateESP(player)
    if self._drawings[player] then return end
    
    -- Only create ESP for enemies
    if player.Team and LocalPlayer.Team and player.Team == LocalPlayer.Team then
        return
    end
    
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

-- Update ESP (ENEMIES ONLY)
function PetyaXESP:UpdateESP()
    if not self.Enabled then return end
    
    local localPlayer = LocalPlayer
    
    for player, drawings in pairs(self._drawings) do
        local character = player.Character
        local humanoid = character and character:FindFirstChildOfClass("Humanoid")
        local rootPart = character and character:FindFirstChild("HumanoidRootPart")
        
        -- Only show ESP for enemies who are alive
        if character and humanoid and humanoid.Health > 0 and rootPart then
            -- Double-check enemy status
            local isEnemy = true
            if player.Team and localPlayer.Team and player.Team == localPlayer.Team then
                isEnemy = false
            end
            
            if isEnemy then
                local screenPosition, onScreen = CurrentCamera:WorldToViewportPoint(rootPart.Position)
                
                if onScreen then
                    -- Calculate box dimensions
                    local boxSize = Vector2.new(50, 80)
                    local boxPosition = Vector2.new(screenPosition.X - boxSize.X / 2, screenPosition.Y - boxSize.Y / 2)
                    
                    -- Update Box
                    if self.Boxes then
                        drawings.Box.Size = boxSize
                        drawings.Box.Position = boxPosition
                        drawings.Box.Color = self.EnemyColor
                        drawings.Box.Visible = true
                    else
                        drawings.Box.Visible = false
                    end
                    
                    -- Update Tracer
                    if self.Tracers then
                        drawings.Tracer.From = Vector2.new(CurrentCamera.ViewportSize.X / 2, CurrentCamera.ViewportSize.Y)
                        drawings.Tracer.To = Vector2.new(screenPosition.X, screenPosition.Y)
                        drawings.Tracer.Color = self.EnemyColor
                        drawings.Tracer.Visible = true
                    else
                        drawings.Tracer.Visible = false
                    end
                    
                    -- Update Name
                    if self.Names then
                        drawings.Name.Text = player.Name
                        drawings.Name.Position = Vector2.new(screenPosition.X, boxPosition.Y - 20)
                        drawings.Name.Color = self.EnemyColor
                        drawings.Name.Visible = true
                    else
                        drawings.Name.Visible = false
                    end
                else
                    -- Hide all if not on screen
                    drawings.Box.Visible = false
                    drawings.Tracer.Visible = false
                    drawings.Name.Visible = false
                end
            else
                -- Hide if not enemy
                drawings.Box.Visible = false
                drawings.Tracer.Visible = false
                drawings.Name.Visible = false
            end
        else
            -- Hide all if player is invalid
            drawings.Box.Visible = false
            drawings.Tracer.Visible = false
            drawings.Name.Visible = false
        end
    end
end

-- Setup function (FIXED)
function PetyaXESP:Setup(config)
    if config.Boxes ~= nil then 
        if type(config.Boxes) == "table" then
            self.Boxes = config.Boxes.Enabled
        else
            self.Boxes = config.Boxes
        end
    end
    
    if config.Tracers ~= nil then 
        if type(config.Tracers) == "table" then
            self.Tracers = config.Tracers.Enabled
        else
            self.Tracers = config.Tracers
        end
    end
    
    if config.Names ~= nil then 
        if type(config.Names) == "table" then
            self.Names = config.Names.Enabled
        else
            self.Names = config.Names
        end
    end
    
    return "ESP configured - Enemy players only"
end

-- Enable ESP
function PetyaXESP:Enable()
    if self.Enabled then return end
    
    self.Enabled = true
    
    -- Create ESP for existing players (ENEMIES ONLY)
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
    
    return "ESP enabled - Enemy targeting"
end

-- Disable ESP
function PetyaXESP:Disable()
    if not self.Enabled then return end
    
    self.Enabled = false
    
    -- Disconnect connections
    for _, connection in pairs(self._connections) do
        if connection then
            connection:Disconnect()
        end
    end
    self._connections = {}
    
    -- Remove all drawings
    for player in pairs(self._drawings) do
        self:RemoveESP(player)
    end
    
    return "ESP disabled"
end

-- Cleanup
function PetyaXESP:Destroy()
    self:Disable()
end

return PetyaXESP
