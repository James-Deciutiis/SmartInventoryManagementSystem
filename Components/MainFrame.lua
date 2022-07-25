local addonName, SIMS = ...
local MainFrameComponent = {}
SIMS.MainFrameComponent = MainFrameComponent

function MainFrameComponent.Create()
    if (MainFrame) then return end

    local f = SIMS.FrameFactory
                  .CreateStandardFrame("MainFrame", "S.I.M.S", "sm")

    local labelXOffset = -70
    local functionLabel = MainFrame:CreateFontString(MainFrame, _,
                                                     "GameFontNormal")
    functionLabel:SetPoint("TOP", labelXOffset, -50)
    functionLabel:SetText("Select Function")

    local functionsDropDown = SIMS.FrameFactory.CreateStandardDropDown(
                                  MainFrame, "CENTER", 0, 0, 150,
                                  "Select Function", nil, "Saved Functions", nil)
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
    local deleteFunctionButton = SIMS.FrameFactory.CreateStandardButton(
                                     MainFrame, "X", "CENTER", 100, 3, "xsm")

    -- TODO add functionality to edit SavedFunction 
    local function updateMainFrame()
        if (not SIMS.Main.isFrameVisible(ConfirmationFrame) and
            not SIMS.Main.isFrameVisible(CreateFunctionFrame) and IsToggled) then

            local functionNames = {}
            local savedFunctionsLength = 0
            for key, val in pairs(SavedFunctions) do
                table.insert(functionNames, key)
                savedFunctionsLength = savedFunctionsLength + 1
            end
            functionsDropDown:updateMenu(functionNames)
            deleteFunctionButton:SetEnabled(savedFunctionsLength >= 1)

            MainFrame:Show()
        end
    end

    MainFrame:SetScript("OnShow", function() updateMainFrame() end)
    queryButton:SetScript("OnClick", function(self)
        SIMS.ConfirmationFrameComponent.Show()
        f:Hide()
    end)
    deleteFunctionButton:SetScript("OnClick", function()
        local currentFunctionName =
            SIMS.mappings.dropDownValues["Saved Functions"]
        SavedFunctions[currentFunctionName] = nil
        UIDropDownMenu_SetText(functionsDropDown, "Select Function")
        updateMainFrame()
    end)

    createNewFunctionButton:SetScript("OnClick", function(self)
        for key, val in pairs(SIMS.mappings.dropDownValues) do
            SIMS.mappings.dropDownValues[key] = nil
        end
        for key, val in pairs(SIMS.mappings.editBoxValues) do
            SIMS.mappings.editBoxValues[key] = nil
        end
        for key, val in pairs(SIMS.mappings.flags) do
            SIMS.mappings.flags[key] = false
            print(key)
        end
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
        if (event.find(event, "SHOW") or event.find(event, "OPENED")) then
            updateMainFrame()
        else
            MainFrame:Hide()
        end
    end)

    MainFrame:Hide()
end

function MainFrameComponent.Show()
    if not MainFrame then MainFrameComponent.Create() end
    if (IsToggled) then MainFrame:Show() end
end
