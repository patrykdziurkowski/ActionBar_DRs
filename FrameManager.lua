local Edge = {}
function Edge:New(button, inset)
    inset = inset or 0

    local edge = button:CreateTexture()
    edge:SetDesaturation(1)
    edge:SetDrawLayer("ARTWORK")
    edge:SetPoint("TOPLEFT", button, "TOPLEFT", -3 + inset, 3 - inset)
    edge:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", 4 - inset, -3 + inset)
    edge:SetTexture("interface\\addons\\actionbar_drs\\textures\\lootgreatvault.png")
    edge:SetVertexColor(0.7, 0.7, 0.7, 1)
    edge:Hide()

    return edge
end

local Cooldown = {}
function Cooldown:New(button, inset)
    inset = inset or 0

    local cooldown = CreateFrame("Cooldown", nil, button, "CooldownFrameTemplate")
    cooldown:SetSwipeTexture("interface\\addons\\actionbar_drs\\textures\\lootgreatvault.png")
    cooldown:SetDrawEdge(false)
    cooldown:SetReverse(true)
    cooldown:SetPoint("TOPLEFT", button, "TOPLEFT", -3 + inset, 3 - inset)
    cooldown:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", 4 - inset, -3 + inset)
    cooldown:Hide()

    return cooldown
end

--[[
    BORDER
]]--
local Border = {}
function Border:New(button, inset)
    inset = inset or 0

    local border = {}
    setmetatable(border, self)
    self.__index = self

    border.edge = Edge:New(button, inset)
    border.cooldown = Cooldown:New(button, inset)
    border.edgeAnimations = border.edge:CreateAnimationGroup()
    border.cooldownAnimations = border.cooldown:CreateAnimationGroup()

    local fadeEdge = border.edgeAnimations:CreateAnimation("Alpha")
    fadeEdge:SetFromAlpha(100)
    fadeEdge:SetToAlpha(0)
    fadeEdge:SetDuration(0.5)

    local fadeCooldown = border.cooldownAnimations:CreateAnimation("Alpha")
    fadeCooldown:SetFromAlpha(100)
    fadeCooldown:SetToAlpha(0)
    fadeCooldown:SetDuration(0.5)

    return border
end

function Border:Show(appliedTime, expirationTime)
    self.edge:Show()
    self.cooldown:SetCooldown(appliedTime, expirationTime - appliedTime)
end

function Border:Hide()
    self.edge:Hide()
    self.cooldown:Hide()
end


--[[
    FRAME MANAGER
]]--
FrameManager = {}

function FrameManager:ShowBorders(button, level, appliedTime, expirationTime)
    if button.dr == nil then
        local borders = {}
        --reverse rendering order to make sure they're z-ordered properly
        for i = 2, 0, -1 do
            local border = Border:New(button, 6 * i)
            borders[i] = border
        end
        button.dr = borders
    end

    if button.dr[0].edgeAnimations:IsPlaying() then
        for i = 0, 2 do
            button.dr[i].edgeAnimations:Stop()
            button.dr[i].cooldownAnimations:Stop()
        end
    end

    for i = 0, 2 do
        local border = button.dr[i]
        if i < level then
            border:Show(appliedTime, expirationTime)
        else
            border:Hide()
        end
    end

    local expiresIn = expirationTime - GetTime()
    -- Cancel any existing timers to avoid early showing of a border
    if button.dr.timer ~= nil then button.dr.timer:Cancel() end
    button.dr.timer = C_Timer.NewTicker(expiresIn, function()
        for i = 0, 2 do
            button.dr[i].edgeAnimations:Play()
            button.dr[i].cooldownAnimations:Play()
            button.dr[i].edgeAnimations:SetScript("OnFinished", function()
                button.dr[i]:Hide()
            end)
        end
    end, 1)
end

function FrameManager:HideBorders(button)
    if button.dr == nil then return end
    for i = 0, 2 do
        button.dr[i]:Hide()
    end
end