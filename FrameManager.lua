--[[
    FRAME MANAGER
]]--
FrameManager = {}
function FrameManager:CreateBorder(button, level, appliedTime, expirationTime)
    if button.drBorderTexture == nil then
        button.drBorderTexture = button:CreateTexture()
        button.drBorderTexture:SetDesaturation(1)
        button.drBorderTexture:SetDrawLayer("ARTWORK")
        button.drBorderTexture:SetPoint("TOPLEFT", button, "TOPLEFT", -3, 3)
        button.drBorderTexture:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", 4, -3)
        button.drBorderTexture:SetTexture("interface\\addons\\actionbar_drs\\textures\\lootgreatvault.png")
        button.drBorderTexture:SetVertexColor(0.7, 0.7, 0.7, 1)
    end
    button.drBorderTexture:Show()

    --Cooldown swipe widget
    local cooldown = CreateFrame("Cooldown", nil, button, "CooldownFrameTemplate")
    cooldown:SetSwipeTexture("interface\\addons\\actionbar_drs\\textures\\lootgreatvault.png")
    cooldown:SetDrawEdge(false)
    cooldown:SetReverse(true)
    cooldown:SetCooldown(appliedTime, expirationTime - appliedTime)
    cooldown:SetAllPoints()
    button.drBorderTexture.cooldown = cooldown

    local expiresIn = expirationTime - GetTime()
    if button.drTimer ~= nil then button.drTimer:Cancel() end
    button.drTimer = C_Timer.After(expiresIn, function()
        self:HideBorder(button)
    end)
end

function FrameManager:HideBorder(button)
    if button.drBorderTexture == nil then return end
    button.drBorderTexture:Hide()
end