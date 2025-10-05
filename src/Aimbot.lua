-- PetyaX Aimbot.lua - Complete Working Version
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local CurrentCamera = workspace.CurrentCamera

local PetyaXAimbot = {
    -- Core Settings
    Enabled = false,
    TeamCheck = true,
    VisibilityCheck = true,
    
    -- Targeting
    AimPart = "Head",
    
    -- Sensitivity & Smoothing
    Sensitivity = 50,
    Smoothing = 0.3,
    
    -- FOV
    FOV = 100,
    ShowFOV = false,
    
    -- Activation
    Hotkey = "MouseButton2",
    
    -- Internal
    _target = nil,
    _connection = nil,
    _isAiming = false
}

-- Setup function
function PetyaXAimbot:Setup(config)
    print("🔧 Configuring Aimbot...")
    
    if config.Enabled ~= nil then self.Enabled = config.Enabled end
    if config.Target then self.AimPart = config.Target end
    if config.Sensitivity then self.Sensitivity = config.Sensitivity end
    if config.Smoothing then self.Smoothing = config.Smoothing end
    if config.FOV then self.FOV = config.FOV end
    if config.Hotkey then self.Hotkey = config.Hotkey end
    
    if config.FOV and config.FOV.Enabled ~= nil then 
        self.ShowFOV = config.FOV.Enabled 
    end
    
    self:SetupHotkey()
    
    if self.Enabled then
        self:Start()
    else
        self:Stop()
    end
    
    return "Aimbot configured successfully"
end

-- Hotkey setup
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
        end
    end)
end

-- Get closest player to cursor
function PetyaXAimbot:GetClosestPlayerToCursor()
    local closestPlayer = nil
    local closestDistance = self.FOV
    
    for _, player in pairs(Players:GetPlayers()) do
        if player == LocalPlayer then goto continue end
        if not player.Character then goto continue end
        
        local character = player.Character
        local humanoid = character:FindFirstChildOfClass("Humanoid")
        if not humanoid or humanoid.Health <= 0 then goto continue end
        
        -- Team check
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

-- Visibility check
function PetyaXAimbot:IsPartVisible(part)
    if not self.VisibilityCheck then return true end
    
    local localCharacter = LocalPlayer.Character
    if not localCharacter then return false end
    
    local localHead = localCharacter:FindFirstChild("Head")
    if not localHead then return false end
    
    local raycastParams = RaycastParams.new()
    raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
    raycastParams.FilterDescendantsInstances = {localCharacter, part.Parent}
    
    local rayOrigin = localHead.Position
    local rayDirection = (part.Position - rayOrigin).Unit * 1000
    local raycastResult = workspace:Raycast(rayOrigin, rayDirection, raycastParams)
    
    return not raycastResult or raycastResult.Instance:IsDescendantOf(part.Parent)
end

-- Smooth aim function
function PetyaXAimbot:SmoothAim(targetPosition)
    local camera = workspace.CurrentCamera
    local currentCFrame = camera.CFrame
    
    local direction = (targetPosition - currentCFrame.Position).Unit
    local currentDirection = currentCFrame.LookVector
    
    local smoothFactor = math.clamp(1 - (self.Sensitivity / 100), 0.1, 0.9) * self.Smoothing
    local smoothedDirection = currentDirection:Lerp(direction, smoothFactor)
    
    camera.CFrame = CFrame.lookAt(currentCFrame.Position, currentCFrame.Position + smoothedDirection)
end

-- Main aimbot loop
function PetyaXAimbot:AimbotLoop()
    if not self.Enabled or not self._isAiming then return end
    
    local target = self:GetClosestPlayerToCursor()
    
    if target and target.Character then
        local character = target.Character
        local aimPart = character:FindFirstChild(self.AimPart) or character:FindFirstChild("HumanoidRootPart")
        
        if aimPart and self:IsPartVisible(aimPart) then
            self:SmoothAim(aimPart.Position)
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
    if self._hotkeyConnection then
        self._hotkeyConnection:Disconnect()
    end
    if self._hotkeyRelease then
        self._hotkeyRelease:Disconnect()
    end
end

print("✅ Aimbot module loaded")
return PetyaXAimbot
