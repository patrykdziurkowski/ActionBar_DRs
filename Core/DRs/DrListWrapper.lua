--[[
    DEPENDENCIES
]]--
local addonName, addon = ...
local DrList = LibStub:GetLibrary("DRList-1.0")

--[[ 
    The purpose of this wrapper is to add extra functionality to DrList such as some spell ids that are potentially not included
]]--
local DrListWrapper = {}
addon.DrListWrapper = DrListWrapper
do
    -- public methods
    function DrListWrapper:GetCategories() end
    function DrListWrapper:GetCategoryBySpellId(spellId) end
    function DrListWrapper:GetResetTime(category) end
    function DrListWrapper:IsPvECategory(category) end
    function DrListWrapper:GetNextDR(diminished, category) end

    local extraTrackedCcSpells = {
        [305483] = "stun", -- Lightning Lasso
        [51485] = "root", -- Earthgrab Totem
    }

    ----------------------------------------------
    -- IMPLEMENTATIONS
    ----------------------------------------------
    local function GetCategories(self)
        return DrList:GetCategories()
    end
    DrListWrapper.GetCategories = GetCategories

    local function GetCategoryBySpellId(self, spellId)
        return extraTrackedCcSpells[spellId] or DrList:GetCategoryBySpellID(spellId)
    end
    DrListWrapper.GetCategoryBySpellId = GetCategoryBySpellId

    local function GetResetTime(self, category)
        category = category or "default"
        return DrList:GetResetTime(category)
    end
    DrListWrapper.GetResetTime = GetResetTime

    local function IsPvECategory(self, category)
        return DrList:IsPvECategory(category)
    end
    DrListWrapper.IsPvECategory = IsPvECategory

    local function GetNextDR(self, diminished, category)
        category = category or "default"
        return DrList:GetNextDR(diminished, category)
    end
    DrListWrapper.GetNextDR = GetNextDR
end