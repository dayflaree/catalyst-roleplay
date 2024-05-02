AddCSLuaFile()

ENT.Type = "anim"
ENT.PrintName = "Vending Machine"
ENT.Category = "Catalyst (Citizen)"
ENT.Spawnable = true
ENT.AdminOnly = true
ENT.PhysgunDisable = true
ENT.bNoPersist = true

ENT.MaxRenderDistance = math.pow(512, 2)
ENT.MaxStock = 10
ENT.Items = {
    {"WATER", "water", 15},
    {"LEMON", "water_lemon", 25},
    {"CHERRY", "water_cherry", 35}
}

function ENT:GetStock(id)
    return self:GetNetVar("stock", {})[id] or self.MaxStock
end

function ENT:GetAllStock()
    return self:GetNetVar("stock", {})
end

if (SERVER) then
    function ENT:Initialize()
        self:SetModel("models/props_interiors/vendingmachinesoda01a.mdl")
        self:PhysicsInit(SOLID_VPHYSICS)
        self:SetSolid(SOLID_VPHYSICS)
        self:SetUseType(SIMPLE_USE)

        local physics = self:GetPhysicsObject()
        physics:EnableMotion(false)
        physics:Sleep()

        self.nextUseTime = 0
        self:SetNetVar("stock", {})
    end

    function ENT:SpawnFunction(client, trace)
        local vendor = ents.Create("ix_vending_machine")

        vendor:SetPos(trace.HitPos + Vector(0, 0, 48))
        vendor:SetAngles(Angle(0, (vendor:GetPos() - client:GetPos()):Angle().y - 180, 0))
        vendor:Spawn()
        vendor:Activate()

        Schema:SaveVendingMachines()
        return vendor
    end

    function ENT:GetClosestButton(client)
        local data = {}
            data.start = client:GetShootPos()
            data.endpos = data.start + client:GetAimVector() * 96
            data.filter = client
        local trace = util.TraceLine(data)
        local tracePosition = trace.HitPos

        if (tracePosition) then
            for k, v in ipairs(self.Items) do
                local position = self:GetPos() + self:GetForward() * 17.5 + self:GetRight() * -24.4 + (self:GetUp() * 5.3 - Vector(0, 0, (k - 1) * 2.1))

                if (position:DistToSqr(tracePosition) <= 1) then
                    return k
                end
            end
        end
    end

    function ENT:SetStock(id, amount)
        if (type(id) == "table") then
            self:SetNetVar("stock", id)
            return
        end

        local stock = self:GetNetVar("stock", {})
        stock[id] = math.Clamp(amount, 0, self.MaxStock)

        self:SetNetVar("stock", stock)
    end

    function ENT:ResetStock(id)
        local stock = self:GetNetVar("stock", {})

        -- reset stock of all items if no id is specified
        if (id) then
            stock[id] = self.MaxStock
        else
            for k, v in ipairs(self.Items) do
                stock[k] = self.MaxStock
            end
        end

        self:SetNetVar("stock", stock)

        self.nextUsetime = CurTime() + 1
    end

    function ENT:RemoveStock(id)
        self:SetStock(id, self:GetStock(id) - 1)
    end

    function ENT:KeyValue(k, v)
        if (k == "OnDispensed" or k == "OnDeny") then
            self:StoreOutput(k,v)
        end
    end
    
    function ENT:AcceptInput(input, activator, caller, data)
        local id = tonumber(data) or 1
        if (input == "Dispense") then
            self:InputDispense(id, false)
        elseif (input == "ForceDispense") then
            self:InputDispense(id, true)
        elseif(input == "ResetStock") then
            self:ResetStock(id)
        elseif(input == "RemoveStock") then
            self:RemoveStock(id)
        end
    end	

    function ENT:InputDispense(id, force)
        local itemInfo = self.Items[id]
        local itemData = ix.item.Get(itemInfo[2])
        
        if (self:GetStock(id) > 0 or force) then
            ix.item.Spawn(itemInfo[2], self:GetPos() + self:GetForward() * 19 + self:GetRight() * 4 + self:GetUp() * -26, function(item, entity) 
                self:EmitSound("buttons/button4.wav", 60)

                if (!force) then
                    self:RemoveStock(id)
                end

                self.nextUseTime = CurTime() + 1
            end)
        end
    end

    function ENT:Use(client)
        local buttonID = self:GetClosestButton(client)

        if (buttonID) then
            client:EmitSound("buttons/lightswitch2.wav", 60, 150)
        else
            return
        end

        if (self.nextUseTime > CurTime()) then
            return
        end

        local character = client:GetCharacter()

        local itemInfo = self.Items[buttonID]
        local itemData = ix.item.Get(itemInfo[2])
        local price = itemInfo[3]

        if (!character:HasMoney(price)) then
            self:EmitSound("buttons/button2.wav", 60)
            self.nextUseTime = CurTime() + 1

            self:TriggerOutput("OnDeny", client)
            client:Notify("You need " .. ix.currency.Get(price) .. " to purchase a " .. itemData.name .. ".")
            return false
        end

        if (self:GetStock(buttonID) > 0) then
            ix.item.Spawn(itemInfo[2], self:GetPos() + self:GetForward() * 19 + self:GetRight() * 4 + self:GetUp() * -26, function(item, entity)
                self:EmitSound("buttons/button4.wav", 60)

                character:TakeMoney(price)
                self:TriggerOutput("OnDispensed", client)
                client:Notify("You have purchased a " .. itemData.name .. " for " .. ix.currency.Get(price) .. ".")

                self:RemoveStock(buttonID)
                self.nextUseTime = CurTime() + 1
            end)
        else
            self:EmitSound("buttons/button2.wav", 60)
            self.nextUseTime = CurTime() + 1
        end
    end

    function ENT:OnRemove()
        if (!ix.shuttingDown) then
            Schema:SaveVendingMachines()
        end
    end
else
    surface.CreateFont("ixVendingMachine", {
        font = "Roboto",
        size = 14,
        weight = 0,
        antialias = false,
    })

    local sprite = ix.util.GetMaterial("sprites/glow04_noz")
	local color_green = Color(0, 255, 0, 255)
	local color_red = Color(255, 0, 0, 255)
	local color_orange = Color(255, 125, 0, 255)
    function ENT:Draw()
        self:DrawModel()

        local position = self:GetPos()

        if (LocalPlayer():GetPos():DistToSqr(position) > self.MaxRenderDistance) then
            return
        end

        local angles = self:GetAngles()
        local forward, right, up = self:GetForward(), self:GetRight(), self:GetUp()

        angles:RotateAroundAxis(angles:Up(), 90)
        angles:RotateAroundAxis(angles:Forward(), 90)

        local width = 70
        local smallWidth = 20
        local height = 29
        local halfWidth = width / 2
        local halfHeight = height / 2

        cam.Start3D2D(position + forward * 17.33 + right * -19.2 + up * 6.1, angles, 0.06)
            render.PushFilterMin(TEXFILTER.NONE)
            render.PushFilterMag(TEXFILTER.NONE)

            for i = 1, 8 do
                local itemInfo = self.Items[i]
                local x = 0
                local y = (i - 1) * 34

                if (itemInfo) then
                    draw.SimpleText(itemInfo[1], "ixVendingMachine", x + halfWidth, y + halfHeight, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
                end
            end

            render.PopFilterMin()
            render.PopFilterMag()
        cam.End3D2D()

        render.SetMaterial(sprite)

        local trace = LocalPlayer():GetEyeTraceNoCursor()

        for i = 1, 8 do
            local color = color_red
            local itemInfo = self.Items[i]
            local x = 0
            local y = (i - 1) * 34

            if (itemInfo) then
                local stock = self:GetStock(i)

                if (stock > 1) then
                    color = color_green
                elseif (stock != 0 and stock <= math.Round(self.MaxStock / 3)) then
                    color = color_orange
                end
            end

            color.a = math.abs(math.sin(RealTime() / 2) * 200 - i * 5)

            local size = 3
            if (trace.HitPos:DistToSqr(position + forward * 18 + right * -24.4 + up * 5.3 - Vector(0, 0, (i - 1) * 2.1)) <= 2) then
                size = size + math.abs(math.sin(RealTime()) * 2)
            end

            render.DrawSprite(position + forward * 18 + right * -24.4 + up * 5.3 - Vector(0, 0, (i - 1) * 2.1), size, size, color)
        end
    end
end