local addonName, SIMS = ...
local FrameFactory = {}
SIMS.FrameFactory = FrameFactory

function FrameFactory.CreateStandardCheckButton(name, parent, boxes, text,
                                                position, x, y, hookScript)
    local CheckButton = CreateFrame("CheckButton", name, parent,
                                    "ChatConfigCheckButtonTemplate")
    CheckButton:SetPoint(position, x, y)
    getglobal(CheckButton:GetName() .. "Text"):SetText(text)

    local checkButtonCallback = function()
        SIMS.mappings.flags[text] = not SIMS.mappings.flags[text]
        for _, box in ipairs(boxes) do
            if (SIMS.mappings.flags[text]) then
                box:Show()
            else
                box:Hide()
            end
        end
    end

    CheckButton:SetScript("OnClick", function()
        checkButtonCallback()
        if (hookScript) then hookScript() end
    end)

    return CheckButton
end

function FrameFactory.CreateStandardEditBox(name, parent, position, x, y,
                                            length, width, hookScript)
    local editBox = CreateFrame("EditBox", nil, parent,
                                BackdropTemplateMixin and "BackdropTemplate")

    editBox:SetPoint(position, x, y)
    editBox:SetFontObject("ChatFontNormal")
    editBox:SetMultiLine(false)
    editBox:SetSize(length, width)
    editBox:SetAutoFocus(false)
    editBox:SetBackdrop(BACKDROP_DIALOG_32_32);
    editBox:SetTextInsets(15, 12, 12, 11)
    local editBoxCallback = function() editBox:ClearFocus() end
    editBox:SetScript("OnChar", function(self, text)
        SIMS.mappings.editBoxValues[name] = editBox:GetText()
        if (hookScript) then hookScript() end
    end)
    editBox:SetScript("OnEscapePressed", function()
        editBoxCallback()
        if (hookScript) then hookScript() end
    end)
    editBox:SetScript("OnEnterPressed", function()
        editBoxCallback()
        if (hookScript) then hookScript() end
    end)

    return editBox
end

function FrameFactory.CreateStandardFrame(name, text, size)
    local f =
        CreateFrame("Frame", name, UIParent, "BasicFrameTemplateWithInset")
    f:SetPoint("CENTER")

    local sizes = {
        ["sm"] = function() f:SetSize(300, 200) end,
        ["md"] = function() f:SetSize(400, 500) end,
        ["lg"] = function() f:SetSize(800, 500) end
    }

    if (sizes[size]) then
        sizes[size]()
    else
        sizes["md"]()
    end

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

function FrameFactory.CreateStandardButton(parent, text, position, x, y, size)
    local button = CreateFrame("Button", nil, parent, "GameMenuButtonTemplate")
    local sizes = {
        ["xsm"] = function() button:SetSize(25, 25) end,
        ["sm"] = function() button:SetSize(75, 25) end,
        ["md"] = function() button:SetSize(100, 25) end,
        ["lg"] = function() button:SetSize(125, 25) end
    }

    if (sizes[size]) then sizes[size]() end

    button:SetPoint(position, x, y)
    button:SetText(text)

    return button
end

function FrameFactory.CreateStandardDropDown(parent, position, x, y, width,
                                             text, menuItems, target, hookScript)
    local dropDown = CreateFrame("FRAME", nil, parent, "UIDropDownMenuTemplate")
    dropDown:SetPoint(position, x, y)
    UIDropDownMenu_SetWidth(dropDown, width)
    UIDropDownMenu_SetText(dropDown, text)

    local function updateFunc(items)
        UIDropDownMenu_Initialize(dropDown, function(self, level, menuList)
            local info = UIDropDownMenu_CreateInfo()
            info.func = self.SetValue
            for key, value in ipairs(items) do

                info.text, info.arg1, info.checked = value, value, value ==
                                                         SIMS.mappings
                                                             .dropDownValues[target]
                UIDropDownMenu_AddButton(info, level)
            end
        end)
    end

    if (menuItems) then updateFunc(menuItems) end

    function dropDown:updateMenu(newMenu) updateFunc(newMenu) end

    function dropDown:SetValue(newValue)
        SIMS.mappings.dropDownValues[target] = newValue
        UIDropDownMenu_SetText(dropDown, newValue)
        CloseDropDownMenus()
        if (hookScript) then hookScript() end
    end

    return dropDown
end
