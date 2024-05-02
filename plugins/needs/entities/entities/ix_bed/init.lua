local PLUGIN = PLUGIN

AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

function ENT:Initialize()
    self:SetModel("models/props/de_inferno/bed.mdl")
    self:PhysicsInit(SOLID_VPHYSICS) 
    self:SetSolid(SOLID_VPHYSICS)
    self:SetUseType(SIMPLE_USE)
    self:SetOccupied(false)

    local physObj = self:GetPhysicsObject()
    if ( IsValid(physObj) ) then
        physObj:EnableMotion(false)
        physObj:Wake()
    end
end

function ENT:Use(ply)
    if ( ply:GetEyeTrace().Entity != self ) then
        return
    end

    local char = ply:GetCharacter()

    if not ( char ) then
        return
    end

    PLUGIN:StartSleeping(char, self)
end

function ENT:OnRemove()
    if not ( ix.shuttingDown ) then
        PLUGIN:SaveBeds()
    end
end