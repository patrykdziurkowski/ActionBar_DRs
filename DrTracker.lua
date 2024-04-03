local DrList = LibStub:GetLibrary("DRList-1.0")

DrTracker = {}
DrTracker.unitDRs = {}

function DrTracker:AddDr(unitGUID, category, ccDuration)
    if self.unitDRs[unitGUID] == nil then
        local categories = DrList:GetCategories()
        local template =  {}
        for category, _ in pairs(categories) do
            template[category] = { level = 0, expirationTime = 0}
        end

        self.unitDRs[unitGUID] = template
    end

    local DRs = self.unitDRs[unitGUID]
    local drDuration = DrList:GetResetTime(category)
    local expirationTime = time() + drDuration + ccDuration
    
    DRs[category].expirationTime = expirationTime
    DRs[category].level = DRs[category].level + 1
    if DRs[category].level > 2 then DRs[category].level = 2 end
end

function DrTracker:GetDrInfo(unitGUID, spellId)
    local DRs = self.unitDRs[unitGUID]
    -- No dr entry means we don't know anything about target's dr, thus assume none
    if DRs == nil then return 0, nil end

    local category = DrList:GetCategoryBySpellID(spellId)

    local level = DRs[category].level
    local remainingDrTime = DRs[category].expirationTime - time()
    if remainingDrTime < 0 then
        remainingDrTime = 0
        level = 0
        DRs[category].level = 0
        DRs[category].expirationTime = 0
    end
    return level, remainingDrTime
end