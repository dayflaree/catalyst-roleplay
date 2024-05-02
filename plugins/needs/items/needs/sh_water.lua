ITEM.name = "Regular Breen's Water"
ITEM.description = "A can of regular Breen's Water."
ITEM.model = "models/props_junk/popcan01a.mdl"

ITEM.uses = 3

ITEM.giveThirst = 5
ITEM.giveItems = {
    "empty_water"
}

ITEM.useText = "Drinking..."
ITEM.useTime = 2
ITEM.useSound = "npc/barnacle/barnacle_gulp1.wav"
ITEM.useMe = {
    "drinks a can of Breen's Water, quenching their thirst.",
    "opens a can and proceeds to drink the contents, refreshing their thirst.",
    "takes a sip from a can of Breen's Water, the cool liquid refreshing their thirst."
}