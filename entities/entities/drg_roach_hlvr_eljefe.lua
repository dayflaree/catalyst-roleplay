if not DrGBase then return end
ENT.Base = "drgbase_nextbot"

ENT.BloodColor = BLOOD_COLOR_ZOMBIE ENT.RagdollOnDeath = false ENT.Omniscient = false ENT.SpotDuration = 60 ENT.RangeAttackRange = 128 ENT.ReachEnemyRange = 30 ENT.UseWalkframes = true ENT.ClimbLedges = false ENT.ClimbProps = false ENT.ClimbLadders = false ENT.ClimbLaddersUp = false ENT.ClimbLaddersDown = false ENT.EyeBone = "head" ENT.PossessionEnabled = true ENT.PossessionPrompt = true ENT.PossessionCrosshair = true ENT.PossessionMovement = POSSESSION_MOVE_CUSTOM ENT.PossessionViews = {{offset = Vector(0, 135, 90),distance = 450},{offset = Vector(7.5, 0, 0),distance = 0,eyepos = true}}

-- Editables --
ENT.PrintName = "Jeff"
ENT.Category = "Catalyst (Zombies)"
ENT.Models = {"models/roach/hla/eljefe.mdl"}
ENT.CollisionBounds = Vector(25, 25, 110)
ENT.SpawnHealth = 2500
ENT.MeleeAttackRange = 60
ENT.Factions = {"FACTION_HLVR"}
ENT.PossessionViews = {{offset = Vector(0, 45, 15),distance = 150},{offset = Vector(7.5, 0, 0),distance = 0,eyepos = true}}
ENT.PossessionBinds = {
	[IN_ATTACK] = {{coroutine = true,onkeydown = function(self)
		self:EmitSound("roach/hlvr/zombie_blind/vox/atk_plr.mp3")
		self:PlaySequenceAndMove("kill_player",0.75,self.PossessionFaceForward)
	end}},
	[IN_USE] = {{coroutine = true,onkeydown = function(self)self:PlaySequenceAndMoveAbsolute("opendoors",{multiply=Vector(1.5,1,1)},self.PossessionFaceForward) end}},
	[IN_RELOAD] = {{coroutine = true,onkeydown = function(self)
		self:PlaySequenceAndMove(not self:IsRunning() and "detect" or ("lose"..math.random(2)))
	end}},
}
ENT.SightRange = 70

if SERVER then
ENT.IdleAnimation = "idle"
ENT.WalkAnimation = "walk"
ENT.RunAnimation = "run"

ENT.ClimbLedges = true
ENT.ClimbLedgesMaxHeight = 1000
ENT.LedgeDetectionDistance = 30
ENT.ClimbProps = true
ENT.ClimbLadders = true
ENT.LaddersUpDistance = 10
ENT.ClimbSpeed = 900
ENT.ClimbUpAnimation = "idle"
ENT.ClimbAnimRate = 1
ENT.ClimbOffset = Vector(-10, 0, 10)

function ENT:OnSpawn()
	ParticleEffectAttach("bo3_thrasher_aura",PATTACH_ABSORIGIN_FOLLOW,self,0)
	self:PlaySequenceAndMove("sense")
end
function ENT:CustomInitialize()
	for k,v in pairs(self:GetSequenceList()) do if string.find(v,"att") and not string.find(v,"grab") then self:SetAttack(v,true)end end
	self:SetDefaultRelationship(D_HT)
	self.Ready = true
	for i=1,math.random(3,5) do self:SequenceEvent("idle",math.random(),self.EmitIdleSound)end
	
	hook.Add("EntityEmitSound",self,function(self,sound)
		if self:IsPossessed() or self:IsAIDisabled() then return end
		if IsValid(sound.Entity) and not sound.Entity:IsPlayer() then return self:OnSound(sound.Entity,sound.SoundName) end
		if (GetConVar("ai_ignoreplayers"):GetInt()==1) then return end
		if (IsValid(sound.Entity) and sound.Entity:IsPlayer()) and string.find(sound.SoundName,"foot") then return end
		self.SoundTarget = sound.Pos 
	end)
	hook.Add("PlayerFootstep",self,function(self,ply,pos)
		if self:IsPossessed() or self:IsAIDisabled() or (GetConVar("ai_ignoreplayers"):GetInt()==1) then return end
		if self:IsInRange(ply,100) and not self:HasEnemy() then 
			self:SpotEntity(ply)
			self.SoundTarget = ply:GetPos()
		elseif not ply:KeyDown(IN_DUCK) then
			self.SoundTarget = ply:GetPos()
		end
	end)
	hook.Add("EntityFireBullets",self,function(self,ent)
		self.SoundTarget = ent:GetPos() 
		-- making an assumption here but honestly if an entity is firing a bullet there's a good chance it comes with a sound
		-- this is mostly a workaround for gmod's shitty bullshit where a player shooting a vanilla hl2 gun
		-- doesn't register as having made a sound serverside for SOME FUCKING REASON
		-- god i hate valve so fucking much
	end)
	hook.Add("PlayerSwitchFlashlight",self,function(self,ply)
		if self:IsPossessed() or self:IsAIDisabled() or (GetConVar("ai_ignoreplayers"):GetInt()==1) then return end
		if self:IsInRange(ply,150) then self:SpotEntity(ply) end
		-- WHY THE FUCK DOES THE FLASHLIGHT NOT MAKE A SOUND SERVERSIDE
		-- CAN YOU EVEN FUCKING PROGRAM YOU ACTUAL BRAINDEAD SPASTICS
	end)
end
function ENT:OnIdle()
	if self.SoundTarget ~= nil then 
		if self:IsPossessed() then return end
		if self.IdleAnimation=="idle" then
			self.IdleAnimation="idle_alert"
			self:PlaySequenceAndMove("alert") 
			--FUCKING PLAY THIS STUPID FUCKING SEQUENCE YOU FUCKING ACTUAL RETARD GOD I HATE GMOD CODE SO FUCKING MUUUUUUUUUUUUUUUUUUUUUUUCH
		end
		self:GoTo(self.SoundTarget,69,function(self)if self:IsInRange(self:GetClosestEnemy(),100) then return true end end) 
		if not self:IsInRange(self:GetClosestEnemy(),100) then self:PlaySequenceAndMove("lose"..math.random(2)) self.IdleAnimation = "idle" else self:OnMeleeAttack(self:GetClosestEnemy()) end
		self.SoundTarget = nil
	end
end
function ENT:OnIdleEnemy()return self:OnIdle() end
function ENT:OnIdleAfraidOf()return self:OnIdle() end
function ENT:EmitIdleSound()return self:EmitSound("roach/hlvr/zombie_blind/vox/growl"..math.random(9)..".mp3",80,100,1,CHAN_VOICE)end
function ENT:HandleAnimEvent(a,b,c,d,e)
	if e == "down" then self:EmitSound("roach/hlvr/zombie_blind/step/bass"..math.random(7)..".mp3",100)
	elseif e=="step" then 
		self:EmitSound("roach/hlvr/zombie_blind/step/step"..math.random(9)..".mp3",100)
		self:Timer(0.15,self.EmitSound,"roach/hlvr/zombie_blind/step/bass"..math.random(7)..".mp3",100)
	elseif e=="detect" then self:EmitSound("roach/hlvr/zombie_blind/vox/react"..math.random(3)..".mp3")
	elseif e=="jawo" then self:EmitSound("roach/hlvr/zombie_blind/jawo"..math.random(4)..".mp3")
	elseif e=="jaws" then self:EmitSound("roach/hlvr/zombie_blind/jaws"..math.random(3)..".mp3")
	end
	if e=="opendoors" then
		for k,door in pairs(ents.FindInSphere(self:LocalToWorld(Vector(0,0,75)), 100)) do
			if IsValid(door) and door:GetClass() == "prop_door_rotating" then
				door:EmitSound("roach/ds1/fsb.frpg_m10/door_wood_k.wav.mp3",100)
				door:SetNotSolid(true)
				door:Fire("setspeed",500)
				door:Fire("openawayfrom",self:GetName())
				
				self:Timer(85/30,function()
					door:Fire("setspeed",100)
					door:Fire("close")
					self:Timer(0.2,function()door:SetNotSolid(false)end)
				end)
			elseif IsValid(door) and string.find(door:GetClass(),"door") then
				door:EmitSound("roach/ds1/fsb.frpg_m10/door_wood_k.wav.mp3",100)
				door:Fire("open")
			end
			if IsValid(door) and string.find(door:GetClass(),"button") then door:Fire("press") end
		end
	end
	if e=="vom" then
		for i=1,3 do ParticleEffectAttach("blood_advisor_shrapnel_impact",PATTACH_POINT_FOLLOW,self,2)end
		for i=2,5 do self:Timer(0.5*i,self.Attack,{damage = function(ent)return ent:Health()*10 end,type = 65,range=125}) end
	end
end
function ENT:OnSound(target,snd)
	if self:IsPossessed() then return end
	if not target:IsNPC() and not target:IsNextBot() and not target:IsPlayer() and not string.find(target:GetClass(),"prop_physics") then return end
	if target==self then return end
	self.SoundTarget = target:GetPos()
end
function ENT:ShouldRun()
	return self.SoundTarget ~=nil
end
function ENT:OnMeleeAttack(enemy)
	self:EmitSound("roach/hlvr/zombie_blind/vox/atk_plr.mp3")
	self:PlaySequenceAndMove("kill_player",0.75,self.FaceEnemy)
end
function ENT:OnTakeDamage(dmg, dir, tr)
	dmg:SetDamage(0)
	if self.Flinching or self:IsDead() then	return end	
	if dmg:IsDamageType(DMG_BLAST) and math.random(4)==3 then
		self.Flinching = true
		self:CICO(function(self)
			local m = math.random(2)
			self:PlaySequenceAndMove("kd"..m.."_1")
			for i=0,math.random(15) do self:PlaySequenceAndMove("kd"..m.."_2") end
			self:PlaySequenceAndMove("kd"..m.."_3")
		end)
	end
end
function ENT:OnDeath(dmg, hitgroup) 
	self:DrG_Dissolve(3)
end
function ENT:OnUpdateAnimation()
	if !self.Ready or self:IsDead() or self:IsDown() then return end
	if !self:IsOnGround() then return self.JumpAnimation, 0.1
	elseif self:IsRunning() then return self.RunAnimation, self.RunAnimRate
	elseif self:IsMoving() then return self.WalkAnimation, self.WalkAnimRate
	else return self.IdleAnimation, self.IdleAnimRate end
end
function ENT:CICO(callback)
	local oldThread = self.BehaveThread
	self.BehaveThread = coroutine.create(function()
		callback(self)
		self.BehaveThread = oldThread
	end)
end
function ENT:PossessionControls(f,b,r,l)
	local direction = self:GetPos()
	if not self.Ready then return end
	if f then direction = direction + self:PossessorForward()
	elseif b then direction = direction - self:PossessorForward() end
	if r then direction = direction + self:PossessorRight()
	elseif l then direction = direction - self:PossessorRight() end
	if direction ~= self:GetPos() then self:MoveTowards(direction)
	end
end
end

AddCSLuaFile()
DrGBase.AddNextbot(ENT)
 