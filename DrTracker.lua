local DrList = LibStub:GetLibrary("DRList-1.0")

--[[ 
    UNIT DRS
]]--
local UnitDRs = {}

function UnitDRs:New(o)
    o = o or {}
    setmetatable(o, self)
    self.__index = self

    local categories = DrList:GetCategories()
    for category, _ in pairs(categories) do
        o[category] = { level = 0, expirationTime = 0 }
    end

    return o
end

function UnitDRs:Refresh(category, expirationTime)
    self:Update(category)

    self[category].expirationTime = expirationTime
    if self[category].level < 2 then
        self[category].level = self[category].level + 1
    end
end

function UnitDRs:Update(category)
    local remainingDrTime = self[category].expirationTime - time()
    if remainingDrTime < 0 then
        self[category].level = 0
        self[category].expirationTime = 0
    end
end


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
    local expirationTime = time() + drDuration + ccDuration
    
    drs:Refresh(category, expirationTime)
end

function DrTracker:GetDrInfo(unitGUID, spellId)
    -- No dr entry means we don't know anything about target's dr, thus assume none
    if self.unitDRs[unitGUID] == nil then return 0, 0 end

    local drs = self.unitDRs[unitGUID]
    local category = DrList:GetCategoryBySpellID(spellId)

    drs:Update(category)

    local level = drs[category].level
    local remainingDrTime = drs[category].expirationTime - time()
    if remainingDrTime < 0 then remainingDrTime = 0 end
    return level, remainingDrTime
end