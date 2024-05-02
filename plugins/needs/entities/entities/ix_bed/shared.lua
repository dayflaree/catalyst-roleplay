ENT.Base = "base_gmodentity"
ENT.Type = "anim"
ENT.PrintName = "Bed"
ENT.Author = "eon (bloodycop)"
ENT.Category = "Catalyst (Citizen)"
ENT.Spawnable = true
ENT.AdminOnly = true
ENT.bNoPersist = true

function ENT:SetupDataTables()
    self:NetworkVar("Bool", 0, "Occupied")
end