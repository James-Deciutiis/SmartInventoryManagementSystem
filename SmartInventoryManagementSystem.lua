SLASH_SIMS1 = "/sims"

SLASH_SIMSTOGGLE1 = "/simstoggle"

local _, SIMS = ...
local Main = {}
local init = false

SIMS.Main = Main

--- split this function into filter, and sumTotalSellPrice
function filter(itemLink, filteredItems, itemCoords, currentBag, slot, flags,
                dropDownValues, editBoxValues)
    itemName, _, itemQuality, itemLevel, itemMinLevel, itemType, itemSubType, itemStackCount, itemEquipLoc, itemTexture, sellPrice, classID, subclassID, bindType, expacID, setID, isCraftingReagent =
        GetItemInfo(itemLink)

    containerItemInfo = C_Container.GetContainerItemInfo(currentBag, slot)
    -- icon, itemCount, locked, quality, readable, lootable, itemLink, isFiltered, noValue, itemID, isBound =
    local itemCount = containerItemInfo.stackCount
    local isBound = containerItemInfo.isBound
    local isHit = true

    -- Check if itemLink is in ReserveList
    for key, value in ipairs(ReserveList) do
        if value == itemLink then return 0 end
    end

    if (not #flags) then return 0 end
    if (flags["Item Name"] and isHit and itemName) then
        if (editBoxValues["Item Name"] and
            not string.find(itemName:lower(), editBoxValues["Item Name"]:lower())) then
            isHit = false
        end
    end
    if (flags["Item Level"] and isHit and editBoxValues["Item Level"] and
        string.len(editBoxValues["Item Level"]) > 0) then
        local ilvl = editBoxValues["Item Level"]
        local operators = {
            ["="] = function() return tonumber(ilvl) == itemLevel end,
            ["<"] = function()
                return itemLevel and itemLevel < tonumber(ilvl) or false
            end,
            [">"] = function()
                return itemLevel and itemLevel > tonumber(ilvl) or false
            end,
            ["<="] = function()
                return itemLevel and itemLevel <= tonumber(ilvl) or false
            end,
            [">="] = function()
                return itemLevel and itemLevel >= tonumber(ilvl) or false
            end,
            ["!="] = function() return tonumber(ilvl) ~= itemLevel end
        }

        if (operators[dropDownValues["Item Level"] or "="]() == false) then
            isHit = false
        end
    end
    if (flags["Equipment"] and isHit) then
        if (itemType ~= "Armor" and itemType ~= "Weapon") then
            isHit = false
        end
    end
    if (flags["Binding Type"] and isHit) then
        if (dropDownValues["Soulbound"] == "Not Bound" and isBound ~= false) then
            isHit = false
        elseif (dropDownValues["Soulbound"] == "Soulbound" and isBound ~= true) then
            isHit = false
        end
    end
    if (flags["Expansion"] and isHit) then
        if (SIMS.mappings.expansionValueMapping[dropDownValues["Expansion"]] ~=
            expacID) then isHit = false end
    end
    if (flags["Quality"] and isHit) then
        if (SIMS.mappings.qualityValueMapping[dropDownValues["Quality"]] ~=
            itemQuality) then isHit = false end
    end
    if (flags["Item Location"] and isHit) then
        if (dropDownValues["Item Location"] ~= _G[itemEquipLoc]) then
            isHit = false
        end
    end
    if (flags["Item Type"] and isHit) then
        if (dropDownValues["Item Type"] ~= itemType) then isHit = false end
    end
    if (isHit) then
        local coords = {}
        coords.bag = currentBag
        coords.slot = slot

        table.insert(itemCoords, coords)
        table.insert(filteredItems, itemLink)
        if (sellPrice and itemCount) then
            return sellPrice * itemCount
        else
            return 0
        end
    end

    return 0
end

function Main.parseBags(shouldFilter, flags, dropDownValues, editBoxValues)
    local filteredItems = {}
    local itemCoords = {}
    local totalSellPrice = 0
    for currentBag = BACKPACK_CONTAINER, NUM_BAG_SLOTS do
        for slot = 1, C_Container.GetContainerNumSlots(currentBag) do
            local itemLink = C_Container.GetContainerItemLink(currentBag, slot)
            if (itemLink) then
                if shouldFilter then
                    totalSellPrice = totalSellPrice +
                                         filter(itemLink, filteredItems,
                                                itemCoords, currentBag, slot,
                                                flags, dropDownValues,
                                                editBoxValues)
                else
                    table.insert(filteredItems, itemLink)
                end
            end

        end
    end

    local results = {}
    results.filteredItems = filteredItems
    results.itemCoords = itemCoords
    results.totalSellPrice = totalSellPrice

    return results
end

function Main.isFrameVisible(frame) return frame and frame:IsVisible() end

function Main.printStatus()
    print("SIMS is currently toggled: " ..
              (IsToggled and "|cff00FF00ON." or "|cffFF0000OFF."))
end

function Main.initialize()
    if (init) then return end

    if IsToggled == nil then IsToggled = false end
    if SavedFunctions == nil then SavedFunctions = {} end
    if ReserveList == nil then ReserveList = {} end

    init = true

    Main.printStatus()
    SIMS.MainFrameComponent.Create()
end

local function SimsHandler()
    Main.parseBags(false)
    SIMS.MainFrameComponent.Show()
end

local function ToggleHandler()
    IsToggled = not IsToggled
    Main.printStatus()
end

SlashCmdList["SIMS"] = SimsHandler
SlashCmdList["SIMSTOGGLE"] = ToggleHandler
