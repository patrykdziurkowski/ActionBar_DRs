--[[
    DEPENDENCIES
]]--
FrameManager = FrameManager
AddOn = AddOn
ColorPickerFrame = ColorPickerFrame
InterfaceOptions_AddCategory = InterfaceOptions_AddCategory
UserSettings = UserSettings



--[[
    OPTIONS PANEL
]]--
local isTestModeEnabled = false
OptionsPanel = {}
function OptionsPanel:Create()
    local panel = CreateFrame("Frame")
    panel.name = "ActionBar_DRs"
    InterfaceOptions_AddCategory(panel)

    local title = panel:CreateFontString("ARTWORK", nil, "GameFontNormalLarge")
    title:SetPoint("TOP", 0, -25)
    title:SetText("ActionBar_DRs")

    local sizeSliderName = "ActionBar_DRs_SizeSlider"
    local sizeSlider = CreateFrame("Slider", sizeSliderName, panel, "OptionsSliderTemplate")
    sizeSlider:SetMinMaxValues(30, 250)
    sizeSlider:SetValue(UserSettings.size)
    sizeSlider:SetValueStep(1)
    sizeSlider:SetObeyStepOnDrag(true)
    sizeSlider.text = _G[sizeSliderName.."Text"]
    sizeSlider.textLow = _G[sizeSliderName.."Low"]
    sizeSlider.textHigh = _G[sizeSliderName.."High"]
    sizeSlider.text:SetText("Button Border Size: " .. sizeSlider:GetValue())
    sizeSlider:SetScript("OnValueChanged", function(self, value)
        self.text:SetText("Button Border Size: " .. value)
        UserSettings.size = value
        for _, button in pairs(AddOn.buttons) do
            FrameManager:ChangeSize(button, value)
        end
    end)
    local min, max = sizeSlider:GetMinMaxValues()
    sizeSlider.textLow:SetText(min)
    sizeSlider.textHigh:SetText(max)
    sizeSlider:SetPoint("TOP", 0, -75)

    local testToggleName = "ActionBar_DRs_TestToggle"
    local testToggle = CreateFrame("Button", testToggleName, panel, "UIPanelButtonTemplate")
    testToggle:SetText("Toggle Test Borders")
    testToggle:SetSize(150, 40)
    testToggle:SetPoint("TOP", 0, -125)
    testToggle:SetScript("OnClick", function()
        isTestModeEnabled = not isTestModeEnabled

        if isTestModeEnabled then
            for _, button in pairs(AddOn.buttons) do
                FrameManager:ShowBorder(button, math.random(4) - 1, GetTime() - math.random(10) - 1, GetTime() + 25 + math.random(5), UserSettings.size, UserSettings.color)
                C_Timer.After(30, function()
                    isTestModeEnabled = false
                end)
            end
        else
            for _, button in pairs(AddOn.buttons) do
                FrameManager:HideBorder(button)
            end
        end
    end)

    local colorChangeName = "ActionBar_DRs_ColorChange"
    local colorChange = CreateFrame("Button", colorChangeName, panel, "UIPanelButtonTemplate")
    colorChange:SetText("Change Color")
    colorChange:SetSize(100, 40)
    colorChange:SetPoint("TOP", 0, -175)
    colorChange:SetScript("OnClick", function()
        local color = UserSettings.color
        ColorPickerFrame:SetScript("OnShow", function()
            ColorPickerFrame.previousValues = { color.r, color.g, color.b }
        end)
        ColorPickerFrame:SetupColorPickerAndShow({
            r = color.r,
            g = color.g,
            b = color.b,
            opacity = nil,
            hasOpacity = false,
            swatchFunc = function()
                color.r, color.g, color.b = ColorPickerFrame:GetColorRGB()
                for _, button in pairs(AddOn.buttons) do
                    FrameManager:ChangeBorderColor(button, color)
                end
            end,
            cancelFunc = function(previousValues)
                color.r, color.g, color.b = unpack(previousValues)
                for _, button in pairs(AddOn.buttons) do
                    FrameManager:ChangeBorderColor(button, color)
                end
            end
        })
    end)
end