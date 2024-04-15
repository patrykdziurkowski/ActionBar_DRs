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
AddOn.buttons = {}
function AddOn:HookButtons()
    if IsAddOnLoaded("Bartender4") then
        self:HookBartender4Buttons()
    elseif IsAddOnLoaded("ElvUI") then
        self:HookElvUIButtons()
    else
        self:HookDefaultButtons()
    end
end

function AddOn:HookBartender4Buttons()
    for i = 1, 360 do 
        local button = _G["BT4Button"..i]
        if button ~= nil and button.id ~= nil then
            button.GetActionId = function(btn) return btn.id end
            table.insert(AddOn.buttons, button)
        end
    end
end

function AddOn:HookElvUIButtons()
    for i = 1, 15 do
        for j = 1, 12 do
            local button = _G["ElvUI_Bar" .. i .. "Button" .. j]
            if button ~= nil and button._state_action ~= nil then
                button.GetActionId = function(btn) return btn._state_action end
                table.insert(AddOn.buttons, button)
            end
        end
    end
end

function AddOn:HookDefaultButtons()
    for i = 1, 12 do
        if _G["ActionButton"..i] ~= nil then
            table.insert(AddOn.buttons, _G["ActionButton"..i])
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
                    table.insert(AddOn.buttons, button)
                end
            end
        end
    end

    for _, button in pairs(AddOn.buttons) do
        button.GetActionId = function(btn) return btn:GetPagedID() end
    end
end

function AddOn:CcCasted(targetGUID, spellId, category)
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
        AddOn:UpdateFrames()
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
        AddOn:UpdateFrames()
    end)
end

function AddOn:UpdateFrames()
    local targetGUID = UnitGUID("target")

    if targetGUID == nil then self:HideDrIndicators() return end
    self:DisplayDrIndicators(targetGUID)
end

function AddOn:DisplayDrIndicators(targetGUID)
    for _, button in pairs(AddOn.buttons) do
        local actionId = button:GetActionId()
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

function AddOn:HideDrIndicators()
    for _, button in pairs(AddOn.buttons) do
        FrameManager:HideBorder(button)
    end
end






