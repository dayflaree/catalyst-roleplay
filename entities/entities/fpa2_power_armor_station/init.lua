AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include('shared.lua')

util.AddNetworkString("FPA_StationOpen")
util.AddNetworkString("FPA_SetArmorPiece")
-- -- -- --

function ENT:Initialize()
	self:SetModel("models/mosi/fallout4/furniture/workstations/powerarmorstation02.mdl")
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_NONE)
	self:SetSolid(SOLID_VPHYSICS)
	self:SetUseType(SIMPLE_USE)
	local phys = self:GetPhysicsObject()
	phys:Wake()
end

function ENT:GetConnectedArmor()
	return self.Armor;
end

function ENT:NotifyPlayer(ply, text)
	ply:ChatPrint("[Fallout 4 PA]: "..text);
end

function ENT:SetConnectedArmor( ent )
	self.Armor = ent;
end

function ENT:Use(ply)
	self.NextUse = self.NextUse or CurTime()-1
	if self.NextUse > CurTime() or ply:IsInPowerArmor() or ply:IsEnteringPowerArmor() then return end
	self.NextUse = CurTime()+1
	-- -- --
	local armor = self:GetConnectedArmor();
	if (IsValid(armor) and armor:GetPos():Distance( self:GetPos() )) then
		self.Armor = nil
		armor = nil
	end
	
	if (!IsValid(armor)) then
		local foundCloseBy = ents.FindInSphere(self:GetPos(), 300);
		for k,v in pairs(foundCloseBy) do
			if (v:GetClass() != "fpa2_power_armor_frame" or v.UsingPowerArmor) then continue end;
			--
			self:SetConnectedArmor(v);
			armor = v;
			break;
		end

		if (armor == nil) then
			self:NotifyPlayer(ply, "No Power Armor is close-by to this station!");
			return;
		end
	end
	-- -- --
	net.Start("FPA_StationOpen")
	net.WriteEntity(self)
	net.WriteEntity(armor)
	net.Send(ply)
end

-- -- -- -- -- -- -- -- --
--NETWORKING
net.Receive("FPA_SetArmorPiece", function(len, ply)
	local armor = net.ReadEntity();
	local armorType = net.ReadInt(5)
	local modelType = net.ReadString();
	-- -- --
	if (armor == nil) then print("ARMOR NIL") return end;
	--
	local distArmor = ply:GetPos():Distance( armor:GetPos() );
	if (distArmor > 300) then print("RETURNING") return end;
	--
	local actualArmorType = nil;
	for k,v in pairs(POWERARMOR.ArmorTypes) do
		if (v == armorType) then
			actualArmorType = k;
			break;
		end
	end
	if (actualArmorType == nil) then return end;
	if (POWERARMOR.Armor[modelType] == nil) then 
		modelType = nil;
	end;
	-- --
	armor:SetArmorPiece(actualArmorType, modelType);
end)