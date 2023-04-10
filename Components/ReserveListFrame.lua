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
    local currentResults = CreateFrame("ScrollingMessageFrame", nil, f)
    currentResults:SetSize(400, 400)
    currentResults:SetPoint("TOP", 0, -5)
    currentResults:SetFontObject(GameFontNormal)

    local MessageFrame = SIMS.FrameFactory.CreateScrollingMessageFrame(
                             currentResults, 185, -10, 350, 300)
    currentResults.MessageFrame = MessageFrame

    local currentResultsCallback = function()
        local reservedItems = ReserveList
        local length = 0
        for key, value in ipairs(reservedItems) do length = length + 1 end

        currentResults.MessageFrame:Clear()
        currentResults.MessageFrame:SetMaxLines(length)
        for key, value in ipairs(reservedItems) do
            currentResults.MessageFrame:AddMessage(value)
        end
        local bottomPadding = 25
        local visualMax = length < bottomPadding and 0 or length - bottomPadding
        if (visualMax == 0) then
            currentResults.MessageFrame.scrollBar:Hide()
        else
            currentResults.MessageFrame.scrollBar:Show()
        end

        currentResults.MessageFrame.scrollBar:SetMinMaxValues(0, visualMax)
        currentResults.MessageFrame:SetScript("OnMouseWheel",
                                              function(self, delta)
            if (((delta < 0 and self:GetScrollOffset() < length - bottomPadding) or
                delta > 0)) then
                self:ScrollByAmount(-delta * 3)
                -- throws lua error, come back to this
                -- currentResults.MessageFrame.scrollBar:SetValue(self:GetScrollOffset())
            end
        end)

    end

    -- left side of Reserve List frame
    local inventory = CreateFrame("ScrollingMessageFrame", nil, f)
    inventory:SetSize(400, 400)
    inventory:SetPoint("TOP", 0, -5)
    inventory:SetFontObject(GameFontNormal)

    local InvMessageFrame = SIMS.FrameFactory.CreateScrollingMessageFrame(
                                inventory, -170, -10, 350, 300)
    inventory.MessageFrame = InvMessageFrame
    local inventoryCallback = function()
        local parseResults = ParseBags()
        local itemLinks = parseResults.filteredItems
        local length = 0
        for key, value in ipairs(itemLinks) do length = length + 1 end

        inventory.MessageFrame:Clear()
        inventory.MessageFrame:SetMaxLines(length)
        for key, value in ipairs(itemLinks) do
            inventory.MessageFrame:AddMessage(value)
        end
        local bottomPadding = 25
        local visualMax = length < bottomPadding and 0 or length - bottomPadding
        if (visualMax == 0) then
            inventory.MessageFrame.scrollBar:Hide()
        else
            inventory.MessageFrame.scrollBar:Show()
        end

        inventory.MessageFrame.scrollBar:SetMinMaxValues(0, visualMax)
        inventory.MessageFrame:SetScript("OnMouseWheel", function(self, delta)
            if (((delta < 0 and self:GetScrollOffset() < length - bottomPadding) or
                delta > 0)) then
                self:ScrollByAmount(-delta * 3)
                -- throws lua error, come back to this
                -- inventory.MessageFrame.scrollBar:SetValue(self:GetScrollOffset())
            end
        end)

    end

    currentResults.MessageFrame:SetScript("OnHyperlinkClick",
                                          function(self, link, text, button)
        SetItemRef(link, text, button, self)

        local tmp = {}
        for key, value in ipairs(ReserveList) do
            if value ~= text then table.insert(tmp, value) end
        end

        ReserveList = tmp
        currentResultsCallback()
        inventoryCallback()
    end)

    inventory.MessageFrame:SetScript("OnHyperlinkClick",
                                     function(self, link, text, button)
        SetItemRef(link, text, button, self)
        table.insert(ReserveList, text)
        currentResultsCallback()
        inventoryCallback()

    end)
    f:SetScript("OnShow", function()
        currentResultsCallback()
        inventoryCallback()
    end)

    ReserveListFrame:Hide()
end

function ReserveListFrameComponent.Show()
    if not ReserveListFrame then ReserveListFrameComponent.Create() end

    ReserveListFrame:Show()
end
