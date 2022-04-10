SLASH_SIMS1 = "/sims"

flags = { }
flags["Item Level"] = false
flags["Equipment"] = false

filteredItems = { }
  
function CreateCheckButton(name, parent, box, text, position, x, y)
  local CheckButton = CreateFrame("CheckButton", name, parent, "ChatConfigCheckButtonTemplate")
  CheckButton:SetPoint(position, x, y)
  getglobal(CheckButton:GetName() .. "Text"):SetText(text)
  CheckButton:SetScript("OnClick", function()
    flags[text] = not flags[text]
    if (flags[text]) then
      box:Show()
    else
      box:Hide()
    end
  end)
  return CheckButton
end

function CreateEditBox(name, parent, position, x, y)
  local editBox = CreateFrame("EditBox", name, MainFrame, BackdropTemplateMixin and "BackdropTemplate")
  editBox:SetPoint(position, x, y)
  editBox:SetFontObject("ChatFontNormal")
  editBox:SetMultiLine(false)
  editBox:SetSize(155, 40)
  editBox:SetAutoFocus(false)
  editBox:SetBackdrop(BACKDROP_DIALOG_32_32);
  editBox:SetTextInsets(15, 12, 12, 11)
  editBox:SetScript("OnEscapePressed", function() editBox:ClearFocus() end)
  editBox:Hide()

  return editBox
end

function filter(itemLink)
  itemName, itemL, itemQuality, itemLevel, itemMinLevel, itemType, itemSubType, itemStackCount, itemEquipLoc, itemTexture, sellPrice, classID, subclassID, bindType, expacID, setID, isCraftingReagent = GetItemInfo(itemLink)
  local isHit = true
  if(flags["Item Level"] and isHit) then
    if(tonumber(ItemLevelEditBox:GetText()) ~= itemLevel) then
      isHit = false
    end
  end
  if(flags["Equipment"] and isHit) then
    if(EquipmentEditBox:GetText() ~= itemType) then
      isHit = false
    end
  end
  if(isHit) then
    table.insert(filteredItems, itemLink)
  end
end

function ParseBags(queries)
  local inventory = { }
  for currentBag = BACKPACK_CONTAINER, NUM_BAG_SLOTS do
    for slot = 1, GetContainerNumSlots(currentBag) do
      local itemLink = GetContainerItemLink(currentBag, slot)
      if(itemLink) then
        filter(itemLink)
        table.insert(inventory, itemLink)
      end
    end
  end

  for key, value in ipairs(inventory) do
  end

  for key, value in ipairs(filteredItems) do
    print(value)
  end
end

function MainFrame_Show()
	if not MainFrame then
    local f = CreateFrame("Frame", "MainFrame", UIParent, "BasicFrameTemplateWithInset")
		f:SetPoint("CENTER")
		f:SetSize(400, 500)
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

    local itemNameEditBox = CreateEditBox("ItemNameEditBox", MainFrame, "TOP", 65, -35)
    local itemNameButton = CreateCheckButton("ItemNameCheckBox", MainFrame, itemNameEditBox, "ItemName", "TOP", -150, -40)
    
    local iLvlEditBox = CreateEditBox("ItemLevelEditBox", MainFrame, "TOP", 65, -75)
    local iLvlButton = CreateCheckButton("ItemLevelCheckBox", MainFrame, iLvlEditBox, "Item Level", "TOP", -150, -80)
    
    local equipmentEditBox = CreateEditBox("EquipmentEditBox", MainFrame, "TOP", 65, -115)
    local equipmentButton = CreateCheckButton("EquipmentCheckBox", MainFrame, equipmentEditBox, "Equipment", "TOP", -150, -120)

    local button = CreateFrame("Button", "AcceptButton", MainFrame, "GameMenuButtonTemplate")
    button:SetPoint("BOTTOM", 0, 10)
    button:SetText("Okay")
    button:SetScript("OnClick", function(self)
      ParseBags(iLvlEditBox:GetText())
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
