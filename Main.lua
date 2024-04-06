local DrList = LibStub:GetLibrary("DRList-1.0")
local DrTracker = DrTracker
local FrameManager = FrameManager

local f2 = CreateFrame("Frame")
f2:RegisterEvent("PLAYER_TARGET_CHANGED")
f2:SetScript("OnEvent", function(self, event)
    local spellId = 64044
    local targetGUID = UnitGUID("target")
    if targetGUID == nil then
        FrameManager:HideBorder(_G["BT4Button99"])
        return
    end
    
    local level, appliedTime, remainingDrTime = DrTracker:GetDrInfo(targetGUID, spellId)
    if level == 0 then 
        FrameManager:HideBorder(_G["BT4Button99"])
        return 
    end
    FrameManager:CreateBorder(_G["BT4Button99"], level, appliedTime, time() + remainingDrTime)
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

    --check if target not immune, npc, etc.
    --different dr durations for knockback etc.
    local ccDuration = 4
    DrTracker:AddDr(targetGUID, category, ccDuration)
    f2:GetScript("OnEvent")(f2, "PLAYER_TARGET_CHANGED");
end)