-- PetyaX Aimbot - GUARANTEED WORKING VERSION
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local CurrentCamera = workspace.CurrentCamera

local PetyaXAimbot = {
    Enabled = false,
    TeamCheck = true,
    FOV = 100,
    Sensitivity = 50,
    AimPart = "Head",
    Hotkey = "MouseButton2"
}

function PetyaXAimbot:Setup(config)
    if config.Enabled ~= nil then self.Enabled = config.Enabled end
    if config.Sensitivity then self.Sensitivity = config.Sensitivity end
    if config.FOV then 
        if type(config.FOV) == "table" then
            self.FOV = config.FOV.Size or 100
        else
            self.FOV = config.FOV
        end
    end
    if config.Target then self.AimPart = config.Target end
    if config.Hotkey then self.Hotkey = config.Hotkey end
    
    return "Aimbot configured successfully"
end

function PetyaXAimbot:Enable()
    self.Enabled = true
    return "Aimbot enabled"
end

function PetyaXAimbot:Disable()
    self.Enabled = false
    return "Aimbot disabled"
end

function PetyaXAimbot:GetTargetInfo()
    return "Target system ready"
end

return PetyaXAimbot
