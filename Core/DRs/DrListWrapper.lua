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
    function DrListWrapper:CheckIfSpellCc(spellId) end
    function DrListWrapper:GetCategories() end
    function DrListWrapper:GetCategoryBySpellId(spellId) end
    function DrListWrapper:GetResetTime(category) end
    function DrListWrapper:IsPvECategory(category) end
    function DrListWrapper:GetNextDR(diminished, category) end

    function DrListWrapper:_GetCategoryKeywords() end

    local extraTrackedCcSpells = {}

    ----------------------------------------------
    -- IMPLEMENTATIONS
    ----------------------------------------------
    local function CheckIfSpellCc(self, spellId)
        local category =  DrList:GetCategoryBySpellID(spellId)
        if category ~= nil then return end

        local spell = Spell:CreateFromSpellID(spellId)
        spell:ContinueOnSpellLoad(function()
            local description = spell:GetSpellDescription()

            for category, keyword in pairs(self:_GetCategoryKeywords()) do
                if string.find(description, keyword) then
                    extraTrackedCcSpells[spellId] = category
                end
            end
        end)
    end
    DrListWrapper.CheckIfSpellCc = CheckIfSpellCc
    
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

    local function _GetCategoryKeywords(self)
        local categoryKeywords = {}
        for categoryName, _ in pairs(self:GetCategories()) do
            categoryKeywords[categoryName] = categoryName
        end
        categoryKeywords["knockback"] = "knock"

        return categoryKeywords
    end
    DrListWrapper._GetCategoryKeywords = _GetCategoryKeywords
end