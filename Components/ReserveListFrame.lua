local addonName, SIMS = ...
local ReserveListFrameComponent = {}
SIMS.ReserveListFrameComponent = ReserveListFrameComponent

local function ReserveListFrame_Show()
    if (not ReserveListFrame) then ReserveListFrame_Create() end

    ReserveListFrame:Show()
end

function ReserveListFrameComponent.Create()
    if (ReserveListFrame) then return end

    local f = SIMS.FrameFactory.CreateStandardFrame("ReserveListFrame",
                                                    "Manage Reservelist", "lg")

    -- Right side of Reserve List frame
    local currentReserveList = CreateFrame("ScrollingMessageFrame", nil, f)
    currentReserveList:SetSize(400, 400)
    currentReserveList:SetPoint("TOP", 0, -5)
    currentReserveList:SetFontObject(GameFontNormal)

    local currentReserveListLabel = currentReserveList:CreateFontString(nil,
                                                                        "ARTWORK",
                                                                        "GameFontNormal")
    currentReserveListLabel:SetPoint("TOP", 185, -30)
    currentReserveListLabel:SetText("Current Reserve List")

    local MessageFrame = SIMS.FrameFactory.CreateScrollingMessageFrame(
                             currentReserveList, 185, -20, 350, 300)
    currentReserveList.MessageFrame = MessageFrame

    local currentReserveListCallback = function()
        local reservedItems = ReserveList
        local length = 0
        for key, value in ipairs(reservedItems) do length = length + 1 end

        currentReserveList.MessageFrame:Clear()
        currentReserveList.MessageFrame:SetMaxLines(length)
        for key, value in ipairs(reservedItems) do
            currentReserveList.MessageFrame:AddMessage(value)
        end
        local topPadding = 20
        local visualMax = length < topPadding and 0 or length - topPadding
        if (visualMax == 0) then
            currentReserveList.MessageFrame.scrollBar:Hide()
        else
            currentReserveList.MessageFrame.scrollBar:Show()
        end

        -- currentReserveList.MessageFrame.scrollBar:SetMinMaxValues(0, visualMax)
        currentReserveList.MessageFrame:SetScript("OnMouseWheel",
                                                  function(self, delta)
            if (((delta < 0 and self:GetScrollOffset() < length - topPadding) or
                delta > 0)) then
                self:ScrollByAmount(-delta * 3)
                -- throws lua error, come back to this
                -- currentReserveList.MessageFrame.scrollBar:SetValue(self:GetScrollOffset())
            end
        end)

    end

    -- left side of Reserve List frame
    local inventory = CreateFrame("ScrollingMessageFrame", nil, f)
    inventory:SetSize(400, 400)
    inventory:SetPoint("TOP", 0, -5)
    inventory:SetFontObject(GameFontNormal)

    local currentInventoryListLabel = inventory:CreateFontString(nil, "ARTWORK",
                                                                 "GameFontNormal")
    currentInventoryListLabel:SetPoint("TOP", -170, -30)
    currentInventoryListLabel:SetText("Current Inventory List")

    local InvMessageFrame = SIMS.FrameFactory.CreateScrollingMessageFrame(
                                inventory, -170, -20, 350, 300)
    inventory.MessageFrame = InvMessageFrame
    local inventoryCallback = function()
        local parseResults = SIMS.Main.parseBags(true, {}, {}, {})
        local itemLinks = parseResults.filteredItems
        local length = 0
        for key, value in ipairs(itemLinks) do length = length + 1 end

        inventory.MessageFrame:Clear()
        inventory.MessageFrame:SetMaxLines(length)
        for key, value in ipairs(itemLinks) do
            inventory.MessageFrame:AddMessage(value)
        end
        local topPadding = 20
        local visualMax = length < topPadding and 0 or length - topPadding
        if (visualMax == 0) then
            inventory.MessageFrame.scrollBar:Hide()
        else
            inventory.MessageFrame.scrollBar:Show()
        end

        -- inventory.MessageFrame.scrollBar:SetMinMaxValues(0, visualMax)
        inventory.MessageFrame:SetScript("OnMouseWheel", function(self, delta)
            if (((delta < 0 and self:GetScrollOffset() < length - topPadding) or
                delta > 0)) then
                self:ScrollByAmount(-delta * 3)
                -- throws lua error, come back to this
                -- inventory.MessageFrame.scrollBar:SetValue(self:GetScrollOffset())
            end
        end)

    end

    currentReserveList.MessageFrame:SetScript("OnHyperlinkClick",
                                              function(self, link, text, button)
        local tmp = {}
        for key, value in ipairs(ReserveList) do
            if value ~= text then table.insert(tmp, value) end
        end

        ReserveList = tmp
        currentReserveListCallback()
        inventoryCallback()
    end)

    inventory.MessageFrame:SetScript("OnHyperlinkClick",
                                     function(self, link, text, button)
        table.insert(ReserveList, text)
        currentReserveListCallback()
        inventoryCallback()
    end)

    local backButton = SIMS.FrameFactory.CreateStandardButton(ReserveListFrame,
                                                              "Back", "BOTTOM",
                                                              0, 50, "sm")

    backButton:SetScript("OnClick", function(self)
        f:Hide()
        SIMS.MainFrameComponent.Show()
    end)

    f:SetScript("OnShow", function()
        currentReserveListCallback()
        inventoryCallback()
    end)

    ReserveListFrame:Hide()
end

function ReserveListFrameComponent.Show()
    if not ReserveListFrame then ReserveListFrameComponent.Create() end

    ReserveListFrame:Show()
end
