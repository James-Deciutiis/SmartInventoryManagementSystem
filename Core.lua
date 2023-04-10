local addonName, SIMS = ...
_G[addonName] = SIMS

local core, events = CreateFrame('Frame', addonName .. 'CoreFrame'), {}

core:RegisterEvent('ADDON_LOADED')
function events:ADDON_LOADED(aName, ...) SIMS.Main.initialize() end

core:SetScript("OnEvent",
               function(self, event, ...) events[event](self, ...); end)
