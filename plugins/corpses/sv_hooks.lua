local PLUGIN = PLUGIN

function PLUGIN:ShouldSpawnClientRagdoll(ply)
    return false
end

function PLUGIN:DoPlayerDeath(ply, attacker, damageinfo)
    if ( hook.Run("ShouldSpawnPlayerCorpse") == false ) then
        return
    end

    local entity = IsValid(ply.ixRagdoll) and ply.ixRagdoll or ply:CreateServerRagdoll()
    local decayTime = ix.config.Get("corpseDecayTime", 60)
    local uniqueID = "ixCorpseDecay" .. entity:EntIndex()

    entity:SetCollisionGroup(COLLISION_GROUP_WORLD)

    local velocity = ply:GetVelocity() / 4
    for i = 0, entity:GetPhysicsObjectCount() - 1 do
        local physObj = entity:GetPhysicsObjectNum(i)

        if ( IsValid(physObj) ) then
            physObj:SetVelocity(velocity)

            local index = entity:TranslatePhysBoneToBone(i)
            if ( index ) then
                local position, angles = ply:GetBonePosition(index)

                physObj:SetPos(position)
                physObj:SetAngles(angles)
            end
        end
    end

    hook.Run("OnPlayerCorpseCreated", ply, entity)
end

function PLUGIN:OnPlayerCorpseCreated(ply, entity)
    local velocity = ply:GetVelocity()

    local char = ply:GetCharacter()
    if not ( char ) then
        return
    end

    local charInventory = char:GetInventory()
    if not ( charInventory ) then
        return
    end

    local charItems = {}
    for v in charInventory:Iter() do
        charItems[#charItems + 1] = v

        if ( v.Unequip ) then
            v:Unequip(ply)
        elseif ( v.RemoveOutfit ) then
            v:RemoveOutfit(ply)
        elseif ( v.RemovePart ) then
            v:RemovePart(ply)
        end

        v:Remove()
    end

    local width, height = charInventory:GetSize()
    local inventory = ix.inventory.Create(width, height, os.time())
    inventory.noSave = true

    for k, v in ipairs(charItems) do
        if ( v.base == "base_weapons" and v:GetData("equip") ) then
            ix.item.Spawn(v.uniqueID, ply:GetShootPos() + Vector(math.random(-16, 16), math.random(-16, 16), 0), function(item, itemEntity)
                item:SetData("ammo", v:GetData("ammo", 0))
                itemEntity:SetVelocity(velocity)
            end)

            continue
        end

        inventory:Add(v.uniqueID, 1, nil, v.gridX, v.gridY)
    end

    entity.ixInventory = inventory

    timer.Simple(ix.config.Get("corpseDecayTime", 60), function()
        if ( IsValid(entity) ) then
            entity:Remove()
        end
    end)

    local faction = char:GetFaction()
    if ( self.factionDrops[faction] ) then
        for itemID, chance in pairs(self.factionDrops[faction]) do
            if ( math.random(1, 100) <= chance ) then
                ix.item.Spawn(itemID, ply:GetShootPos() + Vector(math.random(-16, 16), math.random(-16, 16), 0), function(item, itemEntity)
                    itemEntity:SetVelocity(velocity)
                end)
            end
        end
    end
end

function PLUGIN:OnNPCKilled(npc, attacker, inflictor)
    if ( self.npcDrops[npc:GetClass()] ) then
        for itemID, chance in pairs(self.npcDrops[npc:GetClass()]) do
            if ( math.random(1, 100) <= chance ) then
                ix.item.Spawn(itemID, npc:GetPos() + Vector(math.random(-16, 16), math.random(-16, 16), 0))
            end
        end
    end

    timer.Simple(0, function()
        if not ( IsValid(npc) ) then
            return
        end

        for k, v in ipairs(ents.FindInSphere(npc:GetPos(), 128)) do
            if ( string.find(v:GetClass(), "item_") ) then
                v:Remove()
            end
        end
    end)
end

function PLUGIN:PlayerUse(ply, entity)
    if ( entity:GetClass() == "prop_ragdoll" and entity.ixInventory and not ix.storage.InUse(entity.ixInventory) ) then
        ix.storage.Open(ply, entity.ixInventory, {
            entity = entity,
            name = "Corpse",
            searchText = "Searching...",
            searchTime = 3
        })

        return false
    end
end