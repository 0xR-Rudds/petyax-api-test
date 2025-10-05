-- PetyaX FPS Aimbot - Rivals Roblox Edition
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local CurrentCamera = workspace.CurrentCamera

local PetyaXFPSAimbot = {
    -- Core Settings
    Enabled = false,
    TeamCheck = true,
    VisibilityCheck = true,
    
    -- Targeting
    AimPart = "Head",
    AutoSwitchPart = true, -- Switch to body if head not visible
    
    -- Sensitivity & Smoothing
    Sensitivity = 50, -- In-game sensitivity (1-100)
    Smoothing = 0.3, -- Aim smoothing (0.1-1.0)
    SmoothingCurve = "Linear", -- Linear, Quadratic, Cubic
    
    -- FOV & Range
    FOV = 80,
    MaxDistance = 500,
    ShowFOV = false,
    
    -- Prediction
    Prediction = true,
    PredictionStrength = 1.2,
    
    -- Activation
    Hotkey = "MouseButton2",
    ToggleMode = false,
    SilentAim = false, -- Doesn't move camera
    
    -- Internal
    _target = nil,
    _connection = nil,
    _fovCircle = nil,
    _isAiming = false
}

-- Convert sensitivity to smoothing factor
function PetyaXFPSAimbot:GetSmoothFactor()
    -- Higher sensitivity = less smoothing
    return math.clamp(1 - (self.Sensitivity / 100), 0.1, 0.9) * self.Smoothing
end

-- Apply smoothing curve
function PetyaXFPSAimbot:ApplySmoothing(current, target, delta)
    local smoothFactor = self:GetSmoothFactor()
    
    if self.SmoothingCurve == "Quadratic" then
        return current + (target - current) * smoothFactor * smoothFactor
    elseif self.SmoothingCurve == "Cubic" then
        return current + (target - current) * smoothFactor * smoothFactor * smoothFactor
    else -- Linear
        return current + (target - current) * smoothFactor
    end
end

-- Get valid aim part
function PetyaXFPSAimbot:GetAimPart(character)
    local preferredPart = character:FindFirstChild(self.AimPart)
    
    if preferredPart and self:IsPartVisible(preferredPart) then
        return preferredPart
    end
    
    -- Auto-switch if part not visible
    if self.AutoSwitchPart then
        local fallbackParts = {"HumanoidRootPart", "Torso", "UpperTorso"}
        for _, partName in ipairs(fallbackParts) do
            local part = character:FindFirstChild(partName)
            if part and self:IsPartVisible(part) then
                return part
            end
        end
    end
    
    return preferredPart
end

-- Visibility check with raycast
function PetyaXFPSAimbot:IsPartVisible(part)
    if not self.VisibilityCheck then return true end
    
    local localCharacter = LocalPlayer.Character
    if not localCharacter then return false end
    
    local localHead = localCharacter:FindFirstChild("Head")
    if not localHead then return false end
    
    local raycastParams = RaycastParams.new()
    raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
    raycastParams.FilterDescendantsInstances = {localCharacter, part.Parent}
    
    local rayOrigin = localHead.Position
    local rayDirection = (part.Position - rayOrigin).Unit * self.MaxDistance
    local raycastResult = workspace:Raycast(rayOrigin, rayDirection, raycastParams)
    
    return not raycastResult or raycastResult.Instance:IsDescendantOf(part.Parent)
end

-- Calculate bullet prediction
function PetyaXFPSAimbot:CalculatePrediction(character, part)
    if not self.Prediction then return part.Position end
    
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    if not rootPart then return part.Position end
    
    -- Get target velocity
    local velocity = rootPart.Velocity
    
    -- Estimate bullet travel time (adjust based on game)
    local distance = (part.Position - CurrentCamera.CFrame.Position).Magnitude
    local travelTime = distance / 1000 -- Adjust this value per game
    
    -- Apply prediction
    return part.Position + (velocity * travelTime * self.PredictionStrength)
end

-- Get best target within FOV
function PetyaXFPSAimbot:GetBestTarget()
    local bestTarget = nil
    local closestDistance = self.FOV
    local localTeam = LocalPlayer.Team
    
    for _, player in pairs(Players:GetPlayers()) do
        if player == LocalPlayer then goto continue end
        if not player.Character then goto continue end
        
        local character = player.Character
        local humanoid = character:FindFirstChildOfClass("Humanoid")
        if not humanoid or humanoid.Health <= 0 then goto continue end
        
        -- Team check
        if self.TeamCheck and player.Team and localTeam and player.Team == localTeam then
            goto continue
        end
        
        -- Distance check
        local rootPart = character:FindFirstChild("HumanoidRootPart")
        if not rootPart then goto continue end
        
        local distance = (rootPart.Position - CurrentCamera.CFrame.Position).Magnitude
        if distance > self.MaxDistance then goto continue end
        
        -- Get aim part
        local aimPart = self:GetAimPart(character)
        if not aimPart then goto continue end
        
        -- FOV check
        local screenPoint, onScreen = CurrentCamera:WorldToViewportPoint(aimPart.Position)
        if not onScreen then goto continue end
        
        local mousePos = UserInputService:GetMouseLocation()
        local screenDistance = (Vector2.new(screenPoint.X, screenPoint.Y) - mousePos).Magnitude
        
        if screenDistance < closestDistance then
            closestDistance = screenDistance
            bestTarget = {
                Player = player,
                Character = character,
                AimPart = aimPart,
                Distance = distance
            }
        end
        
        ::continue::
    end
    
    return bestTarget
end

-- Smooth aim at target
function PetyaXFPSAimbot:AimAtTarget(target)
    if not target then return end
    
    local predictedPosition = self:CalculatePrediction(target.Character, target.AimPart)
    local camera = CurrentCamera
    local currentCFrame = camera.CFrame
    
    -- Calculate direction to target
    local lookVector = (predictedPosition - currentCFrame.Position).Unit
    
    if self.SilentAim then
        -- Silent aim doesn't move camera (for certain games)
        return
    end
    
    -- Apply smoothing
    local currentLook = currentCFrame.LookVector
    local smoothedLook = self:ApplySmoothing(currentLook, lookVector, RunService.RenderStepped:Wait())
    
    -- Set camera
    camera.CFrame = CFrame.lookAt(currentCFrame.Position, currentCFrame.Position + smoothedLook)
end

-- Main aimbot loop
function PetyaXFPSAimbot:AimbotLoop()
    if not self.Enabled or not self._isAiming then return end
    
    local target = self:GetBestTarget()
    
    if target then
        self._target = target
        self:AimAtTarget(target)
    else
        self._target = nil
    end
end

-- Setup function
function PetyaXFPSAimbot:Setup(config)
    -- Core settings
    if config.Enabled ~= nil then self.Enabled = config.Enabled end
    if config.TeamCheck ~= nil then self.TeamCheck = config.TeamCheck end
    if config.VisibilityCheck ~= nil then self.VisibilityCheck = config.VisibilityCheck end
    
    -- Targeting
    if config.AimPart then self.AimPart = config.AimPart end
    if config.AutoSwitchPart ~= nil then self.AutoSwitchPart = config.AutoSwitchPart end
    
    -- Sensitivity & Smoothing
    if config.Sensitivity then 
        self.Sensitivity = math.clamp(config.Sensitivity, 1, 100)
    end
    if config.Smoothing then 
        self.Smoothing = math.clamp(config.Smoothing, 0.1, 1.0)
    end
    if config.SmoothingCurve then 
        self.SmoothingCurve = config.SmoothingCurve 
    end
    
    -- FOV & Range
    if config.FOV then self.FOV = math.clamp(config.FOV, 10, 360) end
    if config.MaxDistance then self.MaxDistance = math.max(10, config.MaxDistance) end
    if config.ShowFOV ~= nil then self.ShowFOV = config.ShowFOV end
    
    -- Prediction
    if config.Prediction ~= nil then self.Prediction = config.Prediction end
    if config.PredictionStrength then 
        self.PredictionStrength = math.clamp(config.PredictionStrength, 0.1, 3.0)
    end
    
    -- Activation
    if config.Hotkey then self.Hotkey = config.Hotkey end
    if config.ToggleMode ~= nil then self.ToggleMode = config.ToggleMode end
    if config.SilentAim ~= nil then self.SilentAim = config.SilentAim end
    
    -- Setup hotkey
    self:SetupHotkey()
    
    -- Start if enabled
    if self.Enabled then
        self:Start()
    else
        self:Stop()
    end
    
    return "FPS Aimbot configured successfully"
end

-- Hotkey setup
function PetyaXFPSAimbot:SetupHotkey()
    if self._hotkeyConnection then
        self._hotkeyConnection:Disconnect()
    end
    
    self._hotkeyConnection = UserInputService.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType[self.Hotkey] then
            if self.ToggleMode then
                self.Enabled = not self.Enabled
                self._isAiming = self.Enabled
                print("🎯 Aimbot: " .. (self.Enabled and "ENABLED" or "DISABLED"))
            else
                self._isAiming = true
            end
        end
    end)
    
    -- Release to stop (for hold mode)
    if not self.ToggleMode then
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
end

-- Start aimbot
function PetyaXFPSAimbot:Start()
    if self._connection then return end
    
    self._connection = RunService.RenderStepped:Connect(function()
        self:AimbotLoop()
    end)
    
    print("🎯 FPS Aimbot ACTIVATED")
    print("   Sensitivity: " .. self.Sensitivity)
    print("   Smoothing: " .. self.Smoothing)
    print("   FOV: " .. self.FOV)
end

-- Stop aimbot
function PetyaXFPSAimbot:Stop()
    if self._connection then
        self._connection:Disconnect()
        self._connection = nil
    end
    self._target = nil
    self._isAiming = false
    print("🎯 FPS Aimbot DEACTIVATED")
end

-- Enable/Disable
function PetyaXFPSAimbot:Enable()
    self.Enabled = true
    self:Start()
end

function PetyaXFPSAimbot:Disable()
    self.Enabled = false
    self:Stop()
end

-- Get current target info
function PetyaXFPSAimbot:GetTargetInfo()
    if not self._target then return nil end
    
    return {
        Player = self._target.Player.Name,
        AimPart = self._target.AimPart.Name,
        Distance = math.floor(self._target.Distance)
    }
end

-- Cleanup
function PetyaXFPSAimbot:Destroy()
    self:Stop()
    if self._hotkeyConnection then
        self._hotkeyConnection:Disconnect()
    end
    if self._hotkeyRelease then
        self._hotkeyRelease:Disconnect()
    end
end

return PetyaXFPSAimbot
