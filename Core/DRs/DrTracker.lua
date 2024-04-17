--[[
    DEPENDENCIES
]]--
local DrList = LibStub:GetLibrary("DRList-1.0")
UnitDRs = UnitDRs

--[[ 
    DR TRACKER
]]--
DrTracker = {}
DrTracker.unitDRs = {}
function DrTracker:AddDr(unitGUID, category, ccDuration)
    if self.unitDRs[unitGUID] == nil then
        self.unitDRs[unitGUID] = UnitDRs:New()
    end
    
    local drs = self.unitDRs[unitGUID]
    local drDuration = DrList:GetResetTime(category)

    drs:Refresh(category, ccDuration, drDuration)
end

function DrTracker:GetDrInfo(unitGUID, spellId)
    -- No dr entry means we don't know anything about target's dr, thus assume none
    if self.unitDRs[unitGUID] == nil then return 0, 0, 0 end

    local drs = self.unitDRs[unitGUID]
    local category = DrList:GetCategoryBySpellID(spellId)
    -- spell is not a cc
    if category == nil then return 0, 0, 0 end

    drs:Update(category)

    local level = drs[category].level
    local appliedTime = drs[category].appliedTime
    local remainingDrTime = drs[category].expirationTime - GetTime()
    if remainingDrTime < 0 then remainingDrTime = 0 end
    return level, appliedTime, remainingDrTime
end

function DrTracker:ShortenDr(unitGUID, category)
    if self.unitDRs[unitGUID] == nil then
        self.unitDRs[unitGUID] = UnitDRs:New()
    end

    local drs = self.unitDRs[unitGUID]
    drs:Update(category)
    local drDuration = DrList:GetResetTime(category)

    local isThereALongerCc = GetTime() + drs[category].ccDuration  + drDuration < drs[category].expirationTime
    if isThereALongerCc then return end
    drs:Shorten(category, drDuration)
end