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
    Sensitivity = 50,
    Smoothing = 0.3,
    AimPart = "Head",
    Prediction = false,
    Hotkey = "MouseButton2",
    
    _target = nil,
    _connection = nil,
    _isAiming = false,
    _hotkeyConnection = nil,
    _hotkeyRelease = nil
}

function PetyaXAimbot:Setup(config)
    print("🎯 Configuring Aimbot...")
    
    if config.Enabled ~= nil then self.Enabled = config.Enabled end
    if config.TeamCheck ~= nil then self.TeamCheck = config.TeamCheck end
    if config.VisibilityCheck ~= nil then self.VisibilityCheck = config.VisibilityCheck end
    if config.Target then self.AimPart = config.Target end
    if config.Sensitivity then self.Sensitivity = config.Sensitivity end
    if config.Smoothing then self.Smoothing = config.Smoothing end
    if config.Prediction ~= nil then self.Prediction = config.Prediction end
    if config.Hotkey then self.Hotkey = config.Hotkey end
    
    if config.FOV then
        if type(config.FOV) == "table" then
            if config.FOV.Size then self.FOV = config.FOV.Size end
            if config.FOV.Enabled ~= nil then self.ShowFOV = config.FOV.Enabled end
        else
            self.FOV = config.FOV
        end
    end
    
    self:SetupHotkey()
    
    if self.Enabled then
        self:Start()
    else
        self:Stop()
    end
    
    return "Aimbot configured - Sens: " .. self.Sensitivity .. ", FOV: " .. self.FOV
end

function PetyaXAimbot:SetupHotkey()
    if self._hotkeyConnection then
        self._hotkeyConnection:Disconnect()
    end
    
    self._hotkeyConnection = UserInputService.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType[self.Hotkey] then
            self._isAiming = true
        end
    end)
    
    if self._hotkeyRelease then
        self._hotkeyRelease:Disconnect()
    end
    
    self._hotkeyRelease = UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType[self.Hotkey] then
            self._isAiming = false
            self._target = nil
        end
    end)
end

function PetyaXAimbot:GetClosestPlayerToCursor()
    local closestPlayer = nil
    local closestDistance = self.FOV
    
    for _, player in pairs(Players:GetPlayers()) do
        if player == LocalPlayer then goto continue end
        if not player.Character then goto continue end
        
        local character = player.Character
        local humanoid = character:FindFirstChildOfClass("Humanoid")
        if not humanoid or humanoid.Health <= 0 then goto continue end
        
        if self.TeamCheck and player.Team and LocalPlayer.Team and player.Team == LocalPlayer.Team then
            goto continue
        end
        
        local aimPart = character:FindFirstChild(self.AimPart) or character:FindFirstChild("HumanoidRootPart")
        if not aimPart then goto continue end
        
        local screenPoint, onScreen = CurrentCamera:WorldToViewportPoint(aimPart.Position)
        if not onScreen then goto continue end
        
        local mouseLocation = UserInputService:GetMouseLocation()
        local distance = (Vector2.new(screenPoint.X, screenPoint.Y) - mouseLocation).Magnitude
        
        if distance < closestDistance then
            closestDistance = distance
            closestPlayer = player
        end
        
        ::continue::
    end
    
    return closestPlayer
end

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
    
    local rayOrigin = localHead.Position
    local rayDirection = (targetHead.Position - rayOrigin).Unit * 1000
    local raycastResult = workspace:Raycast(rayOrigin, rayDirection, raycastParams)
    
    return not raycastResult or raycastResult.Instance:IsDescendantOf(character)
end

function PetyaXAimbot:AimbotLoop()
    if not self.Enabled or not self._isAiming then return end
    
    local target = self:GetClosestPlayerToCursor()
    
    if target and target.Character then
        local character = target.Character
        local aimPart = character:FindFirstChild(self.AimPart) or character:FindFirstChild("HumanoidRootPart")
        
        if aimPart and self:IsVisible(character) then
            self._target = target
            
            local camera = workspace.CurrentCamera
            local currentCFrame = camera.CFrame
            
            local smoothFactor = math.clamp(1 - (self.Sensitivity / 100), 0.1, 0.9) * self.Smoothing
            local direction = (aimPart.Position - currentCFrame.Position).Unit
            local currentDirection = currentCFrame.LookVector
            local smoothedDirection = currentDirection:Lerp(direction, smoothFactor)
            
            camera.CFrame = CFrame.lookAt(currentCFrame.Position, currentCFrame.Position + smoothedDirection)
        end
    else
        self._target = nil
    end
end

function PetyaXAimbot:Start()
    if self._connection then return end
    
    self._connection = RunService.RenderStepped:Connect(function()
        self:AimbotLoop()
    end)
    
    print("🎯 Aimbot ACTIVATED")
end

function PetyaXAimbot:Stop()
    if self._connection then
        self._connection:Disconnect()
        self._connection = nil
    end
    self._target = nil
    self._isAiming = false
    print("🎯 Aimbot DEACTIVATED")
end

function PetyaXAimbot:Enable()
    self.Enabled = true
    self:Start()
    return "Aimbot enabled"
end

function PetyaXAimbot:Disable()
    self.Enabled = false
    self:Stop()
    return "Aimbot disabled"
end

function PetyaXAimbot:Destroy()
    self:Stop()
    if self._hotkeyConnection then
        self._hotkeyConnection:Disconnect()
    end
    if self._hotkeyRelease then
        self._hotkeyRelease:Disconnect()
    end
end

return PetyaXAimbot
