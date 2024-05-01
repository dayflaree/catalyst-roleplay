AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include('shared.lua')

util.AddNetworkString("FPA_EntSeq")
util.AddNetworkString("FPA_UpdateArmor")
-- -- -- --
function ENT:Initialize()
	self:SetModel("models/fallout_4/furniture/powerarmorframe.mdl")
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_NONE)
	self:SetSolid(SOLID_VPHYSICS)
	self:SetUseType(SIMPLE_USE)
	local phys = self:GetPhysicsObject()
	phys:Wake()
end

function ENT:SetArmorPiece(armorType, armorModel)
	if (armorModel == nil) then
		armorModel = "";
	end

	self.CurrentArmor[armorType] = armorModel;
	local armorID = POWERARMOR.ArmorTypes[armorType];
	--
	net.Start("FPA_UpdateArmor")
	net.WriteEntity(self.Entity)
	net.WriteInt(armorID,5)
	net.WriteString(armorModel)
	net.Broadcast();
end

function ENT:SetArmor( armorTbl )
	for k,v in pairs(armorTbl) do
		self:SetArmorPiece(k, v);
	end
end

function ENT:Use(ply)
	if (self.UsingPowerArmor) then return end;
	--
	self.UsingPowerArmor = true;
	-- -- -- --
	self:PlayEntitySequence("Enter")
	ply:EnterPowerArmor(self)
	self:EmitSound("fallout_4_powerarmor/pa_enter.wav")
end

function ENT:PlayExitAnimation()
	self:PlayEntitySequence("Exit")
	self:EmitSound("fallout_4_powerarmor/pa_enter2.wav")
end

function ENT:PlayEntitySequence(name)
	local seqID = self:LookupSequence(name)
	self:ResetSequenceInfo()
	self:SetCycle(0)
	self:AddLayeredSequence(seqID, 1);
end