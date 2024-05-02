local PLUGIN = PLUGIN

function PLUGIN:SaveBeds()
    local data = {}

    for k, v in ipairs(ents.FindByClass("ix_bed")) do
        data[#data + 1] = {v:GetPos(), v:GetAngles()} 
    end

    ix.data.Set("beds", data)
end

function PLUGIN:LoadBeds()
    local data = ix.data.Get("beds", {})

    for k, v in ipairs(data) do
        local bed = ents.Create("ix_bed")
        bed:SetPos(v[1])
        bed:SetAngles(v[2])
        bed:Spawn()
    end
end

local wakeUpMessages = {
    "blinks groggily, adjusting to the light as the world comes back into focus.",
    "leisurely rises from their nap, ready to face the world with renewed energy.",
    "luxuriates in the comfort of waking up, relishing the sensation of a well-deserved nap.",
    "opens their eyes, greeted by the tranquility that follows a restorative period of sleep.",
    "reflects on the dreamy haze of slumber, slowly reconnecting with the waking world.",
    "rubs sleep from their eyes, feeling the warmth of waking after a restful nap.",
    "shakes off the remnants of sleep, ready to tackle the day with refreshed enthusiasm.",
    "smiles contentedly, embracing the serenity that lingers after a satisfying nap.",
    "stretches and yawns, slowly emerging from a peaceful slumber.",
    "takes a deep breath, savoring the fresh feeling of a new beginning after a long nap."
}

function PLUGIN:StartSleeping(char, ent)
    local ply = char:GetPlayer()
    if not ( IsValid(ply) ) then
        return
    end

    if not ( IsValid(ent) ) then
        return
    end

    if ( char:GetData("sleeping") != nil ) then
        return
    end

    if ( ent:GetOccupied() ) then
        return
    end

    ent:SetOccupied(true)

    ply:ScreenFade(SCREENFADE.OUT, color_black, 1, 5)

    timer.Simple(1, function()
        if not ( IsValid(ply) ) then
            return
        end

        ply:SendLua([[LocalPlayer():EmitSound("player/heartbeat1.wav", 100, 100, 0.3, CHAN_AUTO)]])
        ply:SetDSP(31)
        ply:SetPos(ent:WorldSpaceCenter() + ent:GetUp() * 10)
        ply:SetEyeAngles(ent:GetAngles())
        ply:SetLocalVelocity(Vector(0, 0, 0))
        ply:Freeze(true)
        ply:ForceSequence("d1_town05_wounded_idle_1", nil, 0, true)

        char:SetData("sleeping", ent)
    end)
end

function PLUGIN:StopSleeping(char, ent)
    local ply = char:GetPlayer()
    if not ( IsValid(ply) ) then
        return
    end

    if not ( IsValid(ent) ) then
        return
    end

    if not ( char:GetData("sleeping") == ent ) then
        return
    end

    char:SetData("sleeping", nil)

    ply:ScreenFade(SCREENFADE.IN, color_black, 5, 2)

    timer.Simple(2, function()
        if not ( IsValid(ply) ) then
            return
        end

        ix.chat.Send(ply, "me", wakeUpMessages[math.random(1, #wakeUpMessages)])
        ent:SetOccupied(false)

        ply:SendLua([[LocalPlayer():StopSound("player/heartbeat1.wav")]])
        ply:SetDSP(1)
        ply:Freeze(false)
        ply:LeaveSequence()
    end)
end