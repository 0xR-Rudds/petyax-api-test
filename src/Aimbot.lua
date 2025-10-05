-- PetyaX Aimbot - Complete Fixed Version11111
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local CurrentCamera = workspace.CurrentCamera

local PetyaXAimbot = {
    Enabled = false,
    TeamCheck = true,
    VisibilityCheck = false,
    FOV = 100,
    Smoothness = 0.3,
    Prediction = false,
    AimPart = "Head",
    Hotkey = "MouseButton2",
    
    _target = nil,
    _connection = nil
}

-- Setup function
function PetyaXAimbot:Setup(config)
    print("🔧 Configuring Aimbot...")
    
    if config.Enabled ~= nil then self.Enabled = config.Enabled end
    if config.Target then self.AimPart = config.Target end
    if config.Sensitivity then 
        self.Smoothness = 1 - config.Sensitivity
    end
    if config.Hotkey then self.Hotkey = config.Hotkey end
    if config.FOV then
        if config.FOV.Size then self.FOV = config.FOV.Size end
        if config.FOV.Enabled ~= nil then self.ShowFOV = config.FOV.Enabled end
    end
    
    -- Setup hotkey
    self:SetupHotkey()
    
    if self.Enabled then
        self:Start()
    else
        self:Stop()
    end
    
    return "Aimbot configured"
end

-- Setup hotkey
function PetyaXAimbot:SetupHotkey()
    if self._hotkeyConnection then
        self._hotkeyConnection:Disconnect()
    end
    
    self._hotkeyConnection = UserInputService.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType[self.Hotkey] then
            self.Enabled = not self.Enabled
            print("🎯 Aimbot: " .. (self.Enabled and "ENABLED" or "DISABLED"))
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

-- Main aimbot loop
function PetyaXAimbot:AimbotLoop()
    if not self.Enabled then return end
    
    local target = self:GetClosestPlayerToCursor()
    
    if target and target.Character then
        local character = target.Character
        local aimPart = character:FindFirstChild(self.AimPart) or character:FindFirstChild("HumanoidRootPart")
        
        if aimPart then
            local targetPosition = aimPart.Position
            local camera = workspace.CurrentCamera
            
            -- Simple smooth aiming
            local currentCFrame = camera.CFrame
            local lookVector = (targetPosition - currentCFrame.Position).Unit
            local newCFrame = CFrame.lookAt(currentCFrame.Position, currentCFrame.Position + lookVector)
            
            camera.CFrame = currentCFrame:Lerp(newCFrame, self.Smoothness)
        end
    end
end

-- Start aimbot
function PetyaXAimbot:Start()
    if self._connection then
        self._connection:Disconnect()
    end
    
    self._connection = RunService.RenderStepped:Connect(function()
        self:AimbotLoop()
    end)
    
    print("🎯 Aimbot started")
end

-- Stop aimbot
function PetyaXAimbot:Stop()
    if self._connection then
        self._connection:Disconnect()
        self._connection = nil
    end
    self._target = nil
    print("🎯 Aimbot stopped")
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
end

return PetyaXAimbot
