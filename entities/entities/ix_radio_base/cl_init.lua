include("shared.lua")

local LocalPlayer = LocalPlayer
local interpolationFunc = math.ease.OutQuint
local glowMaterial = ix.util.GetMaterial("sprites/light_glow02_add")
local color_green = Color(0, 255, 0, 255)
local color_red = Color(255, 0, 0, 255)

local maxSpritesDistanceSqr = 1024 * 1024
local maxVisualsDistanceSqr = 256 * 256

local function easedLerp(fraction, from, to)
    return Lerp(interpolationFunc(fraction), from, to)
end

function ENT:Initialize()
    self.frequency = 0
    self.modelData = self:GetModelData()

    local minBounds, maxBounds = self:GetRenderBounds()
    self.minBounds = minBounds
    self.maxBounds = maxBounds

    self.maxSongs = #self:GetMusicTable() or 0
    self.randomFrequencies = {}

    for i = 1, self.maxSongs do
        self.randomFrequencies[i] = math.random(5, 12)
    end
end

// Sprites
function ENT:RenderSprites()
    local buttonOn = self:GetButtonOnPos()
    local buttonOff = self:GetButtonOffPos()
    local buttonNext = self:GetButtonNextPos()
    local buttonPrev = self:GetButtonPrevPos()

    render.SetMaterial(glowMaterial)

    if self:GetEnabled() then
        render.DrawSprite(buttonOff, 10, 10, color_red)
        render.DrawSprite(buttonNext, 10, 10, Color(50, 50, 150, 255))
        render.DrawSprite(buttonPrev, 10, 10, Color(50, 150, 150, 255))
    else
        render.DrawSprite(buttonOn, 10, 10, color_green)
    end
end

// Frequency Visualization
function ENT:RenderFrequency()
    local modelData = self.modelData
    local visualSize = modelData.visualSize
    local camScale = modelData.camScale
    local camPosOffset = modelData.camPosOffset
    local currentSong = self:GetCurrentSong()

    self.frequency = ( math.abs(currentSong - self.frequency) < 0.05 ) and currentSong or easedLerp(FrameTime(), self.frequency, currentSong)

    local frequencyRatio = self.frequency / self.maxSongs
    local minBounds, maxBounds = self.minBounds, self.maxBounds
    local pos = self:LocalToWorld( maxBounds * camPosOffset )
    local ang = self:GetAngles()

    ang:RotateAroundAxis(ang:Up(), 90)
    ang:RotateAroundAxis(ang:Forward(), 90)

    cam.Start3D2D(pos, ang, camScale)
        surface.SetDrawColor(30, 30, 30, 255)
        surface.DrawRect(0, 0, visualSize.x, visualSize.y)

        surface.SetDrawColor(255, 255, 255, 255)

        for i = 1, self.maxSongs do
            local ySize = self.randomFrequencies[i]
            local x = ( i / self.maxSongs ) * visualSize.x - 6
            surface.DrawRect(x, visualSize.y - ySize, 1, ySize)
        end

        surface.SetDrawColor(150, 100, 59)
        surface.DrawRect(visualSize.x * frequencyRatio - 6, visualSize.y - 15, 2, 15)
    cam.End3D2D()
end

function ENT:Draw()
    self:DrawModel()

    local sqrDistance = LocalPlayer():GetPos():DistToSqr(self:GetPos())

    if sqrDistance > maxSpritesDistanceSqr then
        return
    end

    self:RenderSprites()

    if not ( self:GetEnabled() ) or sqrDistance > maxVisualsDistanceSqr then
        return
    end

    self:RenderFrequency()
end

function ENT:Think()
    self.ShowPlayerInteraction = LocalPlayer():KeyDown(IN_WALK)
end

ENT.PopulateEntityInfo = true

function ENT:OnPopulateEntityInfo(container)
    local title = container:AddRow("name")
    title:SetImportant()
    title:SetText(self.title)
    title:SetBackgroundColor(ix.config.Get("color"))
    title:SizeToContents()

    local description = container:AddRow("description")
    description:SetText(self.description)
    description:SizeToContents()
end