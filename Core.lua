local addonName, SIMS = ...
_G[addonName] = SIMS

local core, events = CreateFrame('Frame', addonName .. 'CoreFrame'), {}

core:RegisterEvent('ADDON_LOADED')
function events:ADDON_LOADED(aName, ...) SIMS.Main.initialize() end

core:SetScript("OnEvent",
               function(self, event, ...) events[event](self, ...); end)

--- Message: bad argument #2 to '?' (Usage: local line = self:CreateFontString([name, drawLayer, templateName]))
--- Time: Mon Feb 27 13:07:42 2023
--- Count: 1
--- Stack: bad argument #2 to '?' (Usage: local line = self:CreateFontString([name, drawLayer, templateName]))
--- [string "=[C]"]: in function `CreateFontString'
--- [string "@Interface/AddOns/SmartInventoryManagementSystem/Components/MainFrame.lua"]:12: in function `Create'
--- [string "@Interface/AddOns/SmartInventoryManagementSystem/SmartInventoryManagementSystem.lua"]:134: in function `initialize'
--- [string "@Interface/AddOns/SmartInventoryManagementSystem/Core.lua"]:7: in function `?'
--- [string "@Interface/AddOns/SmartInventoryManagementSystem/Core.lua"]:10: in function <...rface/AddOns/SmartInventoryManagementSystem/Core.lua:10>
--- 
--- Locals: (*temporary) = "bad argument #2 to '?' (Usage: local line = self:CreateFontString([name, drawLayer, templateName]))"
--- 
