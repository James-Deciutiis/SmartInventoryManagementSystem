SLASH_SIMS1 = "/sims"

flags = {}
flags["Item Level"] = false
flags["Equipment"] = false
flags["Item Name"] = false
flags["Soulbound"] = false
flags["Expansion"] = false

dropDownValues = {}
dropDownValues["Equipment"] = nil
dropDownValues["Soulbound"] = nil
dropDownValues["Expansion"] = nil

expansionValueMapping = {}
expansionValueMapping["Classic"] = 0;
expansionValueMapping["Burning Crusade"] = 1
expansionValueMapping["Wrath of the Lich King"] = 2
expansionValueMapping["Cataclysm"] = 3
expansionValueMapping["Mists of Pandaria"] = 4
expansionValueMapping["Warlords of Draenor"] = 5
expansionValueMapping["Legion"] = 6
expansionValueMapping["Battle for Azeroth"] = 7
expansionValueMapping["Shadowlands"] = 8

qualityValueMapping = {}
qualityValueMapping["Poor"] = 0
qualityValueMapping["Common"] = 1
qualityValueMapping["Uncommon"] = 2
qualityValueMapping["Rare"] = 3
qualityValueMapping["Epic"] = 4
qualityValueMapping["Legendary"] = 5
qualityValueMapping["Artifact"] = 6
qualityValueMapping["Heirloom"] = 7
qualityValueMapping["WoW Token"] = 8

function CreateStandardCheckButton(name, parent, box, text, position, x, y)
    local CheckButton = CreateFrame("CheckButton", name, parent,
                                    "ChatConfigCheckButtonTemplate")
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

function CreateStandardEditBox(name, parent, position, x, y)
    local editBox = CreateFrame("EditBox", name, MainFrame,
                                BackdropTemplateMixin and "BackdropTemplate")
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

function CreateStandardFrame(name, text)
    local f =
        CreateFrame("Frame", name, UIParent, "BasicFrameTemplateWithInset")
    f:SetPoint("CENTER")
    f:SetSize(400, 500)
    f:SetMovable(true)
    f:SetClampedToScreen(true)
    f:EnableKeyboard(true)
    f.title = f:CreateFontString(nil, "OVERLAY")
    f.title:SetFontObject("GameFontHighlight")
    f.title:SetPoint("CENTER", f.TitleBg, 5, 0)
    f.title:SetText(text)

    f:SetScript("OnMouseDown", function(self, button)
        if button == "LeftButton" then self:StartMoving() end
    end)
    f:SetScript("OnKeyDown", function(self, key)
        if (GetBindingFromClick(key) == "TOGGLEGAMEMENU") then
            self:Hide()
        end
    end)
    f:SetScript("OnMouseUp", f.StopMovingOrSizing)

    return f
end

function CreateStandardButton(parent, text, position, x, y, length, height, name)
    local button = nil
    if (name ~= nil) then
        button = CreateFrame("Button", name, parent, "GameMenuButtonTemplate")
    else
        button = CreateFrame("Button", nil, parent, "GameMenuButtonTemplate")
    end
    button:SetPoint(position, x, y)
    if (length ~= nil and height ~= nil) then button:SetSize(length, height) end
    button:SetText(text)
    return button
end

function CreateStandardDropDown(parent, position, x, y, width, text, menuItems,
                                target)
    local dropDown = CreateFrame("FRAME", nil, parent, "UIDropDownMenuTemplate")
    dropDown:SetPoint(position, x, y)
    dropDown:Hide()
    UIDropDownMenu_SetWidth(dropDown, width)
    UIDropDownMenu_SetText(dropDown, text)
    UIDropDownMenu_Initialize(dropDown, function(self, level, menuList)
        local info = UIDropDownMenu_CreateInfo()
        info.func = self.SetValue
        for key, value in ipairs(menuItems) do

            info.text, info.arg1, info.checked = value, value, value ==
                                                     dropDownValues[target]
            UIDropDownMenu_AddButton(info, level)
        end
    end)

    function dropDown:SetValue(newValue)
        dropDownValues[target] = newValue
        UIDropDownMenu_SetText(dropDown, newValue)
        CloseDropDownMenus()
    end

    return dropDown
end

function ConfirmationFrame_Show(itemLinks, totalSellPrice, itemCoords)
    if not ConfirmationFrame then
        local f = CreateStandardFrame("ConfirmationFrame", "Confirm")
        f:EnableMouse(true)
        f:EnableMouseWheel(true)

        local MessageFrame = CreateFrame("ScrollingMessageFrame",
                                         "ConfirmationMessageFrame", f)
        MessageFrame:SetSize(350, 350)
        MessageFrame:SetPoint("CENTER", 0, 20)
        MessageFrame:SetJustifyH("CENTER")
        MessageFrame:SetFading(false)
        MessageFrame:EnableMouseWheel(true)
        MessageFrame:SetHyperlinksEnabled(true)
        MessageFrame:SetInsertMode(SCROLLING_MESSAGE_FRAME_INSERT_MODE_TOP)
        MessageFrame:SetFontObject(GameFontNormal)
        MessageFrame:SetScript("OnHyperlinkClick", ChatFrame_OnHyperlinkShow)
        MessageFrame:HookScript('OnHyperlinkEnter', ChatFrame_OnHyperlinkShow)
        MessageFrame:HookScript('OnHyperlinkLeave', function()
            MessageFrame:SetHyperlinksEnabled(false)
        end)

        local scrollBar = CreateFrame("Slider", "ConfirmationFrameScrollBar", f,
                                      "UIPanelScrollBarTemplate")
        scrollBar:SetPoint("RIGHT", f, "RIGHT", -10, 10)
        scrollBar:SetSize(30, 350)
        f.scrollBar = scrollBar

        local total = CreateFrame("ScrollingMessageFrame",
                                  "TotalSellPriceMessageFrame", f)
        total:SetSize(200, 200)
        total:SetPoint("BOTTOM", 0, 50)
        total:SetFontObject(GameFontNormal)
        total:SetJustifyH("LEFT")
        total:SetFading(false)
        total:SetMaxLines(100)

        local func = function(self) f:Hide() end

        local cancelCallback = function(self)
            f:Hide()
            MainFrame_Show()
        end

        local sellButton = CreateStandardButton(ConfirmationFrame, "Sell",
                                                "BOTTOM", 0, 10, 100, 25,
                                                "SellButton")
        sellButton:RegisterEvent("MERCHANT_SHOW")
        sellButton:RegisterEvent("MERCHANT_CLOSED")
        sellButton:SetEnabled(false)
        sellButton:SetScript("OnEvent", function(self, event)
            if event == "MERCHANT_SHOW" then
                self:SetEnabled(true)
            else
                self:SetEnabled(false)
            end
        end)

        local destroyButton = CreateStandardButton(ConfirmationFrame, "Destroy",
                                                   "BOTTOMLEFT", 20, 10, 100,
                                                   25, "DestroyButton")
        destroyButton:SetScript("OnClick", func)

        local cancelButton = CreateStandardButton(ConfirmationFrame, "Cancel",
                                                  "BOTTOMRIGHT", -20, 10, 100,
                                                  25, "CancelButton")
        cancelButton:SetScript("OnClick", cancelCallback)

        f:Show()
    end

    getglobal("SellButton"):SetScript("OnClick", function(self)
        for key, value in ipairs(itemCoords) do
            UseContainerItem(value.bag, value.slot)
        end

        ConfirmationFrame:Hide()
        MainFrame_Show()
    end)

    getglobal("SellButton"):SetEnabled(MerchantFrame:IsVisible())

    local length = 0
    for key, value in ipairs(itemLinks) do length = length + 1 end

    getglobal("ConfirmationMessageFrame"):Clear()
    getglobal("ConfirmationMessageFrame"):SetMaxLines(length)

    for key, value in ipairs(itemLinks) do
        getglobal("ConfirmationMessageFrame"):AddMessage(value)
    end

    local visualMax = length < 29 and 0 or length - 29
    if (visualMax == 0) then
        ConfirmationFrame.scrollBar:Hide()
    else
        ConfirmationFrame.scrollBar:Show()
    end

    ConfirmationFrame.scrollBar:SetMinMaxValues(0, visualMax)
    ConfirmationFrame.scrollBar:SetValue(0)
    getglobal("ConfirmationMessageFrame"):SetScript("OnMouseWheel",
                                                    function(self, delta)
        if ((delta < 0 and self:GetScrollOffset() < length - 29) or delta > 0) then
            self:ScrollByAmount(-delta * 3)
            ConfirmationFrame.scrollBar:SetValue(self:GetScrollOffset())
        else
            print("end")
        end
    end)

    getglobal("TotalSellPriceMessageFrame"):Clear()
    getglobal("TotalSellPriceMessageFrame"):AddMessage("Total Sell Price")
    getglobal("TotalSellPriceMessageFrame"):AddMessage(
        GetCoinTextureString(totalSellPrice))

    ConfirmationFrame:Show()
end

function updateConfirmationFrame()
    getglobal("SellButton"):SetScript("OnClick", function(self)
        for key, value in ipairs(itemCoords) do
            UseContainerItem(value.bag, value.slot)
        end

        ConfirmationFrame:Hide()
        MainFrame_Show()
    end)
    getglobal("SellButton"):SetEnabled(MerchantFrame:IsVisible())

    getglobal("ConfirmationMessageFrame"):Clear()
    for key, value in ipairs(itemLinks) do
        getglobal("ConfirmationMessageFrame"):AddMessage(value)
    end

    getglobal("TotalSellPriceMessageFrame"):Clear()
    getglobal("TotalSellPriceMessageFrame"):AddMessage("Total Sell Price")
    getglobal("TotalSellPriceMessageFrame"):AddMessage(
        GetCoinTextureString(totalSellPrice))
end

function scanBags()
    for currentBag = BACKPACK_CONTAINER, NUM_BAG_SLOTS do
        for slot = 1, GetContainerNumSlots(currentBag) do
            local itemLink = GetContainerItemLink(currentBag, slot)
        end
    end
end

function filter(itemLink, filteredItems, itemCoords, currentBag, slot)
    itemName, _, itemQuality, itemLevel, itemMinLevel, itemType, itemSubType, itemStackCount, itemEquipLoc, itemTexture, sellPrice, classID, subclassID, bindType, expacID, setID, isCraftingReagent =
        GetItemInfo(itemLink)
    icon, itemCount, locked, quality, readable, lootable, itemLink, isFiltered, noValue, itemID, isBound =
        GetContainerItemInfo(currentBag, slot)
    local isHit = true
    if (sellPrice == nil or sellPrice == 0) then return 0 end
    if (flags["Item Name"] and isHit) then
        if (not string.find(itemName:lower(), ItemNameEditBox:GetText():lower())) then
            isHit = false
        end
    end
    if (flags["Item Level"] and isHit) then
        if (tonumber(ItemLevelEditBox:GetText()) ~= itemLevel) then
            isHit = false
        end
    end
    if (flags["Equipment"] and isHit) then
        if (dropDownValues["Equipment"] ~= itemType) then isHit = false end
    end
    if (flags["Soulbound"] and isHit) then
        if (dropDownValues["Soulbound"] == "Not Soulbound" and isBound ~= false) then
            isHit = false
        elseif (dropDownValues["Soulbound"] == "Soulbound" and isBound ~= true) then
            isHit = false
        end
    end
    if (flags["Expansion"] and isHit) then
        if (expansionValueMapping[dropDownValues["Expansion"]] ~= expacID) then
            isHit = false
        end
    end
    if (flags["Quality"] and isHit) then
        if (qualityValueMapping[dropDownValues["Quality"]] ~= itemQuality) then
            isHit = false
        end
    end
    if (isHit) then
        local coords = {}
        coords.bag = currentBag
        coords.slot = slot

        table.insert(itemCoords, coords)
        table.insert(filteredItems, itemLink)
        return sellPrice
    end

    return 0
end

function ParseBags()
    local filteredItems = {}
    local itemCoords = {}
    local totalSellPrice = 0
    for currentBag = BACKPACK_CONTAINER, NUM_BAG_SLOTS do
        for slot = 1, GetContainerNumSlots(currentBag) do
            local itemLink = GetContainerItemLink(currentBag, slot)
            if (itemLink) then
                totalSellPrice = totalSellPrice +
                                     filter(itemLink, filteredItems, itemCoords,
                                            currentBag, slot)
            end
        end
    end

    ConfirmationFrame_Show(filteredItems, totalSellPrice, itemCoords)
end

function MainFrame_Show()
    if not MainFrame then
        local f = CreateStandardFrame("MainFrame", "S.I.M.S")

        local itemNameEditBox = CreateStandardEditBox("ItemNameEditBox",
                                                      MainFrame, "TOP", 65, -35)
        local itemNameButton = CreateStandardCheckButton("ItemNameCheckBox",
                                                         MainFrame,
                                                         itemNameEditBox,
                                                         "Item Name", "TOP",
                                                         -150, -40)

        local iLvlEditBox = CreateStandardEditBox("ItemLevelEditBox", MainFrame,
                                                  "TOP", 65, -75)
        local iLvlButton = CreateStandardCheckButton("ItemLevelCheckBox",
                                                     MainFrame, iLvlEditBox,
                                                     "Item Level", "TOP", -150,
                                                     -80)

        local equipmentDropDownMenuItems = {"Armor", "Weapon"}
        local equipmentDropDown = CreateStandardDropDown(MainFrame, "TOP", 65,
                                                         -117, 145,
                                                         "Equipment Type",
                                                         equipmentDropDownMenuItems,
                                                         "Equipment")

        local equipmentButton = CreateStandardCheckButton("EquipmentCheckBox",
                                                          MainFrame,
                                                          equipmentDropDown,
                                                          "Equipment", "TOP",
                                                          -150, -120)

        local soulBoundDropDownMenuItems = {"Soulbound", "Not Soulbound"}
        local soulBoundDropDown = CreateStandardDropDown(MainFrame, "TOP", 65,
                                                         -157, 145,
                                                         "Is Soulbound",
                                                         soulBoundDropDownMenuItems,
                                                         "Soulbound")
        local soulBoundButton = CreateStandardCheckButton("SoulBoundCheckBox",
                                                          MainFrame,
                                                          soulBoundDropDown,
                                                          "Soulbound", "TOP",
                                                          -150, -160)

        local expansionDropDownMenuItems = {
            "Classic", "Burning Crusade", "Wrath of the Lich King", "Cataclysm",
            "Mists of Pandaria", "Warlords of Draenor", "Legion",
            "Battle for Azeroth", "Shadowlands"
        }
        local expansionDropDown = CreateStandardDropDown(MainFrame, "TOP", 65,
                                                         -197, 145, "Expansion",
                                                         expansionDropDownMenuItems,
                                                         "Expansion")
        local expansionButton = CreateStandardCheckButton("ExpansionCheckBox",
                                                          MainFrame,
                                                          expansionDropDown,
                                                          "Expansion", "TOP",
                                                          -150, -200)
        local qualityDropDownMenuItems = {
            ITEM_QUALITY0_DESC, ITEM_QUALITY1_DESC, ITEM_QUALITY2_DESC,
            ITEM_QUALITY3_DESC, ITEM_QUALITY4_DESC, ITEM_QUALITY5_DESC,
            ITEM_QUALITY6_DESC, ITEM_QUALITY7_DESC, ITEM_QUALITY8_DESC
        }
        local qualityDropDown = CreateStandardDropDown(MainFrame, "TOP", 65,
                                                       -237, 145, "Quality",
                                                       qualityDropDownMenuItems,
                                                       "Quality")
        local qualityButton = CreateStandardCheckButton("QualityCheckBox",
                                                        MainFrame,
                                                        qualityDropDown,
                                                        "Quality", "TOP", -150,
                                                        -240)

        local button = CreateStandardButton(MainFrame, "Query Bags", "BOTTOM",
                                            0, 15, nil, nil, nil)
        button:SetScript("OnClick", function(self)
            ParseBags()
            f:Hide()
        end)

        f:Show()
    end
    if text then MainFrameEditBox:SetText(text) end

    MainFrame:Show()
end

local function SimsHandler()
    scanBags()
    MainFrame_Show()
end

SlashCmdList["SIMS"] = SimsHandler;
