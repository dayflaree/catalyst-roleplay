ENT.Type 			= "anim"
ENT.Base 			= "base_anim"
ENT.PrintName		= "AI Director"
ENT.Author			= "Cpt. Hazama"
ENT.Contact			= ""
ENT.Purpose			= ""
ENT.Instructions	= ""
-- ENT.Category	= "VJ Base - HLA Antlion" Thank you Hazama for making this.

ENT.Spawnable			= false
ENT.AdminSpawnable		= false

if CLIENT then
	function ENT:Draw()
		return false
	end
end