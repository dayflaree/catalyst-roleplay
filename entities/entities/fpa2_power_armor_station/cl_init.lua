include("shared.lua")

function ENT:Draw()
    self:DrawModel()
end

net.Receive("FPA_StationOpen", function()
    local ent = net.ReadEntity();
    local armor = net.ReadEntity();
    --
    local initialArmor = table.Copy(armor.CurrentArmor);
    if (!IsValid(armor)) then return end;
    -- -- --
    local panel = vgui.Create("DFrame");
    panel:SetSize(ScrW(),ScrH())
    panel:MakePopup()
    panel:SetTitle("")
	panel:ShowCloseButton(false);
	panel:SetDraggable(false)
    -- -- --
    local boneID = armor:LookupBone("Tank_Armor");
    local boneMatrix = armor:GetBoneMatrix(boneID)
    local bonePos, boneAng = boneMatrix:GetTranslation(), boneMatrix:GetAngles();
    local originAng = boneAng + Angle(0,255,0);
    local originPos = bonePos - (originAng:Forward() * 160) - (originAng:Up() * 18);
    originAng.r = 0;

	local greenCol = Color(12, 103, 10)
	local panelCol = Color(greenCol.r, greenCol.g, greenCol.b, 200);
	local lightGreenCol = Color(23, 212, 21, 225)
	local blankCol = Color(0,0,0,50);
	
    panel.Paint = function(self)
        local x, y = self:GetPos()

        local old = DisableClipping( true ) -- Avoid issues introduced by the natural clipping of Panel rendering
            render.RenderView( {
            origin = originPos,
            angles = originAng,
            x = x, y = y,
            w = w, h = h,
            fov = 60,
            drawviewmodel = false,
        } )
        DisableClipping( old )
    end

    local base = vgui.Create("DPanel",panel)
    base:SetSize(panel:GetWide() *.35, panel:GetTall() *.2 )
	base.Paint = function(me, w,  h)
		draw.RoundedBox( 0, 0, 0, w, h, panelCol )
	end

    local panelList = vgui.Create("DPanelList", base)
    panelList:SetSize( base:GetWide() *.95, base:GetTall() *.8 )
    panelList:Center()
    panelList:EnableVerticalScrollbar(true);
    panelList:EnableHorizontal(false);
    panelList.CreateButton = function(me, text)
        local but = vgui.Create("DButton")
        but:SetSize(me:GetWide(), me:GetTall()/5);
        but:SetText("")
		
		but.OnCursorEntered = function(self) self.Cursor = true; end;
		but.OnCursorExited = function(self) self.Cursor = false; end;
		
		but.Paint = function(self, w,  h)
			local text_col = lightGreenCol;
			local box_col = blankCol;
			local selected = false;
			
			for k,v in pairs(armor.CurrentArmor) do
				if (self.ArmorType == k and v == text) then 
					selected = true;
					break; 
				end
			end
			
			if ( self.Cursor or selected ) then
				text_col = color_black;
				box_col = lightGreenCol;
			end
		
			draw.RoundedBox( 0, 0, 0, w, h, box_col )
			
			if (selected) then
				local boxW = (h/2)
				draw.RoundedBox( 0, (boxW/2), h/2 - (boxW/2), boxW, boxW, color_black )
			end
			
			draw.SimpleText( text, "FO4Font", w*.05,  h/2, text_col, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER )
		end
        --
        me:AddItem(but);
        return but;
    end
	
	local col = lightGreenCol
	panelList.VBar.Paint = function(self, w, h)
		draw.RoundedBox( 0, 0, 0, w, h, Color( 70, 70, 70, 100 ) )
  	end
	
  	panelList.VBar.btnUp.Paint = function(self, w, h)
    	draw.RoundedBox( 0, 0, 0, w, h, col )
  	end
	
  	panelList.VBar.btnDown.Paint = function(self, w, h)
    	draw.RoundedBox( 0, 0, 0, w, h, col )
  	end
	
  	panelList.VBar.btnGrip.Paint = function(me, w, h)
    	draw.RoundedBox( 0, w*.25, 0, w/2,h, col )
  	end
	
	panelList.RemoveAllChildren = function(me)
		for k,v in pairs(me:GetItems()) do
            v:Remove();
        end
	end

    panelList.OpenType = function(me, openType)
		me.ArmorType = openType;
		me:RemoveAllChildren();
		me.CurOpenType = openType;
        -- --
		local but = me:CreateButton("NONE")
		but.DoClick = function(me)
                armor:SetArmorPiece(openType, nil);
        end
		--
		local sortedArray = {}
		for k,v in pairs(POWERARMOR.Armor) do
			sortedArray[k] = {
				Model = v,
				Order = POWERARMOR.Order[k]
			}
		end
		
        for k,v in SortedPairsByMemberValue(sortedArray, "Order") do
            local but = me:CreateButton(k);
			but.ArmorType = openType;
            but.DoClick = function(me)
                armor:SetArmorPiece(openType, k);
            end
        end
    end
	
	panelList.ShowArmors = function(me)
		for k,v in SortedPairsByValue(POWERARMOR.ArmorTypes) do
			local but = me:CreateButton(k);
			but.DoClick = function(self)
				panelList:OpenType(k);
			end
		end
	end
	
	panelList:ShowArmors()
	
	local backMenu = vgui.Create("DPanel",panel)
    backMenu:SetSize(base:GetWide()/2, panel:GetTall() *.04 )
    backMenu:SetPos(0, panel:GetTall() *.95 - backMenu:GetTall())
    backMenu:CenterHorizontal() 
	backMenu.Paint = function(self, w, h)
		draw.RoundedBox( 0, 0, 0, w, h, panelCol )
	end
	-- --
	local bx, by = backMenu:GetPos();
	base:SetPos(0, by - base:GetTall() - (backMenu:GetTall()/2))
    base:CenterHorizontal()
	backMenu.CreateButton = function(me, text)
		local but = vgui.Create("DButton", me)
		but:SetText("");
		but.OnCursorEntered = function(self) self.Cursor = true; end;
		but.OnCursorExited = function(self) self.Cursor = false; end;
		but.Paint = function(self, w,  h)
			local text_col = lightGreenCol;
			local box_col = blankCol;
			if ( self.Cursor ) then
				text_col = color_black;
				box_col = lightGreenCol;
			end
		
			draw.RoundedBox( 0, 0, 0, w, h, box_col )
			draw.SimpleText( text, "FO4Font", w*.05,  h/2, text_col, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER )
		end
		-- --
		return but;
	end
	
	local backButton = backMenu:CreateButton("BACK");
	backButton:SetPos( backMenu:GetWide() *.025, 0 );
	backButton:CenterVertical();
	backButton:SetText("");
	backButton.DoClick = function(me)
		if (panelList.CurOpenType != nil) then
			panelList:RemoveAllChildren();
			panelList:ShowArmors();
		end
	end
	
	local acceptButton =  backMenu:CreateButton("ACCEPT");
	acceptButton:SetPos( backMenu:GetWide() - acceptButton:GetWide() - backMenu:GetWide() *.025, 0 );
	acceptButton:CenterVertical();
	acceptButton.DoClick = function(me)
		for k,v in pairs(armor.CurrentArmor) do
			if (v != initialArmor[k]) then
				armor:AttemptSetArmorPiece(k, v);
			end
		end
		-- --
		panel:Remove();
	end
	
	local cancelButton =  backMenu:CreateButton("CANCEL");
	cancelButton:Center();
	cancelButton.DoClick = function(me)
	    for k,v in pairs(initialArmor) do
            if (armor.CurrentArmor[k] == v) then continue end;
            -- --
            if (v == "" or v == nil) then
                armor:SetArmorPiece(k,nil);
                continue;
            end;
            -- --
            armor:SetArmorPiece(k,v);
        end
		-- --
		panel:Remove();
	end
end)

