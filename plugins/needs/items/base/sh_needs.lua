ITEM.name = "Needs Base"
ITEM.description = "A base for all hunger and thirst items."
ITEM.category = "Consumables"
ITEM.model = "models/props_junk/garbage_metalcan001a.mdl"
ITEM.width = 1
ITEM.height = 1

ITEM.uses = 3

/*
ITEM.giveThirst = 0
ITEM.giveHunger = 0
ITEM.giveHealth = 0
ITEM.giveStamina = 0
ITEM.giveSleep = 0

ITEM.giveItems = {}

ITEM.takeThirst = 0
ITEM.takeHunger = 0
ITEM.takeHealth = 0
ITEM.takeStamina = 0
ITEM.takeSleep = 0

ITEM.useText = "Consuming..."
ITEM.useTime = 1
ITEM.useSound = "items/battery_pickup.wav"
ITEM.useMe = "drinks a can of soda."
ITEM.useFunc = function(item, ply, char, inventory)
    // do something
end
*/

ITEM.functions.use = {
    name = "Consume",
    tip = "Consume this item.",
    icon = "icon16/cup.png",
    OnRun = function(item)
        local ply = item.player
        local text = item.useText or "Consuming..."
        local time = item.useTime or 1

        local char = ply:GetCharacter()
        local inventory = char:GetInventory()
        if ( time > 0 ) then
            ply:SetAction(text, time, function()
                item:Consume(ply, char, inventory)
            end)
        else
            item:Consume(ply, char, inventory)
        end

        return false
    end,
    OnCanRun = function(item)
        local ply = item.player
        if ( timer.Exists("ixAct"..ply:UniqueID()) ) then
            return false
        end

        if not ( ply:IsOnGround() ) then
            return false
        end

        return true
    end
}

function ITEM:Consume(ply, char, inventory)
    local item = self

    local snd = item.useSound or "items/battery_pickup.wav"
    ply:EmitSound(snd)

    if ( item.giveThirst ) then
        char:SetThirst( math.Clamp(char:GetThirst() + item.giveThirst, 0, 100) )
    end

    if ( item.giveHunger ) then
        char:SetHunger( math.Clamp(char:GetHunger() + item.giveHunger, 0, 100) )
    end

    if ( item.giveHealth ) then
        ply:SetHealth( math.Clamp(ply:Health() + item.giveHealth, 0, ply:GetMaxHealth()) )
    end

    if ( item.giveStamina ) then
        ply:RestoreStamina(item.giveStamina)
    end

    if ( item.giveSleep ) then
        char:SetSleep( math.Clamp(char:GetSleep() + item.giveSleep, 0, 100) )
    end

    if ( item.takeThirst ) then
        char:SetThirst( math.Clamp(char:GetThirst() - item.takeThirst, 0, 100) )
    end

    if ( item.takeHunger ) then
        char:SetHunger( math.Clamp(char:GetHunger() - item.takeHunger, 0, 100) )
    end

    if ( item.takeHealth ) then
        ply:SetHealth( math.Clamp(ply:Health() - item.takeHealth, 0, ply:GetMaxHealth()) )
    end

    if ( item.takeStamina ) then
        ply:ConsumeStamina(item.takeStamina)
    end

    if ( item.takeSleep ) then
        char:SetSleep( math.Clamp(char:GetSleep() - item.takeSleep, 0, 100) )
    end

    if ( item.useMe ) then
        if ( istable(item.useMe) ) then
            ix.chat.Send(ply, "me", item.useMe[math.random(1, #item.useMe)])
        else
            ix.chat.Send(ply, "me", item.useMe)
        end
    end

    if ( item.useFunc ) then
        item:useFunc(ply, char, inventory)
    end

    local uses = item:GetData("uses", item.uses or 0)
    item:SetData("uses", uses - 1)

    if ( item:GetData("uses", item.uses or 0) <= 0 ) then
        local x, y

        local ent = item:GetEntity()
        if ( IsValid(ent) ) then
            ent:Remove()
        else
            x, y = inventory:Remove(item:GetID())
        end

        if ( item.giveItems ) then
            for k, v in ipairs(item.giveItems) do
                if not ( inventory:Add(v, nil, nil, x, y) ) then
                    ix.item.Spawn(v, ply)
                end
            end
        end
    end

    hook.Run("OnItemConsumed", item, ply)
end

function ITEM:PopulateTooltip(tooltip)
    local uses = self:GetData("uses", self.uses or 0)

    local row = tooltip:AddRow("uses")
    row:SetText("Uses: "..uses.."/"..self.uses)
    row:SizeToContents()
    row.Think = function(this)
        local uses = self:GetData("uses", self.uses or 0)

        this:SetText("Uses: "..uses.."/"..self.uses)

        local color = derma.GetColor("Error", tooltip)
        if ( uses == 1 ) then
            color = derma.GetColor("Warning", tooltip)
        elseif ( uses > 1 ) then
            color = derma.GetColor("Success", tooltip)
        end

        this:SetBackgroundColor(color)
    end
end

function ITEM:OnInstanced()
    self:SetData("uses", self.uses or 0)
end