local PLUGIN = PLUGIN

function PLUGIN:Think()
    if ( ( self.nextNeedsUpdate or 0 ) < CurTime() ) then
        if ( ix.config.Get("enableNeeds", true) ) then
            for _, v in player.Iterator() do
                local char = v:GetCharacter()
                if not ( char ) then
                    continue
                end

                if not ( v:Alive() ) then
                    continue
                end

                if ( ix.faction.Get(v:Team()).bNoNeeds ) then
                    continue
                end

                if ( char:GetHunger() > 0 and math.random(1, 10) == 1 ) then
                    char:SetHunger(math.Clamp(char:GetHunger() - math.random(1, 2), 0, 100))
                end

                if ( char:GetThirst() > 0 and math.random(1, 10) == 1 ) then
                    char:SetThirst(math.Clamp(char:GetThirst() - math.random(1, 2) * 2, 0, 100))
                end

                if ( char:GetSleep() > 0 and math.random(1, 10) == 1 ) then
                    char:GetSleep(math.Clamp(char:GetSleep() - math.random(1, 2) * 2, 0, 100))
                end

                local emptyNeeds = 0
                if ( char:GetHunger() <= 0 ) then
                    emptyNeeds = emptyNeeds + 1
                end

                if ( char:GetThirst() <= 0 ) then
                    emptyNeeds = emptyNeeds + 1
                end
                
                if ( char:GetSleep() <= 0 ) then
                    emptyNeeds = emptyNeeds + 1
                end

                if ( emptyNeeds >= 2 and math.random(1, 10) == 1 ) then
                    v:TakeDamage(1)
                end
            end
        end

        self.nextNeedsUpdate = CurTime() + math.random(30, 120)
    end

    if ( ( self.nextSleepUpdate or 0 ) < CurTime() ) then
        for _, v in player.Iterator() do
            local char = v:GetCharacter()
            if not ( char ) then
                continue
            end

            if not ( v:Alive() ) then
                continue
            end

            if ( ix.faction.Get(v:Team()).bNoNeeds ) then
                continue
            end

            if ( char:GetData("sleeping", false) ) then
                char:SetSleep(math.Clamp(char:GetSleep() + 1, 0, 100))
            end

            if ( math.random(1, 10) == 1 ) then
                local health = v:Health()
                v:SetHealth(math.Clamp(health + 1, 0, v:GetMaxHealth()))
            end
        end

        self.nextSleepUpdate = CurTime() + 5
    end
end

function PLUGIN:SetupMove(ply, mv, cmd)
    local char = ply:GetCharacter()
    if not ( char ) then
        return
    end

    if not ( ply:Alive() ) then
        return
    end

    if ( ix.config.Get("enableNeeds", true) ) then
        if ( ix.faction.Get(ply:Team()).bNoNeeds ) then
            return
        end
        
        if ( char:GetHunger() <= 0 ) then
            mv:SetMaxClientSpeed(mv:GetMaxClientSpeed() * 0.75)
        end

        if ( char:GetThirst() <= 0 ) then
            mv:SetMaxClientSpeed(mv:GetMaxClientSpeed() * 0.75)
        end

        if ( char:GetSleep() <= 0 ) then
            mv:SetMaxClientSpeed(mv:GetMaxClientSpeed() * 0.75)
        end
    end
end

function PLUGIN:SaveData()
    self:SaveBeds()
end

function PLUGIN:LoadData()
    self:LoadBeds()
end

function PLUGIN:PlayerButtonDown(ply, button)
    if ( ply.nextKeyUse and ply.nextKeyUse > CurTime() ) then
        return
    end

    if ( button == KEY_E ) then
        local char = ply:GetCharacter()
        if not ( char ) then
            return
        end

        if ( char:GetData("sleeping", false) ) then
            self:StopSleeping(char, char:GetData("sleeping"))
        end
    end

    ply.nextKeyUse = CurTime() + 0.5
end

function PLUGIN:DoPlayerDeath(ply)
    local char = ply:GetCharacter()
    if not ( char ) then
        return
    end

    self:StopSleeping(char)
end

function PLUGIN:PlayerDisconnected(ply)
    local char = ply:GetCharacter()
    if not ( char ) then
        return
    end

    self:StopSleeping(char)
end

function PLUGIN:EntityTakeDamage(ent, dmgInfo)
    if ( ent:IsPlayer() ) then
        local char = ent:GetCharacter()
        if not ( char ) then
            return
        end

        if ( ix.config.Get("enableNeeds", true) ) then
            if ( ix.faction.Get(ent:Team()).bNoNeeds ) then
                return
            end

            if ( char:GetHunger() <= 0 ) then
                dmgInfo:ScaleDamage(1.5)
            end

            if ( char:GetThirst() <= 0 ) then
                dmgInfo:ScaleDamage(1.5)
            end

            if ( char:GetSleep() <= 0 ) then
                dmgInfo:ScaleDamage(1.5)
            end
        end
    end
end