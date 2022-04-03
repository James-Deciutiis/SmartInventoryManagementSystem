SLASH_SIMS1 = "/sims"

local data = ""
function KethoEditBox_Show()
	if not KethoEditBox then
		local f = CreateFrame("Frame", "KethoEditBox", UIParent, "BasicFrameTemplateWithInset")
		f:SetPoint("CENTER")
		f:SetSize(600, 500)
		f:SetMovable(true)
		f:SetClampedToScreen(true)
		f:SetScript("OnMouseDown", function(self, button)
				if button == "LeftButton" then
						self:StartMoving()
				end
		end)
		f:SetScript("OnMouseUp", f.StopMovingOrSizing)
		---KethoEditBoxButton:HookScript("OnClick", function(self)
		---	for currentBag = BACKPACK_CONTAINER, NUM_BAG_SLOTS do 
		---		for slot = 1, GetContainerNumSlots(currentBag) do
		---			local itemLink = GetContainerItemLink(currentBag, slot)
		---			if(itemLink) then
		---				print(GetItemInfo(itemLink))
		---			end
		---		end
		---	end
		---end)
		
		-- ScrollFrame
		local sf = CreateFrame("ScrollFrame", "KethoEditBoxScrollFrame", KethoEditBox, "UIPanelScrollFrameTemplate")
		sf:SetPoint("LEFT", 16, 0)
		sf:SetPoint("RIGHT", -32, 0)
		sf:SetPoint("TOP", 0, -16)
		sf:SetPoint("BOTTOM", KethoEditBoxButton, "TOP", 0, 0)
		
		-- EditBox
		local eb = CreateFrame("EditBox", "KethoEditBoxEditBox", KethoEditBoxScrollFrame)
		eb:SetSize(sf:GetSize())
		eb:SetMultiLine(true)
		eb:SetAutoFocus(true) -- dont automatically focus
		eb:SetFontObject("ChatFontNormal")
		eb:SetScript("OnEscapePressed", function() f:Hide() end)
		sf:SetScrollChild(eb)
		
		-- Resizable
		f:SetResizable(true)
		f:SetMinResize(150, 100)
		
		local rb = CreateFrame("Button", "KethoEditBoxResizeButton", KethoEditBox)
		rb:SetPoint("BOTTOMRIGHT", -6, 7)
		rb:SetSize(16, 16)
		
		rb:SetNormalTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Up")
		rb:SetHighlightTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Highlight")
		rb:SetPushedTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Down")
		
		rb:SetScript("OnMouseDown", function(self, button)
				if button == "LeftButton" then
						f:StartSizing("BOTTOMRIGHT")
						self:GetHighlightTexture():Hide() -- more noticeable
				end
		end)
		rb:SetScript("OnMouseUp", function(self, button)
				f:StopMovingOrSizing()
				self:GetHighlightTexture():Show()
				eb:SetWidth(sf:GetWidth())
		end)
		f:Show()
	end
 	if text then
			KethoEditBoxEditBox:SetText(text)
	end
	KethoEditBox:Show()
end

local function SimsHandler()
	print("YEEER")
	KethoEditBox_Show()
end

SlashCmdList["SIMS"] = SimsHandler;
