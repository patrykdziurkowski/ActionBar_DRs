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
end