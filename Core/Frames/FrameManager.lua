--[[
    DEPENDENCIES
]]--
Border = Border

--[[
    FRAME MANAGER
]]--
FrameManager = {}
do
    -- public methods
    function FrameManager:ShowBorder(button, level, appliedTime, expirationTime, size, color, alpha, texturePath) end
    function FrameManager:HideBorder(button) end
    function FrameManager:ChangeSize(button, size) end
    function FrameManager:ChangeBorderColor(button, color) end
    function FrameManager:ChangeCooldownAlpha(button, alpha) end
    function FrameManager:ChangeBorderTexture(button, texturePath) end

    ----------------------------------------------
    -- IMPLEMENTATIONS
    ----------------------------------------------
    local function ShowBorder(self, button, level, appliedTime, expirationTime, size, color, alpha, texturePath)
        if button.ActionBar_DRs == nil then button.ActionBar_DRs = Border:New(button, size, color, alpha, texturePath) end
        local border = button.ActionBar_DRs
        border:PauseExistingAnimations()
        border:Show(level, appliedTime, expirationTime)
        border:StartExpirationTimer(expirationTime)
    end
    FrameManager.ShowBorder = ShowBorder

    local function HideBorder(self, button)
        if button.ActionBar_DRs == nil then return end

        local border = button.ActionBar_DRs
        border:Hide()
    end
    FrameManager.HideBorder = HideBorder

    local function ChangeSize(self, button, size)
        if button.ActionBar_DRs == nil then return end
        local border = button.ActionBar_DRs
        border:ChangeSize(size)
    end
    FrameManager.ChangeSize = ChangeSize

    local function ChangeBorderColor(self, button, color)
        if button.ActionBar_DRs == nil then return end
        local border = button.ActionBar_DRs
        border:ChangeColor(color)
    end
    FrameManager.ChangeBorderColor = ChangeBorderColor

    local function ChangeCooldownAlpha(self, button, alpha)
        if button.ActionBar_DRs == nil then return end
        local border = button.ActionBar_DRs
        border:ChangeAlpha(alpha)
    end
    FrameManager.ChangeCooldownAlpha = ChangeCooldownAlpha

    local function ChangeBorderTexture(self, button, texturePath)
        if button.ActionBar_DRs == nil then return end
        local border = button.ActionBar_DRs
        border:ChangeTexture(texturePath)
    end
    FrameManager.ChangeBorderTexture = ChangeBorderTexture
end