--[[
    DEPENDENCIES
]]--
local addonName, addon = ...

local DrList = addon.DrListWrapper
local DrTracker = addon.DrTracker
local FrameManager = addon.FrameManager
local ButtonManager = addon.ButtonManager
ABDRs_UserSettings = ABDRs_UserSettings




--[[
    MAIN ADDON LOGIC
]]--
local AddOn = {}
addon.AddOn = AddOn
do
    -- public methods
    function AddOn:Initialize() end
    function AddOn:CcCasted(targetGUID, spellId, category) end
    function AddOn:CcRemoved(targetGUID, category) end
    function AddOn:UpdateFrames() end

    -- private methods
    function AddOn:_DisplayDrIndicators(targetGUID) end
    function AddOn:_HideDrIndicators() end

    ----------------------------------------------
    -- IMPLEMENTATIONS
    ----------------------------------------------
    local function Initialize(self)
        ButtonManager:HookButtons()
        ButtonManager:ForEachButton(function(button)
            button.ActionBar_DRs = FrameManager:New(button, ABDRs_UserSettings.size, ABDRs_UserSettings.color, ABDRs_UserSettings.alpha, ABDRs_UserSettings.texture.path)
        end)
    end
    AddOn.Initialize = Initialize

    local function CcCasted(self, targetGUID, spellId, category)
        local spellName = GetSpellInfo(spellId)
        local unit = UnitTokenFromGUID(targetGUID)
        
        -- nil unit means we couldn't find unit anywhere in nameplates, party, pets, target, raid, etc., see below:
        -- https://wowpedia.fandom.com/wiki/API_UnitTokenFromGUID
        if unit == nil then
            -- default estimated cc duration if we fail figuring it out exactly
            local level = DrTracker:GetDrInfo(targetGUID, spellId)
            local diminishFactor = DrList:GetNextDR(level, category)
            local ccDuration = 6 * diminishFactor
            DrTracker:AddDr(targetGUID, category, ccDuration)
            self:UpdateFrames()
            return
        end

        -- quest boss mobs (i.e. the ones with an exclamation mark on their nameplate, not just any mob needed for a quest) tend to receive all DR categories
        -- players and their pets receive all DR categories
        -- other pve mobs either immune the CCs or they receive DRs only from a subset of categories
        local hasDiminishingReturns = UnitIsPlayer(unit) or UnitIsOtherPlayersPet(unit) or UnitIsQuestBoss(unit) or DrList:IsPvECategory(category)
        if not hasDiminishingReturns then return end

        -- small delay because apparently this code runs before the debuff is available via AuraUtils
        RunNextFrame(function()
            local _, _, _, _, duration = AuraUtil.FindAuraByName(spellName, unit, "HARMFUL")
            -- nil duration means someone's immuning the CC so dont extend it
            if duration == nil then return end
            DrTracker:AddDr(targetGUID, category, duration)
            self:UpdateFrames()
        end)
    end
    AddOn.CcCasted = CcCasted

    local function CcRemoved(self, targetGUID, category)
        DrTracker:ShortenDr(targetGUID, category)
        self:UpdateFrames()
    end
    AddOn.CcRemoved = CcRemoved

    local function UpdateFrames(self)
        local targetGUID = UnitGUID("target")

        if targetGUID == nil then AddOn:_HideDrIndicators() return end
        AddOn:_DisplayDrIndicators(targetGUID)
    end
    AddOn.UpdateFrames = UpdateFrames

    -- private
    local function _DisplayDrIndicators(self, targetGUID)
        ButtonManager:ForEachButton(function(button)
            local actionId = button:GetActionId()
            if actionId ~= nil then
                local type, spellId, subtype = GetActionInfo(actionId)
                if type == "spell" or type == "macro" and subtype == "spell" then
                    local level, appliedTime, remainingTime = DrTracker:GetDrInfo(targetGUID, spellId)
                    if level == 0 then
                        button.ActionBar_DRs:HideBorder()
                    else
                        button.ActionBar_DRs:ShowBorder(level, appliedTime, GetTime() + remainingTime)
                    end
                end
            end
        end)
    end
    AddOn._DisplayDrIndicators = _DisplayDrIndicators

    local function _HideDrIndicators(self)
        ButtonManager:ForEachButton(function(button)
            button.ActionBar_DRs:HideBorder()
        end)
    end
    AddOn._HideDrIndicators = _HideDrIndicators
end



