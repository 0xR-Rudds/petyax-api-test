-- PetyaX Aimbot - Complete Working Version
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local CurrentCamera = workspace.CurrentCamera

local PetyaXAimbot = {
    Enabled = false,
    TeamCheck = true,
    VisibilityCheck = true,
    FOV = 100,
    Smoothness = 0.2,
    Prediction = true,
    AimPart = "Head",
    PredictionStrength = 0.165,
    Hotkey = "MouseButton2",
    
    ShowFOV = false,
    FOVColor = Color3.new(1, 0, 0),
    
    _target = nil,
    _connection = nil,
    _fovCircle = nil,
    _hotkeyConnection = nil
}

-- Setup function
function PetyaXAimbot:Setup(config)
    if config.Enabled ~= nil then self.Enabled = config.Enabled end
    if config.Target then self.AimPart = config.Target end
    if config.Sensitivity then 
        self.Smoothness = 1 - config.Sensitivity
    end
    if config.Hotkey then self.Hotkey = config.Hotkey end
    if config.FOV then
        if config.FOV.Size then self.FOV = config.FOV.Size end
        if config.FOV.Color then self.FOVColor = config.FOV.Color end
        if config.FOV.Enabled ~= nil then self.ShowFOV = config.FOV.Enabled end
    end
    
    if self.ShowFOV and not self._fovCircle then
        self:CreateFOVCircle()
    end
    
    self:SetupHotkey()
    
    if self.Enabled then
        self:Start()
    else
        self:Stop()
    end
    
    return "Aimbot configured successfully"
end

-- Create FOV circle
function PetyaXAimbot:CreateFOVCircle()
    if self._fovCircle then
        self._fovCircle:Remove()
    end
    
    local circle = Drawing.new("Circle")
    circle.Visible = self.ShowFOV
    circle.Radius = self.FOV
    circle.Color = self.FOVColor
    circle.Thickness = 2
    circle.Position = Vector2.new(CurrentCamera.ViewportSize.X / 2, CurrentCamera.ViewportSize.Y / 2)
    circle.Filled = false
    circle.Transparency = 1
    
    self._fovCircle = circle
    
    if not self._fovUpdate then
        self._fovUpdate = RunService.RenderStepped:Connect(function()
            if self._fovCircle then
                self._fovCircle.Position = Vector2.new(CurrentCamera.ViewportSize.X / 2, CurrentCamera.ViewportSize.Y / 2)
                self._fovCircle.Radius = self.FOV
                self._fovCircle.Visible = self.ShowFOV
            end
        end)
    end
end

-- Setup hotkey
function PetyaXAimbot:SetupHotkey()
    if self._hotkeyConnection then
        self._hotkeyConnection:Disconnect()
    end
    
    self._hotkeyConnection = UserInputService.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType[self.Hotkey] then
            self.Enabled = not self.Enabled
            if self.Enabled then
                self:Start()
            else
                self:Stop()
            end
        end
    end)
end

-- Get closest player to cursor
function PetyaXAimbot:GetClosestPlayerToCursor()
    local closestPlayer = nil
    local closestDistance = self.FOV
    
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local character = player.Character
            local humanoid = character:FindFirstChildOfClass("Humanoid")
            
            if humanoid and humanoid.Health > 0 then
                if self.TeamCheck and player.Team == LocalPlayer.Team then
                    continue
                end
                
                if self.VisibilityCheck and not self:IsVisible(character) then
                    continue
                end
                
                local aimPart = character:FindFirstChild(self.AimPart) or character:FindFirstChild("HumanoidRootPart")
                if aimPart then
                    local screenPoint, onScreen = CurrentCamera:WorldToViewportPoint(aimPart.Position)
                    
                    if onScreen then
                        local mouseLocation = UserInputService:GetMouseLocation()
                        local distance = (Vector2.new(screenPoint.X, screenPoint.Y) - mouseLocation).Magnitude
                        
                        if distance < closestDistance then
                            closestDistance = distance
                            closestPlayer = player
                        end
                    end
                end
            end
        end
    end
    
    return closestPlayer
end

-- Visibility check
function PetyaXAimbot:IsVisible(character)
    if not self.VisibilityCheck then return true end
    
    local localCharacter = LocalPlayer.Character
    if not localCharacter then return false end
    
    local localHead = localCharacter:FindFirstChild("Head")
    local targetHead = character:FindFirstChild("Head")
    
    if not localHead or not targetHead then return false end
    
    local raycastParams = RaycastParams.new()
    raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
    raycastParams.FilterDescendantsInstances = {localCharacter, character}
    
    local raycastResult = workspace:Raycast(localHead.Position, (targetHead.Position - localHead.Position).Unit * 1000, raycastParams)
    
    return not raycastResult or raycastResult.Instance:IsDescendantOf(character)
end

-- Calculate prediction
function PetyaXAimbot:CalculatePrediction(character, part)
    if not self.Prediction then return part.Position end
    
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    if not rootPart then return part.Position end
    
    local velocity = rootPart.Velocity
    return part.Position + (velocity * self.PredictionStrength * 0.1)
end

-- Smooth aim function
function PetyaXAimbot:SmoothAim(targetPosition)
    local camera = workspace.CurrentCamera
    local cameraFocus = camera.Focus.Position
    
    local direction = (targetPosition - cameraFocus).Unit
    local currentDirection = camera.CFrame.LookVector
    
    local smoothedDirection = currentDirection:Lerp(direction, self.Smoothness)
    
    camera.CFrame = CFrame.lookAt(cameraFocus, cameraFocus + smoothedDirection)
end

-- Main aimbot loop
function PetyaXAimbot:AimbotLoop()
    if not self.Enabled then return end
    
    self._target = self:GetClosestPlayerToCursor()
    
    if self._target and self._target.Character then
        local character = self._target.Character
        local aimPart = character:FindFirstChild(self.AimPart) or character:FindFirstChild("HumanoidRootPart")
        
        if aimPart then
            local targetPosition = self:CalculatePrediction(character, aimPart)
            self:SmoothAim(targetPosition)
        end
    end
end

-- Start aimbot
function PetyaXAimbot:Start()
    if self._connection then return end
    
    self._connection = RunService.RenderStepped:Connect(function()
        self:AimbotLoop()
    end)
    
    print("🎯 Aimbot ACTIVATED")
end

-- Stop aimbot
function PetyaXAimbot:Stop()
    if self._connection then
        self._connection:Disconnect()
        self._connection = nil
    end
    self._target = nil
    print("🎯 Aimbot DEACTIVATED")
end

-- Enable/Disable
function PetyaXAimbot:Enable()
    self.Enabled = true
    self:Start()
end

function PetyaXAimbot:Disable()
    self.Enabled = false
    self:Stop()
end

-- Cleanup
function PetyaXAimbot:Destroy()
    self:Stop()
    if self._fovCircle then
        self._fovCircle:Remove()
        self._fovCircle = nil
    end
    if self._fovUpdate then
        self._fovUpdate:Disconnect()
        self._fovUpdate = nil
    end
    if self._hotkeyConnection then
        self._hotkeyConnection:Disconnect()
        self._hotkeyConnection = nil
    end
end

return PetyaXAimbot
