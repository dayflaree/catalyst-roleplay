local PLUGIN = PLUGIN

function PLUGIN:PlayerLoadedCharacter(ply, char, oldChar)
    local music = PLUGIN.introMusic[ix.option.Get(ply, "introMusic", "default")].Music

    ply:ConCommand("play "..table.Random(music))
end