include("shared.lua")

function ENT:Draw()
    self:DrawModel()
end

ENT.PopulateEntityInfo = true

function ENT:OnPopulateEntityInfo(container)
    local title = container:AddRow("name")
    title:SetImportant()
    title:SetText(self.PrintName)
    title:SetBackgroundColor(ix.config.Get("color"))
    title:SizeToContents()

    local description = container:AddRow("description")
    description:SetText("A bed that you can sleep in.")
    description:SizeToContents()
end