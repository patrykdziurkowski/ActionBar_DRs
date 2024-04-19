--[[
    DEPENDENCIES
]]--
local DrList = LibStub:GetLibrary("DRList-1.0")
DrTracker = DrTracker
FrameManager = FrameManager
UserSettings = UserSettings




--[[
    MAIN ADDON LOGIC
]]--
AddOn = {}
do
    -- public fields
    AddOn.buttons = {}

    -- private fields
    local _AddOn = {}
    setmetatable(_AddOn, AddOn)
    AddOn.__index = AddOn

    -- public methods
    function AddOn:HookButtons() end
    function AddOn:CcCasted(targetGUID, spellId, category) end
    function AddOn:CcRemoved(targetGUID, category) end
    function AddOn:UpdateFrames() end

    -- private methods
    function _AddOn:HookBartender4Buttons() end
    function _AddOn:HookElvUIButtons() end
    function _AddOn:HookDefaultButtons() end
    function _AddOn:DisplayDrIndicators(targetGUID) end
    function _AddOn:HideDrIndicators() end

    ----------------------------------------------
    -- IMPLEMENTATIONS
    ----------------------------------------------
    local function HookButtons(self)
        if IsAddOnLoaded("Bartender4") then
            _AddOn:HookBartender4Buttons()
        elseif IsAddOnLoaded("ElvUI") then
            _AddOn:HookElvUIButtons()
        else
            _AddOn:HookDefaultButtons()
        end
    end
    AddOn.HookButtons = HookButtons

    local function CcCasted(self, targetGUID, spellId, category)
        local spellName = GetSpellInfo(spellId)
        local unit = UnitTokenFromGUID(targetGUID)
        
        -- nil unit means we couldn't find unit anywhere in nameplates, party, pets, target, raid, etc., see below:
        -- https://wowpedia.fandom.com/wiki/API_UnitTokenFromGUID
        if unit == nil then
            -- default estimated cc duration if we fail figuring it out exactly
            local level = DrTracker:GetDrInfo(targetGUID, spellId)
            local diminishFactor = DrList:GetNextDR(level, category)
            local ccDuration = 6 * diminishFactor
            DrTracker:AddDr(targetGUID, category, ccDuration)
            self:UpdateFrames()
            return
        end

        -- quest boss mobs (i.e. the ones with an exclamation mark on their nameplate, not just any mob needed for a quest) tend to receive all DR categories
        -- players and their pets receive all DR categories
        -- other pve mobs either immune the CCs or they receive DRs only from a subset of categories
        local hasDiminishingReturns = UnitIsPlayer(unit) or UnitIsOtherPlayersPet(unit) or UnitIsQuestBoss(unit) or DrList:IsPvECategory(category)
        if not hasDiminishingReturns then return end

        -- small delay because apparently this code runs before the debuff is available via AuraUtils
        RunNextFrame(function()
            local _, _, _, _, duration = AuraUtil.FindAuraByName(spellName, unit, "HARMFUL")
            -- nil duration means someone's immuning the CC so dont extend it
            if duration == nil then return end
            DrTracker:AddDr(targetGUID, category, duration)
            self:UpdateFrames()
        end)
    end
    AddOn.CcCasted = CcCasted

    local function CcRemoved(self, targetGUID, category)
        DrTracker:ShortenDr(targetGUID, category)
        self:UpdateFrames()
    end
    AddOn.CcRemoved = CcRemoved

    local function UpdateFrames(self)
        local targetGUID = UnitGUID("target")

        if targetGUID == nil then _AddOn:HideDrIndicators() return end
        _AddOn:DisplayDrIndicators(targetGUID)
    end
    AddOn.UpdateFrames = UpdateFrames

    -- private
    local function DisplayDrIndicators(self, targetGUID)
        for _, button in pairs(self.buttons) do
            local actionId = button:GetActionId()
            if actionId ~= nil then
                local type, spellId, subtype = GetActionInfo(actionId)
                if type == "spell" or type == "macro" and subtype == "spell" then
                    local level, appliedTime, remainingTime = DrTracker:GetDrInfo(targetGUID, spellId)
                    if level == 0 then
                        FrameManager:HideBorder(button)
                    else
                        FrameManager:ShowBorder(button, level, appliedTime, GetTime() + remainingTime, UserSettings.size, UserSettings.color, UserSettings.alpha, UserSettings.texture.path)
                    end
                end
            end
        end
    end
    _AddOn.DisplayDrIndicators = DisplayDrIndicators

    local function HideDrIndicators(self)
        for _, button in pairs(self.buttons) do
            FrameManager:HideBorder(button)
        end
    end
    _AddOn.HideDrIndicators = HideDrIndicators

    local function HookBartender4Buttons(self)
        for i = 1, 360 do 
            local button = _G["BT4Button"..i]
            if button ~= nil then
                button.GetActionId = function(btn)
                    if btn._state_action == nil then return -1 end
                    return btn._state_action
                end
                table.insert(self.buttons, button)
            end
        end
    end
    _AddOn.HookBartender4Buttons = HookBartender4Buttons

    local function HookElvUIButtons(self)
        for i = 1, 15 do
            for j = 1, 12 do
                local button = _G["ElvUI_Bar" .. i .. "Button" .. j]
                if button ~= nil then
                    button.GetActionId = function(btn)
                        if btn._state_action == nil then return -1 end
                        return btn._state_action
                    end
                    table.insert(self.buttons, button)
                end
            end
        end
    end
    _AddOn.HookElvUIButtons = HookElvUIButtons

    local function HookDefaultButtons(self)
        for i = 1, 12 do
            if _G["ActionButton"..i] ~= nil then
                table.insert(self.buttons, _G["ActionButton"..i])
            end
        end

        -- keys are the <X> in various frames named MultiBar<X>
        local keys = {5, 6, 7, "BottomLeft", "BottomRight", "Left", "Right"}
        for _, key in pairs(keys) do
            local barName = "MultiBar".. key
            local bar = _G[barName]
            if bar ~= nil then
                for i = 1, 12 do
                    local button = _G[barName .. "Button" .. i]
                    if button ~= nil then
                        table.insert(self.buttons, button)
                    end
                end
            end
        end

        for _, button in pairs(self.buttons) do
            button.GetActionId = function(btn)
                if btn:GetPagedID() == nil then return -1 end
                return btn:GetPagedID()
            end
        end
    end
    _AddOn.HookDefaultButtons = HookDefaultButtons
end



