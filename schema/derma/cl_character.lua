
local gradient = surface.GetTextureID("vgui/gradient-l")
local audioFadeInTime = 2
local animationTime = 0.5
local matrixZScale = Vector(1, 1, 0.0001)

-- character menu panel
DEFINE_BASECLASS("ixSubpanelParent")
local PANEL = {}

function PANEL:Init()
    self:SetSize(self:GetParent():GetSize())
    self:SetPos(0, 0)

    self.childPanels = {}
    self.subpanels = {}
    self.activeSubpanel = ""

    self.currentDimAmount = 0
    self.currentY = 0
    self.currentScale = 1
    self.currentAlpha = 255
    self.targetDimAmount = 255
    self.targetScale = 0.9
end

function PANEL:Dim(length, callback)
    length = length or animationTime
    self.currentDimAmount = 0

    self:CreateAnimation(length, {
        target = {
            currentDimAmount = self.targetDimAmount,
            currentScale = self.targetScale
        },
        easing = "outCubic",
        OnComplete = callback
    })

    self:OnDim()
end

function PANEL:Undim(length, callback)
    length = length or animationTime
    self.currentDimAmount = self.targetDimAmount

    self:CreateAnimation(length, {
        target = {
            currentDimAmount = 0,
            currentScale = 1
        },
        easing = "outCubic",
        OnComplete = callback
    })

    self:OnUndim()
end

function PANEL:OnDim()
end

function PANEL:OnUndim()
end

function PANEL:Paint(width, height)
    local amount = self.currentDimAmount
    local bShouldScale = self.currentScale != 1
    local matrix

    -- draw child panels with scaling if needed
    if (bShouldScale) then
        matrix = Matrix()
        matrix:Scale(matrixZScale * self.currentScale)
        matrix:Translate(Vector(
            ScrW() * 0.5 - (ScrW() * self.currentScale * 0.5),
            ScrH() * 0.5 - (ScrH() * self.currentScale * 0.5),
            1
        ))

        cam.PushModelMatrix(matrix)
        self.currentMatrix = matrix
    end

    BaseClass.Paint(self, width, height)

    if (bShouldScale) then
        cam.PopModelMatrix()
        self.currentMatrix = nil
    end

    if (amount > 0) then
        local color = Color(0, 0, 0, amount)

        surface.SetDrawColor(color)
        surface.DrawRect(0, 0, width, height)
    end
end

vgui.Register("ixCharMenuPanel", PANEL, "ixSubpanelParent")

-- character menu main button list
PANEL = {}

function PANEL:Init()
    local parent = self:GetParent()
    self:SetSize(parent:GetWide() * 0.25, parent:GetTall())

    self:GetVBar():SetWide(0)
    self:GetVBar():SetVisible(false)
end

function PANEL:Add(name)
    local panel = vgui.Create(name, self)
    panel:Dock(TOP)

    return panel
end

function PANEL:SizeToContents()
    self:GetCanvas():InvalidateLayout(true)

    -- if the canvas has extra space, forcefully dock to the bottom so it doesn't anchor to the top
    if (self:GetTall() > self:GetCanvas():GetTall()) then
        self:GetCanvas():Dock(BOTTOM)
    else
        self:GetCanvas():Dock(NODOCK)
    end
end

vgui.Register("ixCharMenuButtonList", PANEL, "DScrollPanel")

-- main character menu panel
PANEL = {}

AccessorFunc(PANEL, "bUsingCharacter", "UsingCharacter", FORCE_BOOL)

function PANEL:Init()
    local parent = self:GetParent()
    local padding = self:GetPadding()
    local halfWidth = ScrW() * 0.5
    local halfPadding = padding * 0.5
    local bHasCharacter = #ix.characters > 0

    self.bUsingCharacter = LocalPlayer().GetCharacter and LocalPlayer():GetCharacter()
    self:DockPadding(padding, padding, padding, padding)

    local authorLabel = self:Add("DLabel")
    authorLabel:SetTextColor(ColorAlpha(ix.config.Get("color"), 150))
    authorLabel:SetFont("ixMenuMiniFont")
    authorLabel:SetText("Founded by "..Schema.author)
    authorLabel:SizeToContents()
    authorLabel:SetPos(4, ScrH() - authorLabel:GetTall() - 4)

    local infoLabel = self:Add("DLabel")
    infoLabel:SetTextColor(ColorAlpha(ix.config.Get("color"), 150))
    infoLabel:SetFont("ixMenuMiniFont")
    infoLabel:SetText("Catalyst: "..Schema.build.." | "..Schema.version)
    infoLabel:SizeToContents()
    infoLabel:SetPos(ScrW() - infoLabel:GetWide() - 4, ScrH() - infoLabel:GetTall() - 4)

    local newHeight = padding
    local subtitle = Schema.description

    self.logoPanel = self:Add("DPanel")
    self.logoPanel:SetSize(ScrW(), 300)
    self.logoPanel:SetPos(0, ScrH() / 3)
    self.logoPanel.Paint = function(panel, width, height)
    end

    --local titleLabel = self.logoPanel:Add("DLabel")
    --titleLabel:SetTextColor(ix.config.Get("color"))
    --titleLabel:SetFont("InterlockTitleFont")
    --titleLabel:SetText(Schema.name)
    --titleLabel:SizeToContents()
    --titleLabel:Dock(TOP)
    --titleLabel:DockMargin(ScreenScale(50), 10, 10, 10)
    --newHeight = newHeight + titleLabel:GetTall()

    if (subtitle) then
        local subtitleLabel = self.logoPanel:Add("DLabel")
        subtitleLabel:SetTextColor(color_white)
        subtitleLabel:SetFont("InterlockSubTitleFont")
        subtitleLabel:SetText(subtitle)
        subtitleLabel:SizeToContents()
        subtitleLabel:Dock(TOP)
        subtitleLabel:DockMargin(ScreenScale(50), 0, 10, 10)
        newHeight = newHeight + subtitleLabel:GetTall()
    end

    self.logoPanel:SetTall(newHeight)

    -- button list
    self.mainButtonList = self:Add("ixCharMenuButtonList")
    self.mainButtonList:Dock(LEFT)
    self.mainButtonList:DockMargin(ScreenScale(35), ScreenScale(30), 0, ScreenScale(70))

    -- create character button
    local createButton = self.mainButtonList:Add("ixMenuButton")
    createButton:SetText("")
    createButton:SetFont("InterlockFont40-Light")
    local material = ix.util.GetMaterial("catalyst/ui/create_story.png")
    if material then
        createButton.Paint = function(self, w, h)
            -- Draw the material to cover the entire button area
            surface.SetDrawColor(255, 255, 255, 255)
            surface.SetMaterial(material)
        
            -- Calculate the aspect ratio of the image
            local matWidth = material:Width()
            local matHeight = material:Height()
            local aspectRatio = matWidth / matHeight
        
            -- Calculate scaling factors
            local scaleX = w / matWidth
            local scaleY = h / matHeight
        
            -- Determine how to scale the image to cover the button
            if scaleX > scaleY then
                -- Scale by height
                local drawWidth = matWidth * scaleY
                surface.DrawTexturedRect((w - drawWidth) / 5, 0, drawWidth, h)
            else
                -- Scale by width
                local drawHeight = matHeight * scaleX
                surface.DrawTexturedRect(0, (h - drawHeight) / 5, w, drawHeight)
            end
        end
    
        createButton:SizeToContents()
    end
    createButton.DoClick = function()
        local maximum = hook.Run("GetMaxPlayerCharacter", LocalPlayer()) or ix.config.Get("maxCharacters", 5)
        -- don't allow creation if we've hit the character limit
        if (#ix.characters >= maximum) then
            self:GetParent():ShowNotice(3, L("maxCharacters"))
            return
        end

        self:Dim()
        parent.newCharacterPanel:SetActiveSubpanel("faction", 0)
        parent.newCharacterPanel:SlideUp()
    end

    -- load character button
    self.loadButton = self.mainButtonList:Add("ixMenuButton")
    self.loadButton:SetText("")
    self.loadButton:SetFont("InterlockFont40-Light")
    local material = ix.util.GetMaterial("catalyst/ui/continue_story.png")
    if material then
        self.loadButton.Paint = function(self, w, h)
            -- Draw the material to cover the entire button area
            surface.SetDrawColor(255, 255, 255, 255)
            surface.SetMaterial(material)
        
            -- Calculate the aspect ratio of the image
            local matWidth = material:Width()
            local matHeight = material:Height()
            local aspectRatio = matWidth / matHeight
        
            -- Calculate scaling factors
            local scaleX = w / matWidth
            local scaleY = h / matHeight
        
            -- Determine how to scale the image to cover the button
            if scaleX > scaleY then
                -- Scale by height
                local drawWidth = matWidth * scaleY
                surface.DrawTexturedRect((w - drawWidth) / 5, 0, drawWidth, h)
            else
                -- Scale by width
                local drawHeight = matHeight * scaleX
                surface.DrawTexturedRect(0, (h - drawHeight) / 5, w, drawHeight)
            end
        end
    
        self.loadButton:SizeToContents()
    end
    self.loadButton.DoClick = function()
        self:Dim()
        parent.loadCharacterPanel:SlideUp()
    end

    if (!bHasCharacter) then
        self.loadButton:SetDisabled(true)
    end

    -- community button
    local extraURL = ix.config.Get("communityURL", "")
    local extraText = ix.config.Get("communityText", "@community")

    if (extraURL != "" and extraText != "") then
        if (extraText:sub(1, 1) == "@") then
            extraText = L(extraText:sub(2))
        end

        local extraButton = self.mainButtonList:Add("ixMenuButton")
        extraButton:SetText("")
        extraButton:SetFont("InterlockFont40-Light")
        local material = ix.util.GetMaterial("catalyst/ui/community.png")
        if material then
            extraButton.Paint = function(self, w, h)
                -- Draw the material to cover the entire button area
                surface.SetDrawColor(255, 255, 255, 255)
                surface.SetMaterial(material)
            
                -- Calculate the aspect ratio of the image
                local matWidth = material:Width()
                local matHeight = material:Height()
                local aspectRatio = matWidth / matHeight
            
                -- Calculate scaling factors
                local scaleX = w / matWidth
                local scaleY = h / matHeight
            
                -- Determine how to scale the image to cover the button
                if scaleX > scaleY then
                    -- Scale by height
                    local drawWidth = matWidth * scaleY
                    surface.DrawTexturedRect((w - drawWidth) / 5, 0, drawWidth, h)
                else
                    -- Scale by width
                    local drawHeight = matHeight * scaleX
                    surface.DrawTexturedRect(0, (h - drawHeight) / 5, w, drawHeight)
                end
            end
        
            extraButton:SizeToContents()
        end
        extraButton.DoClick = function()
            gui.OpenURL(extraURL)
        end
    end

    local changelogButton = self.mainButtonList:Add("ixMenuButton")
    changelogButton:SetText("")
    changelogButton:SetFont("InterlockFont40-Light")
    local material = ix.util.GetMaterial("catalyst/ui/changelog.png")
    if material then
        changelogButton.Paint = function(self, w, h)
            -- Draw the material to cover the entire button area
            surface.SetDrawColor(255, 255, 255, 255)
            surface.SetMaterial(material)
        
            -- Calculate the aspect ratio of the image
            local matWidth = material:Width()
            local matHeight = material:Height()
            local aspectRatio = matWidth / matHeight
        
            -- Calculate scaling factors
            local scaleX = w / matWidth
            local scaleY = h / matHeight
        
            -- Determine how to scale the image to cover the button
            if scaleX > scaleY then
                -- Scale by height
                local drawWidth = matWidth * scaleY
                surface.DrawTexturedRect((w - drawWidth) / 5, 0, drawWidth, h)
            else
                -- Scale by width
                local drawHeight = matHeight * scaleX
                surface.DrawTexturedRect(0, (h - drawHeight) / 5, w, drawHeight)
            end
        end
    
        changelogButton:SizeToContents()
    end
    changelogButton.DoClick = function()
        self:Dim()
        parent.changelogs:SlideUp()
    end

    -- leave/return button
    self.returnButton = self.mainButtonList:Add("ixMenuButton")
    self:UpdateReturnButton()
    self.returnButton.DoClick = function()
        if (self.bUsingCharacter) then
            parent:Close()
        else
            RunConsoleCommand("disconnect")
        end
    end

    self.mainButtonList:SizeToContents()
end

function PANEL:UpdateReturnButton(bValue)
    if (bValue != nil) then
        self.bUsingCharacter = bValue
    end

    --self.returnButton:SetText(self.bUsingCharacter and "return" or "leave")
    self.returnButton:SetText("")
    self.returnButton:SetFont("InterlockFont40-Light")
    local material = ix.util.GetMaterial("catalyst/ui/return.png")
    if material then
        self.returnButton.Paint = function(self, w, h)
            -- Draw the material to cover the entire button area
            surface.SetDrawColor(255, 255, 255, 255)
            surface.SetMaterial(material)
        
            -- Calculate the aspect ratio of the image
            local matWidth = material:Width()
            local matHeight = material:Height()
            local aspectRatio = matWidth / matHeight
        
            -- Calculate scaling factors
            local scaleX = w / matWidth
            local scaleY = h / matHeight
        
            -- Determine how to scale the image to cover the button
            if scaleX > scaleY then
                -- Scale by height
                local drawWidth = matWidth * scaleY
                surface.DrawTexturedRect((w - drawWidth) / 5, 0, drawWidth, h)
            else
                -- Scale by width
                local drawHeight = matHeight * scaleX
                surface.DrawTexturedRect(0, (h - drawHeight) / 5, w, drawHeight)
            end
        end
    
        self.returnButton:SizeToContents()
    end
end

function PANEL:OnDim()
    -- disable input on this panel since it will still be in the background while invisible - prone to stray clicks if the
    -- panels overtop slide out of the way
    self:SetMouseInputEnabled(false)
    self:SetKeyboardInputEnabled(false)
end

function PANEL:OnUndim()
    self:SetMouseInputEnabled(true)
    self:SetKeyboardInputEnabled(true)

    -- we may have just deleted a character so update the status of the return button
    self.bUsingCharacter = LocalPlayer().GetCharacter and LocalPlayer():GetCharacter()
    self:UpdateReturnButton()
end

function PANEL:OnClose()
    for _, v in pairs(self:GetChildren()) do
        if (IsValid(v)) then
            v:SetVisible(false)
        end
    end
end

vgui.Register("ixCharMenuMain", PANEL, "ixCharMenuPanel")

-- container panel
PANEL = {}

function PANEL:Init()
    if (IsValid(ix.gui.loading)) then
        ix.gui.loading:Remove()
    end

    if (IsValid(ix.gui.characterMenu)) then
        if (IsValid(ix.gui.characterMenu.channel)) then
            ix.gui.characterMenu.channel:Stop()
        end

        ix.gui.characterMenu:Remove()
    end

    self:SetSize(ScrW(), ScrH())
    self:SetPos(0, 0)

    -- main menu panel
    self.mainPanel = self:Add("ixCharMenuMain")

    -- new character panel
    self.newCharacterPanel = self:Add("ixCharMenuNew")
    self.newCharacterPanel:SlideDown(0)

    -- load character panel
    self.loadCharacterPanel = self:Add("ixCharMenuLoad")
    self.loadCharacterPanel:SlideDown(0)

    -- load changelogs panel
    self.changelogs = self:Add("ixCharMenuChangelogs")
    self.changelogs:SlideDown(0)

    -- notice bar
    self.notice = self:Add("ixNoticeBar")

    -- finalization
    self:MakePopup()
    self.currentAlpha = 255
    self.volume = 0

    ix.gui.characterMenu = self

    if (!IsValid(ix.gui.intro)) then
        self:PlayMusic()
    end

    hook.Run("OnCharacterMenuCreated", self)
end

function PANEL:PlayMusic()
    local path = "sound/" .. ix.config.Get("music")
    local url = path:match("http[s]?://.+")
    local play = url and sound.PlayURL or sound.PlayFile
    path = url and url or path

    play(path, "noplay", function(channel, error, message)
        if (!IsValid(self) or !IsValid(channel)) then
            return
        end

        channel:SetVolume(self.volume or 0)
        channel:Play()

        self.channel = channel

        self:CreateAnimation(audioFadeInTime, {
            index = 10,
            target = {volume = 1},

            Think = function(animation, panel)
                if (IsValid(panel.channel)) then
                    panel.channel:SetVolume(self.volume * 0.5)
                end
            end
        })
    end)
end

function PANEL:ShowNotice(type, text)
    self.notice:SetType(type)
    self.notice:SetText(text)
    self.notice:Show()
end

function PANEL:HideNotice()
    if (IsValid(self.notice) and !self.notice:GetHidden()) then
        self.notice:Slide("up", 0.5, true)
    end
end

function PANEL:OnCharacterDeleted(character)
    if (#ix.characters == 0) then
        self.mainPanel.loadButton:SetDisabled(true)
        self.mainPanel:Undim() -- undim since the load panel will slide down
    else
        self.mainPanel.loadButton:SetDisabled(false)
    end

    self.loadCharacterPanel:OnCharacterDeleted(character)
end

function PANEL:OnCharacterLoadFailed(error)
    self.loadCharacterPanel:SetMouseInputEnabled(true)
    self.loadCharacterPanel:SlideUp()
    self:ShowNotice(3, error)
end

function PANEL:IsClosing()
    return self.bClosing
end

function PANEL:Close(bFromMenu)
    self.bClosing = true
    self.bFromMenu = bFromMenu

    local fadeOutTime = animationTime * 8

    self:CreateAnimation(fadeOutTime, {
        index = 1,
        target = {currentAlpha = 0},

        Think = function(animation, panel)
            panel:SetAlpha(panel.currentAlpha)
        end,

        OnComplete = function(animation, panel)
            panel:Remove()
        end
    })

    self:CreateAnimation(fadeOutTime - 0.1, {
        index = 10,
        target = {volume = 0},

        Think = function(animation, panel)
            if (IsValid(panel.channel)) then
                panel.channel:SetVolume(self.volume * 0.5)
            end
        end,

        OnComplete = function(animation, panel)
            if (IsValid(panel.channel)) then
                panel.channel:Stop()
                panel.channel = nil
            end
        end
    })

    -- hide children if we're already dimmed
    if (bFromMenu) then
        for _, v in pairs(self:GetChildren()) do
            if (IsValid(v)) then
                v:SetVisible(false)
            end
        end
    else
        -- fade out the main panel quicker because it significantly blocks the screen
        self.mainPanel.currentAlpha = 255

        self.mainPanel:CreateAnimation(animationTime * 2, {
            target = {currentAlpha = 0},
            easing = "outQuint",

            Think = function(animation, panel)
                panel:SetAlpha(panel.currentAlpha)
            end,

            OnComplete = function(animation, panel)
                panel:SetVisible(false)
            end
        })
    end

    -- relinquish mouse control
    self:SetMouseInputEnabled(false)
    self:SetKeyboardInputEnabled(false)
    gui.EnableScreenClicker(false)
end

function PANEL:Paint(width, height)
    surface.SetTexture(gradient)
    surface.SetDrawColor(0, 0, 0, 255)
    surface.DrawTexturedRect(0, 0, width, height)
    surface.DrawTexturedRect(0, 0, width, height)

    surface.SetDrawColor(0, 0, 0, 150)
    surface.DrawRect(0, 0, width, height)

    surface.SetDrawColor(color_white)
    surface.SetMaterial(ix.util.GetMaterial("catalyst/ui/catalyst_title.png"))
    surface.DrawTexturedRect(150, 270, 500, 125)
end

function PANEL:PaintOver(width, height)
    if (self.bClosing and self.bFromMenu) then
        surface.SetDrawColor(color_black)
        surface.DrawRect(0, 0, width, height)
    end
end

function PANEL:OnRemove()
    if (self.channel) then
        self.channel:Stop()
        self.channel = nil
    end
end

vgui.Register("ixCharMenu", PANEL, "EditablePanel")

if (IsValid(ix.gui.characterMenu)) then
    ix.gui.characterMenu:Remove()

    --TODO: REMOVE ME
    ix.gui.characterMenu = vgui.Create("ixCharMenu")
end
