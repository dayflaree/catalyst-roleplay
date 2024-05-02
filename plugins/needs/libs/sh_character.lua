local PLUGIN = PLUGIN

ix.char.RegisterVar("hunger", {
    field = "hunger",
    fieldType = ix.type.number,
    default = 100,
    isLocal = true,
    bNoDisplay = true,
})

ix.char.RegisterVar("thirst", {
    field = "thirst",
    fieldType = ix.type.number,
    default = 100,
    isLocal = true,
    bNoDisplay = true,
})

ix.char.RegisterVar("sleep", {
    field = "sleep",
    fieldType = ix.type.number,
    default = 100,
    isLocal = true,
    bNoDisplay = true,
})

ix.command.Add("CharSetHunger", {
    description = "Set a character's hunger.",
    adminOnly = true,
    arguments = {
        ix.type.character,
        bit.bor(ix.type.number, ix.type.optional)
    },
    OnRun = function(self, ply, target, hunger)
        if not ( hunger ) then
            hunger = 100
        end

        target:SetHunger(hunger)
        ply:Notify("You have set "..target:GetName().."'s hunger percentage to "..hunger..".")
    end
})

ix.command.Add("CharSetThirst", {
    description = "Set a character's thirst.",
    adminOnly = true,
    arguments = {
        ix.type.character,
        bit.bor(ix.type.number, ix.type.optional)
    },
    OnRun = function(self, ply, target, thirst)
        if not ( thirst ) then
            thirst = 100
        end

        target:SetThirst(thirst)
        ply:Notify("You have set "..target:GetName().."'s thirst percentage to "..thirst..".")
    end
})

ix.command.Add("CharSetSleep", {
    description = "Set a character's sleep.",
    adminOnly = true,
    arguments = {
        ix.type.character,
        bit.bor(ix.type.number, ix.type.optional)
    },
    OnRun = function(self, ply, target, sleep)
        if not ( sleep ) then
            sleep = 100
        end

        target:SetSleep(sleep)
        ply:Notify("You have set "..target:GetName().."'s sleep percentage to "..sleep..".")
    end
})