-- Modul - code.lua

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera

local LocalPlayer = Players.LocalPlayer
local FOVCircle = nil

local Aimbot = {}
Aimbot.Enabled = true
Aimbot.FOVRadius = 100  -- Standardwert für FOV
Aimbot.FOVCircle = nil  -- FOVCircle noch nicht gesetzt
Aimbot.FOVColor = Color3.fromRGB(255, 255, 255)  -- Standardfarbe (weiß)

-- Funktion zum Erstellen des FOV-Kreises, wenn er noch nicht existiert
local function CreateFOVCircle()
    if not Aimbot.FOVCircle then
        -- Wenn der FOV-Kreis noch nicht existiert, erstellen
        Aimbot.FOVCircle = Drawing.new("Circle")
        Aimbot.FOVCircle.Visible = false
        Aimbot.FOVCircle.Color = Aimbot.FOVColor
        Aimbot.FOVCircle.Radius = Aimbot.FOVRadius
        Aimbot.FOVCircle.Thickness = 1
        Aimbot.FOVCircle.Filled = false
    end
end

-- Funktion zum Aktualisieren des FOV-Kreises (bewegt ihn mit der Maus)
local function UpdateFOVCircle()
    local mousePos = UserInputService:GetMouseLocation()
    Aimbot.FOVCircle.Position = Vector2.new(mousePos.X, mousePos.Y)
end

-- Funktion, um den FOV-Kreis anzuzeigen oder zu verbergen
local function SetFOVCircleVisible(visible)
    if Aimbot.FOVCircle then
        Aimbot.FOVCircle.Visible = visible
    end
end

-- Funktion zum Anpassen des FOV-Radius
local function SetFOVRadius(radius)
    if Aimbot.FOVCircle then
        Aimbot.FOVCircle.Radius = radius
        Aimbot.FOVRadius = radius
    end
end

-- Funktion zum Ändern der FOV-Farbe
local function SetFOVColor(color)
    if Aimbot.FOVCircle then
        Aimbot.FOVCircle.Color = color
        Aimbot.FOVColor = color
    end
end

-- Wird im RenderStepped aufgerufen, um den FOV-Kreis ständig zu aktualisieren
RunService.RenderStepped:Connect(function()
    if Aimbot.Enabled then
        UpdateFOVCircle()
    end
end)

-- Öffentlich zugängliche Funktionen, die von außen verwendet werden
Aimbot.CreateFOVCircle = CreateFOVCircle
Aimbot.SetFOVCircleVisible = SetFOVCircleVisible
Aimbot.SetFOVRadius = SetFOVRadius
Aimbot.SetFOVColor = SetFOVColor

return Aimbot
