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
        button.drBorderTexture:SetAtlas("greatVault-frame-whole")
        button.drBorderTexture:SetVertexColor(0.7, 0.7, 0.7, 1)
    end
    button.drBorderTexture:Show()

    --TODO prevent timer overlap
    local expiresIn = expirationTime - time()
    C_Timer.After(expiresIn, function()
        self:HideBorder(button)
    end)
end

function FrameManager:HideBorder(button)
    if button.drBorderTexture == nil then return end
    button.drBorderTexture:Hide()
end