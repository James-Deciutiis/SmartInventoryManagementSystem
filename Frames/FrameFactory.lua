local addonName, SIMS = ...
local FrameFactory = {}
SIMS.FrameFactory = FrameFactory

function FrameFactory.CreateStandardCheckButton(name, parent, boxes, text,
                                                position, x, y)
    local CheckButton = CreateFrame("CheckButton", name, parent,
                                    "ChatConfigCheckButtonTemplate")
    CheckButton:SetPoint(position, x, y)
    getglobal(CheckButton:GetName() .. "Text"):SetText(text)
    CheckButton:SetScript("OnClick", function()
        SIMS.mappings.flags[text] = not SIMS.mappings.flags[text]
        for _, box in ipairs(boxes) do
            if (SIMS.mappings.flags[text]) then
                box:Show()
            else
                box:Hide()
            end
        end
    end)
    return CheckButton
end

function FrameFactory.CreateStandardEditBox(name, parent, position, x, y,
                                            length, width)
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

function FrameFactory.CreateStandardFrame(name, text)
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

function FrameFactory.CreateStandardButton(parent, text, position, x, y, length,
                                           height, name)
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

function FrameFactory.CreateStandardDropDown(parent, position, x, y, width,
                                             text, menuItems, target)
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
                                                     SIMS.mappings
                                                         .dropDownValues[target]
            UIDropDownMenu_AddButton(info, level)
        end
    end)

    function dropDown:SetValue(newValue)
        SIMS.mappings.dropDownValues[target] = newValue
        UIDropDownMenu_SetText(dropDown, newValue)
        CloseDropDownMenus()
    end

    return dropDown
end
