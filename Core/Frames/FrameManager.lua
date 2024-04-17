--[[
    DEPENDENCIES
]]--
Border = Border

--[[
    FRAME MANAGER
]]--
FrameManager = {}
function FrameManager:ShowBorder(button, level, appliedTime, expirationTime, size, color, alpha, texturePath)
    if button.dr == nil then button.dr = Border:New(button, size, color, alpha, texturePath) end
    local border = button.dr
    border:PauseExistingAnimations()
    border:Show(level, appliedTime, expirationTime)
    border:StartExpirationTimer(expirationTime)
end

function FrameManager:HideBorder(button)
    if button.dr == nil then return end

    local border = button.dr
    border:Hide()
end

function FrameManager:ChangeSize(button, size)
    if button.dr == nil then return end
    local border = button.dr
    border:ChangeSize(size)
end

function FrameManager:ChangeBorderColor(button, color)
    if button.dr == nil then return end
    local border = button.dr
    border:ChangeColor(color)
end

function FrameManager:ChangeCooldownAlpha(button, alpha)
    if button.dr == nil then return end
    local border = button.dr
    border:ChangeAlpha(alpha)
end

function FrameManager:ChangeBorderTexture(button, texturePath)
    if button.dr == nil then return end
    local border = button.dr
    border:ChangeTexture(texturePath)
end