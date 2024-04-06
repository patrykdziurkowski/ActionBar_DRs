local DrList = LibStub:GetLibrary("DRList-1.0")
local DrTracker = DrTracker

local f = CreateFrame("Frame")
f:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
f:SetScript("OnEvent", function(self, event)
    if event == "COMBAT_LOG_EVENT_UNFILTERED" then
        local _, subevent, _, casterGUID, _, _, _, targetGUID, _, _, _, spellId = CombatLogGetCurrentEventInfo()
        if subevent == "SPELL_CAST_SUCCESS" then
            local category = DrList:GetCategoryBySpellID(spellId)
            -- if category is nil then it's not a CC
            if category == nil then return end

            --check if target not immune, npc, etc.
            DrTracker:AddDr(targetGUID, category, 4)
            local level, remainingDrTime = DrTracker:GetDrInfo(targetGUID, spellId)
            FrameManager:CreateBorder(_G["BT4Button99"], level, time(), time() + remainingDrTime)
        end
    end
end)