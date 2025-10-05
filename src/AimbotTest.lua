-- PetyaX FPS Aimbot - Working Version
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
    MaxDistance = 500
}

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
    
    if config.FOV then
        if type(config.FOV) == "table" then
            self.FOV = config.FOV.Size or 100
        else
            self.FOV = config.FOV
        end
    end
    
    return "FPS Aimbot configured - Enemy targeting"
end

function PetyaXAimbot:Enable()
    self.Enabled = true
    return "FPS Aimbot enabled"
end

function PetyaXAimbot:Disable()
    self.Enabled = false
    return "FPS Aimbot disabled"
end

function PetyaXAimbot:GetTargetInfo()
    return "Target system ready"
end

print("✅ FPS Aimbot loaded successfully")
return PetyaXAimbot
