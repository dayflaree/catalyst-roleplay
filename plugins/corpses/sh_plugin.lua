local PLUGIN = PLUGIN

PLUGIN.name = "Corpses"
PLUGIN.description = "Adds an inventory to dead player corpses and npcs."
PLUGIN.author = "Riggs"
PLUGIN.schema = "Any"

PLUGIN.factionDrops = {}

if ( FACTION_CP ) then
    PLUGIN.factionDrops[FACTION_CP] = {
        ["health_vial"] = 50, // 50% chance
    }
end

if ( FACTION_TF ) then
    PLUGIN.factionDrops[FACTION_TF] = {
        ["health_vial"] = 35, // 35% chance
    }
end

PLUGIN.npcDrops = {
    ["npc_metropolice"] = {
        ["health_vial"] = 50, // 50% chance
    },
    ["npc_combine_s"] = {
        ["health_vial"] = 35, // 25% chance
    },
}

ix.util.Include("sv_hooks.lua")