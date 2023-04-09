local addonName, SIMS = ...
local ConfirmationFrameComponent = {}
SIMS.ConfirmationFrameComponent = ConfirmationFrameComponent

function ConfirmDeleteFrame_Create()
    if ConfirmDeleteFrame then return end

    local f = SIMS.FrameFactory.CreateStandardFrame("ConfirmDeleteFrame",
                                                    "Confirm Delete", "sm")

    local confirmButton = SIMS.FrameFactory.CreateStandardButton(f, "Confirm",
                                                                 "CENTER", -50,
                                                                 -70, "md")
    local cancelButton = SIMS.FrameFactory.CreateStandardButton(f, "Cancel",
                                                                "CENTER", 50,
                                                                -70, "md")
    local total = CreateFrame("ScrollingMessageFrame",
                              "TotalSellPriceMessageFrame", f)
    total:SetSize(250, 200)
    total:SetPoint("BOTTOM", 0, 80)
    total:SetFontObject(GameFontNormal)
    total:SetJustifyH("LEFT")
    total:SetFading(false)
    total:SetMaxLines(100)
    f.TotalFrame = total

    f.ConfirmButton = confirmButton

    cancelButton:SetScript("OnClick", function()
        ConfirmationFrame:Show()
        f:Hide()
    end)
end

function ConfirmDeleteFrame_Show(coords, totalSellPrice)
    if not ConfirmDeleteFrame then ConfirmDeleteFrame_Create() end

    ConfirmationFrame:Hide()
    ConfirmDeleteFrame.ConfirmButton:SetScript("OnClick", function()
        for key, value in ipairs(itemCoords) do
            PickupContainerItem(value.bag, value.slot)
            DeleteCursorItem()
        end

        ConfirmDeleteFrame:Hide()
        SIMS.MainFrameComponent.Show()
    end)

    ConfirmDeleteFrame.TotalFrame:Clear()
    ConfirmDeleteFrame.TotalFrame:AddMessage(
        "Warning, this action will PERMANENTLY destory")
    ConfirmDeleteFrame.TotalFrame:AddMessage(
        GetCoinTextureString(totalSellPrice))
    ConfirmDeleteFrame.TotalFrame:AddMessage("worth of items, please confirm")
    ConfirmDeleteFrame:Show()
end

function ConfirmationFrameComponent.Create()
    if not ConfirmationFrame then
        local f = SIMS.FrameFactory.CreateStandardFrame("ConfirmationFrame",
                                                        "Confirm", "md")
        f:EnableMouse(true)
        f:EnableMouseWheel(true)

        local MessageFrame = SIMS.FrameFactory.CreateScrollingMessageFrame(f, 0,
                                                                           30,
                                                                           350,
                                                                           300)
        f.MessageFrame = MessageFrame

        local resultsLabel = ConfirmationFrame:CreateFontString(
                                 "ConfirmationFrame", nil, "GameFontNormal")
        resultsLabel:SetPoint("TOP", -100, -40)
        resultsLabel:SetText("Results")
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
            SIMS.MainFrameComponent.Show()
        end

        local sellButton = SIMS.FrameFactory.CreateStandardButton(
                               ConfirmationFrame, "Sell", "BOTTOM", 0, 10, "md")
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

        local mailButton = SIMS.FrameFactory.CreateStandardButton(
                               ConfirmationFrame, "Mail", "BOTTOM", -70, 40,
                               "md")

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

        local bankButton = SIMS.FrameFactory.CreateStandardButton(
                               ConfirmationFrame, "Deposit", "BOTTOM", 70, 40,
                               "md")

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

        local destroyButton = SIMS.FrameFactory.CreateStandardButton(
                                  ConfirmationFrame, "Destroy", "BOTTOMLEFT",
                                  20, 10, "md")
        f.DestroyButton = destroyButton

        local cancelButton = SIMS.FrameFactory.CreateStandardButton(
                                 ConfirmationFrame, "Cancel", "BOTTOMRIGHT",
                                 -20, 10, "md")
        cancelButton:SetScript("OnClick", cancelCallback)

        f:Show()
    end
end

function ConfirmationFrameComponent.Show()
    if not ConfirmationFrame then ConfirmationFrameComponent.Create() end

    local currentFunction =
        SavedFunctions[SIMS.mappings.dropDownValues["Saved Functions"]]

    if (currentFunction) then
        local currentFlags = currentFunction.flags
        local currentDropDownValues = currentFunction.dropDownValues
        local currentEditBoxValues = currentFunction.editBoxValues

        for key, val in pairs(currentFlags) do
            SIMS.mappings.flags[key] = val
        end
        for key, val in pairs(currentDropDownValues) do
            SIMS.mappings.dropDownValues[key] = val
        end
        for key, val in pairs(currentEditBoxValues) do
            SIMS.mappings.editBoxValues[key] = val
        end
    end

    local filterResults = ParseBags()
    itemLinks = filterResults.filteredItems
    totalSellPrice = filterResults.totalSellPrice
    itemCoords = filterResults.itemCoords

    ConfirmationFrame.SellButton:SetScript("OnClick", function()
        for key, value in ipairs(itemCoords) do
            C_Container.UseContainerItem(value.bag, value.slot)
        end

        ConfirmationFrame:Hide()
        SIMS.MainFrameComponent.Show()
    end)
    ConfirmationFrame.SellButton:SetEnabled(MerchantFrame:IsVisible())

    ConfirmationFrame.DestroyButton:SetScript("OnClick", function()
        ConfirmDeleteFrame_Show(coords, totalSellPrice)
    end)

    ConfirmationFrame.MailButton:SetScript("OnClick", function()
        if (SendMailFrame:IsShown()) then
            for key, value in ipairs(itemCoords) do
                C_Container.UseContainerItem(value.bag, value.slot)
            end
            ConfirmationFrame:Hide()
            SIMS.MainFrameComponent.Show()
        end
    end)
    ConfirmationFrame.MailButton:SetEnabled(MailFrame:IsVisible())

    ConfirmationFrame.BankButton:SetScript("OnClick", function()
        for key, value in ipairs(itemCoords) do
            C_Container.UseContainerItem(value.bag, value.slot)
        end
        ConfirmationFrame:Hide()
        SIMS.MainFrameComponent.Show()
    end)
    ConfirmationFrame.BankButton:SetEnabled(BankFrame:IsShown())

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
        ConfirmationFrame.MessageFrame.scrollBar:Hide()
    else
        ConfirmationFrame.MessageFrame.scrollBar:Show()
    end

    ConfirmationFrame.MessageFrame.scrollBar:SetMinMaxValues(0, visualMax)
    -- ConfirmationFrame.MessageFrame.scrollBar:SetValue(0)
    ConfirmationFrame.MessageFrame:SetScript("OnMouseWheel",
                                             function(self, delta)
        if ((delta < 0 and self:GetScrollOffset() < length - bottomPadding) or
            delta > 0) then
            self:ScrollByAmount(-delta * 3)
            -- ConfirmationFrame.MessageFrame.scrollBar:SetValue( self:GetScrollOffset())
        end
    end)

    ConfirmationFrame.TotalFrame:Clear()
    ConfirmationFrame.TotalFrame:AddMessage("Total Sell Price")
    ConfirmationFrame.TotalFrame:AddMessage(GetCoinTextureString(totalSellPrice))

    ConfirmationFrame:Show()
end
