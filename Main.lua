local DrList = LibStub:GetLibrary("DRList-1.0")
-- Module that tracks Diminishing Returns
local DrTracker = DrTracker
-- Module that creates the DR frames around buttons
local FrameManager = FrameManager
local isTestModeEnabled = false


local AddOn = {}
AddOn.buttons = {}
C_Timer.After(2, function()
    for i = 1, 360 do
        if _G["BT4Button"..i] ~= nil then
            table.insert(AddOn.buttons, _G["BT4Button"..i])
        end
    end
end)


--[[
    EVENTS
]]--
local f3 = CreateFrame("Frame")
f3:RegisterEvent("ADDON_LOADED")
f3:SetScript("OnEvent", function(self, event, addOnName)
    if addOnName ~= "ActionBar_DRs" then return end

    if UserSettings == nil then
        UserSettings = {
            inset = 6
        }
    end
    AddOn:LoadOptionsPanel()
end)

local f2 = CreateFrame("Frame")
f2:RegisterEvent("PLAYER_TARGET_CHANGED")
f2:SetScript("OnEvent", function(self, event)
    AddOn:UpdateFrames()
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

    AddOn:CcCasted(targetGUID, spellId, category)
end)





--[[
    ADDON FUNCTIONS
]]--
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
        local type, spellId = GetActionInfo(button.id)
        if type == "spell" then
            local level, appliedTime, remainingTime = DrTracker:GetDrInfo(targetGUID, spellId)
            if level == 0 then
                FrameManager:HideBorder(button)
            else
                FrameManager:ShowBorder(button, level, appliedTime, GetTime() + remainingTime, UserSettings.inset)
            end
        end
    end
end

function AddOn:HideDrIndicators()
    for _, button in pairs(AddOn.buttons) do
        FrameManager:HideBorder(button)
    end
end




--[[
    SETTINGS FRAME
]]--
function AddOn:LoadOptionsPanel()
    local panel = CreateFrame("Frame")
    panel.name = "ActionBar_DRs"
    InterfaceOptions_AddCategory(panel)

    local title = panel:CreateFontString("ARTWORK", nil, "GameFontNormalLarge")
    title:SetPoint("TOP", 0, -25)
    title:SetText("ActionBar_DRs")

    local insetSliderName = "ActionBar_DRs_InsetSlider"
    local insetSlider = CreateFrame("Slider", insetSliderName, panel, "OptionsSliderTemplate")
    insetSlider:SetMinMaxValues(-15, 15)
    insetSlider:SetValue(UserSettings.inset)
    insetSlider:SetValueStep(1)
    insetSlider:SetObeyStepOnDrag(true)
    insetSlider.text = _G[insetSliderName.."Text"]
    insetSlider.textLow = _G[insetSliderName.."Low"]
    insetSlider.textHigh = _G[insetSliderName.."High"]
    insetSlider.text:SetText("Button Border Inset: " .. insetSlider:GetValue())
    insetSlider:SetScript("OnValueChanged", function(self, value)
        self.text:SetText("Button Border Inset: " .. value)
        UserSettings.inset = value
        for _, button in pairs(AddOn.buttons) do
            FrameManager:ChangeInset(button, value)
        end
    end)
    local min, max = insetSlider:GetMinMaxValues()
    insetSlider.textLow:SetText(min)
    insetSlider.textHigh:SetText(max)
    insetSlider:SetPoint("TOP", 0, -75)

    local testToggleName = "ActionBar_DRs_TestToggle"
    local testToggle = CreateFrame("Button", testToggleName, panel, "UIPanelButtonTemplate")
    testToggle:SetText("Toggle Test Borders")
    testToggle:SetSize(150, 40)
    testToggle:SetPoint("TOP", 0, -125)
    testToggle:SetScript("OnClick", function()
        isTestModeEnabled = not isTestModeEnabled

        if isTestModeEnabled then
            for _, button in pairs(AddOn.buttons) do
                FrameManager:ShowBorder(button, math.random(4) - 1, GetTime() - math.random(10) - 1, GetTime() + 25, UserSettings.inset)
            end
        else
            for _, button in pairs(AddOn.buttons) do
                FrameManager:HideBorder(button)
            end
        end
    end)
end

SLASH_ABDRS1 = "/abdrs"
SLASH_ABDRS2 = "/actionbardrs"
SLASH_ABDRS3 = "/actionbar_drs"
function SlashCmdList.ABDRS(msg, editbox)
    InterfaceOptionsFrame_OpenToCategory("ActionBar_DRs")
end