--[[
    DEPENDENCIES
]]--
local DrList = LibStub:GetLibrary("DRList-1.0")
AddOn = AddOn
OptionsPanel = OptionsPanel
SlashCmdList = SlashCmdList
InterfaceOptionsFrame_OpenToCategory = InterfaceOptionsFrame_OpenToCategory
UserSettings = UserSettings




--[[
    EVENTS
]]--
local f4 = CreateFrame("Frame")
f4:RegisterEvent("PLAYER_ENTERING_WORLD")
f4:SetScript("OnEvent", function(self, event)
    AddOn:HookButtons()
end)

local f3 = CreateFrame("Frame")
f3:RegisterEvent("ADDON_LOADED")
f3:SetScript("OnEvent", function(self, event, addOnName)
    if addOnName ~= "ActionBar_DRs" then return end
    if UserSettings == nil then
        UserSettings = {
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
    if event ~= "COMBAT_LOG_EVENT_UNFILTERED" then return end
    local _, subevent, _, casterGUID, _, _, _, targetGUID, _, _, _, spellId = CombatLogGetCurrentEventInfo()
    if subevent ~= "SPELL_CAST_SUCCESS" then return end

    -- if category is nil then it's not a CC so we skip
    local category = DrList:GetCategoryBySpellID(spellId)
    if category == nil then return end

    AddOn:CcCasted(targetGUID, spellId, category)
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