-- PetyaX - Premium Rivals Enhancement Suite (ULTRA ACCURATE AIMBOT + FIXED ESP)
getgenv().PetyaX = true

-- Services
local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local VirtualInputManager = game:GetService("VirtualInputManager")
local HttpService = game:GetService("HttpService")

-- =============================================================================
-- CONFIG SYSTEM
-- =============================================================================

getgenv().ConfigSystem = nil
getgenv().ConfigPath = "./PetyaX/"

local function InitializeConfigSystem()
    print("🔧 Initializing PetyaX Config System...")
    
    -- Working Config Functions
    local ConfigSystem = {}
    
    function ConfigSystem.Save(name, config)
        local success = pcall(function()
            local json = HttpService:JSONEncode(config)
            makefolder(getgenv().ConfigPath)
            writefile(getgenv().ConfigPath .. name .. ".json", json)
            return true
        end)
        
        if success then
            print("✅ Config saved: " .. getgenv().ConfigPath .. name .. ".json")
            return true
        else
            print("❌ Failed to save config: " .. name)
            return false
        end
    end
    
    function ConfigSystem.Load(name)
        local success, config = pcall(function()
            local content = readfile(getgenv().ConfigPath .. name .. ".json")
            return HttpService:JSONDecode(content)
        end)
        
        if success and config then
            print("✅ Config loaded: " .. name)
            return config
        else
            print("❌ Config not found: " .. name)
            return nil
        end
    end
    
    function ConfigSystem.List()
        local success, files = pcall(function()
            makefolder(getgenv().ConfigPath)
            return listfiles(getgenv().ConfigPath)
        end)
        
        if success then
            local configs = {}
            for i, file in ipairs(files) do
                if string.find(file, ".json") then
                    local name = string.gsub(file, getgenv().ConfigPath, "")
                    name = string.gsub(name, ".json", "")
                    table.insert(configs, name)
                end
            end
            return configs
        else
            return {}
        end
    end
    
    function ConfigSystem.Delete(name)
        local success = pcall(function()
            delfile(getgenv().ConfigPath .. name .. ".json")
            return true
        end)
        
        if success then
            print("✅ Config deleted: " .. name)
            return true
        else
            print("❌ Failed to delete config: " .. name)
            return false
        end
    end
    
    -- Create config directory
    pcall(function()
        makefolder(getgenv().ConfigPath)
    end)
    
    print("🎯 Config System Ready: " .. getgenv().ConfigPath)
    return ConfigSystem
end

-- Initialize the config system
getgenv().ConfigSystem = InitializeConfigSystem()

-- Configuration Management Functions
function SaveCurrentConfig(name)
    if not name or name == "" then
        name = "default"
    end
    
    local configToSave = {
        ESP = getgenv().ESP,
        Aimbot = getgenv().Aimbot,
        Crosshair = getgenv().Crosshair,
        Timestamp = os.time(),
        Version = "PetyaX v1.0"
    }
    
    return getgenv().ConfigSystem.Save(name, configToSave)
end

function LoadConfig(name)
    local loadedConfig = getgenv().ConfigSystem.Load(name)
    
    if loadedConfig then
        -- Update ESP settings
        if loadedConfig.ESP then
            for key, value in pairs(loadedConfig.ESP) do
                getgenv().ESP[key] = value
            end
        end
        
        -- Update Aimbot settings
        if loadedConfig.Aimbot then
            for key, value in pairs(loadedConfig.Aimbot) do
                getgenv().Aimbot[key] = value
            end
        end
        
        -- Update Crosshair settings
        if loadedConfig.Crosshair then
            for key, value in pairs(loadedConfig.Crosshair) do
                getgenv().Crosshair[key] = value
            end
        end
        
        print("🎯 Config loaded and applied: " .. name)
        return true
    end
    
    return false
end

function GetConfigList()
    return getgenv().ConfigSystem.List()
end

function DeleteConfig(name)
    return getgenv().ConfigSystem.Delete(name)
end

-- Individual Color Variables
local MainGradientTopColor = Color3.fromHex("0A0A0A")
local MainGradientBottomColor = Color3.fromHex("1A1A1A")
local NeonBorderColor = Color3.fromHex("FF69B4")
local AccentStrokeColor = Color3.fromHex("C71585")
local TextColorColor = Color3.fromHex("FFFFFF")
local SectionBoxColor = Color3.fromHex("1A1A1A")

-- Store references to all UI elements
local UIReferences = {
    MainFrame = nil,
    OuterGlow = nil,
    TopBar = nil,
    TopBarStroke = nil,
    Title = nil,
    CloseButton = nil,
    CloseStroke = nil,
    Sidebar = nil,
    SidebarGradient = nil,
    Content = nil,
    ContentGradient = nil,
    Divider = nil,
    MainGradient = nil,
    SettingsScroll = nil,
    tabButtons = {},
    tabUnderlines = {}
}

-- Simple color preview storage
local ColorPreviews = {}

-- =============================================================================
-- UPDATED CONFIGURATION WITH ULTRA ACCURATE AIMBOT & FIXED ESP
-- =============================================================================

-- ESP Configuration (UPDATED WITH FIXED BOXES & HEALTH BARS)
getgenv().ESP = {
    Enabled = true,
    Tracers = true,
    Boxes = true,
    Names = true,
    HealthBar = true,
    Distance = true,
    Rainbow = true,
    MaxDistance = 1200,
    TeamCheck = true,
    BoxColor = Color3.fromRGB(255, 105, 180),
    TracerColor = Color3.fromRGB(255, 105, 180),
    NameColor = Color3.fromRGB(255, 255, 255),
    BoxThickness = 2,
    TracerThickness = 1
}

-- ULTRA ACCURATE AIMBOT CONFIGURATION
getgenv().Aimbot = {
    Enabled = true,
    FOV = 80,
    Smoothing = 0.05, -- Reduced for maximum accuracy
    AimPart = "Head",
    Prediction = 0.15, -- Optimized prediction
    RainbowFOV = false,
    VisibleCheck = true, -- Enabled for better accuracy
    TeamCheck = true,
    Toggle = false,
    TriggerKey = "MouseButton2"
}

-- Crosshair Configuration
getgenv().Crosshair = {
    Enabled = false,
    Size = 14,
    Thickness = 2,
    Color = Color3.fromRGB(255, 105, 180),
    Transparency = 0.8,
    CenterDot = true,
    RainbowCrosshair = true,
    GapSize = 4
}

-- =============================================================================
-- UPDATED ESP SYSTEM WITH FIXED BOXES & ACCURATE HEALTH BARS
-- =============================================================================

local ESPDrawings = {}
local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

-- Rainbow color generator
local rainbowOffset = 0
function GetRainbowColor()
    rainbowOffset = rainbowOffset + 0.003
    if rainbowOffset > 1 then rainbowOffset = 0 end
    local r = math.sin(rainbowOffset * 6.28) * 0.5 + 0.5
    local g = math.sin((rainbowOffset + 0.33) * 6.28) * 0.5 + 0.5
    local b = math.sin((rainbowOffset + 0.66) * 6.28) * 0.5 + 0.5
    return Color3.new(r, g, b)
end

-- Create ESP for player (UPDATED WITH FIXED BOXES)
function CreateESP(player)
    if player == LocalPlayer then return end
    if ESPDrawings[player] then return end
    
    local drawings = {
        Tracer = Drawing.new("Line"),
        Box = Drawing.new("Square"),
        Name = Drawing.new("Text"),
        HealthBar = Drawing.new("Square"),
        HealthBackground = Drawing.new("Square"),
        Distance = Drawing.new("Text")
    }
    
    -- Setup properties
    for _, drawing in pairs(drawings) do
        drawing.Visible = false
    end
    
    drawings.Tracer.Thickness = getgenv().ESP.TracerThickness
    drawings.Box.Thickness = getgenv().ESP.BoxThickness
    drawings.Box.Filled = false
    drawings.Name.Size = 14
    drawings.Name.Outline = true
    drawings.HealthBackground.Filled = true
    drawings.HealthBackground.Color = Color3.new(0, 0, 0)
    drawings.HealthBar.Filled = true
    drawings.Distance.Size = 12
    drawings.Distance.Outline = true
    
    ESPDrawings[player] = drawings
end

-- UPDATED ESP FUNCTION WITH FIXED FULL BODY BOXES & ACCURATE HEALTH BARS
function UpdateESP()
    for player, drawings in pairs(ESPDrawings) do
        if not player or not player.Character then
            for _, drawing in pairs(drawings) do drawing.Visible = false end
            continue
        end
        
        local character = player.Character
        local humanoid = character:FindFirstChildOfClass("Humanoid")
        if not humanoid or humanoid.Health <= 0 then
            for _, drawing in pairs(drawings) do drawing.Visible = false end
            continue
        end
        
        -- TEAM CHECK
        if getgenv().ESP.TeamCheck and player.Team == LocalPlayer.Team then
            for _, drawing in pairs(drawings) do drawing.Visible = false end
            continue
        end
        
        local rootPart = character:FindFirstChild("HumanoidRootPart")
        if not rootPart then continue end
        
        local distance = (rootPart.Position - Camera.CFrame.Position).Magnitude
        if distance > getgenv().ESP.MaxDistance then
            for _, drawing in pairs(drawings) do drawing.Visible = false end
            continue
        end
        
        -- Calculate proper bounding box that doesn't change with distance
        local cf = rootPart.CFrame
        local size = character:GetExtentsSize()
        
        -- Create corner points for full body bounding box
        local corners = {
            cf * CFrame.new(size.X/2, size.Y/2, size.Z/2),
            cf * CFrame.new(-size.X/2, size.Y/2, size.Z/2),
            cf * CFrame.new(size.X/2, -size.Y/2, size.Z/2),
            cf * CFrame.new(-size.X/2, -size.Y/2, size.Z/2),
            cf * CFrame.new(size.X/2, size.Y/2, -size.Z/2),
            cf * CFrame.new(-size.X/2, size.Y/2, -size.Z/2),
            cf * CFrame.new(size.X/2, -size.Y/2, -size.Z/2),
            cf * CFrame.new(-size.X/2, -size.Y/2, -size.Z/2)
        }
        
        -- Project corners to screen space for consistent box size
        local minX, minY, maxX, maxY = math.huge, math.huge, -math.huge, -math.huge
        local anyVisible = false
        
        for _, corner in pairs(corners) do
            local screenPos, visible = Camera:WorldToViewportPoint(corner.Position)
            if visible then
                anyVisible = true
                minX = math.min(minX, screenPos.X)
                minY = math.min(minY, screenPos.Y)
                maxX = math.max(maxX, screenPos.X)
                maxY = math.max(maxY, screenPos.Y)
            end
        end
        
        if not anyVisible then
            for _, drawing in pairs(drawings) do drawing.Visible = false end
            continue
        end
        
        local health = humanoid.Health
        local maxHealth = humanoid.MaxHealth
        local healthPercent = math.clamp(health / maxHealth, 0, 1)
        
        local espColor = getgenv().ESP.Rainbow and GetRainbowColor() or getgenv().ESP.BoxColor
        
        -- Tracers
        if getgenv().ESP.Tracers then
            drawings.Tracer.From = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y)
            drawings.Tracer.To = Vector2.new((minX + maxX) / 2, maxY)
            drawings.Tracer.Color = getgenv().ESP.Rainbow and GetRainbowColor() or getgenv().ESP.TracerColor
            drawings.Tracer.Thickness = getgenv().ESP.TracerThickness
            drawings.Tracer.Visible = true
        else
            drawings.Tracer.Visible = false
        end
        
        -- FIXED BOXES: Full body boxes that don't change with distance
        if getgenv().ESP.Boxes then
            drawings.Box.Size = Vector2.new(maxX - minX, maxY - minY)
            drawings.Box.Position = Vector2.new(minX, minY)
            drawings.Box.Color = espColor
            drawings.Box.Thickness = getgenv().ESP.BoxThickness
            drawings.Box.Visible = true
        else
            drawings.Box.Visible = false
        end
        
        -- Name
        if getgenv().ESP.Names then
            drawings.Name.Text = player.Name
            drawings.Name.Position = Vector2.new((minX + maxX) / 2, minY - 20)
            drawings.Name.Color = getgenv().ESP.Rainbow and GetRainbowColor() or getgenv().ESP.NameColor
            drawings.Name.Visible = true
        else
            drawings.Name.Visible = false
        end
        
        -- Distance
        if getgenv().ESP.Distance then
            drawings.Distance.Text = tostring(math.floor(distance)) .. "m"
            drawings.Distance.Position = Vector2.new((minX + maxX) / 2, maxY + 5)
            drawings.Distance.Color = espColor
            drawings.Distance.Visible = true
        else
            drawings.Distance.Visible = false
        end
        
        -- FIXED HEALTH BAR: Accurate health bars that react to player health
        if getgenv().ESP.HealthBar then
            local barWidth = 4
            local barHeight = maxY - minY
            local barX = minX - 8
            local barY = minY
            local healthHeight = barHeight * healthPercent
            
            drawings.HealthBackground.Size = Vector2.new(barWidth, barHeight)
            drawings.HealthBackground.Position = Vector2.new(barX, barY)
            drawings.HealthBackground.Visible = true
            
            drawings.HealthBar.Size = Vector2.new(barWidth, healthHeight)
            drawings.HealthBar.Position = Vector2.new(barX, barY + (barHeight - healthHeight))
            
            -- UPDATED: Health bar colors - green to red based on health
            if healthPercent > 0.5 then
                -- Green to yellow (100% - 50%)
                local greenToYellow = (healthPercent - 0.5) * 2
                drawings.HealthBar.Color = Color3.new(greenToYellow, 1, 0)
            else
                -- Yellow to red (50% - 0%)
                local yellowToRed = healthPercent * 2
                drawings.HealthBar.Color = Color3.new(1, yellowToRed, 0)
            end
            
            drawings.HealthBar.Visible = true
        else
            drawings.HealthBar.Visible = false
            drawings.HealthBackground.Visible = false
        end
    end
end

-- Cleanup ESP function
local function CleanupESP()
    for _, drawings in pairs(ESPDrawings) do
        for _, drawing in pairs(drawings) do
            drawing:Remove()
        end
    end
    ESPDrawings = {}
end

-- =============================================================================
-- ULTRA ACCURATE AIMBOT SYSTEM
-- =============================================================================

local aiming = false

-- UPDATED: Ultra Accurate Target Finding
function FindTarget()
    local closest = nil
    local closestDist = getgenv().Aimbot.FOV
    local center = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
    
    for _, player in pairs(Players:GetPlayers()) do
        if player == LocalPlayer then continue end
        if getgenv().Aimbot.TeamCheck and player.Team == LocalPlayer.Team then continue end
        if not player.Character then continue end
        
        local char = player.Character
        local humanoid = char:FindFirstChildOfClass("Humanoid")
        if not humanoid or humanoid.Health <= 0 then continue end
        
        local head = char:FindFirstChild(getgenv().Aimbot.AimPart)
        if not head then continue end
        
        local distance = (char:GetPivot().Position - Camera.CFrame.Position).Magnitude
        if distance > getgenv().ESP.MaxDistance then continue end
        
        -- UPDATED: Visibility check for better accuracy
        if getgenv().Aimbot.VisibleCheck then
            local ray = Ray.new(Camera.CFrame.Position, (head.Position - Camera.CFrame.Position).Unit * distance)
            local hit, position = Workspace:FindPartOnRayWithIgnoreList(ray, {LocalPlayer.Character, char})
            if not hit or not hit:IsDescendantOf(char) then
                continue
            end
        end
        
        local screenPos, onScreen = Camera:WorldToViewportPoint(head.Position)
        if not onScreen then continue end
        
        local pos = Vector2.new(screenPos.X, screenPos.Y)
        local dist = (center - pos).Magnitude
        
        if dist < closestDist then
            closestDist = dist
            closest = {
                Head = head, 
                ScreenPos = pos, 
                Player = player,
                Character = char,
                Humanoid = humanoid
            }
        end
    end
    
    return closest
end

-- UPDATED: Ultra Accurate Mouse Movement with Advanced Prediction
function MoveCrosshairToTarget(target)
    if not target then return end
    
    local center = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
    local targetPos = target.ScreenPos
    
    -- UPDATED: Advanced prediction with gravity compensation
    if getgenv().Aimbot.Prediction > 0 then
        local char = target.Player.Character
        local humanoid = target.Humanoid
        if humanoid and humanoid.MoveDirection.Magnitude > 0 then
            local moveDirection = humanoid.MoveDirection
            local velocity = moveDirection * humanoid.WalkSpeed * getgenv().Aimbot.Prediction
            
            -- Add subtle height adjustment based on distance
            local distance = (target.Head.Position - Camera.CFrame.Position).Magnitude
            if distance > 50 then
                local gravityCompensation = Vector3.new(0, (distance * 0.0005) * getgenv().Aimbot.Prediction, 0)
                velocity = velocity + gravityCompensation
            end
            
            local predictedPos = target.Head.Position + velocity
            local predictedScreenPos = Camera:WorldToViewportPoint(predictedPos)
            targetPos = Vector2.new(predictedScreenPos.X, predictedScreenPos.Y)
        end
    end
    
    local delta = targetPos - center
    
    -- UPDATED: Advanced smoothing with distance-based factors
    local smoothFactor = getgenv().Aimbot.Smoothing
    local distanceFactor = math.clamp(delta.Magnitude / 100, 0.1, 1.0)
    smoothFactor = smoothFactor * distanceFactor
    
    local smoothedDelta = delta * smoothFactor
    
    -- ULTRA-PRECISE mouse movement
    mousemoverel(
        math.floor(smoothedDelta.X),
        math.floor(smoothedDelta.Y)
    )
end

-- Mouse movement function
local function mousemoverel(x, y)
    VirtualInputManager:SendMouseMoveEvent(x, y, Workspace)
end

-- FOV Circle
local FOVCircle = Drawing.new("Circle")
FOVCircle.Visible = true
FOVCircle.Radius = getgenv().Aimbot.FOV
FOVCircle.Color = Color3.fromRGB(255, 105, 180)
FOVCircle.Thickness = 2
FOVCircle.Position = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
FOVCircle.Filled = false

-- =============================================================================
-- CROSSHAIR SYSTEM
-- =============================================================================

local CrosshairTop, CrosshairBottom, CrosshairLeft, CrosshairRight, CrosshairCenter

function CreateCrosshair()
    CrosshairTop = Drawing.new("Line")
    CrosshairBottom = Drawing.new("Line")
    CrosshairLeft = Drawing.new("Line")
    CrosshairRight = Drawing.new("Line")
    CrosshairCenter = Drawing.new("Circle")
    
    for _, part in pairs({CrosshairTop, CrosshairBottom, CrosshairLeft, CrosshairRight}) do
        part.Visible = false
        part.Thickness = getgenv().Crosshair.Thickness
    end
    
    CrosshairCenter.Radius = 2
    CrosshairCenter.Filled = true
end

function UpdateCrosshair()
    if not CrosshairTop then CreateCrosshair() end
    if not getgenv().Crosshair.Enabled then
        for _, part in pairs({CrosshairTop, CrosshairBottom, CrosshairLeft, CrosshairRight, CrosshairCenter}) do
            part.Visible = false
        end
        return
    end
    
    local center = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
    local size = getgenv().Crosshair.Size
    local gap = getgenv().Crosshair.GapSize
    
    local crosshairColor = getgenv().Crosshair.RainbowCrosshair and GetRainbowColor() or getgenv().Crosshair.Color
    
    for _, part in pairs({CrosshairTop, CrosshairBottom, CrosshairLeft, CrosshairRight}) do
        part.Color = crosshairColor
        part.Thickness = getgenv().Crosshair.Thickness
        part.Transparency = getgenv().Crosshair.Transparency
    end
    
    CrosshairCenter.Color = crosshairColor
    CrosshairCenter.Transparency = getgenv().Crosshair.Transparency
    
    -- Crosshair lines
    CrosshairTop.From = Vector2.new(center.X, center.Y - gap - size)
    CrosshairTop.To = Vector2.new(center.X, center.Y - gap)
    CrosshairTop.Visible = true
    
    CrosshairBottom.From = Vector2.new(center.X, center.Y + gap)
    CrosshairBottom.To = Vector2.new(center.X, center.Y + gap + size)
    CrosshairBottom.Visible = true
    
    CrosshairLeft.From = Vector2.new(center.X - gap - size, center.Y)
    CrosshairLeft.To = Vector2.new(center.X - gap, center.Y)
    CrosshairLeft.Visible = true
    
    CrosshairRight.From = Vector2.new(center.X + gap, center.Y)
    CrosshairRight.To = Vector2.new(center.X + gap + size, center.Y)
    CrosshairRight.Visible = true
    
    -- Center dot
    CrosshairCenter.Position = center
    CrosshairCenter.Visible = getgenv().Crosshair.CenterDot
end

-- =============================================================================
-- CUSTOM UI FRAMEWORK WITH BOXED SECTIONS
-- =============================================================================

-- Create ScreenGui
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "PetyaX_UI"
ScreenGui.Parent = CoreGui
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true

-- Create main window (Frame)
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 500, 0, 650)
MainFrame.Position = UDim2.new(0.5, -250, 0.5, -325)
MainFrame.BackgroundColor3 = MainGradientTopColor
MainFrame.BorderSizePixel = 0
MainFrame.ZIndex = 1000
MainFrame.Parent = ScreenGui
UIReferences.MainFrame = MainFrame

-- Thin neon border
local OuterGlow = Instance.new("UIStroke")
OuterGlow.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
OuterGlow.Color = NeonBorderColor
OuterGlow.Thickness = 0.8
OuterGlow.Transparency = 0.3
OuterGlow.Parent = MainFrame
UIReferences.OuterGlow = OuterGlow

-- Subtle shadow
local Shadow = Instance.new("UIStroke")
Shadow.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
Shadow.Color = Color3.fromHex("000000")
Shadow.Thickness = 2
Shadow.Transparency = 0.7
Shadow.Parent = MainFrame

-- Sharp corners
local Corner = Instance.new("UICorner")
Corner.CornerRadius = UDim.new(0, 4)
Corner.Parent = MainFrame

-- Subtle gradient
local MainGradient = Instance.new("UIGradient")
MainGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, MainGradientTopColor),
    ColorSequenceKeypoint.new(1, MainGradientBottomColor)
})
MainGradient.Rotation = 90
MainGradient.Parent = MainFrame
UIReferences.MainGradient = MainGradient

-- Top Bar
local TopBar = Instance.new("Frame")
TopBar.Size = UDim2.new(1, 0, 0, 40)
TopBar.BackgroundColor3 = MainGradientTopColor
TopBar.BorderSizePixel = 0
TopBar.ZIndex = 1001
TopBar.Parent = MainFrame
UIReferences.TopBar = TopBar

local TopBarStroke = Instance.new("UIStroke")
TopBarStroke.Color = AccentStrokeColor
TopBarStroke.Thickness = 0.8
TopBarStroke.Transparency = 0.4
TopBarStroke.Parent = TopBar
UIReferences.TopBarStroke = TopBarStroke

-- UPDATED: Title with pink X
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -20, 0, 24)
Title.BackgroundTransparency = 1
Title.Text = "Petya<font color='#FF69B4'>X</font> - #1 Rivals Script"
Title.RichText = true
Title.TextColor3 = TextColorColor
Title.TextSize = 18
Title.Font = Enum.Font.Code
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Position = UDim2.new(0, 10, 0, 8)
Title.ZIndex = 1002
Title.Parent = TopBar
UIReferences.Title = Title

-- Close Button
local CloseButton = Instance.new("TextButton")
CloseButton.Size = UDim2.new(0, 26, 0, 26)
CloseButton.Position = UDim2.new(1, -34, 0, 7)
CloseButton.BackgroundColor3 = MainGradientTopColor
CloseButton.TextColor3 = NeonBorderColor
CloseButton.Text = "X"
CloseButton.TextSize = 14
CloseButton.Font = Enum.Font.Code
CloseButton.ZIndex = 1002
CloseButton.Parent = TopBar
UIReferences.CloseButton = CloseButton

local CloseStroke = Instance.new("UIStroke")
CloseStroke.Color = AccentStrokeColor
CloseStroke.Transparency = 0.4
CloseStroke.Thickness = 0.8
CloseStroke.Parent = CloseButton
UIReferences.CloseStroke = CloseStroke

CloseButton.MouseEnter:Connect(function()
    if CloseStroke then
        TweenService:Create(CloseStroke, TweenInfo.new(0.1), {Transparency = 0, Color = NeonBorderColor}):Play()
    end
end)

CloseButton.MouseLeave:Connect(function()
    if CloseStroke then
        TweenService:Create(CloseStroke, TweenInfo.new(0.1), {Transparency = 0.4, Color = AccentStrokeColor}):Play()
    end
end)

-- Sidebar (for tabs)
local Sidebar = Instance.new("Frame")
Sidebar.Size = UDim2.new(0, 120, 1, -40)
Sidebar.Position = UDim2.new(0, 0, 0, 40)
Sidebar.BackgroundColor3 = MainGradientTopColor
Sidebar.BorderSizePixel = 0
Sidebar.ZIndex = 1001
Sidebar.Parent = MainFrame
UIReferences.Sidebar = Sidebar

local SidebarGradient = Instance.new("UIGradient")
SidebarGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, MainGradientTopColor),
    ColorSequenceKeypoint.new(1, MainGradientBottomColor)
})
SidebarGradient.Rotation = 90
SidebarGradient.Parent = Sidebar
UIReferences.SidebarGradient = SidebarGradient

-- Content Area
local Content = Instance.new("Frame")
Content.Size = UDim2.new(1, -120, 1, -40)
Content.Position = UDim2.new(0, 120, 0, 40)
Content.BackgroundColor3 = MainGradientTopColor
Content.BorderSizePixel = 0
Content.ZIndex = 1001
Content.Parent = MainFrame
UIReferences.Content = Content

local ContentGradient = Instance.new("UIGradient")
ContentGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, MainGradientTopColor),
    ColorSequenceKeypoint.new(1, MainGradientBottomColor)
})
ContentGradient.Rotation = 90
ContentGradient.Parent = Content
UIReferences.ContentGradient = ContentGradient

-- Sidebar-Content Divider
local Divider = Instance.new("Frame")
Divider.Size = UDim2.new(0, 1, 1, -40)
Divider.Position = UDim2.new(0, 120, 0, 40)
Divider.BackgroundColor3 = AccentStrokeColor
Divider.BackgroundTransparency = 0.6
Divider.BorderSizePixel = 0
Divider.ZIndex = 1001
Divider.Parent = MainFrame
UIReferences.Divider = Divider

-- SECTION BOX CREATION FUNCTION
local function CreateSectionBox(parent, title, layoutOrder, height)
    local SectionFrame = Instance.new("Frame")
    SectionFrame.Size = UDim2.new(1, 0, 0, height or 120)
    SectionFrame.BackgroundColor3 = SectionBoxColor
    SectionFrame.BorderSizePixel = 0
    SectionFrame.LayoutOrder = layoutOrder
    SectionFrame.ZIndex = 1003
    SectionFrame.Parent = parent

    -- Section border
    local SectionStroke = Instance.new("UIStroke")
    SectionStroke.Color = AccentStrokeColor
    SectionStroke.Thickness = 1
    SectionStroke.Transparency = 0.3
    SectionStroke.Parent = SectionFrame

    -- Section corners
    local SectionCorner = Instance.new("UICorner")
    SectionCorner.CornerRadius = UDim.new(0, 6)
    SectionCorner.Parent = SectionFrame

    -- Section title
    local TitleLabel = Instance.new("TextLabel")
    TitleLabel.Size = UDim2.new(1, -20, 0, 25)
    TitleLabel.Position = UDim2.new(0, 10, 0, 5)
    TitleLabel.BackgroundTransparency = 1
    TitleLabel.Text = title
    TitleLabel.TextColor3 = NeonBorderColor
    TitleLabel.TextSize = 14
    TitleLabel.Font = Enum.Font.Code
    TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
    TitleLabel.ZIndex = 1004
    TitleLabel.Parent = SectionFrame

    -- Content container
    local ContentFrame = Instance.new("Frame")
    ContentFrame.Size = UDim2.new(1, -20, 1, -35)
    ContentFrame.Position = UDim2.new(0, 10, 0, 30)
    ContentFrame.BackgroundTransparency = 1
    ContentFrame.ZIndex = 1004
    ContentFrame.Parent = SectionFrame

    return ContentFrame
end

-- UPDATED: Tab System with Config tab
local tabs = {"ESP", "Aimbot", "Crosshair", "Config", "Settings"}
local tabFrames = {}

local function createTab(name, index)
    local TabButton = Instance.new("TextButton")
    TabButton.Size = UDim2.new(1, -10, 0, 35)
    TabButton.Position = UDim2.new(0, 5, 0, 5 + ((index - 1) * 40))
    TabButton.BackgroundTransparency = 1
    TabButton.TextColor3 = TextColorColor
    TabButton.Text = name
    TabButton.TextSize = 14
    TabButton.Font = Enum.Font.Code
    TabButton.ZIndex = 1002
    TabButton.Parent = Sidebar
    table.insert(UIReferences.tabButtons, TabButton)

    local TabUnderline = Instance.new("Frame")
    TabUnderline.Name = "TabUnderline"
    TabUnderline.Size = UDim2.new(1, -10, 0, 2)
    TabUnderline.Position = UDim2.new(0, 5, 1, -3)
    TabUnderline.BackgroundColor3 = NeonBorderColor
    TabUnderline.BackgroundTransparency = name == "ESP" and 0 or 1
    TabUnderline.ZIndex = 1002
    TabUnderline.Parent = TabButton
    table.insert(UIReferences.tabUnderlines, TabUnderline)

    local TabFrame = Instance.new("Frame")
    TabFrame.Size = UDim2.new(1, 0, 1, 0)
    TabFrame.BackgroundTransparency = 1
    TabFrame.ZIndex = 1002
    TabFrame.Visible = name == "ESP"
    TabFrame.Parent = Content

    TabButton.MouseEnter:Connect(function()
        if TabUnderline and TabUnderline.BackgroundTransparency == 1 then
            TweenService:Create(TabUnderline, TweenInfo.new(0.1), {BackgroundTransparency = 0.5}):Play()
        end
    end)

    TabButton.MouseLeave:Connect(function()
        if TabUnderline and TabUnderline.BackgroundTransparency == 0.5 then
            TweenService:Create(TabUnderline, TweenInfo.new(0.1), {BackgroundTransparency = 1}):Play()
        end
    end)

    TabButton.MouseButton1Click:Connect(function()
        for _, frame in pairs(tabFrames) do
            if frame then
                frame.Visible = false
            end
        end
        for _, underline in pairs(UIReferences.tabUnderlines) do
            if underline then
                underline.BackgroundTransparency = 1
            end
        end
        if TabFrame then
            TabFrame.Visible = true
        end
        if TabUnderline then
            TabUnderline.BackgroundTransparency = 0
        end
    end)

    table.insert(tabFrames, TabFrame)
    return TabFrame
end

-- Create Tabs
local ESPTab = createTab("ESP", 1)
local AimbotTab = createTab("Aimbot", 2)
local CrosshairTab = createTab("Crosshair", 3)
local ConfigTab = createTab("Config", 4)
local SettingsTab = createTab("Settings", 5)

-- =============================================================================
-- CONFIG TAB CONTENT
-- =============================================================================

local ConfigScroll = Instance.new("ScrollingFrame")
ConfigScroll.Size = UDim2.new(1, -20, 1, -20)
ConfigScroll.Position = UDim2.new(0, 10, 0, 10)
ConfigScroll.BackgroundTransparency = 1
ConfigScroll.ScrollBarThickness = 6
ConfigScroll.ScrollBarImageColor3 = NeonBorderColor
ConfigScroll.ZIndex = 1003
ConfigScroll.Parent = ConfigTab

local ConfigLayout = Instance.new("UIListLayout")
ConfigLayout.SortOrder = Enum.SortOrder.LayoutOrder
ConfigLayout.Padding = UDim.new(0, 10)
ConfigLayout.Parent = ConfigScroll

ConfigLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    ConfigScroll.CanvasSize = UDim2.new(0, 0, 0, ConfigLayout.AbsoluteContentSize.Y + 10)
end)

-- Config Management Section
local ConfigManagementSection = CreateSectionBox(ConfigScroll, "CONFIG MANAGEMENT", 1, 200)
local ConfigManagementLayout = Instance.new("UIListLayout")
ConfigManagementLayout.SortOrder = Enum.SortOrder.LayoutOrder
ConfigManagementLayout.Padding = UDim.new(0, 5)
ConfigManagementLayout.Parent = ConfigManagementSection

-- Config Name Input
local ConfigNameFrame = Instance.new("Frame")
ConfigNameFrame.Size = UDim2.new(1, 0, 0, 50)
ConfigNameFrame.BackgroundTransparency = 1
ConfigNameFrame.LayoutOrder = 1
ConfigNameFrame.Parent = ConfigManagementSection

local ConfigNameLabel = Instance.new("TextLabel")
ConfigNameLabel.Size = UDim2.new(1, 0, 0, 20)
ConfigNameLabel.BackgroundTransparency = 1
ConfigNameLabel.Text = "Config Name"
ConfigNameLabel.TextColor3 = TextColorColor
ConfigNameLabel.TextSize = 14
ConfigNameLabel.Font = Enum.Font.Code
ConfigNameLabel.TextXAlignment = Enum.TextXAlignment.Left
ConfigNameLabel.Parent = ConfigNameFrame

local ConfigNameBox = Instance.new("TextBox")
ConfigNameBox.Size = UDim2.new(1, 0, 0, 25)
ConfigNameBox.Position = UDim2.new(0, 0, 0, 20)
ConfigNameBox.BackgroundColor3 = MainGradientTopColor
ConfigNameBox.TextColor3 = TextColorColor
ConfigNameBox.Text = "default"
ConfigNameBox.PlaceholderText = "Enter config name..."
ConfigNameBox.TextSize = 12
ConfigNameBox.Font = Enum.Font.Code
ConfigNameBox.Parent = ConfigNameFrame

local ConfigNameStroke = Instance.new("UIStroke")
ConfigNameStroke.Color = AccentStrokeColor
ConfigNameStroke.Thickness = 1
ConfigNameStroke.Parent = ConfigNameBox

local ConfigNameCorner = Instance.new("UICorner")
ConfigNameCorner.CornerRadius = UDim.new(0, 4)
ConfigNameCorner.Parent = ConfigNameBox

-- Save/Load Buttons
local ConfigButtonsFrame = Instance.new("Frame")
ConfigButtonsFrame.Size = UDim2.new(1, 0, 0, 80)
ConfigButtonsFrame.BackgroundTransparency = 1
ConfigButtonsFrame.LayoutOrder = 2
ConfigButtonsFrame.Parent = ConfigManagementSection

local SaveConfigButton = Instance.new("TextButton")
SaveConfigButton.Size = UDim2.new(1, 0, 0, 30)
SaveConfigButton.BackgroundColor3 = NeonBorderColor
SaveConfigButton.TextColor3 = MainGradientTopColor
SaveConfigButton.Text = "💾 Save Config"
SaveConfigButton.TextSize = 12
SaveConfigButton.Font = Enum.Font.Code
SaveConfigButton.Parent = ConfigButtonsFrame

local SaveConfigCorner = Instance.new("UICorner")
SaveConfigCorner.CornerRadius = UDim.new(0, 4)
SaveConfigCorner.Parent = SaveConfigButton

local LoadConfigButton = Instance.new("TextButton")
LoadConfigButton.Size = UDim2.new(1, 0, 0, 30)
LoadConfigButton.Position = UDim2.new(0, 0, 0, 35)
LoadConfigButton.BackgroundColor3 = NeonBorderColor
LoadConfigButton.TextColor3 = MainGradientTopColor
LoadConfigButton.Text = "📂 Load Config"
LoadConfigButton.TextSize = 12
LoadConfigButton.Font = Enum.Font.Code
LoadConfigButton.Parent = ConfigButtonsFrame

local LoadConfigCorner = Instance.new("UICorner")
LoadConfigCorner.CornerRadius = UDim.new(0, 4)
LoadConfigCorner.Parent = LoadConfigButton

-- Config List Section
local ConfigListSection = CreateSectionBox(ConfigScroll, "SAVED CONFIGS", 2, 200)
local ConfigListLayout = Instance.new("UIListLayout")
ConfigListLayout.SortOrder = Enum.SortOrder.LayoutOrder
ConfigListLayout.Padding = UDim.new(0, 5)
ConfigListLayout.Parent = ConfigListSection

local ConfigListLabel = Instance.new("TextLabel")
ConfigListLabel.Size = UDim2.new(1, 0, 0, 20)
ConfigListLabel.BackgroundTransparency = 1
ConfigListLabel.Text = "Available Configs:"
ConfigListLabel.TextColor3 = TextColorColor
ConfigListLabel.TextSize = 14
ConfigListLabel.Font = Enum.Font.Code
ConfigListLabel.TextXAlignment = Enum.TextXAlignment.Left
ConfigListLabel.LayoutOrder = 1
ConfigListLabel.Parent = ConfigListSection

local ConfigListFrame = Instance.new("ScrollingFrame")
ConfigListFrame.Size = UDim2.new(1, 0, 0, 150)
ConfigListFrame.BackgroundTransparency = 1
ConfigListFrame.ScrollBarThickness = 4
ConfigListFrame.ScrollBarImageColor3 = NeonBorderColor
ConfigListFrame.LayoutOrder = 2
ConfigListFrame.Parent = ConfigListSection

local ConfigListLayoutInner = Instance.new("UIListLayout")
ConfigListLayoutInner.SortOrder = Enum.SortOrder.LayoutOrder
ConfigListLayoutInner.Padding = UDim.new(0, 2)
ConfigListLayoutInner.Parent = ConfigListFrame

-- Function to refresh config list
function RefreshConfigList()
    -- Clear existing config buttons
    for _, child in pairs(ConfigListFrame:GetChildren()) do
        if child:IsA("TextButton") then
            child:Destroy()
        end
    end
    
    local configs = GetConfigList()
    ConfigListFrame.CanvasSize = UDim2.new(0, 0, 0, #configs * 30)
    
    for i, configName in ipairs(configs) do
        local ConfigButton = Instance.new("TextButton")
        ConfigButton.Size = UDim2.new(1, 0, 0, 25)
        ConfigButton.Position = UDim2.new(0, 0, 0, (i-1)*30)
        ConfigButton.BackgroundColor3 = MainGradientTopColor
        ConfigButton.TextColor3 = TextColorColor
        ConfigButton.Text = "⚙️ " .. configName
        ConfigButton.TextSize = 11
        ConfigButton.Font = Enum.Font.Code
        ConfigButton.TextXAlignment = Enum.TextXAlignment.Left
        ConfigButton.Parent = ConfigListFrame
        
        local ConfigButtonStroke = Instance.new("UIStroke")
        ConfigButtonStroke.Color = AccentStrokeColor
        ConfigButtonStroke.Thickness = 1
        ConfigButtonStroke.Parent = ConfigButton
        
        local ConfigButtonCorner = Instance.new("UICorner")
        ConfigButtonCorner.CornerRadius = UDim.new(0, 4)
        ConfigButtonCorner.Parent = ConfigButton
        
        -- Load on click
        ConfigButton.MouseButton1Click:Connect(function()
            ConfigNameBox.Text = configName
            LoadConfig(configName)
        end)
        
        -- Delete on right click
        ConfigButton.MouseButton2Click:Connect(function()
            DeleteConfig(configName)
            RefreshConfigList()
        end)
        
        ConfigButton.MouseEnter:Connect(function()
            TweenService:Create(ConfigButtonStroke, TweenInfo.new(0.2), {Color = NeonBorderColor}):Play()
        end)
        
        ConfigButton.MouseLeave:Connect(function()
            TweenService:Create(ConfigButtonStroke, TweenInfo.new(0.2), {Color = AccentStrokeColor}):Play()
        end)
    end
    
    if #configs == 0 then
        local NoConfigsLabel = Instance.new("TextLabel")
        NoConfigsLabel.Size = UDim2.new(1, 0, 0, 25)
        NoConfigsLabel.BackgroundTransparency = 1
        NoConfigsLabel.Text = "No configs saved yet"
        NoConfigsLabel.TextColor3 = TextColorColor
        NoConfigsLabel.TextSize = 11
        NoConfigsLabel.Font = Enum.Font.Code
        NoConfigsLabel.Parent = ConfigListFrame
    end
end

-- Button click handlers
SaveConfigButton.MouseButton1Click:Connect(function()
    local configName = ConfigNameBox.Text
    if configName and configName ~= "" then
        SaveCurrentConfig(configName)
        RefreshConfigList()
    end
end)

LoadConfigButton.MouseButton1Click:Connect(function()
    local configName = ConfigNameBox.Text
    if configName and configName ~= "" then
        LoadConfig(configName)
    end
end)

-- Initial refresh
RefreshConfigList()

-- =============================================================================
-- ESP TAB CONTENT
-- =============================================================================

local ESPScroll = Instance.new("ScrollingFrame")
ESPScroll.Size = UDim2.new(1, -20, 1, -20)
ESPScroll.Position = UDim2.new(0, 10, 0, 10)
ESPScroll.BackgroundTransparency = 1
ESPScroll.ScrollBarThickness = 6
ESPScroll.ScrollBarImageColor3 = NeonBorderColor
ESPScroll.ZIndex = 1003
ESPScroll.Parent = ESPTab

local ESPLayout = Instance.new("UIListLayout")
ESPLayout.SortOrder = Enum.SortOrder.LayoutOrder
ESPLayout.Padding = UDim.new(0, 10)
ESPLayout.Parent = ESPScroll

ESPLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    ESPScroll.CanvasSize = UDim2.new(0, 0, 0, ESPLayout.AbsoluteContentSize.Y + 10)
end)

-- ESP Main Toggle Section
local ESPMainSection = CreateSectionBox(ESPScroll, "ESP MAIN", 1, 80)
local ESPMainLayout = Instance.new("UIListLayout")
ESPMainLayout.SortOrder = Enum.SortOrder.LayoutOrder
ESPMainLayout.Padding = UDim.new(0, 5)
ESPMainLayout.Parent = ESPMainSection

-- ESP Toggle
local ESPToggleFrame = Instance.new("Frame")
ESPToggleFrame.Size = UDim2.new(1, 0, 0, 25)
ESPToggleFrame.BackgroundTransparency = 1
ESPToggleFrame.LayoutOrder = 1
ESPToggleFrame.Parent = ESPMainSection

local ESPLabel = Instance.new("TextLabel")
ESPLabel.Size = UDim2.new(0.7, 0, 1, 0)
ESPLabel.BackgroundTransparency = 1
ESPLabel.Text = "ESP Enabled"
ESPLabel.TextColor3 = TextColorColor
ESPLabel.TextSize = 14
ESPLabel.Font = Enum.Font.Code
ESPLabel.TextXAlignment = Enum.TextXAlignment.Left
ESPLabel.Parent = ESPToggleFrame

local ESPCheckbox = Instance.new("TextButton")
ESPCheckbox.Size = UDim2.new(0, 20, 0, 20)
ESPCheckbox.Position = UDim2.new(0.85, 0, 0.1, 0)
ESPCheckbox.BackgroundColor3 = MainGradientTopColor
ESPCheckbox.Text = ""
ESPCheckbox.AutoButtonColor = false
ESPCheckbox.Parent = ESPToggleFrame

local ESPCheckboxStroke = Instance.new("UIStroke")
ESPCheckboxStroke.Color = AccentStrokeColor
ESPCheckboxStroke.Thickness = 1
ESPCheckboxStroke.Parent = ESPCheckbox

local ESPCheckboxCorner = Instance.new("UICorner")
ESPCheckboxCorner.CornerRadius = UDim.new(0, 4)
ESPCheckboxCorner.Parent = ESPCheckbox

local ESPCheckmark = Instance.new("TextLabel")
ESPCheckmark.Size = UDim2.new(1, 0, 1, 0)
ESPCheckmark.BackgroundTransparency = 1
ESPCheckmark.Text = "✓"
ESPCheckmark.TextColor3 = NeonBorderColor
ESPCheckmark.TextSize = 14
ESPCheckmark.Font = Enum.Font.Code
ESPCheckmark.Visible = getgenv().ESP.Enabled
ESPCheckmark.Parent = ESPCheckbox

ESPCheckbox.MouseButton1Click:Connect(function()
    getgenv().ESP.Enabled = not getgenv().ESP.Enabled
    ESPCheckmark.Visible = getgenv().ESP.Enabled
end)

-- ESP Features Section
local ESPFeaturesSection = CreateSectionBox(ESPScroll, "ESP FEATURES", 2, 180)
local ESPFeaturesLayout = Instance.new("UIListLayout")
ESPFeaturesLayout.SortOrder = Enum.SortOrder.LayoutOrder
ESPFeaturesLayout.Padding = UDim.new(0, 5)
ESPFeaturesLayout.Parent = ESPFeaturesSection

-- ESP Checkbox Function
local function CreateESPCheckbox(parent, labelText, configKey, defaultValue, layoutOrder)
    local CheckboxFrame = Instance.new("Frame")
    CheckboxFrame.Size = UDim2.new(1, 0, 0, 25)
    CheckboxFrame.BackgroundTransparency = 1
    CheckboxFrame.LayoutOrder = layoutOrder
    CheckboxFrame.Parent = parent

    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(0.7, 0, 1, 0)
    Label.BackgroundTransparency = 1
    Label.Text = labelText
    Label.TextColor3 = TextColorColor
    Label.TextSize = 14
    Label.Font = Enum.Font.Code
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = CheckboxFrame

    local Checkbox = Instance.new("TextButton")
    Checkbox.Size = UDim2.new(0, 20, 0, 20)
    Checkbox.Position = UDim2.new(0.85, 0, 0.1, 0)
    Checkbox.BackgroundColor3 = MainGradientTopColor
    Checkbox.Text = ""
    Checkbox.AutoButtonColor = false
    Checkbox.Parent = CheckboxFrame

    local CheckboxStroke = Instance.new("UIStroke")
    CheckboxStroke.Color = AccentStrokeColor
    CheckboxStroke.Thickness = 1
    CheckboxStroke.Parent = Checkbox

    local CheckboxCorner = Instance.new("UICorner")
    CheckboxCorner.CornerRadius = UDim.new(0, 4)
    CheckboxCorner.Parent = Checkbox

    local Checkmark = Instance.new("TextLabel")
    Checkmark.Size = UDim2.new(1, 0, 1, 0)
    Checkmark.BackgroundTransparency = 1
    Checkmark.Text = "✓"
    Checkmark.TextColor3 = NeonBorderColor
    Checkmark.TextSize = 14
    Checkmark.Font = Enum.Font.Code
    Checkmark.Visible = defaultValue
    Checkmark.Parent = Checkbox

    Checkbox.MouseButton1Click:Connect(function()
        getgenv().ESP[configKey] = not getgenv().ESP[configKey]
        Checkmark.Visible = getgenv().ESP[configKey]
    end)

    return CheckboxFrame
end

-- Create ESP Checkboxes
local BoxesCheckFrame = CreateESPCheckbox(ESPFeaturesSection, "Boxes", "Boxes", true, 1)
local TracersCheckFrame = CreateESPCheckbox(ESPFeaturesSection, "Tracers", "Tracers", true, 2)
local NamesCheckFrame = CreateESPCheckbox(ESPFeaturesSection, "Names", "Names", true, 3)
local DistanceCheckFrame = CreateESPCheckbox(ESPFeaturesSection, "Distance", "Distance", true, 4)
local HealthBarCheckFrame = CreateESPCheckbox(ESPFeaturesSection, "Health Bar", "HealthBar", true, 5)

-- ESP Settings Section
local ESPSettingsSection = CreateSectionBox(ESPScroll, "ESP SETTINGS", 3, 150)
local ESPSettingsLayout = Instance.new("UIListLayout")
ESPSettingsLayout.SortOrder = Enum.SortOrder.LayoutOrder
ESPSettingsLayout.Padding = UDim.new(0, 5)
ESPSettingsLayout.Parent = ESPSettingsSection

local TeamESPCheckFrame = CreateESPCheckbox(ESPSettingsSection, "Team Check", "TeamCheck", true, 1)
local RainbowESPCheckFrame = CreateESPCheckbox(ESPSettingsSection, "Rainbow ESP", "Rainbow", true, 2)

-- ESP Color Picker
local ESPColorFrame = Instance.new("Frame")
ESPColorFrame.Size = UDim2.new(1, 0, 0, 50)
ESPColorFrame.BackgroundTransparency = 1
ESPColorFrame.LayoutOrder = 3
ESPColorFrame.Parent = ESPSettingsSection

local ESPColorLabel = Instance.new("TextLabel")
ESPColorLabel.Size = UDim2.new(0.6, 0, 1, 0)
ESPColorLabel.BackgroundTransparency = 1
ESPColorLabel.Text = "ESP Color"
ESPColorLabel.TextColor3 = TextColorColor
ESPColorLabel.TextSize = 14
ESPColorLabel.Font = Enum.Font.Code
ESPColorLabel.TextXAlignment = Enum.TextXAlignment.Left
ESPColorLabel.Parent = ESPColorFrame

local ESPColorPreview = Instance.new("TextButton")
ESPColorPreview.Size = UDim2.new(0, 40, 0, 40)
ESPColorPreview.Position = UDim2.new(0.7, 0, 0.05, 0)
ESPColorPreview.BackgroundColor3 = getgenv().ESP.BoxColor
ESPColorPreview.Text = ""
ESPColorPreview.AutoButtonColor = false
ESPColorPreview.ZIndex = 1003
ESPColorPreview.Parent = ESPColorFrame

local ESPPreviewStroke = Instance.new("UIStroke")
ESPPreviewStroke.Color = AccentStrokeColor
ESPPreviewStroke.Thickness = 1
ESPPreviewStroke.Parent = ESPColorPreview

local ESPPreviewCorner = Instance.new("UICorner")
ESPPreviewCorner.CornerRadius = UDim.new(0, 4)
ESPPreviewCorner.Parent = ESPColorPreview

-- ESP Configuration Section
local ESPConfigSection = CreateSectionBox(ESPScroll, "ESP CONFIGURATION", 4, 180)
local ESPConfigLayout = Instance.new("UIListLayout")
ESPConfigLayout.SortOrder = Enum.SortOrder.LayoutOrder
ESPConfigLayout.Padding = UDim.new(0, 5)
ESPConfigLayout.Parent = ESPConfigSection

-- ESP Slider Function
local function CreateESPSlider(parent, labelText, configKey, minValue, maxValue, defaultValue, step, layoutOrder)
    local SliderFrame = Instance.new("Frame")
    SliderFrame.Size = UDim2.new(1, 0, 0, 40)
    SliderFrame.BackgroundTransparency = 1
    SliderFrame.LayoutOrder = layoutOrder
    SliderFrame.Parent = parent

    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(1, 0, 0, 20)
    Label.BackgroundTransparency = 1
    Label.Text = labelText .. ": " .. defaultValue
    Label.TextColor3 = TextColorColor
    Label.TextSize = 14
    Label.Font = Enum.Font.Code
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = SliderFrame

    local Slider = Instance.new("TextButton")
    Slider.Size = UDim2.new(1, 0, 0, 12)
    Slider.Position = UDim2.new(0, 0, 0, 25)
    Slider.BackgroundColor3 = MainGradientTopColor
    Slider.Text = ""
    Slider.AutoButtonColor = false
    Slider.Parent = SliderFrame

    local SliderFill = Instance.new("Frame")
    SliderFill.Size = UDim2.new((defaultValue - minValue) / (maxValue - minValue), 0, 1, 0)
    SliderFill.BackgroundColor3 = NeonBorderColor
    SliderFill.BorderSizePixel = 0
    SliderFill.Parent = Slider

    local SliderStroke = Instance.new("UIStroke")
    SliderStroke.Color = AccentStrokeColor
    SliderStroke.Thickness = 1
    SliderStroke.Parent = Slider

    local function updateValue(value)
        local normalizedValue = math.clamp(value, 0, 1)
        local scaledValue = minValue + (normalizedValue * (maxValue - minValue))
        
        if step then
            scaledValue = math.floor(scaledValue / step) * step
        end
        
        scaledValue = math.clamp(scaledValue, minValue, maxValue)
        getgenv().ESP[configKey] = math.floor(scaledValue)
        Label.Text = labelText .. ": " .. getgenv().ESP[configKey]
        SliderFill.Size = UDim2.new(normalizedValue, 0, 1, 0)
    end

    Slider.MouseButton1Down:Connect(function()
        local connection
        connection = RunService.Heartbeat:Connect(function()
            local mousePos = UserInputService:GetMouseLocation()
            local sliderPos = Slider.AbsolutePosition
            local sliderSize = Slider.AbsoluteSize
            local relativeX = math.clamp((mousePos.X - sliderPos.X) / sliderSize.X, 0, 1)
            updateValue(relativeX)
        end)
        
        local endedConnection
        endedConnection = UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                connection:Disconnect()
                endedConnection:Disconnect()
            end
        end)
    end)

    return SliderFrame
end

-- ESP Thickness Slider Function
local function CreateESPThicknessSlider(parent, labelText, configKey, minValue, maxValue, defaultValue, layoutOrder)
    local SliderFrame = Instance.new("Frame")
    SliderFrame.Size = UDim2.new(1, 0, 0, 40)
    SliderFrame.BackgroundTransparency = 1
    SliderFrame.LayoutOrder = layoutOrder
    SliderFrame.Parent = parent

    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(1, 0, 0, 20)
    Label.BackgroundTransparency = 1
    Label.Text = labelText .. ": " .. defaultValue
    Label.TextColor3 = TextColorColor
    Label.TextSize = 14
    Label.Font = Enum.Font.Code
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = SliderFrame

    local Slider = Instance.new("TextButton")
    Slider.Size = UDim2.new(1, 0, 0, 12)
    Slider.Position = UDim2.new(0, 0, 0, 25)
    Slider.BackgroundColor3 = MainGradientTopColor
    Slider.Text = ""
    Slider.AutoButtonColor = false
    Slider.Parent = SliderFrame

    local SliderFill = Instance.new("Frame")
    SliderFill.Size = UDim2.new((defaultValue - minValue) / (maxValue - minValue), 0, 1, 0)
    SliderFill.BackgroundColor3 = NeonBorderColor
    SliderFill.BorderSizePixel = 0
    SliderFill.Parent = Slider

    local SliderStroke = Instance.new("UIStroke")
    SliderStroke.Color = AccentStrokeColor
    SliderStroke.Thickness = 1
    SliderStroke.Parent = Slider

    local function updateValue(value)
        local normalizedValue = math.clamp(value, 0, 1)
        local scaledValue = minValue + (normalizedValue * (maxValue - minValue))
        scaledValue = math.floor(scaledValue)
        scaledValue = math.clamp(scaledValue, minValue, maxValue)
        getgenv().ESP[configKey] = scaledValue
        Label.Text = labelText .. ": " .. getgenv().ESP[configKey]
        SliderFill.Size = UDim2.new(normalizedValue, 0, 1, 0)
    end

    Slider.MouseButton1Down:Connect(function()
        local connection
        connection = RunService.Heartbeat:Connect(function()
            local mousePos = UserInputService:GetMouseLocation()
            local sliderPos = Slider.AbsolutePosition
            local sliderSize = Slider.AbsoluteSize
            local relativeX = math.clamp((mousePos.X - sliderPos.X) / sliderSize.X, 0, 1)
            updateValue(relativeX)
        end)
        
        local endedConnection
        endedConnection = UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                connection:Disconnect()
                endedConnection:Disconnect()
            end
        end)
    end)

    return SliderFrame
end

-- Create ESP Sliders
local ESPDistanceSlider = CreateESPSlider(ESPConfigSection, "Max Distance", "MaxDistance", 50, 2000, 1200, 50, 1)
local BoxThicknessSlider = CreateESPThicknessSlider(ESPConfigSection, "Box Thickness", "BoxThickness", 1, 5, 2, 2)
local TracerThicknessSlider = CreateESPThicknessSlider(ESPConfigSection, "Tracer Thickness", "TracerThickness", 1, 5, 1, 3)

-- ESP Color Picker Connection
ESPColorPreview.MouseButton1Click:Connect(function()
    local currentColor = getgenv().ESP.BoxColor
    local r, g, b = currentColor.R, currentColor.G, currentColor.B
    local newR = 1 - r
    local newG = 1 - g
    local newB = 1 - b
    local newColor = Color3.new(newR, newG, newB)
    getgenv().ESP.BoxColor = newColor
    getgenv().ESP.TracerColor = newColor
    ESPColorPreview.BackgroundColor3 = newColor
end)

-- =============================================================================
-- AIMBOT TAB CONTENT
-- =============================================================================

local AimbotScroll = Instance.new("ScrollingFrame")
AimbotScroll.Size = UDim2.new(1, -20, 1, -20)
AimbotScroll.Position = UDim2.new(0, 10, 0, 10)
AimbotScroll.BackgroundTransparency = 1
AimbotScroll.ScrollBarThickness = 6
AimbotScroll.ScrollBarImageColor3 = NeonBorderColor
AimbotScroll.ZIndex = 1003
AimbotScroll.Parent = AimbotTab

local AimbotLayout = Instance.new("UIListLayout")
AimbotLayout.SortOrder = Enum.SortOrder.LayoutOrder
AimbotLayout.Padding = UDim.new(0, 10)
AimbotLayout.Parent = AimbotScroll

AimbotLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    AimbotScroll.CanvasSize = UDim2.new(0, 0, 0, AimbotLayout.AbsoluteContentSize.Y + 10)
end)

-- Aimbot Main Section
local AimbotMainSection = CreateSectionBox(AimbotScroll, "AIMBOT MAIN", 1, 80)
local AimbotMainLayout = Instance.new("UIListLayout")
AimbotMainLayout.SortOrder = Enum.SortOrder.LayoutOrder
AimbotMainLayout.Padding = UDim.new(0, 5)
AimbotMainLayout.Parent = AimbotMainSection

-- Aimbot Toggle
local AimbotToggleFrame = Instance.new("Frame")
AimbotToggleFrame.Size = UDim2.new(1, 0, 0, 25)
AimbotToggleFrame.BackgroundTransparency = 1
AimbotToggleFrame.LayoutOrder = 1
AimbotToggleFrame.Parent = AimbotMainSection

local AimbotLabel = Instance.new("TextLabel")
AimbotLabel.Size = UDim2.new(0.7, 0, 1, 0)
AimbotLabel.BackgroundTransparency = 1
AimbotLabel.Text = "Aimbot Enabled"
AimbotLabel.TextColor3 = TextColorColor
AimbotLabel.TextSize = 14
AimbotLabel.Font = Enum.Font.Code
AimbotLabel.TextXAlignment = Enum.TextXAlignment.Left
AimbotLabel.Parent = AimbotToggleFrame

local AimbotCheckbox = Instance.new("TextButton")
AimbotCheckbox.Size = UDim2.new(0, 20, 0, 20)
AimbotCheckbox.Position = UDim2.new(0.85, 0, 0.1, 0)
AimbotCheckbox.BackgroundColor3 = MainGradientTopColor
AimbotCheckbox.Text = ""
AimbotCheckbox.AutoButtonColor = false
AimbotCheckbox.Parent = AimbotToggleFrame

local AimbotCheckboxStroke = Instance.new("UIStroke")
AimbotCheckboxStroke.Color = AccentStrokeColor
AimbotCheckboxStroke.Thickness = 1
AimbotCheckboxStroke.Parent = AimbotCheckbox

local AimbotCheckboxCorner = Instance.new("UICorner")
AimbotCheckboxCorner.CornerRadius = UDim.new(0, 4)
AimbotCheckboxCorner.Parent = AimbotCheckbox

local AimbotCheckmark = Instance.new("TextLabel")
AimbotCheckmark.Size = UDim2.new(1, 0, 1, 0)
AimbotCheckmark.BackgroundTransparency = 1
AimbotCheckmark.Text = "✓"
AimbotCheckmark.TextColor3 = NeonBorderColor
AimbotCheckmark.TextSize = 14
AimbotCheckmark.Font = Enum.Font.Code
AimbotCheckmark.Visible = getgenv().Aimbot.Enabled
AimbotCheckmark.Parent = AimbotCheckbox

AimbotCheckbox.MouseButton1Click:Connect(function()
    getgenv().Aimbot.Enabled = not getgenv().Aimbot.Enabled
    AimbotCheckmark.Visible = getgenv().Aimbot.Enabled
end)

-- Keybind Info
local KeybindLabel = Instance.new("TextLabel")
KeybindLabel.Size = UDim2.new(1, 0, 0, 20)
KeybindLabel.BackgroundTransparency = 1
KeybindLabel.Text = "Aim Key: Right Click (Hold)"
KeybindLabel.TextColor3 = TextColorColor
KeybindLabel.TextSize = 12
KeybindLabel.Font = Enum.Font.Code
KeybindLabel.TextXAlignment = Enum.TextXAlignment.Left
KeybindLabel.LayoutOrder = 2
KeybindLabel.Parent = AimbotMainSection

-- Aimbot Settings Section
local AimbotSettingsSection = CreateSectionBox(AimbotScroll, "AIMBOT SETTINGS", 2, 180)
local AimbotSettingsLayout = Instance.new("UIListLayout")
AimbotSettingsLayout.SortOrder = Enum.SortOrder.LayoutOrder
AimbotSettingsLayout.Padding = UDim.new(0, 5)
AimbotSettingsLayout.Parent = AimbotSettingsSection

-- Aimbot Checkbox Function
local function CreateAimbotCheckbox(parent, labelText, configKey, defaultValue, layoutOrder)
    local CheckboxFrame = Instance.new("Frame")
    CheckboxFrame.Size = UDim2.new(1, 0, 0, 25)
    CheckboxFrame.BackgroundTransparency = 1
    CheckboxFrame.LayoutOrder = layoutOrder
    CheckboxFrame.Parent = parent

    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(0.7, 0, 1, 0)
    Label.BackgroundTransparency = 1
    Label.Text = labelText
    Label.TextColor3 = TextColorColor
    Label.TextSize = 14
    Label.Font = Enum.Font.Code
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = CheckboxFrame

    local Checkbox = Instance.new("TextButton")
    Checkbox.Size = UDim2.new(0, 20, 0, 20)
    Checkbox.Position = UDim2.new(0.85, 0, 0.1, 0)
    Checkbox.BackgroundColor3 = MainGradientTopColor
    Checkbox.Text = ""
    Checkbox.AutoButtonColor = false
    Checkbox.Parent = CheckboxFrame

    local CheckboxStroke = Instance.new("UIStroke")
    CheckboxStroke.Color = AccentStrokeColor
    CheckboxStroke.Thickness = 1
    CheckboxStroke.Parent = Checkbox

    local CheckboxCorner = Instance.new("UICorner")
    CheckboxCorner.CornerRadius = UDim.new(0, 4)
    CheckboxCorner.Parent = Checkbox

    local Checkmark = Instance.new("TextLabel")
    Checkmark.Size = UDim2.new(1, 0, 1, 0)
    Checkmark.BackgroundTransparency = 1
    Checkmark.Text = "✓"
    Checkmark.TextColor3 = NeonBorderColor
    Checkmark.TextSize = 14
    Checkmark.Font = Enum.Font.Code
    Checkmark.Visible = defaultValue
    Checkmark.Parent = Checkbox

    Checkbox.MouseButton1Click:Connect(function()
        getgenv().Aimbot[configKey] = not getgenv().Aimbot[configKey]
        Checkmark.Visible = getgenv().Aimbot[configKey]
    end)

    return CheckboxFrame
end

-- Create Aimbot Checkboxes
local TeamCheckFrame = CreateAimbotCheckbox(AimbotSettingsSection, "Team Check", "TeamCheck", true, 1)
local VisibleCheckFrame = CreateAimbotCheckbox(AimbotSettingsSection, "Visible Check", "VisibleCheck", true, 2)
local RainbowFOVFrame = CreateAimbotCheckbox(AimbotSettingsSection, "Rainbow FOV", "RainbowFOV", false, 3)
local ToggleModeFrame = CreateAimbotCheckbox(AimbotSettingsSection, "Toggle Mode", "Toggle", false, 4)

-- Aimbot Configuration Section
local AimbotConfigSection = CreateSectionBox(AimbotScroll, "AIMBOT CONFIGURATION", 3, 180)
local AimbotConfigLayout = Instance.new("UIListLayout")
AimbotConfigLayout.SortOrder = Enum.SortOrder.LayoutOrder
AimbotConfigLayout.Padding = UDim.new(0, 5)
AimbotConfigLayout.Parent = AimbotConfigSection

-- Aimbot Slider Function
local function CreateAimbotSlider(parent, labelText, configKey, minValue, maxValue, defaultValue, decimals, layoutOrder)
    local SliderFrame = Instance.new("Frame")
    SliderFrame.Size = UDim2.new(1, 0, 0, 40)
    SliderFrame.BackgroundTransparency = 1
    SliderFrame.LayoutOrder = layoutOrder
    SliderFrame.Parent = parent

    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(1, 0, 0, 20)
    Label.BackgroundTransparency = 1
    Label.Text = labelText .. ": " .. defaultValue
    Label.TextColor3 = TextColorColor
    Label.TextSize = 14
    Label.Font = Enum.Font.Code
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = SliderFrame

    local Slider = Instance.new("TextButton")
    Slider.Size = UDim2.new(1, 0, 0, 12)
    Slider.Position = UDim2.new(0, 0, 0, 25)
    Slider.BackgroundColor3 = MainGradientTopColor
    Slider.Text = ""
    Slider.AutoButtonColor = false
    Slider.Parent = SliderFrame

    local SliderFill = Instance.new("Frame")
    SliderFill.Size = UDim2.new((defaultValue - minValue) / (maxValue - minValue), 0, 1, 0)
    SliderFill.BackgroundColor3 = NeonBorderColor
    SliderFill.BorderSizePixel = 0
    SliderFill.Parent = Slider

    local SliderStroke = Instance.new("UIStroke")
    SliderStroke.Color = AccentStrokeColor
    SliderStroke.Thickness = 1
    SliderStroke.Parent = Slider

    local function updateValue(value)
        local normalizedValue = math.clamp(value, 0, 1)
        local scaledValue = minValue + (normalizedValue * (maxValue - minValue))
        
        if decimals == 0 then
            scaledValue = math.floor(scaledValue)
        else
            scaledValue = math.floor(scaledValue * (10 ^ decimals)) / (10 ^ decimals)
        end
        
        scaledValue = math.clamp(scaledValue, minValue, maxValue)
        getgenv().Aimbot[configKey] = scaledValue
        
        if decimals == 0 then
            Label.Text = labelText .. ": " .. scaledValue
        else
            Label.Text = labelText .. ": " .. string.format("%." .. decimals .. "f", scaledValue)
        end
        
        SliderFill.Size = UDim2.new(normalizedValue, 0, 1, 0)
        
        if configKey == "FOV" then
            FOVCircle.Radius = scaledValue
        end
    end

    Slider.MouseButton1Down:Connect(function()
        local connection
        connection = RunService.Heartbeat:Connect(function()
            local mousePos = UserInputService:GetMouseLocation()
            local sliderPos = Slider.AbsolutePosition
            local sliderSize = Slider.AbsoluteSize
            local relativeX = math.clamp((mousePos.X - sliderPos.X) / sliderSize.X, 0, 1)
            updateValue(relativeX)
        end)
        
        local endedConnection
        endedConnection = UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                connection:Disconnect()
                endedConnection:Disconnect()
            end
        end)
    end)

    return SliderFrame
end

-- Create Aimbot Sliders
local FOVSlider = CreateAimbotSlider(AimbotConfigSection, "Aim FOV", "FOV", 10, 600, 80, 0, 1)
local SmoothSlider = CreateAimbotSlider(AimbotConfigSection, "Smoothing", "Smoothing", 0.00, 1.00, 0.05, 2, 2)
local PredictionSlider = CreateAimbotSlider(AimbotConfigSection, "Prediction", "Prediction", 0, 0.3, 0.15, 2, 3)

-- Target Part Section
local TargetPartSection = CreateSectionBox(AimbotScroll, "TARGET SETTINGS", 4, 80)
local TargetPartLayout = Instance.new("UIListLayout")
TargetPartLayout.SortOrder = Enum.SortOrder.LayoutOrder
TargetPartLayout.Padding = UDim.new(0, 5)
TargetPartLayout.Parent = TargetPartSection

-- Target Part Dropdown
local TargetPartFrame = Instance.new("Frame")
TargetPartFrame.Size = UDim2.new(1, 0, 0, 50)
TargetPartFrame.BackgroundTransparency = 1
TargetPartFrame.LayoutOrder = 1
TargetPartFrame.Parent = TargetPartSection

local TargetPartLabel = Instance.new("TextLabel")
TargetPartLabel.Size = UDim2.new(1, 0, 0, 20)
TargetPartLabel.BackgroundTransparency = 1
TargetPartLabel.Text = "Target Part"
TargetPartLabel.TextColor3 = TextColorColor
TargetPartLabel.TextSize = 14
TargetPartLabel.Font = Enum.Font.Code
TargetPartLabel.TextXAlignment = Enum.TextXAlignment.Left
TargetPartLabel.Parent = TargetPartFrame

local TargetPartDropdown = Instance.new("TextButton")
TargetPartDropdown.Size = UDim2.new(1, 0, 0, 25)
TargetPartDropdown.Position = UDim2.new(0, 0, 0, 20)
TargetPartDropdown.BackgroundColor3 = MainGradientTopColor
TargetPartDropdown.TextColor3 = TextColorColor
TargetPartDropdown.Text = "Head"
TargetPartDropdown.TextSize = 12
TargetPartDropdown.Font = Enum.Font.Code
TargetPartDropdown.Parent = TargetPartFrame

local TargetPartStroke = Instance.new("UIStroke")
TargetPartStroke.Color = AccentStrokeColor
TargetPartStroke.Thickness = 1
TargetPartStroke.Parent = TargetPartDropdown

local TargetPartCorner = Instance.new("UICorner")
TargetPartCorner.CornerRadius = UDim.new(0, 4)
TargetPartCorner.Parent = TargetPartDropdown

-- Dropdown Menu Function
local function CreateDropdown(dropdownButton, options, defaultOption, callback)
    local dropdownOpen = false
    local dropdownMenu
    
    local function CloseDropdown()
        if dropdownMenu then
            dropdownMenu:Destroy()
            dropdownMenu = nil
        end
        dropdownOpen = false
    end
    
    local function OpenDropdown()
        if dropdownOpen then
            CloseDropdown()
            return
        end
        
        dropdownOpen = true
        dropdownMenu = Instance.new("Frame")
        dropdownMenu.Size = UDim2.new(1, 0, 0, math.min(#options * 25, 125))
        dropdownMenu.Position = UDim2.new(0, 0, 1, 2)
        dropdownMenu.BackgroundColor3 = MainGradientTopColor
        dropdownMenu.ZIndex = 1004
        dropdownMenu.Parent = dropdownButton
        
        local dropdownStroke = Instance.new("UIStroke")
        dropdownStroke.Color = AccentStrokeColor
        dropdownStroke.Thickness = 1
        dropdownStroke.Parent = dropdownMenu
        
        local dropdownCorner = Instance.new("UICorner")
        dropdownCorner.CornerRadius = UDim.new(0, 4)
        dropdownCorner.Parent = dropdownMenu
        
        -- Create scrolling frame
        local dropdownScroll = Instance.new("ScrollingFrame")
        dropdownScroll.Size = UDim2.new(1, 0, 1, 0)
        dropdownScroll.BackgroundTransparency = 1
        dropdownScroll.ScrollBarThickness = 4
        dropdownScroll.ScrollBarImageColor3 = NeonBorderColor
        dropdownScroll.CanvasSize = UDim2.new(0, 0, 0, #options * 25)
        dropdownScroll.ZIndex = 1005
        dropdownScroll.Parent = dropdownMenu
        
        for i, option in ipairs(options) do
            local optionButton = Instance.new("TextButton")
            optionButton.Size = UDim2.new(1, 0, 0, 25)
            optionButton.Position = UDim2.new(0, 0, 0, (i-1)*25)
            optionButton.BackgroundColor3 = MainGradientTopColor
            optionButton.TextColor3 = TextColorColor
            optionButton.Text = option
            optionButton.TextSize = 12
            optionButton.Font = Enum.Font.Code
            optionButton.ZIndex = 1006
            optionButton.Parent = dropdownScroll
            
            optionButton.MouseButton1Click:Connect(function()
                dropdownButton.Text = option
                callback(option)
                CloseDropdown()
            end)
            
            optionButton.MouseEnter:Connect(function()
                optionButton.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
            end)
            
            optionButton.MouseLeave:Connect(function()
                optionButton.BackgroundColor3 = MainGradientTopColor
            end)
        end
    end
    
    dropdownButton.MouseButton1Click:Connect(OpenDropdown)
    
    -- Close dropdown when clicking elsewhere
    UserInputService.InputBegan:Connect(function(input)
        if dropdownOpen and input.UserInputType == Enum.UserInputType.MouseButton1 then
            local mousePos = UserInputService:GetMouseLocation()
            local dropdownPos = dropdownMenu.AbsolutePosition
            local dropdownSize = dropdownMenu.AbsoluteSize
            
            if not (mousePos.X >= dropdownPos.X and mousePos.X <= dropdownPos.X + dropdownSize.X and
                   mousePos.Y >= dropdownPos.Y and mousePos.Y <= dropdownPos.Y + dropdownSize.Y) then
                CloseDropdown()
            end
        end
    end)
end

-- Create Target Part Dropdown
CreateDropdown(TargetPartDropdown, {"Head", "UpperTorso", "HumanoidRootPart", "LowerTorso"}, "Head", function(option)
    getgenv().Aimbot.AimPart = option
end)

-- =============================================================================
-- CROSSHAIR TAB CONTENT
-- =============================================================================

local CrosshairScroll = Instance.new("ScrollingFrame")
CrosshairScroll.Size = UDim2.new(1, -20, 1, -20)
CrosshairScroll.Position = UDim2.new(0, 10, 0, 10)
CrosshairScroll.BackgroundTransparency = 1
CrosshairScroll.ScrollBarThickness = 6
CrosshairScroll.ScrollBarImageColor3 = NeonBorderColor
CrosshairScroll.ZIndex = 1003
CrosshairScroll.Parent = CrosshairTab

local CrosshairLayout = Instance.new("UIListLayout")
CrosshairLayout.SortOrder = Enum.SortOrder.LayoutOrder
CrosshairLayout.Padding = UDim.new(0, 10)
CrosshairLayout.Parent = CrosshairScroll

CrosshairLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    CrosshairScroll.CanvasSize = UDim2.new(0, 0, 0, CrosshairLayout.AbsoluteContentSize.Y + 10)
end)

-- Crosshair Main Section
local CrosshairMainSection = CreateSectionBox(CrosshairScroll, "CROSSHAIR MAIN", 1, 80)
local CrosshairMainLayout = Instance.new("UIListLayout")
CrosshairMainLayout.SortOrder = Enum.SortOrder.LayoutOrder
CrosshairMainLayout.Padding = UDim.new(0, 5)
CrosshairMainLayout.Parent = CrosshairMainSection

-- Crosshair Toggle
local CrosshairToggleFrame = Instance.new("Frame")
CrosshairToggleFrame.Size = UDim2.new(1, 0, 0, 25)
CrosshairToggleFrame.BackgroundTransparency = 1
CrosshairToggleFrame.LayoutOrder = 1
CrosshairToggleFrame.Parent = CrosshairMainSection

local CrosshairLabel = Instance.new("TextLabel")
CrosshairLabel.Size = UDim2.new(0.7, 0, 1, 0)
CrosshairLabel.BackgroundTransparency = 1
CrosshairLabel.Text = "Crosshair Enabled"
CrosshairLabel.TextColor3 = TextColorColor
CrosshairLabel.TextSize = 14
CrosshairLabel.Font = Enum.Font.Code
CrosshairLabel.TextXAlignment = Enum.TextXAlignment.Left
CrosshairLabel.Parent = CrosshairToggleFrame

local CrosshairCheckbox = Instance.new("TextButton")
CrosshairCheckbox.Size = UDim2.new(0, 20, 0, 20)
CrosshairCheckbox.Position = UDim2.new(0.85, 0, 0.1, 0)
CrosshairCheckbox.BackgroundColor3 = MainGradientTopColor
CrosshairCheckbox.Text = ""
CrosshairCheckbox.AutoButtonColor = false
CrosshairCheckbox.Parent = CrosshairToggleFrame

local CrosshairCheckboxStroke = Instance.new("UIStroke")
CrosshairCheckboxStroke.Color = AccentStrokeColor
CrosshairCheckboxStroke.Thickness = 1
CrosshairCheckboxStroke.Parent = CrosshairCheckbox

local CrosshairCheckboxCorner = Instance.new("UICorner")
CrosshairCheckboxCorner.CornerRadius = UDim.new(0, 4)
CrosshairCheckboxCorner.Parent = CrosshairCheckbox

local CrosshairCheckmark = Instance.new("TextLabel")
CrosshairCheckmark.Size = UDim2.new(1, 0, 1, 0)
CrosshairCheckmark.BackgroundTransparency = 1
CrosshairCheckmark.Text = "✓"
CrosshairCheckmark.TextColor3 = NeonBorderColor
CrosshairCheckmark.TextSize = 14
CrosshairCheckmark.Font = Enum.Font.Code
CrosshairCheckmark.Visible = getgenv().Crosshair.Enabled
CrosshairCheckmark.Parent = CrosshairCheckbox

CrosshairCheckbox.MouseButton1Click:Connect(function()
    getgenv().Crosshair.Enabled = not getgenv().Crosshair.Enabled
    CrosshairCheckmark.Visible = getgenv().Crosshair.Enabled
    UpdateCrosshair()
end)

-- Crosshair Features Section
local CrosshairFeaturesSection = CreateSectionBox(CrosshairScroll, "CROSSHAIR FEATURES", 2, 80)
local CrosshairFeaturesLayout = Instance.new("UIListLayout")
CrosshairFeaturesLayout.SortOrder = Enum.SortOrder.LayoutOrder
CrosshairFeaturesLayout.Padding = UDim.new(0, 5)
CrosshairFeaturesLayout.Parent = CrosshairFeaturesSection

-- Crosshair Checkbox Function
local function CreateCrosshairCheckbox(parent, labelText, configKey, defaultValue, layoutOrder)
    local CheckboxFrame = Instance.new("Frame")
    CheckboxFrame.Size = UDim2.new(1, 0, 0, 25)
    CheckboxFrame.BackgroundTransparency = 1
    CheckboxFrame.LayoutOrder = layoutOrder
    CheckboxFrame.Parent = parent

    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(0.7, 0, 1, 0)
    Label.BackgroundTransparency = 1
    Label.Text = labelText
    Label.TextColor3 = TextColorColor
    Label.TextSize = 14
    Label.Font = Enum.Font.Code
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = CheckboxFrame

    local Checkbox = Instance.new("TextButton")
    Checkbox.Size = UDim2.new(0, 20, 0, 20)
    Checkbox.Position = UDim2.new(0.85, 0, 0.1, 0)
    Checkbox.BackgroundColor3 = MainGradientTopColor
    Checkbox.Text = ""
    Checkbox.AutoButtonColor = false
    Checkbox.Parent = CheckboxFrame

    local CheckboxStroke = Instance.new("UIStroke")
    CheckboxStroke.Color = AccentStrokeColor
    CheckboxStroke.Thickness = 1
    CheckboxStroke.Parent = Checkbox

    local CheckboxCorner = Instance.new("UICorner")
    CheckboxCorner.CornerRadius = UDim.new(0, 4)
    CheckboxCorner.Parent = Checkbox

    local Checkmark = Instance.new("TextLabel")
    Checkmark.Size = UDim2.new(1, 0, 1, 0)
    Checkmark.BackgroundTransparency = 1
    Checkmark.Text = "✓"
    Checkmark.TextColor3 = NeonBorderColor
    Checkmark.TextSize = 14
    Checkmark.Font = Enum.Font.Code
    Checkmark.Visible = defaultValue
    Checkmark.Parent = Checkbox

    Checkbox.MouseButton1Click:Connect(function()
        getgenv().Crosshair[configKey] = not getgenv().Crosshair[configKey]
        Checkmark.Visible = getgenv().Crosshair[configKey]
        UpdateCrosshair()
    end)

    return CheckboxFrame
end

-- Create Crosshair Checkboxes
local CenterDotFrame = CreateCrosshairCheckbox(CrosshairFeaturesSection, "Center Dot", "CenterDot", true, 1)
local RainbowCrosshairFrame = CreateCrosshairCheckbox(CrosshairFeaturesSection, "Rainbow Crosshair", "RainbowCrosshair", true, 2)

-- Crosshair Configuration Section
local CrosshairConfigSection = CreateSectionBox(CrosshairScroll, "CROSSHAIR CONFIGURATION", 3, 200)
local CrosshairConfigLayout = Instance.new("UIListLayout")
CrosshairConfigLayout.SortOrder = Enum.SortOrder.LayoutOrder
CrosshairConfigLayout.Padding = UDim.new(0, 5)
CrosshairConfigLayout.Parent = CrosshairConfigSection

-- Crosshair Slider Function
local function CreateCrosshairSlider(parent, labelText, configKey, minValue, maxValue, defaultValue, decimals, layoutOrder)
    local SliderFrame = Instance.new("Frame")
    SliderFrame.Size = UDim2.new(1, 0, 0, 40)
    SliderFrame.BackgroundTransparency = 1
    SliderFrame.LayoutOrder = layoutOrder
    SliderFrame.Parent = parent

    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(1, 0, 0, 20)
    Label.BackgroundTransparency = 1
    Label.Text = labelText .. ": " .. defaultValue
    Label.TextColor3 = TextColorColor
    Label.TextSize = 14
    Label.Font = Enum.Font.Code
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = SliderFrame

    local Slider = Instance.new("TextButton")
    Slider.Size = UDim2.new(1, 0, 0, 12)
    Slider.Position = UDim2.new(0, 0, 0, 25)
    Slider.BackgroundColor3 = MainGradientTopColor
    Slider.Text = ""
    Slider.AutoButtonColor = false
    Slider.Parent = SliderFrame

    local SliderFill = Instance.new("Frame")
    SliderFill.Size = UDim2.new((defaultValue - minValue) / (maxValue - minValue), 0, 1, 0)
    SliderFill.BackgroundColor3 = NeonBorderColor
    SliderFill.BorderSizePixel = 0
    SliderFill.Parent = Slider

    local SliderStroke = Instance.new("UIStroke")
    SliderStroke.Color = AccentStrokeColor
    SliderStroke.Thickness = 1
    SliderStroke.Parent = Slider

    local function updateValue(value)
        local normalizedValue = math.clamp(value, 0, 1)
        local scaledValue = minValue + (normalizedValue * (maxValue - minValue))
        
        if decimals == 0 then
            scaledValue = math.floor(scaledValue)
        else
            scaledValue = math.floor(scaledValue * (10 ^ decimals)) / (10 ^ decimals)
        end
        
        scaledValue = math.clamp(scaledValue, minValue, maxValue)
        getgenv().Crosshair[configKey] = scaledValue
        
        if decimals == 0 then
            Label.Text = labelText .. ": " .. scaledValue
        else
            Label.Text = labelText .. ": " .. string.format("%." .. decimals .. "f", scaledValue)
        end
        
        SliderFill.Size = UDim2.new(normalizedValue, 0, 1, 0)
        UpdateCrosshair()
    end

    Slider.MouseButton1Down:Connect(function()
        local connection
        connection = RunService.Heartbeat:Connect(function()
            local mousePos = UserInputService:GetMouseLocation()
            local sliderPos = Slider.AbsolutePosition
            local sliderSize = Slider.AbsoluteSize
            local relativeX = math.clamp((mousePos.X - sliderPos.X) / sliderSize.X, 0, 1)
            updateValue(relativeX)
        end)
        
        local endedConnection
        endedConnection = UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                connection:Disconnect()
                endedConnection:Disconnect()
            end
        end)
    end)

    return SliderFrame
end

-- Create Crosshair Sliders
local CrosshairSizeSlider = CreateCrosshairSlider(CrosshairConfigSection, "Crosshair Size", "Size", 8, 24, 14, 0, 1)
local CrosshairThicknessSlider = CreateCrosshairSlider(CrosshairConfigSection, "Crosshair Thickness", "Thickness", 1, 5, 2, 0, 2)
local CrosshairGapSlider = CreateCrosshairSlider(CrosshairConfigSection, "Gap Size", "GapSize", 2, 10, 4, 0, 3)
local CrosshairTransparencySlider = CreateCrosshairSlider(CrosshairConfigSection, "Transparency", "Transparency", 0, 1, 0.8, 2, 4)

-- Crosshair Color Section
local CrosshairColorSection = CreateSectionBox(CrosshairScroll, "CROSSHAIR COLOR", 4, 80)
local CrosshairColorLayout = Instance.new("UIListLayout")
CrosshairColorLayout.SortOrder = Enum.SortOrder.LayoutOrder
CrosshairColorLayout.Padding = UDim.new(0, 5)
CrosshairColorLayout.Parent = CrosshairColorSection

-- Crosshair Color Picker
local CrosshairColorFrame = Instance.new("Frame")
CrosshairColorFrame.Size = UDim2.new(1, 0, 0, 50)
CrosshairColorFrame.BackgroundTransparency = 1
CrosshairColorFrame.LayoutOrder = 1
CrosshairColorFrame.Parent = CrosshairColorSection

local CrosshairColorLabel = Instance.new("TextLabel")
CrosshairColorLabel.Size = UDim2.new(0.6, 0, 1, 0)
CrosshairColorLabel.BackgroundTransparency = 1
CrosshairColorLabel.Text = "Crosshair Color"
CrosshairColorLabel.TextColor3 = TextColorColor
CrosshairColorLabel.TextSize = 14
CrosshairColorLabel.Font = Enum.Font.Code
CrosshairColorLabel.TextXAlignment = Enum.TextXAlignment.Left
CrosshairColorLabel.Parent = CrosshairColorFrame

local CrosshairColorPreview = Instance.new("TextButton")
CrosshairColorPreview.Size = UDim2.new(0, 40, 0, 40)
CrosshairColorPreview.Position = UDim2.new(0.7, 0, 0.05, 0)
CrosshairColorPreview.BackgroundColor3 = getgenv().Crosshair.Color
CrosshairColorPreview.Text = ""
CrosshairColorPreview.AutoButtonColor = false
CrosshairColorPreview.ZIndex = 1003
CrosshairColorPreview.Parent = CrosshairColorFrame

local CrosshairPreviewStroke = Instance.new("UIStroke")
CrosshairPreviewStroke.Color = AccentStrokeColor
CrosshairPreviewStroke.Thickness = 1
CrosshairPreviewStroke.Parent = CrosshairColorPreview

local CrosshairPreviewCorner = Instance.new("UICorner")
CrosshairPreviewCorner.CornerRadius = UDim.new(0, 4)
CrosshairPreviewCorner.Parent = CrosshairColorPreview

CrosshairColorPreview.MouseButton1Click:Connect(function()
    local currentColor = getgenv().Crosshair.Color
    local r, g, b = currentColor.R, currentColor.G, currentColor.B
    local newR = 1 - r
    local newG = 1 - g
    local newB = 1 - b
    local newColor = Color3.new(newR, newG, newB)
    getgenv().Crosshair.Color = newColor
    CrosshairColorPreview.BackgroundColor3 = newColor
    UpdateCrosshair()
end)

-- =============================================================================
-- SETTINGS TAB CONTENT
-- =============================================================================

local SettingsScroll = Instance.new("ScrollingFrame")
SettingsScroll.Size = UDim2.new(1, -20, 1, -20)
SettingsScroll.Position = UDim2.new(0, 10, 0, 10)
SettingsScroll.BackgroundTransparency = 1
SettingsScroll.ScrollBarThickness = 6
SettingsScroll.ScrollBarImageColor3 = NeonBorderColor
SettingsScroll.ZIndex = 1003
SettingsScroll.Parent = SettingsTab

local SettingsLayout = Instance.new("UIListLayout")
SettingsLayout.SortOrder = Enum.SortOrder.LayoutOrder
SettingsLayout.Padding = UDim.new(0, 10)
SettingsLayout.Parent = SettingsScroll

SettingsLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    SettingsScroll.CanvasSize = UDim2.new(0, 0, 0, SettingsLayout.AbsoluteContentSize.Y + 10)
end)

-- Color Management Functions
local function ApplyColors()
    if UIReferences.MainFrame then
        UIReferences.MainFrame.BackgroundColor3 = MainGradientTopColor
    end
    
    if UIReferences.MainGradient then
        UIReferences.MainGradient.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, MainGradientTopColor),
            ColorSequenceKeypoint.new(1, MainGradientBottomColor)
        })
    end
    
    if UIReferences.OuterGlow then
        UIReferences.OuterGlow.Color = NeonBorderColor
    end
    
    if UIReferences.TopBarStroke then
        UIReferences.TopBarStroke.Color = AccentStrokeColor
    end
    
    if UIReferences.CloseStroke then
        UIReferences.CloseStroke.Color = AccentStrokeColor
    end
    
    if UIReferences.TopBar then
        UIReferences.TopBar.BackgroundColor3 = MainGradientTopColor
    end
    
    if UIReferences.Sidebar then
        UIReferences.Sidebar.BackgroundColor3 = MainGradientTopColor
    end
    
    if UIReferences.Content then
        UIReferences.Content.BackgroundColor3 = MainGradientTopColor
    end
    
    if UIReferences.SidebarGradient then
        UIReferences.SidebarGradient.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, MainGradientTopColor),
            ColorSequenceKeypoint.new(1, MainGradientBottomColor)
        })
    end
    
    if UIReferences.ContentGradient then
        UIReferences.ContentGradient.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, MainGradientTopColor),
            ColorSequenceKeypoint.new(1, MainGradientBottomColor)
        })
    end
    
    if UIReferences.Title then
        UIReferences.Title.TextColor3 = TextColorColor
    end
    
    if UIReferences.CloseButton then
        UIReferences.CloseButton.TextColor3 = NeonBorderColor
    end
    
    for _, button in pairs(UIReferences.tabButtons) do
        if button then 
            button.TextColor3 = TextColorColor
        end
    end
    
    for _, underline in pairs(UIReferences.tabUnderlines) do
        if underline then 
            underline.BackgroundColor3 = NeonBorderColor
        end
    end
    
    if UIReferences.Divider then
        UIReferences.Divider.BackgroundColor3 = AccentStrokeColor
    end
    
    if UIReferences.SettingsScroll then
        UIReferences.SettingsScroll.ScrollBarImageColor3 = NeonBorderColor
    end
end

local function SetColor(colorKey, newColor)
    if colorKey == "MainGradientTop" then
        MainGradientTopColor = newColor
    elseif colorKey == "MainGradientBottom" then
        MainGradientBottomColor = newColor
    elseif colorKey == "NeonBorder" then
        NeonBorderColor = newColor
    elseif colorKey == "AccentStroke" then
        AccentStrokeColor = newColor
    elseif colorKey == "TextColor" then
        TextColorColor = newColor
    elseif colorKey == "ESPColor" then
        getgenv().ESP.BoxColor = newColor
        getgenv().ESP.TracerColor = newColor
    else
        return false
    end
    
    if ColorPreviews[colorKey] then
        ColorPreviews[colorKey].BackgroundColor3 = newColor
    end
    
    ApplyColors()
    return true
end

local function GetColor(colorKey)
    if colorKey == "MainGradientTop" then
        return MainGradientTopColor
    elseif colorKey == "MainGradientBottom" then
        return MainGradientBottomColor
    elseif colorKey == "NeonBorder" then
        return NeonBorderColor
    elseif colorKey == "AccentStroke" then
        return AccentStrokeColor
    elseif colorKey == "TextColor" then
        return TextColorColor
    elseif colorKey == "ESPColor" then
        return getgenv().ESP.BoxColor
    end
    return Color3.new(1, 1, 1)
end

-- UI Colors Section
local UIColorSection = CreateSectionBox(SettingsScroll, "UI COLORS", 1, 300)
local UIColorLayout = Instance.new("UIListLayout")
UIColorLayout.SortOrder = Enum.SortOrder.LayoutOrder
UIColorLayout.Padding = UDim.new(0, 5)
UIColorLayout.Parent = UIColorSection

-- Simple Color Picker Function
local function CreateColorPicker(parent, labelText, colorKey, layoutOrder)
    local PickerFrame = Instance.new("Frame")
    PickerFrame.Size = UDim2.new(1, 0, 0, 50)
    PickerFrame.BackgroundTransparency = 1
    PickerFrame.LayoutOrder = layoutOrder
    PickerFrame.Parent = parent

    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(0.6, 0, 1, 0)
    Label.BackgroundTransparency = 1
    Label.Text = labelText
    Label.TextColor3 = TextColorColor
    Label.TextSize = 14
    Label.Font = Enum.Font.Code
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = PickerFrame

    -- Color Preview Box
    local ColorPreview = Instance.new("TextButton")
    ColorPreview.Name = "ColorPreview"
    ColorPreview.Size = UDim2.new(0, 40, 0, 40)
    ColorPreview.Position = UDim2.new(0.7, 0, 0.05, 0)
    ColorPreview.BackgroundColor3 = GetColor(colorKey)
    ColorPreview.Text = ""
    ColorPreview.AutoButtonColor = false
    ColorPreview.ZIndex = 1003
    ColorPreview.Parent = PickerFrame

    -- Store in global table
    ColorPreviews[colorKey] = ColorPreview

    local PreviewStroke = Instance.new("UIStroke")
    PreviewStroke.Color = AccentStrokeColor
    PreviewStroke.Thickness = 1
    PreviewStroke.Parent = ColorPreview

    local PreviewCorner = Instance.new("UICorner")
    PreviewCorner.CornerRadius = UDim.new(0, 4)
    PreviewCorner.Parent = ColorPreview

    -- Click to change color
    ColorPreview.MouseButton1Click:Connect(function()
        local currentColor = GetColor(colorKey)
        local r, g, b = currentColor.R, currentColor.G, currentColor.B
        local newR = 1 - r
        local newG = 1 - g
        local newB = 1 - b
        local newColor = Color3.new(newR, newG, newB)
        SetColor(colorKey, newColor)
    end)

    -- Add hover effect
    ColorPreview.MouseEnter:Connect(function()
        TweenService:Create(PreviewStroke, TweenInfo.new(0.2), {Color = NeonBorderColor}):Play()
    end)

    ColorPreview.MouseLeave:Connect(function()
        TweenService:Create(PreviewStroke, TweenInfo.new(0.2), {Color = AccentStrokeColor}):Play()
    end)
end

-- Create Color Pickers in Settings Tab
CreateColorPicker(UIColorSection, "Main Gradient Top", "MainGradientTop", 1)
CreateColorPicker(UIColorSection, "Main Gradient Bottom", "MainGradientBottom", 2)
CreateColorPicker(UIColorSection, "Neon Border", "NeonBorder", 3)
CreateColorPicker(UIColorSection, "Accent Stroke", "AccentStroke", 4)
CreateColorPicker(UIColorSection, "Text Color", "TextColor", 5)

-- Keybind Section
local KeybindSection = CreateSectionBox(SettingsScroll, "KEYBIND SETTINGS", 2, 120)
local KeybindLayout = Instance.new("UIListLayout")
KeybindLayout.SortOrder = Enum.SortOrder.LayoutOrder
KeybindLayout.Padding = UDim.new(0, 5)
KeybindLayout.Parent = KeybindSection

-- Initialize variables
local ToggleKey = Enum.KeyCode.P
local IsListeningForKeybind = false
local GuiVisible = true

local KeybindLabel = Instance.new("TextLabel")
KeybindLabel.Size = UDim2.new(1, 0, 0, 20)
KeybindLabel.BackgroundTransparency = 1
KeybindLabel.Text = "Current Toggle Key: " .. ToggleKey.Name
KeybindLabel.TextColor3 = TextColorColor
KeybindLabel.TextSize = 12
KeybindLabel.Font = Enum.Font.Code
KeybindLabel.TextXAlignment = Enum.TextXAlignment.Left
KeybindLabel.LayoutOrder = 1
KeybindLabel.Parent = KeybindSection

local VisibilityLabel = Instance.new("TextLabel")
VisibilityLabel.Size = UDim2.new(1, 0, 0, 20)
VisibilityLabel.BackgroundTransparency = 1
VisibilityLabel.Text = "Menu: " .. (GuiVisible and "Visible" or "Hidden")
VisibilityLabel.TextColor3 = TextColorColor
VisibilityLabel.TextSize = 12
VisibilityLabel.Font = Enum.Font.Code
VisibilityLabel.TextXAlignment = Enum.TextXAlignment.Left
VisibilityLabel.LayoutOrder = 2
VisibilityLabel.Parent = KeybindSection

local SetKeyButton = Instance.new("TextButton")
SetKeyButton.Size = UDim2.new(1, 0, 0, 30)
SetKeyButton.LayoutOrder = 3
SetKeyButton.BackgroundColor3 = NeonBorderColor
SetKeyButton.Text = "Set New Key"
SetKeyButton.TextColor3 = MainGradientTopColor
SetKeyButton.TextSize = 12
SetKeyButton.Font = Enum.Font.Code
SetKeyButton.Parent = KeybindSection

SetKeyButton.MouseButton1Click:Connect(function()
    IsListeningForKeybind = true
    KeybindLabel.Text = "Press a key to set new bind..."
    SetKeyButton.Text = "Listening..."
    SetKeyButton.BackgroundColor3 = AccentStrokeColor
end)

-- =============================================================================
-- INPUT HANDLING AND MAIN GAME LOOP
-- =============================================================================

-- Input handling
UserInputService.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton2 then
        if getgenv().Aimbot.Toggle then
            aiming = not aiming
        else
            aiming = true
        end
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton2 and not getgenv().Aimbot.Toggle then
        aiming = false
    end
end)

-- Keybind Toggle Logic
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end

    if IsListeningForKeybind and input.KeyCode ~= Enum.KeyCode.Unknown then
        ToggleKey = input.KeyCode
        KeybindLabel.Text = "Current Toggle Key: " .. ToggleKey.Name
        SetKeyButton.Text = "Set New Key"
        SetKeyButton.BackgroundColor3 = NeonBorderColor
        IsListeningForKeybind = false
        return
    end

    if input.KeyCode == ToggleKey then
        GuiVisible = not GuiVisible
        VisibilityLabel.Text = "Menu: " .. (GuiVisible and "Visible" or "Hidden")
        MainFrame.Visible = GuiVisible
    end
end)

-- Close Button Logic
CloseButton.MouseButton1Click:Connect(function()
    -- Cleanup ESP drawings
    CleanupESP()
    -- Remove FOV circle
    if FOVCircle then
        FOVCircle:Remove()
    end
    -- Remove crosshair
    for _, part in pairs({CrosshairTop, CrosshairBottom, CrosshairLeft, CrosshairRight, CrosshairCenter}) do
        if part then part:Remove() end
    end
    -- Destroy UI
    ScreenGui:Destroy()
    getgenv().PetyaX = false
end)

-- Dragging Logic for Main Window
local dragging, dragInput, dragStart, startPos

local function update(input)
    local delta = input.Position - dragStart
    MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
end

TopBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = MainFrame.Position
        
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

TopBar.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement then
        dragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        update(input)
    end
end)

-- Initial color application
ApplyColors()

-- =============================================================================
-- UPDATED MAIN GAME LOOP
-- =============================================================================

RunService.RenderStepped:Connect(function()
    -- Update FOV circle
    FOVCircle.Position = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
    if getgenv().Aimbot.RainbowFOV then
        FOVCircle.Color = GetRainbowColor()
    end
    
    -- UPDATED: Run ultra accurate aimbot
    if aiming and getgenv().Aimbot.Enabled then
        local target = FindTarget()
        if target then
            MoveCrosshairToTarget(target)
        end
    end
    
    -- UPDATED: Run fixed ESP with full body boxes
    if getgenv().ESP.Enabled then
        UpdateESP()
    else
        -- Hide all ESP when disabled
        for _, drawings in pairs(ESPDrawings) do
            for _, drawing in pairs(drawings) do
                drawing.Visible = false
            end
        end
    end
    
    -- Update crosshair
    UpdateCrosshair()
end)

-- Initialize ESP for all players
for _, player in pairs(Players:GetPlayers()) do
    CreateESP(player)
end

Players.PlayerAdded:Connect(function(player)
    wait(1)
    CreateESP(player)
end)

Players.PlayerRemoving:Connect(function(player)
    if ESPDrawings[player] then
        for _, drawing in pairs(ESPDrawings[player]) do
            drawing:Remove()
        end
        ESPDrawings[player] = nil
    end
end)

print("🎯 PetyaX ULTRA ACCURATE FPS Enhancement Suite Fully Loaded!")
print("👁️ FIXED ESP: Full body boxes & accurate health bars")
print("🎯 ULTRA ACCURATE AIMBOT: Advanced prediction & smoothing")
print("💾 CONFIG SYSTEM: Ready (./PetyaX/)")
print("🌈 Rainbow ESP: Ready")
print("🎯 Crosshair System: Working (Customizable, Rainbow)")
print("🎨 Custom UI: Ready (Boxed Sections, Professional Design)")
print("🔧 All Features: Fully Functional")
print("Press " .. ToggleKey.Name .. " to toggle the menu")
