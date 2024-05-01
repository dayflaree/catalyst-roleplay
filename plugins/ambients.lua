
local PLUGIN = PLUGIN
local _tonumber = tonumber
local _math_ceil = math.ceil
local _SoundDuration = SoundDuration
local util_PrecacheSound = util.PrecacheSound

PLUGIN.name = "Ambient Music"
PLUGIN.description = "Adds background music"
PLUGIN.author = "Bilwin"
PLUGIN.schema = "Any"
PLUGIN.version = 1.0

// Add the default songs
PLUGIN.songs = {
    {path = "music/hl2_song13.mp3", duration = 54},
    {path = "music/hl2_song17.mp3", duration = 61},
    {path = "music/hl2_song2.mp3", duration = 173},
    {path = "music/hl2_song30.mp3", duration = 104},
    {path = "music/hl2_song8.mp3", duration = 60},
}

-- This music is for daytime. I selected Silent Hill music since it fits the "foggy town" atmosphere.
if ( game.GetMap() == "rp_ms_city17_outskirts_day" ) then
    // Override the default songs with the ones for the map
    PLUGIN.songs = {
        // Silent Hill
        {path = "minerva_ravenholm/music/silenthill/ambient/silenthill_innocentmoon.mp3", duration = 98},
        {path = "minerva_ravenholm/music/silenthill/ambient/silenthill_neverforgiveforget.mp3", duration = 139},
        {path = "minerva_ravenholm/music/silenthill/ambient/silenthill_morningcalm.mp3", duration = 128},
        {path = "minerva_ravenholm/music/silenthill/ambient/silenthill_foresttrail.mp3", duration = 280},
        {path = "minerva_ravenholm/music/silenthill/ambient/silenthill_fearofthedark.mp3", duration = 74},
        {path = "minerva_ravenholm/music/silenthill/ambient/silenthill_silentheaven.mp3", duration = 134},
        {path = "minerva_ravenholm/music/silenthill/ambient/silenthill_dayofnight.mp3", duration = 97},
        {path = "minerva_ravenholm/music/silenthill/ambient/silenthill_ordinaryvanity.mp3", duration = 99},
        {path = "minerva_ravenholm/music/silenthill/ambient/silenthill_worldofmadness.mp3", duration = 107},
        {path = "minerva_ravenholm/music/silenthill/ambient/silenthill_whitenoiz.mp3", duration = 83},
    }
end

ix.lang.AddTable("english", {
    optEnableAmbient = "Enable ambient",
    optAmbientVolume = "Ambient volume"
})

ix.lang.AddTable("russian", {
    optEnableAmbient = "Включить фоновую музыку",
    optAmbientVolume = "Громкость фоновой музыки"
})

if CLIENT then
    if !table.IsEmpty(PLUGIN.songs) then
        for _, data in ipairs(PLUGIN.songs) do
            util_PrecacheSound(data.path)
        end
    end

    ixAmbientCooldown = ixAmbientCooldown or 0
    bAmbientPreSaver = bAmbientPreSaver or false

    ix.option.Add("enableAmbient", ix.type.bool, true, {
        category = PLUGIN.name,
        OnChanged = function(oldValue, value)
            if value then
                if IsValid(PLUGIN.ambient) then
                    local volume = ix.option.Get("ambientVolume", 1)
                    PLUGIN.ambient:SetVolume(volume)
                end
            else
                if IsValid(PLUGIN.ambient) then
                    PLUGIN.ambient:SetVolume(0)
                end
            end
        end
    })

    ix.option.Add("ambientVolume", ix.type.number, 0.5, {
        category = PLUGIN.name,
        min = 0.1,
        max = 2,
        decimals = 1,
        OnChanged = function(oldValue, value)
            if IsValid(PLUGIN.ambient) and ix.option.Get("enableAmbient", true) then
                PLUGIN.ambient:SetVolume(value)
            end
        end
    })

    function PLUGIN:CreateAmbient()
        local bEnabled = ix.option.Get("enableAmbient", true)

        if (bEnabled and !bAmbientPreSaver) then
            local flVolume = _tonumber(ix.option.Get("ambientVolume", 1))
            local mSongTable = self.songs[math.random(1, #self.songs)]
            local mSongPath = mSongTable.path
            local mSongDuration = mSongTable.duration or _SoundDuration(mSongPath)

            sound.PlayFile("sound/" .. mSongTable.path, "noblock", function(radio)
                if IsValid(radio) then
                    if IsValid(self.ambient) then self.ambient:Stop() end

                    radio:SetVolume(flVolume)
                    radio:Play()
                    self.ambient = radio

                    ixAmbientCooldown = os.time() + _tonumber(mSongDuration) + 10
                end
            end)
        end
    end

    net.Receive("ixPlayAmbient", function()
        if !timer.Exists("ixAmbientMusicChecker") then
            timer.Create("ixAmbientMusicChecker", 5, 0, function()
                if (ixAmbientCooldown or 0) > os.time() then return end
                PLUGIN:CreateAmbient()
            end)
        end

        if !timer.Exists("ixAmbientChecker") then
            timer.Create("ixAmbientChecker", 0.5, 0, function()
                if IsValid(ix.gui.characterMenu) and ix.config.Get("music") != "" then
                    if IsValid(PLUGIN.ambient) then
                        PLUGIN.ambient:SetVolume(0)
                    end
                else
                    if ix.option.Get("enableAmbient", true) then
                        if IsValid(PLUGIN.ambient) then
                            local volume = ix.option.Get("ambientVolume", 1)
                            PLUGIN.ambient:SetVolume(volume)
                        end
                    end
                end
            end)
        end
    end)
end

if (SERVER) then
    util.AddNetworkString("ixPlayAmbient")
    function PLUGIN:PlayerLoadedCharacter(client, character, currentChar)
        net.Start("ixPlayAmbient")
        net.Send(client)
    end
end