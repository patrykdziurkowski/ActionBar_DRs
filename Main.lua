local DrList = LibStub:GetLibrary("DRList-1.0")
local DrTracker = DrTracker
local FrameManager = FrameManager


local buttons = {}
C_Timer.After(2, function()
    for i = 1, 360 do
        if _G["BT4Button"..i] ~= nil then
            buttons[i] = _G["BT4Button"..i]
        end
    end
end)


local f2 = CreateFrame("Frame")
f2:RegisterEvent("PLAYER_TARGET_CHANGED")
f2:SetScript("OnEvent", function(self, event)
    local targetGUID = UnitGUID("target")

    if targetGUID == nil then
        for i, button in pairs(buttons) do
            FrameManager:HideBorder(button)
        end
        return
    end
    
    for i, button in pairs(buttons) do
        local type, spellId = GetActionInfo(button.id)
        if type == "spell" then
            local level, appliedTime, remainingDrTime = DrTracker:GetDrInfo(targetGUID, spellId)
            if level == 0 then 
                FrameManager:HideBorder(button)
            else
                FrameManager:ShowBorder(button, level, appliedTime, GetTime() + remainingDrTime)
            end
        end
    end
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

    if string.sub(targetGUID, 1, 6) ~= "Player" and not DrList:IsPvECategory(category) then return end

    local spellName = GetSpellInfo(spellId)
    local unit = UnitTokenFromGUID(targetGUID)
    
    if unit ~= nil then
        -- small delay because apparently this code runs before the debuff is available via AuraUtils
        C_Timer.After(0.01, function()
            local _, _, _, _, duration = AuraUtil.FindAuraByName(spellName, unit, "HARMFUL")
            DrTracker:AddDr(targetGUID, category, duration)
            f2:GetScript("OnEvent")(f2, "PLAYER_TARGET_CHANGED");
        end)
    else
        -- default cc duration if we fail figuring it out exactly
        local ccDuration = 6
        DrTracker:AddDr(targetGUID, category, ccDuration)
        f2:GetScript("OnEvent")(f2, "PLAYER_TARGET_CHANGED");
    end
end)