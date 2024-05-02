AddCSLuaFile()

ENT.Base = "ix_radio_base"
ENT.Type = "anim"
ENT.PrintName = "Radio (Regular)"
ENT.Author = "Riggs"
ENT.Category = "Catalyst (Citizen)"
ENT.Spawnable = true
ENT.AdminOnly = true
ENT.bNoPersist = true
ENT.Holdable = true

ENT.inventoryItemID = "music_radio_regular"
ENT.title = "Regular Radio"
ENT.description = "A regular radio with a collection of songs."

function ENT:GetMusicTable()
    return {
        {path = "catalyst/radio/billie_jean.mp3", length = 294},
        {path = "catalyst/radio/california_love.mp3", length = 285},
        {path = "catalyst/radio/canibus_poet_laureate.mp3", length = 446},
        {path = "catalyst/radio/cosmos.mp3", length = 254},
        {path = "catalyst/radio/everybody_wants_to_rule_the_world.mp3", length = 252},
        {path = "catalyst/radio/eye_of_the_tiger.mp3", length = 245},
        {path = "catalyst/radio/gangstas_paradise.mp3", length = 241},
        {path = "catalyst/radio/heres_to_you.mp3", length = 189},
        {path = "catalyst/radio/highway_to_hell.mp3", length = 208},
        {path = "catalyst/radio/hip_hop_essentials.mp3", length = 254},
        {path = "catalyst/radio/i_who_have_nothing.mp3", length = 284},
        {path = "catalyst/radio/mo_murder_mo_crime.mp3", length = 263},
        {path = "catalyst/radio/music_sounds_better_with_you.mp3", length = 261},
        {path = "catalyst/radio/rhythm_is_a_dancer.mp3", length = 226},
        {path = "catalyst/radio/smooth_criminal.mp3", length = 258},
        {path = "catalyst/radio/stayin_alive.mp3", length = 93},
        {path = "catalyst/radio/straight_outta_compton.mp3", length = 259},
        {path = "catalyst/radio/tainted_love.mp3", length = 154},
        {path = "catalyst/radio/take_on_me.mp3", length = 225},
        {path = "catalyst/radio/the_andromeda_strain.mp3", length = 235},
        {path = "catalyst/radio/the_power_of_love.mp3", length = 234},
        {path = "catalyst/radio/wake_me_up_before_you_go.mp3", length = 231},
        {path = "catalyst/radio/you_spin_me_round.mp3", length = 196},
    }
end

for k, v in pairs(file.Find("sound/catalyst/radio/*.mp3", "GAME")) do
    local path = "minerva/halflife2/radio/"..v
    resource.AddFile("sound/" .. path)
    util.PrecacheSound(path)
end