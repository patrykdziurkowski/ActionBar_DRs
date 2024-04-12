local DrList = LibStub:GetLibrary("DRList-1.0")
local DrTracker = DrTracker
local FrameManager = FrameManager
local AddOn = {}

AddOn.buttons = {}
C_Timer.After(2, function()
    for i = 1, 360 do
        if _G["BT4Button"..i] ~= nil then
            table.insert(AddOn.buttons, _G["BT4Button"..i])
        end
    end
end)




local f2 = CreateFrame("Frame")
f2:RegisterEvent("PLAYER_TARGET_CHANGED")
f2:SetScript("OnEvent", function(self, event)
    AddOn:UpdateFrames()
end)


local f = CreateFrame("Frame")
f:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
f:SetScript("OnEvent", function(self, event)
    if event ~= "COMBAT_LOG_EVENT_UNFILTERED" then return end
    local _, subevent, _, casterGUID, _, _, _, targetGUID, _, _, _, spellId = CombatLogGetCurrentEventInfo()
    if subevent ~= "SPELL_CAST_SUCCESS" then return end

    -- if category is nil then it's not a CC so we skip
    local category = DrList:GetCategoryBySpellID(spellId) 
    if category == nil then return end

    local spellName = GetSpellInfo(spellId)
    local unit = UnitTokenFromGUID(targetGUID)

    -- quest boss mobs (i.e. the ones with an exclamation mark on their nameplate, not just any mob needed for a quest) tend to receive full DRs
    -- players and their pets receive full DRs
    -- other pve mobs either immune the CCs or they receive DRs only from a subset of their categories
    local hasDiminishingReturns = UnitIsPlayer(unit) or UnitIsOtherPlayersPet(unit) or UnitIsQuestBoss(unit) or DrList:IsPvECategory(category)
    if not hasDiminishingReturns then return end
    
    -- couldn't find unit anywhere in nameplates, party, pets, target, raid, etc.
    -- https://wowpedia.fandom.com/wiki/API_UnitTokenFromGUID
    if unit == nil then
        -- default estimated cc duration if we fail figuring it out exactly
        local level = DrTracker:GetDrInfo(targetGUID, spellId)
        local diminishFactor = DrList:GetNextDR(level, category)
        local ccDuration = 6 * diminishFactor
        DrTracker:AddDr(targetGUID, category, ccDuration)
        AddOn:UpdateFrames()
        return
    end

    -- small delay because apparently this code runs before the debuff is available via AuraUtils
    RunNextFrame(function()
        local _, _, _, _, duration = AuraUtil.FindAuraByName(spellName, unit, "HARMFUL")
        -- nil duration means someone's immuning the CC so dont extend it
        if duration == nil then return end
        DrTracker:AddDr(targetGUID, category, duration)
        AddOn:UpdateFrames()
    end)
end)

function AddOn:UpdateFrames()
    local targetGUID = UnitGUID("target")

    if targetGUID == nil then self:HideDrIndicators() return end
    
    self:DisplayDrIndicators(targetGUID)
end

function AddOn:DisplayDrIndicators(targetGUID)
    for _, button in pairs(AddOn.buttons) do
        local type, spellId = GetActionInfo(button.id)
        if type == "spell" then
            local level, appliedTime, remainingDrTime = DrTracker:GetDrInfo(targetGUID, spellId)
            if level == 0 then 
                FrameManager:HideBorders(button)
            else
                FrameManager:ShowBorders(button, level, appliedTime, GetTime() + remainingDrTime)
            end
        end
    end
end

function AddOn:HideDrIndicators()
    for _, button in pairs(AddOn.buttons) do
        FrameManager:HideBorders(button)
    end
end