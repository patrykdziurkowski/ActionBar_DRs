--[[
    FRAME MANAGER
]]--
FrameManager = {}
function FrameManager:CreateBorder(button, level, appliedTime, expirationTime)
    button.tex = button:CreateTexture()
    button.tex:SetDesaturation(1)
    button.tex:SetDrawLayer("ARTWORK")
    button.tex:SetPoint("TOPLEFT", button, "TOPLEFT", -3, 3)
    button.tex:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", 4, -3)
    button.tex:SetAtlas("greatVault-frame-whole")
    button.tex:SetVertexColor(0.7, 0.7, 0.7, 1)

    --TODO prevent timer overlap
    local expiresIn = expirationTime - time()
    C_Timer.After(expiresIn, function()
        button.tex:Hide()
    end)
end

function FrameManager:HideBorder(button)
    if button.tex == nil then return end
    button.tex:Hide()
end