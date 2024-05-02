ENT.Type = "anim"
ENT.Base = "base_entity"
ENT.Author = "Extra"
ENT.Category = "Catalyst (Fallout)"
ENT.PrintName = "Power Armor Chassis"
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