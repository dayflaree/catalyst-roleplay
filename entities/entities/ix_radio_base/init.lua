AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

function ENT:Initialize()
    self:SetModel("models/props_lab/citizenradio.mdl")
    self:PhysicsInit(SOLID_VPHYSICS) 
    self:SetSolid(SOLID_VPHYSICS)
    self:SetUseType(SIMPLE_USE)
    self:SetExploded(false)
    self:SetHealth(100)

    self.modelData = self:GetModelData()

    local physObj = self:GetPhysicsObject()

    if ( IsValid(physObj) ) then
        physObj:EnableMotion(false)
        physObj:Wake()
    end
end

function ENT:OnTakeDamage(damageInfo)
    self:SetHealth(math.max(self:Health() - damageInfo:GetDamage(), 0))
    self:EmitSound("physics/metal/metal_sheet_impact_bullet"..math.random(1, 2)..".wav", 80, math.random(95, 110))
    self:EmitSound("physics/metal/metal_sheet_impact_bullet"..math.random(1, 2)..".wav", 80, math.random(95, 110))
    
    if ( self:Health() <= 0 ) then
        self:Explode()
    end
end

function ENT:Explode()
    if ( self:GetExploded() ) then
        return
    end

    self:SetExploded(true)
    self:EmitSound("physics/metal/metal_sheet_impact_soft2.wav", 80, math.random(95, 110))

    local position = self:LocalToWorld(self:OBBCenter())
    local effect = EffectData()
        effect:SetStart(position)
        effect:SetOrigin(position)
        effect:SetScale(3)
    util.Effect("GlassImpact", effect)

    local angles = self:GetAngles()
    local pos = self:GetPos()
    timer.Simple(0.1, function()
        for i = 1, math.random(2, 5) do
            ix.item.Spawn("scrap_metal", pos + angles:Up() * 3, function(item, ent)
                local phys = ent:GetPhysicsObject()
                if not ( IsValid(phys) ) then
                    return
                end
    
                phys:SetVelocity(Vector(math.random(-250, 250), math.random(-250, 250), math.random(-250, 250)))
            end, angles, nil)
        end

        ix.item.Spawn("circuit_board", pos + angles:Up() * 3, function(item, ent)
            local phys = ent:GetPhysicsObject()
            if not ( IsValid(phys) ) then
                return
            end

            phys:SetVelocity(Vector(math.random(-250, 250), math.random(-250, 250), math.random(-250, 250)))
        end, angles, nil)
    end)

    self:Remove()
end

function ENT:PerformPickup(ply)
    if ( timer.Exists("ixCharacterInteraction"..ply:SteamID()) ) then
        return 
    end

    ply:PerformInteraction(ix.config.Get("itemPickupTime"), self, function(k)
        ply:GetCharacter():GetInventory():Add(self.inventoryItemID)

        self:StopSong()
        self:Remove()
    end)
end

function ENT:PickSong(forward)
    self:StopSong()

    local currentSong = self:GetCurrentSong() or 0
    local nextSong = currentSong + (forward and 1 or -1)
    nextSong = nextSong > #self:GetMusicTable() and 1 or nextSong
    nextSong = nextSong < 1 and #self:GetMusicTable() or nextSong

    self:SetCurrentSong(nextSong)

    local song = self:GetMusicTable()[nextSong]
    local path = song.path
    local length = song.length

    self:EmitSound(path, 60)
    self:EmitSound(path, 60)

    timer.Create("ixMusicRadio"..self:EntIndex(), length, 1, function()
        if not ( IsValid(self) ) then
            return
        end

        self:PickSong(true)
    end)
end

function ENT:StopSong()
    local currentSong = self:GetCurrentSong() or 0
    if not ( currentSong ) or currentSong == 0 then
        return
    end

    self:StopSound(self:GetMusicTable()[currentSong].path)
    self:StopSound(self:GetMusicTable()[currentSong].path)

    if ( timer.Exists("ixMusicRadio"..self:EntIndex()) ) then
        timer.Remove("ixMusicRadio"..self:EntIndex())
    end
end

function ENT:OnRemove()
    self:StopSong()
end

function ENT:Use(ply)
    if ( ply:GetEyeTrace().Entity != self ) then
        return
    end

    if ( self.nextUse and self.nextUse > CurTime() ) then
        return
    end

    if ( ply:KeyDown(IN_WALK) ) then
        return self:PerformPickup(ply)
    end

    local buttonOn = self:GetButtonOnPos()
    local buttonOff = self:GetButtonOffPos()
    local buttonNext = self:GetButtonNextPos()
    local buttonPrev = self:GetButtonPrevPos()

    local tr = ply:GetEyeTrace()
    if tr.HitPos:Distance(buttonOn) <= 2 and not ( self:GetEnabled() )  then
        self:SetEnabled(true)
        self:PickSong(true)
        self:EmitSound("buttons/lightswitch2.wav", 60, 120, 0.4)
    elseif self:GetEnabled() and  tr.HitPos:Distance(buttonOff) <= 2 then
        self:SetEnabled(false)
        self:StopSong()
        self:SetCurrentSong(0)
        self:EmitSound("buttons/lightswitch2.wav", 60, 80, 0.4)

        timer.Remove("ixMusicRadio"..self:EntIndex())
    elseif self:GetEnabled() and ( tr.HitPos:Distance(buttonNext) <= 2 ) then
        self:PickSong(true)
        self:EmitSound("buttons/lightswitch2.wav", 60, 120, 0.4)
    elseif self:GetEnabled() and ( tr.HitPos:Distance(buttonPrev) <= 2 ) then
        self:PickSong(false)
        self:EmitSound("buttons/lightswitch2.wav", 60, 120, 0.4)
    end

    self.nextUse = CurTime() + ix.config.Get("itemPickupTime")
end