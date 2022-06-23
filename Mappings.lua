local addonName, SIMS = ...
SIMS.mappings = {}

local flags = {}
SIMS.mappings.flags = flags
flags["Item Level"] = false
flags["Equipment"] = false
flags["Item Name"] = false
flags["Binding Type"] = false
flags["Expansion"] = false
flags["Item Location"] = false
flags["Item Type"] = false

local dropDownValues = {}
SIMS.mappings.dropDownValues = dropDownValues
dropDownValues["Expansion"] = nil
dropDownValues["Item Location"] = nil
dropDownValues["Item Type"] = nil
dropDownValues["Item Level"] = nil
dropDownValues["Soulbound"] = nil

local expansionValueMapping = {}
SIMS.mappings.expansionValueMapping = expansionValueMapping
expansionValueMapping["Classic"] = 0
expansionValueMapping["Burning Crusade"] = 1
expansionValueMapping["Wrath of the Lich King"] = 2
expansionValueMapping["Cataclysm"] = 3
expansionValueMapping["Mists of Pandaria"] = 4
expansionValueMapping["Warlords of Draenor"] = 5
expansionValueMapping["Legion"] = 6
expansionValueMapping["Battle for Azeroth"] = 7
expansionValueMapping["Shadowlands"] = 8

local qualityValueMapping = {}
SIMS.mappings.qualityValueMapping = qualityValueMapping
qualityValueMapping["Poor"] = 0
qualityValueMapping["Common"] = 1
qualityValueMapping["Uncommon"] = 2
qualityValueMapping["Rare"] = 3
qualityValueMapping["Epic"] = 4
qualityValueMapping["Legendary"] = 5
qualityValueMapping["Artifact"] = 6
qualityValueMapping["Heirloom"] = 7
qualityValueMapping["WoW Token"] = 8

local editBoxValues = {}
SIMS.mappings.editBoxValues = editBoxValues
editBoxValues["Item Name"] = nil
editBoxValues["Item Level"] = nil
