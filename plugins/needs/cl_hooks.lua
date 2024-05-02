local PLUGIN = PLUGIN

local skinTable = derma.GetSkinTable()["helix"] or {}
local colors = skinTable["Colours"] or skinTable["Colors"] or {}
local infoColor = colors["Info"] or Color(0, 255, 255)
local successColor = colors["Success"] or Color(0, 255, 0)
local errorColor = colors["Error"] or Color(255, 0, 0)
local warningColor = colors["Warning"] or Color(255, 140, 0)

local lerpBarWidth = 0
function PLUGIN:HUDPaint()
    local ply = LocalPlayer()
    if not ( IsValid(ply) ) then
        return
    end

    local char = ply:GetCharacter()
    if not ( char ) then
        return
    end

    local bSleeping = char:GetData("sleeping", false)
    if ( bSleeping ) then
        draw.RoundedBox(0, 0, 0, ScrW(), ScrH(), Color(0, 0, 0, 255))
        
        local scrW, scrH = ScrW(), ScrH()
        local x, y = scrW * 0.5, scrH * 0.45
        local text = "You are sleeping, press '" .. input.LookupBinding("+use", true):upper() .. "' to wake up."
        local font = "MinervaGenericFont32"
        local color = Color(255, 255, 255, 255)
        local textWidth, textHeight = ix.util.GetTextSize(text, font)

        y = y - textHeight * 0.5

        draw.SimpleText(text, font, x, y, color, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

        local fraction = math.Clamp((char:GetSleep() / 100), 0, 1)
        local barW, barH = scrW * 0.5, 32
        local barX, barY = scrW * 0.5 - barW * 0.5, scrH * 0.5
        local barColor = errorColor

        if ( fraction > 0.75 ) then
            barColor = successColor
        elseif ( fraction > 0.5 ) then
            barColor = infoColor
        elseif ( fraction > 0.25 ) then
            barColor = warningColor
        end

        lerpBarWidth = Lerp(FrameTime() * 5, lerpBarWidth, fraction)

        draw.RoundedBox(4, barX, barY, barW, barH, Color(0, 0, 0, 200))
        draw.RoundedBox(4, barX, barY, barW * lerpBarWidth, barH, barColor)

        draw.SimpleText(math.Round(char:GetSleep()).."%", "MinervaGenericFont24", x, barY + barH * 0.5, color, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end
end