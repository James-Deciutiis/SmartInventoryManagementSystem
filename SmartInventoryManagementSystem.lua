SLASH_SIMS1 = "/sims"

local data = ""

function MainFrame_Show()
	if not MainFrame then
		local f = CreateFrame("Frame", "MainFrame", UIParent, "BasicFrameTemplateWithInset")
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
    f.title = f:CreateFontString(nil, "OVERLAY")
    f.title:SetFontObject("GameFontHighlight")
    f.title:SetPoint("CENTER", f.TitleBg, 5, 0)
    f.title:SetText("S.I.M.S")

    local editBox = CreateFrame("EditBox", "MainEditBox", MainFrame)
    editBox:SetPoint("CENTER")
    editBox:SetFontObject("ChatFontNormal")
    editBox:SetMultiLine(true)
    editBox:SetSize(200, 100)
    editBox:SetAutoFocus(true)
    editBox:SetScript("OnEscapePressed", function() f:Hide() end)

    local button = CreateFrame("Button", "AcceptButton", MainFrame, "GameMenuButtonTemplate")
    button:SetPoint("BOTTOM", 0, 10)
    button:SetText("Okay")
    button:SetScript("OnClick", function(self)
      local query = editBox:GetText()
      for currentBag = BACKPACK_CONTAINER, NUM_BAG_SLOTS do 
        for slot = 1, GetContainerNumSlots(currentBag) do
          local itemLink = GetContainerItemLink(currentBag, slot)
          if(itemLink) then
            print(GetItemInfo(itemLink))
          end
        end
      end
    end)
    
		f:Show()
	end
 	if text then
			MainFrameEditBox:SetText(text)
	end

	MainFrame:Show()
end

local function SimsHandler()
	MainFrame_Show()
end

SlashCmdList["SIMS"] = SimsHandler;
