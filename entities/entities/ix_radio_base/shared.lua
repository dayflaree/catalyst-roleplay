ENT.Base = "base_gmodentity"
ENT.Type = "anim"
ENT.PrintName = "Base Radio"
ENT.Author = "Riggs"
ENT.Category = "Helix: HL2 RP"
ENT.Spawnable = false
ENT.AdminOnly = true
ENT.bNoPersist = true
ENT.Holdable = true

ENT.title = ""
ENT.description = ""

local modelData = {
    ["models/props_lab/citizenradio.mdl"] = {
        buttonPosOffsets = {
            off = Vector(10, 8.7, 7.4),
            on = Vector(10, 1.5, 7.4),
            next = Vector(10, -10, 7.4),
            prev = Vector(10, -10, 3.6)
        },
        camScale = 0.1,
        camPosOffset = Vector(0.9, -0.4, 0.88),
        visualSize = Vector(172, 35)
    },
}

function ENT:GetModelData()
    return modelData[self:GetModel()] and modelData[self:GetModel()] or {}
end

function ENT:GetButtonOnPos()
    return self:LocalToWorld(self.modelData.buttonPosOffsets.on)
end

function ENT:GetButtonOffPos()
    return self:LocalToWorld(self.modelData.buttonPosOffsets.off)
end

function ENT:GetButtonNextPos()
    return self:LocalToWorld(self.modelData.buttonPosOffsets.next)
end

function ENT:GetButtonPrevPos()
    return self:LocalToWorld(self.modelData.buttonPosOffsets.prev)
end

function ENT:SetupDataTables()
    self:NetworkVar("Bool", 0, "Enabled")
    self:NetworkVar("Bool", 1, "Exploded")
    self:NetworkVar("Int", 0, "CurrentSong")
end

