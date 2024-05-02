local PLUGIN = PLUGIN

function PLUGIN:InitializedConfig()
    ix.config.Add("enableNeeds", true, "Whether or not needs are enabled.", nil, {
        category = "Needs"
    })
end