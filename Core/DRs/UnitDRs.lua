--[[
    DEPENDENCIES
]]--
local addonName, addon = ...

local DrList = addon.DrListWrapper

--[[ 
    UNIT DRS
]]--
local UnitDRs = {}
addon.UnitDRs = UnitDRs
do
    -- public methods
    function UnitDRs:New() end
    function UnitDRs:Refresh(category, ccDuration, drDuration) end
    function UnitDRs:Update(category) end
    function UnitDRs:Shorten(category, drDuration)  end

    ----------------------------------------------
    -- IMPLEMENTATIONS
    ----------------------------------------------
    local function New(self)
        local unitDRs = {}
        setmetatable(unitDRs, self)
        self.__index = self

        local categories = DrList:GetCategories()
        for category, _ in pairs(categories) do
            unitDRs[category] = {
                level = 0,
                appliedTime = 0,
                ccDuration = 0,
                drDuration = 0,
                expirationTime = 0
            }
        end

        return unitDRs
    end
    UnitDRs.New = New

    local function Refresh(self, category, ccDuration, drDuration)
        self:Update(category)

        local appliedTime = GetTime()
        local expirationTime = appliedTime + ccDuration + drDuration

        self[category].appliedTime = appliedTime
        self[category].ccDuration = ccDuration
        self[category].drDuration = drDuration
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
    UnitDRs.Refresh = Refresh

    local function Update(self, category)
        local remainingDrTime = self[category].expirationTime - GetTime()
        if remainingDrTime < 0 then
            self[category].level = 0
            self[category].appliedTime = 0
            self[category].ccDuration = 0
            self[category].drDuration = 0
            self[category].expirationTime = 0
        end
    end
    UnitDRs.Update = Update

    local function Shorten(self, category, drDuration)
        self:Update(category)

        local appliedTime = GetTime()

        self[category].appliedTime = appliedTime
        self[category].ccDuration = 0
        self[category].drDuration = drDuration
        self[category].expirationTime = appliedTime + drDuration
    end
    UnitDRs.Shorten = Shorten
end