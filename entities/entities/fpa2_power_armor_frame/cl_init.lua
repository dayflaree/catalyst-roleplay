include("shared.lua")
ENT.ArmorPieces = ENT.ArmorPieces or {}

function ENT:Draw()
    self:DrawModel()
	
	for k,v in pairs(self.ArmorPieces) do
		if ( IsValid(v) and !IsValid(v:GetParent()) ) then
			v:SetParent(self.Entity);
		end
	end
end

function ENT:OnRemove()
	for k,v in pairs(self.ArmorPieces) do
		if (IsValid(v)) then
			v:Remove()
		end
	end
end

function ENT:SetArmorPiece(armorType, armorModel)
    if (IsValid(self.ArmorPieces[armorType])) then
        self.ArmorPieces[armorType]:Remove();
        self.CurrentArmor[armorType] = "";
    end

    if (armorModel == nil or armorModel == "") then return end
    -- -- --
    local clientMdl = ClientsideModel( POWERARMOR.Armor[armorModel][armorType] )
    clientMdl:SetParent( self )
    clientMdl:AddEffects( EF_BONEMERGE )
	clientMdl.Frame = self.Entity;
	
    self.ArmorPieces[armorType] = clientMdl;
    self.CurrentArmor[armorType] = armorModel
end

function ENT:AttemptSetArmorPiece(armorType, armorModel)
	local armorTypeID = nil;
	for k,v in pairs(POWERARMOR.ArmorTypes) do
		if (k == armorType) then
			armorTypeID = v;
			break
		end
	end
	-- --
	net.Start("FPA_SetArmorPiece")
	net.WriteEntity(self)
	net.WriteInt(armorTypeID, 5)
	net.WriteString(armorModel)
	net.SendToServer();
end

net.Receive("FPA_UpdateArmor", function()
	local frame = net.ReadEntity()
	local armorID = net.ReadInt(5)
	local armorModel = net.ReadString()
	-- --
	local actualArmorType = nil;
	for k,v in pairs(POWERARMOR.ArmorTypes) do
		if (v == armorID) then
			actualArmorType = k;
			break;
		end
	end
	-- --
	frame:SetArmorPiece(actualArmorType, armorModel);
	--
	if armorModel == nil then armorModel = "NONE" end;
end)