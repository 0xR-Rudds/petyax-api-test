-- PetyaX FPS Aimbot - Working with Loop and FOV
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
    Prediction = true,
    Hotkey = "MouseButton2",
    MaxDistance = 500,
    ShowFOV = true,
    
    -- Internal variables
    _target = nil,
    _connection = nil,
    _fovCircle = nil,
    _isAiming = false,
    _hotkeyConnection = nil,
    _hotkeyRelease = nil
}

-- Create FOV circle
function PetyaXAimbot:CreateFOVCircle()
    if self._fovCircle then
        self._fovCircle:Remove()
    end
    
    self._fovCircle = Drawing.new("Circle")
    self._fovCircle.Visible = self.ShowFOV
    self._fovCircle.Radius = self.FOV
    self._fovCircle.Color = Color3.new(1, 0, 0)
    self._fovCircle.Thickness = 2
    self._fovCircle.Position = Vector2.new(CurrentCamera.ViewportSize.X / 2, CurrentCamera.ViewportSize.Y / 2)
    self._fovCircle.Filled = false
    self._fovCircle.Transparency = 1
    
    -- Update FOV circle position continuously
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

-- Get closest enemy to cursor
function PetyaXAimbot:GetClosestEnemy()
    local closestPlayer = nil
    local closestDistance = self.FOV
    local localTeam = LocalPlayer.Team

    for _, player in pairs(Players:GetPlayers()) do
        if player == LocalPlayer then goto continue end
        if not player.Character then goto continue end
        
        local character = player.Character
        local humanoid = character:FindFirstChildOfClass("Humanoid")
        if not humanoid or humanoid.Health <= 0 then goto continue end
        
        -- Enemy check
        if self.TeamCheck and player.Team and localTeam and player.Team == localTeam then
            goto continue
        end
        
        local aimPart = character:FindFirstChild(self.AimPart) or character:FindFirstChild("HumanoidRootPart")
        if not aimPart then goto continue end
        
        local screenPoint, onScreen = CurrentCamera:WorldToViewportPoint(aimPart.Position)
        if not onScreen then goto continue end
        
        local mousePos = UserInputService:GetMouseLocation()
        local screenDistance = (Vector2.new(screenPoint.X, screenPoint.Y) - mousePos).Magnitude
        
        if screenDistance < closestDistance then
            closestDistance = screenDistance
            closestPlayer = player
        end
        
        ::continue::
    end
    
    return closestPlayer
end

-- Main aimbot function
function PetyaXAimbot:AimAtTarget()
    if not self.Enabled or not self._isAiming then return end
    
    local target = self:GetClosestEnemy()
    
    if target and target.Character then
        local character = target.Character
        local aimPart = character:FindFirstChild(self.AimPart) or character:FindFirstChild("HumanoidRootPart")
        
        if aimPart then
            self._target = target
            
            -- Smooth aiming
            local camera = CurrentCamera
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
            self._target = nil
        end
    end)
end

-- Start aimbot loop
function PetyaXAimbot:Start()
    if self._connection then return end
    
    self._connection = RunService.RenderStepped:Connect(function()
        self:AimAtTarget()
    end)
end

-- Stop aimbot loop
function PetyaXAimbot:Stop()
    if self._connection then
        self._connection:Disconnect()
        self._connection = nil
    end
    self._target = nil
    self._isAiming = false
end

function PetyaXAimbot:Setup(config)
    if config.Enabled ~= nil then self.Enabled = config.Enabled end
    if config.TeamCheck ~= nil then self.TeamCheck = config.TeamCheck end
    if config.VisibilityCheck ~= nil then self.VisibilityCheck = config.VisibilityCheck end
    if config.Sensitivity then self.Sensitivity = config.Sensitivity end
    if config.Smoothing then self.Smoothing = config.Smoothing end
    if config.Target then self.AimPart = config.Target end
    if config.Prediction ~= nil then self.Prediction = config.Prediction end
    if config.Hotkey then self.Hotkey = config.Hotkey end
    if config.MaxDistance then self.MaxDistance = config.MaxDistance end
    if config.ShowFOV ~= nil then self.ShowFOV = config.ShowFOV end
    
    if config.FOV then
        if type(config.FOV) == "table" then
            self.FOV = config.FOV.Size or 100
            if config.FOV.Enabled ~= nil then
                self.ShowFOV = config.FOV.Enabled
            end
        else
            self.FOV = config.FOV
        end
    end
    
    -- Setup FOV circle
    if self.ShowFOV then
        self:CreateFOVCircle()
    elseif self._fovCircle then
        self._fovCircle.Visible = false
    end
    
    -- Setup hotkey
    self:SetupHotkey()
    
    -- Start/stop based on enabled state
    if self.Enabled then
        self:Start()
    else
        self:Stop()
    end
    
    return "FPS Aimbot active - Hold " .. self.Hotkey .. " to aim"
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

function PetyaXAimbot:GetTargetInfo()
    if not self._target then return "No target" end
    return "Targeting: " .. self._target.Name
end

function PetyaXAimbot:Destroy()
    self:Stop()
    if self._hotkeyConnection then
        self._hotkeyConnection:Disconnect()
    end
    if self._hotkeyRelease then
        self._hotkeyRelease:Disconnect()
    end
    if self._fovCircle then
        self._fovCircle:Remove()
    end
    if self._fovUpdate then
        self._fovUpdate:Disconnect()
    end
end

print("✅ FPS Aimbot loaded with FOV circle")
return PetyaXAimbot
