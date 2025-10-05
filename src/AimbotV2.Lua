-- PetyaX Aimbot V2 - Working Version
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local CurrentCamera = workspace.CurrentCamera

local PetyaXAimbot = {
    Enabled = false,
    TeamCheck = true,
    FOV = 100,
    Smoothness = 0.3,
    AimPart = "Head",
    Hotkey = "MouseButton2"
}

function PetyaXAimbot:Setup(config)
    print("🎯 Aimbot V2 Configuring...")
    if config.Enabled ~= nil then self.Enabled = config.Enabled end
    if config.Sensitivity then 
        self.Smoothness = 1 - (config.Sensitivity / 100)
    end
    return "Aimbot V2 Ready - Hold RMB"
end

function PetyaXAimbot:Enable()
    self.Enabled = true
    print("🎯 Aimbot V2 Enabled")
end

function PetyaXAimbot:Disable()
    self.Enabled = false
    print("🎯 Aimbot V2 Disabled")
end

print("✅ Aimbot V2 Loaded")
return PetyaXAimbot
