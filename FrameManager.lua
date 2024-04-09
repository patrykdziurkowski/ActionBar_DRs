--[[
    FRAME MANAGER
]]--
FrameManager = {}
function FrameManager:ShowBorder(button, level, appliedTime, expirationTime)
    if button.drBorder == nil then self:CreateBorder(button) end
    if button.drBorder.cooldown == nil then self:CreateCooldownSwipe(button) end

    button.drBorder:Show()
    button.drBorder.cooldown:SetCooldown(appliedTime, expirationTime - appliedTime)

    local expiresIn = expirationTime - GetTime()
    -- Cancel any existing timers to avoid early showing of a border
    if button.drBorder.timer ~= nil then button.drBorder.timer:Cancel() end
    button.drBorder.timer = C_Timer.NewTicker(expiresIn, function()
        self:HideBorder(button)
    end, 1)
end

function FrameManager:HideBorder(button)
    if button.drBorder == nil then return end
    button.drBorder:Hide()
    button.drBorder.cooldown:Hide()
end



function FrameManager:CreateBorder(button)
    local border = button:CreateTexture()
    border:SetDesaturation(1)
    border:SetDrawLayer("ARTWORK")
    border:SetPoint("TOPLEFT", button, "TOPLEFT", -3, 3)
    border:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", 4, -3)
    border:SetTexture("interface\\addons\\actionbar_drs\\textures\\lootgreatvault.png")
    border:SetVertexColor(0.7, 0.7, 0.7, 1)
    button.drBorder = border
end

function FrameManager:CreateCooldownSwipe(button)
    local cooldown = CreateFrame("Cooldown", nil, button, "CooldownFrameTemplate")
    cooldown:SetSwipeTexture("interface\\addons\\actionbar_drs\\textures\\lootgreatvault.png")
    cooldown:SetDrawEdge(false)
    cooldown:SetReverse(true)
    cooldown:SetAllPoints()
    button.drBorder.cooldown = cooldown
end