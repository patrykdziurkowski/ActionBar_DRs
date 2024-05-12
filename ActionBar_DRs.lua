--[[
    DEPENDENCIES
]]--
local addonName, addon = ...

local DrList = addon.DrListWrapper
local AddOn = addon.AddOn
local OptionsPanel = addon.OptionsPanel
local SlashCmdList = SlashCmdList
local InterfaceOptionsFrame_OpenToCategory = InterfaceOptionsFrame_OpenToCategory
ABDRs_UserSettings = ABDRs_UserSettings




--[[
    EVENTS
]]--
local f5 = CreateFrame("Frame")
f5:RegisterEvent("ACTIONBAR_SLOT_CHANGED")
f5:SetScript("OnEvent", function(self, event, slot)
    -- run next frame to prevent evaluating which button to draw border for based
    -- on the old buttons that are about to disappear (i.e. when changing stances)
    RunNextFrame(function()
        AddOn:UpdateFrames()
    end)
end)

local f4 = CreateFrame("Frame")
f4:RegisterEvent("PLAYER_ENTERING_WORLD")
f4:SetScript("OnEvent", function(self, event)
    AddOn:HookButtons()
    AddOn:ScanButtonsForCc()
end)

local f3 = CreateFrame("Frame")
f3:RegisterEvent("ADDON_LOADED")
f3:SetScript("OnEvent", function(self, event, addOnName)
    if addOnName ~= "ActionBar_DRs" then return end
    if ABDRs_UserSettings == nil then
        ABDRs_UserSettings = {
            size = 60,
            alpha = 1,
            color = {
                r = 0.85,
                g = 0.85,
                b = 0.85
            },
            texture = {
                name = "Square",
                path = "interface\\addons\\actionbar_drs\\textures\\customsquare.png"
            }
        }
    end
    OptionsPanel:Create()
end)

local f2 = CreateFrame("Frame")
f2:RegisterEvent("PLAYER_TARGET_CHANGED")
f2:SetScript("OnEvent", function(self, event)
    AddOn:UpdateFrames()
end)

local f = CreateFrame("Frame")
f:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
f:SetScript("OnEvent", function(self, event)
    local _, subevent, _, casterGUID, _, _, _, targetGUID, _, _, _, spellId, amount = CombatLogGetCurrentEventInfo()

    if subevent == "SPELL_AURA_APPLIED" then
        -- if category is nil then it's not a CC so we skip
        local category = DrList:GetCategoryBySpellId(spellId)
        if category == nil then return end

        AddOn:CcCasted(targetGUID, spellId, category)
    -- when cc gets removed (i.e. it expires, gets trinketed, it breaks, etc.)
    elseif subevent == "SPELL_AURA_REMOVED" then
        local category = DrList:GetCategoryBySpellId(spellId)
        if category == nil then return end

        AddOn:CcRemoved(targetGUID, category)
    end
end)




--[[
    SLASH COMMANDS
]]--
SLASH_ABDRS1 = "/abdrs"
SLASH_ABDRS2 = "/actionbardrs"
SLASH_ABDRS3 = "/actionbar_drs"
function SlashCmdList.ABDRS(msg, editbox)
    InterfaceOptionsFrame_OpenToCategory("ActionBar_DRs")
end