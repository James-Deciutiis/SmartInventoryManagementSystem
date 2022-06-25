local addonName, SIMS = ...
local MainFrameComponent = {}
SIMS.MainFrameComponent = MainFrameComponent

function MainFrameComponent.Create()
    if (MainFrame) then return end

    local f = SIMS.FrameFactory
                  .CreateStandardFrame("MainFrame", "S.I.M.S", "sm")

    local functionNames = {}
    for key, val in pairs(SavedFunctions) do table.insert(functionNames, key) end

    local labelXOffset = -70
    local functionLabel = f:CreateFontString(f, _, "GameFontNormal")
    functionLabel:SetPoint("TOP", labelXOffset, -50)
    functionLabel:SetText("Select Function")

    local functionsDropDown = SIMS.FrameFactory.CreateStandardDropDown(
                                  MainFrame, "CENTER", 0, 0, 150,
                                  "Select Function", functionNames,
                                  "Saved Functions", nil)
    local queryButton = SIMS.FrameFactory.CreateStandardButton(MainFrame,
                                                               "Query Bags",
                                                               "BOTTOM", 0, 15,
                                                               "md")
    local cancelButton = SIMS.FrameFactory.CreateStandardButton(MainFrame,
                                                                "Cancel",
                                                                "BOTTOM", -50,
                                                                50, "sm")
    local createNewFunctionButton = SIMS.FrameFactory.CreateStandardButton(
                                        MainFrame, "New", "BOTTOM", 50, 50, "sm")

    queryButton:SetScript("OnClick", function(self)
        SIMS.ConfirmationFrameComponent.Show()
        f:Hide()
    end)

    createNewFunctionButton:SetScript("OnClick", function(self)
        SIMS.CreateFunctionFrameComponent.Show()
        f:Hide()
    end)

    cancelButton:SetScript("OnClick", function(self) f:Hide() end)

    MainFrame:RegisterEvent("MERCHANT_SHOW")
    MainFrame:RegisterEvent("MERCHANT_CLOSED")
    MainFrame:RegisterEvent("MAIL_SHOW")
    MainFrame:RegisterEvent("MAIL_CLOSED")
    MainFrame:RegisterEvent("BANKFRAME_OPENED")
    MainFrame:RegisterEvent("BANKFRAME_CLOSED")
    MainFrame:SetScript("OnEvent", function(self, event)
        if (event.find(event, "SHOW") and not isFrameVisible(ConfirmationFrame) and
            not isFrameVisible(CreateFunctionFrame)) then
            MainFrameComponent.Show()
        else
            MainFrame:Hide()
        end
    end)

    MainFrame:Hide()
end

function MainFrameComponent.Show()
    if not MainFrame then MainFrameComponent.Create() end
    MainFrame:Show()
end
