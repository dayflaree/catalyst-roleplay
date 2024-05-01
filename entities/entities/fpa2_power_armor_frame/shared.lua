ENT.Type = "anim"
ENT.Base = "base_entity"
ENT.Author = "Extra"
ENT.Category = "Fallout 4 Power Armor"
ENT.PrintName = "Power Armor Frame"
ENT.Spawnable = true
ENT.AdminSpawnable = true
ENT.CurrentArmor = ENT.CurrentArmor or {
    ["Head"] = "",
    ["Body"] = "",
    ["Left Arm"] = "",
    ["Right Arm"] = "",
    ["Left Leg"] = "",
    ["Right Leg"] = ""
}

function ENT:Think()
    -- Do stuff
    self:NextThink( CurTime() ) -- Set the next think to run as soon as possible, i.e. the next frame.
    return true -- Apply NextThink call
end