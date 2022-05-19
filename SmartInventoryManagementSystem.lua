SLASH_SIMS1 = "/sims"

flags = {}
flags["Item Level"] = false
flags["Equipment"] = false
flags["Item Name"] = false
flags["Binding Type"] = false
flags["Expansion"] = false
flags["Item Location"] = false
flags["Item Type"] = false

dropDownValues = {}
dropDownValues["Expansion"] = nil
dropDownValues["Item Location"] = nil
dropDownValues["Item Type"] = nil
dropDownValues["Item Level"] = nil
dropDownValues["Soulbound"] = nil

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

itemTypeValueMapping = {}
itemTypeValueMapping["Consumable"] = 0
itemTypeValueMapping["Container"] = 1
itemTypeValueMapping["Weapon"] = 2
itemTypeValueMapping["Gem"] = 3
itemTypeValueMapping["Armor"] = 4
itemTypeValueMapping["Tradegoods"] = 7
itemTypeValueMapping["ItemEnhancement"] = 8
itemTypeValueMapping["Recipe"] = 9
itemTypeValueMapping["Questitem"] = 12
itemTypeValueMapping["Miscellaneous"] = 15
itemTypeValueMapping["Glyph"] = 16
itemTypeValueMapping["BattlePet"] = 17
itemTypeValueMapping["WoWToken"] = 18

function CreateStandardCheckButton(name, parent, boxes, text, position, x, y)
    local CheckButton = CreateFrame("CheckButton", name, parent,
                                    "ChatConfigCheckButtonTemplate")
    CheckButton:SetPoint(position, x, y)
    getglobal(CheckButton:GetName() .. "Text"):SetText(text)
    CheckButton:SetScript("OnClick", function()
        flags[text] = not flags[text]
        for _, box in ipairs(boxes) do
            if (flags[text]) then
                box:Show()
            else
                box:Hide()
            end
        end
    end)
    return CheckButton
end

function CreateStandardEditBox(name, parent, position, x, y, length, width)
    local editBox = CreateFrame("EditBox", name, parent,
                                BackdropTemplateMixin and "BackdropTemplate")
    editBox:SetPoint(position, x, y)
    editBox:SetFontObject("ChatFontNormal")
    editBox:SetMultiLine(false)
    editBox:SetSize(length, width)
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
        MessageFrame:SetSize(350, 300)
        MessageFrame:SetPoint("CENTER", 0, 30)
        MessageFrame:SetJustifyH("CENTER")
        MessageFrame:SetFading(false)
        MessageFrame:EnableMouseWheel(true)
        MessageFrame:SetHyperlinksEnabled(true)
        MessageFrame:SetInsertMode(SCROLLING_MESSAGE_FRAME_INSERT_MODE_TOP)
        MessageFrame:SetFontObject(GameFontNormal)
        MessageFrame:SetScript("OnHyperlinkClick", ChatFrame_OnHyperlinkShow)
        MessageFrame:HookScript('OnHyperlinkEnter', function(self, link, text)
            GameTooltip_SetDefaultAnchor(GameTooltip, UIParent)
            GameTooltip:SetHyperlink(link)
            GameTooltip:Show()
        end)
        MessageFrame:HookScript('OnHyperlinkLeave', function(self, link, text)
            GameTooltip:Hide()
        end)
        f.MessageFrame = MessageFrame

        local resultsLabel = ConfirmationFrame:CreateFontString(
                                 ConfirmationFrame, _, "GameFontNormal")
        resultsLabel:SetPoint("TOP", -100, -40)
        resultsLabel:SetText("Results")

        local scrollBar = CreateFrame("Slider", "ConfirmationFrameScrollBar", f,
                                      "UIPanelScrollBarTemplate")
        scrollBar:SetPoint("RIGHT", f, "RIGHT", -10, 30)
        scrollBar:SetSize(30, 280)
        f.scrollBar = scrollBar

        local total = CreateFrame("ScrollingMessageFrame",
                                  "TotalSellPriceMessageFrame", f)
        total:SetSize(200, 200)
        total:SetPoint("BOTTOM", 0, 80)
        total:SetFontObject(GameFontNormal)
        total:SetJustifyH("LEFT")
        total:SetFading(false)
        total:SetMaxLines(100)
        f.TotalFrame = total

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
        f.SellButton = sellButton

        local mailButton = CreateStandardButton(ConfirmationFrame, "Mail",
                                                "BOTTOM", -70, 40, 100, 25)

        f.MailButton = mailButton
        mailButton:RegisterEvent("MAIL_SHOW")
        mailButton:RegisterEvent("MAIL_CLOSED")
        mailButton:SetEnabled(false)
        mailButton:SetScript("OnEvent", function(self, event)
            if event == "MAIL_SHOW" then
                self:SetEnabled(true)
            else
                self:SetEnabled(false)
            end
        end)

        local bankButton = CreateStandardButton(ConfirmationFrame, "Deposit",
                                                "BOTTOM", 70, 40, 100, 25)

        f.BankButton = bankButton
        bankButton:RegisterEvent("BANKFRAME_OPENED")
        bankButton:RegisterEvent("BANKFRAME_CLOSED")
        bankButton:SetEnabled(false)
        bankButton:SetScript("OnEvent", function(self, event)
            if event == "BANKFRAME_OPENED" then
                self:SetEnabled(true)
            else
                self:SetEnabled(false)
            end
        end)

        local destroyButton = CreateStandardButton(ConfirmationFrame, "Destroy",
                                                   "BOTTOMLEFT", 20, 10, 100,
                                                   25, "DestroyButton")
        f.DestroyButton = destroyButton

        local cancelButton = CreateStandardButton(ConfirmationFrame, "Cancel",
                                                  "BOTTOMRIGHT", -20, 10, 100,
                                                  25, "CancelButton")
        cancelButton:SetScript("OnClick", cancelCallback)

        f:Show()
    end

    ConfirmationFrame.SellButton:SetScript("OnClick", function(self)
        for key, value in ipairs(itemCoords) do
            UseContainerItem(value.bag, value.slot)
        end

        ConfirmationFrame:Hide()
        MainFrame_Show()
    end)
    ConfirmationFrame.SellButton:SetEnabled(MerchantFrame:IsVisible())

    ConfirmationFrame.DestroyButton:SetScript("OnClick", function()
        for key, value in ipairs(itemCoords) do
            PickupContainerItem(value.bag, value.slot)
            DeleteCursorItem()
        end

        ConfirmationFrame:Hide()
        MainFrame_Show()
    end)

    ConfirmationFrame.MailButton:SetScript("OnClick", function()
        if (SendMailFrame:IsShown()) then
            for key, value in ipairs(itemCoords) do
                UseContainerItem(value.bag, value.slot)
            end
            ConfirmationFrame:Hide()
            MainFrame_Show()
        end
    end)
    ConfirmationFrame.MailButton:SetEnabled(MailFrame:IsVisible())

    ConfirmationFrame.BankButton:SetScript("OnClick", function()
        for key, value in ipairs(itemCoords) do
            UseContainerItem(value.bag, value.slot)
        end
        ConfirmationFrame:Hide()
        MainFrame_Show()
    end)
    ConfirmationFrame.BankButton:SetEnabled(BankFrame:IsVisible())

    local length = 0
    for key, value in ipairs(itemLinks) do length = length + 1 end

    ConfirmationFrame.MessageFrame:Clear()
    ConfirmationFrame.MessageFrame:SetMaxLines(length)

    for key, value in ipairs(itemLinks) do
        ConfirmationFrame.MessageFrame:AddMessage(value)
    end

    local bottomPadding = 25
    local visualMax = length < bottomPadding and 0 or length - bottomPadding
    if (visualMax == 0) then
        ConfirmationFrame.scrollBar:Hide()
    else
        ConfirmationFrame.scrollBar:Show()
    end

    ConfirmationFrame.scrollBar:SetMinMaxValues(0, visualMax)
    ConfirmationFrame.scrollBar:SetValue(0)
    ConfirmationFrame.MessageFrame:SetScript("OnMouseWheel",
                                             function(self, delta)
        if ((delta < 0 and self:GetScrollOffset() < length - bottomPadding) or
            delta > 0) then
            self:ScrollByAmount(-delta * 3)
            ConfirmationFrame.scrollBar:SetValue(self:GetScrollOffset())
        end
    end)

    ConfirmationFrame.TotalFrame:Clear()
    ConfirmationFrame.TotalFrame:AddMessage("Total Sell Price")
    ConfirmationFrame.TotalFrame:AddMessage(GetCoinTextureString(totalSellPrice))

    ConfirmationFrame:Show()
end

function updateConfirmationFrame() end

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
    if (flags["Item Name"] and isHit) then
        if (not string.find(itemName:lower(), ItemNameEditBox:GetText():lower())) then
            isHit = false
        end
    end
    if (flags["Item Level"] and isHit) then
        local operators = {
            ["="] = function()
                return tonumber(ItemLevelEditBox:GetText()) == itemLevel
            end,
            ["<"] = function()
                return itemLevel and itemLevel <
                           tonumber(ItemLevelEditBox:GetText()) or false
            end,
            [">"] = function()
                return itemLevel and itemLevel >
                           tonumber(ItemLevelEditBox:GetText()) or false
            end,
            ["<="] = function()
                return itemLevel and itemLevel <=
                           tonumber(ItemLevelEditBox:GetText()) or false
            end,
            [">="] = function()
                return itemLevel and itemLevel >=
                           tonumber(ItemLevelEditBox:GetText()) or false
            end,
            ["!="] = function()
                return tonumber(ItemLevelEditBox:GetText()) ~= itemLevel
            end
        }

        if (operators[dropDownValues["Item Level"] or "="]() == false) then
            isHit = false
        end
    end
    if (flags["Equipment"] and isHit) then
        if (itemType ~= "Armor" and itemType ~= "Weapon") then
            isHit = false
        end
    end
    if (flags["Binding Type"] and isHit) then
        if (dropDownValues["Soulbound"] == "Not Bound" and isBound ~= false) then
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
    if (flags["Item Location"] and isHit) then
        if (dropDownValues["Item Location"] ~= _G[itemEquipLoc]) then
            isHit = false
        end
    end
    if (flags["Item Type"] and isHit) then
        if (dropDownValues["Item Type"] ~= itemType) then isHit = false end
    end
    if (isHit) then
        local coords = {}
        coords.bag = currentBag
        coords.slot = slot

        table.insert(itemCoords, coords)
        table.insert(filteredItems, itemLink)
        if (sellPrice) then
            return sellPrice * itemCount
        else
            return 0
        end
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

        local queries = CreateFrame("ScrollingMessageFrame", nil, f)
        queries:SetSize(400, 400)
        queries:SetPoint("TOP", 0, -5)
        queries:SetFontObject(GameFontNormal)
        queries:SetJustifyH("CENTER")

        local queryLabel =
            queries:CreateFontString(queries, _, "GameFontNormal")
        queryLabel:SetPoint("TOP", -150, -30)
        queryLabel:SetText("Queries")

        local flags = CreateFrame("ScrollingMessageFrame", nil, f)
        flags:SetSize(400, 100)
        flags:SetPoint("BOTTOM", 0, 55)
        flags:SetFontObject(GameFontNormal)
        flags:SetJustifyH("CENTER")

        local itemNameEditBox = CreateStandardEditBox("ItemNameEditBox",
                                                      queries, "TOP", 65, -45,
                                                      155, 40)
        local itemNameButton = CreateStandardCheckButton("ItemNameCheckBox",
                                                         queries,
                                                         {itemNameEditBox},
                                                         "Item Name", "TOP",
                                                         -150, -50)

        local iLvlDropDownMenuItems = {"=", "<", ">", "<=", ">=", "!="}
        local iLvlDropDown = CreateStandardDropDown(queries, "TOP", 27, -90, 70,
                                                    "Operator",
                                                    iLvlDropDownMenuItems,
                                                    "Item Level")
        local iLvlEditBox = CreateStandardEditBox("ItemLevelEditBox", queries,
                                                  "TOP", 115, -80, 77.5, 40)
        local iLvlButton = CreateStandardCheckButton("ItemLevelCheckBox",
                                                     queries, {
            iLvlEditBox, iLvlDropDown
        }, "Item Level", "TOP", -150, -90)

        local expansionDropDownMenuItems = {
            "Classic", "Burning Crusade", "Wrath of the Lich King", "Cataclysm",
            "Mists of Pandaria", "Warlords of Draenor", "Legion",
            "Battle for Azeroth", "Shadowlands"
        }
        local expansionDropDown = CreateStandardDropDown(queries, "TOP", 65,
                                                         -125, 145, "Expansion",
                                                         expansionDropDownMenuItems,
                                                         "Expansion")
        local expansionButton = CreateStandardCheckButton("ExpansionCheckBox",
                                                          queries,
                                                          {expansionDropDown},
                                                          "Expansion", "TOP",
                                                          -150, -130)
        local qualityDropDownMenuItems = {
            ITEM_QUALITY0_DESC, ITEM_QUALITY1_DESC, ITEM_QUALITY2_DESC,
            ITEM_QUALITY3_DESC, ITEM_QUALITY4_DESC, ITEM_QUALITY5_DESC,
            ITEM_QUALITY6_DESC, ITEM_QUALITY7_DESC, ITEM_QUALITY8_DESC
        }

        local qualityDropDown = CreateStandardDropDown(queries, "TOP", 65, -165,
                                                       145, "Quality",
                                                       qualityDropDownMenuItems,
                                                       "Quality")
        local qualityButton = CreateStandardCheckButton("QualityCheckBox",
                                                        queries,
                                                        {qualityDropDown},
                                                        "Quality", "TOP", -150,
                                                        -170)

        local itemLocationDropDownMenuItems = {
            INVTYPE_HEAD, INVTYPE_NECK, INVTYPE_SHOULDER, INVTYPE_BODY,
            INVTYPE_CHEST, INVTYPE_WAIST, INVTYPE_LEGS, INVTYPE_FEET,
            INVTYPE_WRIST, INVTYPE_HAND, INVTYPE_FINGER, INVTYPE_TRINKET,
            INVTYPE_WEAPON, INVTYPE_RANGED, INVTYPE_CLOAK, INVTYPE_2HWEAPON,
            INVTYPE_BAG, INVTYPE_TABARD, INVTYPE_WEAPONOFFHAND,
            INVTYPE_HOLDABLE, INVTYPE_AMMO, INVTYPE_THROWN, INVTYPE_RANGEDRIGHT,
            INVTYPE_QUIVER, INVTYPE_RELIC, INVTYPE_WEAPONMAINHAND
        }

        local itemLocationDropDown = CreateStandardDropDown(queries, "TOP", 65,
                                                            -205, 145,
                                                            "Item Location",
                                                            itemLocationDropDownMenuItems,
                                                            "Item Location")
        local itemLocationButton = CreateStandardCheckButton(
                                       "ItemTypeCheckButton", queries,
                                       {itemLocationDropDown}, "Item Location",
                                       "TOP", -150, -210)

        local itemTypeDropDownMenuItems = {
            "Armor", "Consumable", "Container", "Gem", "Key", "Miscellaneous",
            "Money", "Recipe", "Projectile", "Quest", "Quiver", "Tradeskill",
            "Weapon"
        }

        local itemTypeDropDown = CreateStandardDropDown(queries, "TOP", 65,
                                                        -245, 145, "Item Type",
                                                        itemTypeDropDownMenuItems,
                                                        "Item Type")

        local itemTypeButton = CreateStandardCheckButton("ItemTypeCheckBox",
                                                         queries,
                                                         {itemTypeDropDown},
                                                         "Item Type", "TOP",
                                                         -150, -250)

        local bindingTypeDropDownMenuItems = {"Soulbound", "Not Bound"}
        local bindingTypeDropDown = CreateStandardDropDown(queries, "TOP", 65,
                                                           -285, 145,
                                                           "Binding Type",
                                                           bindingTypeDropDownMenuItems,
                                                           "Soulbound")
        local bindingTypeButton = CreateStandardCheckButton("SoulBoundCheckBox",
                                                            queries, {
            bindingTypeDropDown
        }, "Binding Type", "TOP", -150, -290)

        local flagLabel = flags:CreateFontString(flags, _, "GameFontNormal")
        flagLabel:SetPoint("TOP", -150, -30)
        flagLabel:SetText("Flags")

        local equipmentButton = CreateStandardCheckButton("EquipmentCheckBox",
                                                          flags, nil,
                                                          "Equipment", "TOP",
                                                          -150, -50)

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
