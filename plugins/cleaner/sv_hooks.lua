local PLUGIN = PLUGIN

// Add a timer to prevent map entities from being added to the list.
function PLUGIN:InitPostEntity()
    self.bAllowCleanup = false

    timer.Simple(30, function()
        self.bAllowCleanup = true
    end)
end

// Remove the entity if it's in the list.
function PLUGIN:OnEntityCreated(ent)
    timer.Simple(1 / 3, function()
        if not ( IsValid(ent) ) then
            return
        end

        local class = ent:GetClass()
        if ( self.bAllowCleanup ) then
            local time = self.entities[class]
            if ( time ) then
                timer.Simple(time, function()
                    if ( IsValid(ent) ) then
                        ent:Remove()
                    end
                end)
            end
        end

        if ( self.entityCollisions[class] ) then
            ent:SetCollisionGroup(self.entityCollisions[class])
        end
    end)
end