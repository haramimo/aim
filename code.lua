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
Aimbot.FOVColor = Color3.fromRGB(255, 255, 255)  -- Standardfarbe (weiß)

-- Funktion zum Erstellen des FOV-Kreises
local function CreateFOVCircle()
    if not FOVCircle then
        -- Wenn der FOV-Kreis noch nicht existiert, erstellen
        FOVCircle = Drawing.new("Circle")
        FOVCircle.Visible = false
        FOVCircle.Color = Aimbot.FOVColor
        FOVCircle.Radius = Aimbot.FOVRadius
        FOVCircle.Thickness = 1
        FOVCircle.Filled = false
    end
end

-- Funktion zum Aktualisieren des FOV-Kreises (bewegt ihn mit der Maus)
local function UpdateFOVCircle()
    local mousePos = UserInputService:GetMouseLocation()
    FOVCircle.Position = Vector2.new(mousePos.X, mousePos.Y)
end

-- Funktion, um den FOV-Kreis anzuzeigen oder zu verbergen
local function SetFOVCircleVisible(visible)
    if FOVCircle then
        FOVCircle.Visible = visible
    end
end

-- Funktion zum Anpassen des FOV-Radius
local function SetFOVRadius(radius)
    if FOVCircle then
        FOVCircle.Radius = radius
        Aimbot.FOVRadius = radius
    end
end

-- Funktion zum Ändern der FOV-Farbe
local function SetFOVColor(color)
    if FOVCircle then
        FOVCircle.Color = color
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
