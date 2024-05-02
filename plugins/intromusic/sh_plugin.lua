local PLUGIN = PLUGIN

PLUGIN.name = "Intro Music"
PLUGIN.description = "Plays music on character load."
PLUGIN.author = "Riggs Mackay"
PLUGIN.schema = "HL2 RP"

PLUGIN.introMusic = {
    ["default"] = {
        name = "Default",
        Music = {
            "ui/hls_loading_enter.mp3",
        },
    },
}

ix.lang.AddTable("english", {
    optIntroMusic = "Intro Music",
    optdIntroMusic = "What type of music should play once you load in a character?",
})

ix.util.Include("sv_plugin.lua")