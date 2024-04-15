--[[
    DEPENDENCIES
]]--
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
        o[category] = { level = 0, appliedTime = 0, expirationTime = 0 }
    end

    return o
end

function UnitDRs:Refresh(category, expirationTime)
    self:Update(category)

    self[category].appliedTime = GetTime()
    -- In rare (?) cases where you can overlap a long CC with a shorter one,
    -- keep the bigger expiration time. Example: Sap -> immediate Gouge
    if self[category].expirationTime < expirationTime then
        self[category].expirationTime = expirationTime
    end
    -- Max DRs out at level 3 (0 - no drs, 3 - immune)
    if self[category].level < 3 then
        self[category].level = self[category].level + 1
    end
end

function UnitDRs:Update(category)
    local remainingDrTime = self[category].expirationTime - GetTime()
    if remainingDrTime < 0 then
        self[category].level = 0
        self[category].expirationTime = 0
        self[category].appliedTime = 0
    end
end

function UnitDRs:Shorten(category, expirationTime)
    self:Update(category)

    self[category].appliedTime = GetTime()
    self[category].expirationTime = expirationTime
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
    local expirationTime = GetTime() + drDuration + ccDuration

    drs:Refresh(category, expirationTime)
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
    local drDuration = DrList:GetResetTime(category)
    local expirationTime = GetTime() + drDuration

    drs:Shorten(category, expirationTime)
end