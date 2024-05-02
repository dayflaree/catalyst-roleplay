
SWEP.Base                = "weapon_base"
SWEP.Category	= "Catalyst (Firearms)"
SWEP.Spawnable           = true
SWEP.AdminSpawnable          = true
SWEP.AdminOnly = false
SWEP.UseHands = true
 
SWEP.ViewModel				= "models/weapons/Immolator/v_immolator.mdl"
SWEP.WorldModel				= ""

SWEP.Primary.Sound = "weapons/immolator/immolator_fire_player_01.wav"
SWEP.Primary.ClipSize    = -1
SWEP.Primary.DefaultClip = 9999
SWEP.Primary.Automatic   = true
SWEP.Primary.Ammo                = "Plasma"

SWEP.Secondary.ClipSize  = -1
SWEP.Secondary.Delay             = 3
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic         = true
SWEP.Secondary.Ammo              = ""

SWEP.IronSightsPos = Vector(0, -18, -20)
SWEP.IronSightsAng = Vector(45, 0, 0)

 
	SWEP.PrintName  = "Immolator"                       
    SWEP.Author       = "Dnjido"
    SWEP.Instructions = ""
    SWEP.ViewModelFOV = 60
    SWEP.Slot         = 4

 
	SWEP.DrawCrosshair = true

	SWEP.Weight = 50

	SWEP.AutoSwitchTo = false
	SWEP.AutoSwitchFrom = false


function SWEP:CustomAmmoDisplay()
                               
local table1={}
		table1.Draw = true
		table1.PrimaryClip = self.Owner:GetAmmoCount(self.Primary.Ammo)
		table1.PrimaryAmmo = -1
		table1.SecondaryAmmo = -1

		return table1 
end

function SWEP:Initialize()
local NextSprintTime
        self:SetWeaponHoldType( "physgun" )
		if SERVER then
end
end 

local IRONSIGHT_TIME = 0.3
-- Time to enter in the ironsight mod

function SWEP:GetViewModelPosition(pos, ang)

	if (not self.IronSightsPos) then return pos, ang end

	local bIron = self.Weapon:GetNWBool("Ironsights")

	if (bIron != self.bLastIron) then
		self.bLastIron = bIron
		self.fIronTime = CurTime()

	end

	local fIronTime = self.fIronTime or 0

	if (not bIron and fIronTime < CurTime() - IRONSIGHT_TIME) then
		return pos, ang
	end

	local Mul = 1.0

	if (fIronTime > CurTime() - IRONSIGHT_TIME) then
		Mul = math.Clamp((CurTime() - fIronTime) / IRONSIGHT_TIME, 0, 1)

		if not bIron then Mul = 1 - Mul end
	end

	local Offset	= self.IronSightsPos

	if (self.IronSightsAng) then
		ang = ang * 1
		ang:RotateAroundAxis(ang:Right(), 		self.IronSightsAng.x * Mul)
		ang:RotateAroundAxis(ang:Up(), 		self.IronSightsAng.y * Mul)
		ang:RotateAroundAxis(ang:Forward(), 	self.IronSightsAng.z * Mul)
	end

	local Right 	= ang:Right()
	local Up 		= ang:Up()
	local Forward 	= ang:Forward()

	pos = pos + Offset.x * Right * Mul
	pos = pos + Offset.y * Forward * Mul
	pos = pos + Offset.z * Up * Mul

	return pos, ang
end

function SWEP:SetIronsights(b)
	self.Weapon:SetNetworkedBool("Ironsights", b)
end

function SWEP:Think()
if SERVER then

	local vel = self.Owner:GetVelocity():Length()
	local crouchspeed = self.Owner:GetWalkSpeed() * self.Owner:GetCrouchedWalkSpeed()

if self.Owner:KeyDown(IN_ATTACK) then 
self:SetIronsights(false)
end
if self.Owner:KeyDown(IN_SPEED) and vel >= crouchspeed and self.Owner:OnGround() and !self.Owner:KeyDown(IN_ATTACK) and !self.Owner:KeyDown(IN_ATTACK2) then
if NextSprintTime == nil or CurTime() > NextSprintTime then
self:SetIronsights(true)
end
end
if self.Owner:KeyReleased(IN_SPEED) or self.Owner:KeyDown(IN_SPEED) and vel < crouchspeed or self.Owner:KeyDown(IN_SPEED) and !self.Owner:OnGround() then
self:SetIronsights(false)
end
if self.Owner:GetAmmoCount(self.Primary.Ammo) > 0 and self.Owner:KeyDown(IN_ATTACK) then
if (SERVER) then
local trace = self.Owner:GetEyeTrace()local flamefx = EffectData()
flamefx:SetOrigin(trace.HitPos)
flamefx:SetStart(self.Owner:GetShootPos())
flamefx:SetAttachment(1)
flamefx:SetEntity(self.Weapon)
util.Effect("immolator_flame",flamefx,true,true)

end
end
if self.Owner:KeyReleased(IN_ATTACK) then
self:StopSound( self.Primary.Sound )
self.Weapon:EmitSound("weapons/immolator/immolator_end_player_01.wav")
end




end
end

function SWEP:Reload()
self:DefaultReload(ACT_VM_RELOAD)
if self.Owner:KeyPressed(IN_RELOAD) then
self:SendWeaponAnim(ACT_VM_FIDGET)
end
end

function SWEP:PrimaryAttack()

if self.Owner:IsPlayer() and self.Owner:KeyDown(IN_ATTACK2) then return end
if !self.Owner:IsPlayer() or (self.Owner:IsPlayer() and self.Owner:GetAmmoCount(self.Primary.Ammo)>0) then

self.Weapon:EmitSound(Sound(self.Primary.Sound))

self:SendWeaponAnim(ACT_VM_PRIMARYATTACK)
self.Owner:SetAnimation(PLAYER_ATTACK1)
if self.Owner:IsPlayer() then
self.Owner:RemoveAmmo(1,self.Primary.Ammo)
end
self:SetNextPrimaryFire(CurTime()+0.01)

self.Owner:MuzzleFlash()

self.Weapon:SetNextPrimaryFire( CurTime() + 0.01 )

if self.Weapon:Ammo1() <= 0 then
	self:StopSound( self.Primary.Sound )
	self.Weapon:EmitSound("weapons/immolator/immolator_end_player_01.wav")
end

if (SERVER) then

	local trace = self.Owner:GetEyeTrace()
	local Distance = self.Owner:GetPos():Distance(trace.HitPos)

	if Distance < 520 then


	//This is how we ignite stuff
	local Ignite = function()

	//Safeguard
	if !self:IsValid() then return end

	//Damage things in radius of impact
	local flame = ents.Create("point_hurt")
	flame:SetPos(trace.HitPos)
	flame:SetOwner(self.Owner)
	flame:SetKeyValue("DamageRadius",128)
	flame:SetKeyValue("Damage",4)
	flame:SetKeyValue("DamageDelay",0.32)
	flame:SetKeyValue("DamageType",8)
	flame:Spawn()
	flame:Fire("TurnOn","",0) 
	flame:Fire("kill","",0.72)

	if trace.HitWorld then
	local nearbystuff = ents.FindInSphere(trace.HitPos, 100)

	for _, stuff in pairs(nearbystuff) do

	if stuff != self.Owner then

	if stuff:GetPhysicsObject():IsValid() && !stuff:IsNPC() && !stuff:IsPlayer() then
	if !stuff:IsOnFire() then stuff:Ignite(math.random(16,32), 100) end end

	if stuff:IsPlayer() then
	if stuff:GetPhysicsObject():IsValid() then
	stuff:Ignite(1, 100) end end

	if stuff:IsNPC() then
	if stuff:GetPhysicsObject():IsValid() then
	local npc = stuff:GetClass()
	if npc == "npc_antlionguard" || npc == "npc_hunter" || npc == "npc_kleiner"
	|| npc == "npc_gman" || npc == "npc_eli" || npc == "npc_alyx"
	|| npc == "npc_mossman" || npc == "npc_breen" || npc == "npc_monk"
	|| npc == "npc_vortigaunt" || npc == "npc_citizen" || npc == "npc_rebel"
	|| npc == "npc_barney" || npc == "npc_magnusson" then
	stuff:Fire("Ignite","",1)
	end
	stuff:Ignite(math.random(12,16), 100) end end

	end
	end
	end

	if trace.Entity:IsValid() then

	if trace.Entity:GetPhysicsObject():IsValid() && !trace.Entity:IsNPC() && !trace.Entity:IsPlayer() then
	if !trace.Entity:IsOnFire() then trace.Entity:Ignite(math.random(8,12), 100) end end

	if trace.Entity:IsPlayer() then
	if trace.Entity:GetPhysicsObject():IsValid() then
	trace.Entity:Ignite(math.random(1,2), 100) end end

	if trace.Entity:IsNPC() then
	if trace.Entity:GetPhysicsObject():IsValid() then
	local npc = trace.Entity:GetClass()
	if npc == "npc_antlionguard" || npc == "npc_hunter" || npc == "npc_kleiner"
	|| npc == "npc_gman" || npc == "npc_eli" || npc == "npc_alyx"
	|| npc == "npc_mossman" || npc == "npc_breen" || npc == "npc_monk"
	|| npc == "npc_vortigaunt" || npc == "npc_citizen" || npc == "npc_rebel"
	|| npc == "npc_barney" || npc == "npc_magnusson" then
	trace.Entity:Fire("Ignite","",1)
	end
	trace.Entity:Ignite(math.random(8,12), 100) end end

	end

	if (SERVER) then
	local firefx = EffectData()
	firefx:SetOrigin(trace.HitPos)
	util.Effect("",firefx,true,true)
	end

	end


	//Ignite stuff; based on how long it takes for flame to reach it
	timer.Simple(Distance/1520, Ignite)

	end

end

end
end

function SWEP:DoImpactEffect( trace, damageType )

	return true
end

function SWEP:FireAnimationEvent(pos,ang,event,options)
return true
end
 
function SWEP:SecondaryAttack()
end

