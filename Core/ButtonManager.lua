--[[
    DEPENDENCIES
]]--
local addonName, addon = ...

local DrList = addon.DrListWrapper

--[[
    BUTTON MANAGER
]]--
local ButtonManager = {}
addon.ButtonManager = ButtonManager
do
    ButtonManager.buttons = {}
    

    -- public methods
    function ButtonManager:ForEachButton(func) end
    function ButtonManager:HookButtons() end

    -- private methods
    function ButtonManager:_HookBartender4Buttons() end
    function ButtonManager:_HookElvUIButtons() end
    function ButtonManager:_HookDefaultButtons() end
    function ButtonManager:_GetButtonDrCategory(button) end

    ----------------------------------------------
    -- IMPLEMENTATIONS
    ----------------------------------------------
    local function ForEachButton(self, func)
        for categoryName, buttons in pairs(self.buttons) do
            for key, button in pairs(buttons) do
                func(button)
            end
        end
    end
    ButtonManager.ForEachButton = ForEachButton

    local function HookButtons(self)
        for category, _ in pairs(DrList:GetCategories()) do
            ButtonManager.buttons[category] = {}
        end

        if C_AddOns.IsAddOnLoaded("Bartender4") then
            self:_HookBartender4Buttons()
        elseif C_AddOns.IsAddOnLoaded("ElvUI") then
            self:_HookElvUIButtons()
        else
            self:_HookDefaultButtons()
        end
    end
    ButtonManager.HookButtons = HookButtons


    local function _HookBartender4Buttons(self)
        for i = 1, 360 do 
            local button = _G["BT4Button"..i]
            if button ~= nil then
                button.GetActionId = function(btn)
                    if btn._state_action == nil then return -1 end
                    return btn._state_action
                end

                local category = self:_GetButtonDrCategory(button)
                if category ~= nil then
                    table.insert(self.buttons[category], button)
                end
            end
        end
    end
    ButtonManager._HookBartender4Buttons = _HookBartender4Buttons

    local function _HookElvUIButtons(self)
        for i = 1, 15 do
            for j = 1, 12 do
                local button = _G["ElvUI_Bar" .. i .. "Button" .. j]
                if button ~= nil then
                    button.GetActionId = function(btn)
                        if btn._state_action == nil then return -1 end
                        return btn._state_action
                    end
                    
                    local category = self:_GetButtonDrCategory(button)
                    if category ~= nil then
                        table.insert(self.buttons[category], button)
                    end
                end
            end
        end
    end
    ButtonManager._HookElvUIButtons = _HookElvUIButtons

    local function _HookDefaultButtons(self)
        for i = 1, 12 do
            local button = _G["ActionButton"..i]
            if button ~= nil then
                button.GetActionId = function(btn)
                    if btn:GetPagedID() == nil then return -1 end
                    return btn:GetPagedID()
                end

                local category = self:_GetButtonDrCategory(button)
                if category ~= nil then
                    table.insert(self.buttons[category], button)
                end
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
                        button.GetActionId = function(btn)
                            if btn:GetPagedID() == nil then return -1 end
                            return btn:GetPagedID()
                        end

                        local category = self:_GetButtonDrCategory(button)
                        if category ~= nil then
                            table.insert(self.buttons[category], button)
                        end
                    end
                end
            end
        end
    end
    ButtonManager._HookDefaultButtons = _HookDefaultButtons

    local function _GetButtonDrCategory(self, button)
        local type, id = GetActionInfo(button:GetActionId())
        if type == "spell" then
            return DrList:GetCategoryBySpellId(id)
        end
        return nil
    end
    ButtonManager._GetButtonDrCategory = _GetButtonDrCategory
end