local _, SIMS = ...

function SIMS.FrameFactory.CreateScrollingMessageFrame(parent, xpos, ypos,
                                                       length, width)
    local MessageFrame = CreateFrame("ScrollingMessageFrame", nil, parent)
    MessageFrame:SetSize(length, width)
    MessageFrame:SetPoint("CENTER", xpos, ypos)
    MessageFrame:SetJustifyH("CENTER")
    MessageFrame:SetFading(false)
    MessageFrame:EnableMouseWheel(true)
    MessageFrame:SetHyperlinksEnabled(true)
    MessageFrame:SetInsertMode(SCROLLING_MESSAGE_FRAME_INSERT_MODE_TOP)
    MessageFrame:SetFontObject(GameFontNormal)
    MessageFrame:SetScript("OnHyperlinkClick", ChatFrame_OnHyperlinkShow)
    MessageFrame:HookScript('OnHyperlinkEnter', function(_, link)
        GameTooltip_SetDefaultAnchor(GameTooltip, UIParent)
        GameTooltip:SetHyperlink(link)
        GameTooltip:Show()
    end)
    MessageFrame:HookScript('OnHyperlinkLeave',
                            function() GameTooltip:Hide() end)
    local scrollBar = CreateFrame("Slider", nil, MessageFrame,
                                  "UIPanelScrollBarTemplate")
    scrollBar:SetPoint("RIGHT", MessageFrame, "RIGHT", math.floor(length / 2), 0)
    scrollBar:SetSize(length, width)
    MessageFrame.scrollBar = scrollBar

    return MessageFrame
end
