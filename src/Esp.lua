local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local CurrentCamera = workspace.CurrentCamera

local PetyaXESP = {
    Enabled = false,
    Boxes = true,
    Tracers = true,
    Names = true,
    TeamCheck = true,
    
    _drawings = {},
    _connections = {}
}

function PetyaXESP:Setup(config)
    print("🔮 Configuring ESP...")
    
    if config.Boxes ~= nil then self.Boxes = config.Boxes.Enabled end
    if config.Tracers ~= nil then self.Tracers = config.Tracers.Enabled end
    if config.Names ~= nil then self.Names = config.Names.Enabled end
    if config.TeamCheck ~= nil then self.TeamCheck = config.TeamCheck end
    
    if self.Enabled then
        self:Disable()
        self:Enable()
    end
    
    return "ESP configured - Boxes: " .. tostring(self.Boxes) .. ", Tracers: " .. tostring(self.Tracers)
end

function PetyaXESP:CreateESP(player)
    if self._drawings[player] then return end
    
    local drawings = {
        Box = Drawing.new("Square"),
        Tracer = Drawing.new("Line"),
        Name = Drawing.new("Text")
    }
    
    drawings.Box.Thickness = 2
    drawings.Box.Filled = false
    drawings.Box.Visible = false
    
    drawings.Tracer.Thickness = 1
    drawings.Tracer.Visible = false
    
    drawings.Name.Size = 16
    drawings.Name.Outline = true
    drawings.Name.Center = true
    drawings.Name.Visible = false
    
    self._drawings[player] = drawings
end

function PetyaXESP:RemoveESP(player)
    local drawings = self._drawings[player]
    if drawings then
        for _, drawing in pairs(drawings) do
            drawing:Remove()
        end
        self._drawings[player] = nil
    end
end

function PetyaXESP:UpdateESP()
    if not self.Enabled then return end
    
    local localPlayer = LocalPlayer
    
    for player, drawings in pairs(self._drawings) do
        local character = player.Character
        local humanoid = character and character:FindFirstChildOfClass("Humanoid")
        local rootPart = character and character:FindFirstChild("HumanoidRootPart")
        
        if character and humanoid and humanoid.Health > 0 and rootPart then
            local isTeammate = self.TeamCheck and player.Team and localPlayer.Team and player.Team == localPlayer.Team
            local color = isTeammate and Color3.new(0, 1, 0) or Color3.new(1, 0, 0)
            
            local screenPosition, onScreen = CurrentCamera:WorldToViewportPoint(rootPart.Position)
            
            if onScreen then
                local boxSize = Vector2.new(40, 60)
                local boxPosition = Vector2.new(screenPosition.X - boxSize.X / 2, screenPosition.Y - boxSize.Y / 2)
                
                if self.Boxes then
                    drawings.Box.Size = boxSize
                    drawings.Box.Position = boxPosition
                    drawings.Box.Color = color
                    drawings.Box.Visible = true
                else
                    drawings.Box.Visible = false
                end
                
                if self.Tracers then
                    drawings.Tracer.From = Vector2.new(CurrentCamera.ViewportSize.X / 2, CurrentCamera.ViewportSize.Y)
                    drawings.Tracer.To = Vector2.new(screenPosition.X, screenPosition.Y)
                    drawings.Tracer.Color = color
                    drawings.Tracer.Visible = true
                else
                    drawings.Tracer.Visible = false
                end
                
                if self.Names then
                    drawings.Name.Text = player.Name
                    drawings.Name.Position = Vector2.new(screenPosition.X, boxPosition.Y - 20)
                    drawings.Name.Color = color
                    drawings.Name.Visible = true
                else
                    drawings.Name.Visible = false
                end
            else
                drawings.Box.Visible = false
                drawings.Tracer.Visible = false
                drawings.Name.Visible = false
            end
        else
            drawings.Box.Visible = false
            drawings.Tracer.Visible = false
            drawings.Name.Visible = false
        end
    end
end

function PetyaXESP:Enable()
    if self.Enabled then return end
    
    self.Enabled = true
    
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            self:CreateESP(player)
        end
    end
    
    self._connections.playerAdded = Players.PlayerAdded:Connect(function(player)
        task.wait(1)
        self:CreateESP(player)
    end)
    
    self._connections.playerRemoving = Players.PlayerRemoving:Connect(function(player)
        self:RemoveESP(player)
    end)
    
    self._connections.update = RunService.RenderStepped:Connect(function()
        self:UpdateESP()
    end)
    
    print("🔮 ESP ENABLED")
    return "ESP enabled"
end

function PetyaXESP:Disable()
    if not self.Enabled then return end
    
    self.Enabled = false
    
    for _, connection in pairs(self._connections) do
        connection:Disconnect()
    end
    self._connections = {}
    
    for player in pairs(self._drawings) do
        self:RemoveESP(player)
    end
    
    print("🔮 ESP DISABLED")
    return "ESP disabled"
end

function PetyaXESP:Destroy()
    self:Disable()
end

return PetyaXESP
