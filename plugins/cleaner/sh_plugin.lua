local PLUGIN = PLUGIN

PLUGIN.name = "Entity Cleaner"
PLUGIN.description = "Allows you to input a list of entities, and as soon as they are created they are removed in a certain amount of time."
PLUGIN.author = "Riggs"
PLUGIN.schema = "Any"

PLUGIN.entities = {
    ["prop_ragdoll"] = 300,
}

PLUGIN.entityCollisions = {
    ["prop_ragdoll"] = COLLISION_GROUP_WORLD
}

ix.util.Include("sv_hooks.lua")