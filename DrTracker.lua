local DrList = LibStub:GetLibrary("DRList-1.0")

DrTracker = {}
DrTracker.unitDRs = {}

function DrTracker:AddDr(unitGUID, category, ccDuration)
    if self.unitDRs[unitGUID] == nil then
        local categories = DrList:GetCategories()
        local template =  {}
        for category, _ in pairs(categories) do
            template[category] = { level = 0, expirationTime = nil}
        end

        self.unitDRs[unitGUID] = template
    end
    local DRs = self.unitDRs[unitGUID]
    local drDuration = DrList:GetResetTime(category)

    local currentDrLevel = DRs[category].level
    if currentDrLevel + 1 >= 2 then currentDrLevel = 1 end
    local expirationTime = time() + drDuration + ccDuration

    DRs[category].level = currentDrLevel + 1
    DRs[category].expirationTime = expirationTime
end

function DrTracker:GetDrInfo(unitGUID, spellId)
    local DRs = self.unitDRs[unitGUID]
    local category = DrList:GetCategoryBySpellID(spellId)

    local level = DRs[category].level
    local remainingDrTime = DRs[category].expirationTime - time()
    return level, remainingDrTime
end