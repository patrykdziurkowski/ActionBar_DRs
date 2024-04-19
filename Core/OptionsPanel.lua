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
OptionsPanel = {}
do
    -- private fields
    local _OptionsPanel = {}
    _OptionsPanel.isTestModeEnabled = false

    -- public methods
    function OptionsPanel:Create() end
    function OptionsPanel:CreateSizeSlider() end
    function OptionsPanel:CreateAlphaSlider() end
    function OptionsPanel:CreateTextureDropDown() end
    function OptionsPanel:CreateTestToggle() end
    function OptionsPanel:CreateColorChange() end

    ----------------------------------------------
    -- IMPLEMENTATIONS
    ----------------------------------------------
    local function Create(self)
        self.panel = CreateFrame("Frame")
        self.panel.name = "ActionBar_DRs"
        InterfaceOptions_AddCategory(self.panel)

        local title = self.panel:CreateFontString("ARTWORK", nil, "GameFontNormalLarge")
        title:SetPoint("TOP", 0, -25)
        title:SetText("ActionBar_DRs")

        self:CreateSizeSlider()
        self:CreateAlphaSlider()
        self:CreateTestToggle()
        self:CreateColorChange()
        self:CreateTextureDropDown()
    end
    OptionsPanel.Create = Create

    local function CreateSizeSlider(self)
        local sizeSliderName = "ActionBar_DRs_SizeSlider"
        local sizeSlider = CreateFrame("Slider", sizeSliderName, self.panel, "OptionsSliderTemplate")
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
    end
    OptionsPanel.CreateSizeSlider = CreateSizeSlider

    local function CreateAlphaSlider(self)
        local alphaSliderName = "ActionBar_DRs_AlphaSlider"
        local alphaSlider = CreateFrame("Slider", alphaSliderName, self.panel, "OptionsSliderTemplate")
        alphaSlider:SetMinMaxValues(0, 1)
        alphaSlider:SetValue(UserSettings.alpha)
        alphaSlider:SetValueStep(0.01)
        alphaSlider:SetObeyStepOnDrag(true)
        alphaSlider.text = _G[alphaSliderName.."Text"]
        alphaSlider.textLow = _G[alphaSliderName.."Low"]
        alphaSlider.textHigh = _G[alphaSliderName.."High"]
        alphaSlider.text:SetText("Cooldown Widget Alpha: " .. math.floor(alphaSlider:GetValue() * 100) / 100)
        alphaSlider:SetScript("OnValueChanged", function(self, value)
            value = math.floor(value * 100) / 100
            self.text:SetText("Cooldown Widget Alpha: " .. value)
            UserSettings.alpha = value
            for _, button in pairs(AddOn.buttons) do
                FrameManager:ChangeCooldownAlpha(button, value)
            end
        end)
        local min, max = alphaSlider:GetMinMaxValues()
        alphaSlider.textLow:SetText(min)
        alphaSlider.textHigh:SetText(max)
        alphaSlider:SetPoint("TOP", 0, -125)
    end
    OptionsPanel.CreateAlphaSlider = CreateAlphaSlider

    local function CreateTextureDropDown(self)
        local textureDropDownName = "ActionBar_DRs_TextureDropdown"
        local textureDropDown = CreateFrame("Frame", textureDropDownName, self.panel, "UIDropDownMenuTemplate")
        textureDropDown:SetPoint("TOP", 0, -175)
        UIDropDownMenu_SetText(textureDropDown, UserSettings.texture.name)
        UIDropDownMenu_SetWidth(textureDropDown, 150)

        UIDropDownMenu_Initialize(textureDropDown, function()
            local OptionClicked = function(self, optionText, texturePath, checked)
                UIDropDownMenu_SetText(textureDropDown, optionText)
                for _, button in pairs(AddOn.buttons) do
                    UserSettings.texture.name = optionText
                    UserSettings.texture.path = texturePath
                    FrameManager:ChangeBorderTexture(button, texturePath)
                end
            end

            UIDropDownMenu_AddButton({
                text = "Square",
                arg1 = "Square",
                arg2 = "interface\\addons\\actionbar_drs\\textures\\customsquare.png",
                checked = UserSettings.texture.name == "Square",
                func = OptionClicked
            })
            UIDropDownMenu_AddButton({
                text = "Octagon",
                arg1 = "Octagon",
                arg2 = "interface\\addons\\actionbar_drs\\textures\\lootgreatvault.png",
                checked = UserSettings.texture.name == "Octagon",
                func = OptionClicked
            })
        end)
    end
    OptionsPanel.CreateTextureDropDown = CreateTextureDropDown

    local function CreateTestToggle(self)
        local testToggleName = "ActionBar_DRs_TestToggle"
        local testToggle = CreateFrame("Button", testToggleName, self.panel, "UIPanelButtonTemplate")
        testToggle:SetText("Toggle Test Borders")
        testToggle:SetSize(150, 40)
        testToggle:SetPoint("TOP", 0, -225)
        testToggle:SetScript("OnClick", function()
            _OptionsPanel.isTestModeEnabled = not _OptionsPanel.isTestModeEnabled

            if _OptionsPanel.isTestModeEnabled then
                for _, button in pairs(AddOn.buttons) do
                    FrameManager:ShowBorder(button, math.random(4) - 1, GetTime() - math.random(10) - 1, GetTime() + 25 + math.random(5), UserSettings.size, UserSettings.color, UserSettings.alpha, UserSettings.texture.path)
                    C_Timer.After(30, function()
                        _OptionsPanel.isTestModeEnabled = false
                    end)
                end
            else
                for _, button in pairs(AddOn.buttons) do
                    FrameManager:HideBorder(button)
                end
            end
        end)
    end
    OptionsPanel.CreateTestToggle = CreateTestToggle

    local function CreateColorChange(self)
        local colorChangeName = "ActionBar_DRs_ColorChange"
        local colorChange = CreateFrame("Button", colorChangeName, self.panel, "UIPanelButtonTemplate")
        colorChange:SetText("Change Color")
        colorChange:SetSize(125, 40)
        colorChange:SetPoint("TOP", 0, -275)
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
    OptionsPanel.CreateColorChange = CreateColorChange
end