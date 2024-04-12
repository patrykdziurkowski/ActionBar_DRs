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
    RING
]]--
local Ring = {}
function Ring:New(button, inset)
    inset = inset or 0

    local ring = {}
    setmetatable(ring, self)
    self.__index = self

    ring.edge = Edge:New(button, inset)
    ring.cooldown = Cooldown:New(button, inset)
    ring.edgeAnimations = ring.edge:CreateAnimationGroup()
    ring.cooldownAnimations = ring.cooldown:CreateAnimationGroup()

    local fadeEdge = ring.edgeAnimations:CreateAnimation("Alpha")
    fadeEdge:SetFromAlpha(100)
    fadeEdge:SetToAlpha(0)
    fadeEdge:SetDuration(0.5)

    local fadeCooldown = ring.cooldownAnimations:CreateAnimation("Alpha")
    fadeCooldown:SetFromAlpha(100)
    fadeCooldown:SetToAlpha(0)
    fadeCooldown:SetDuration(0.5)

    return ring
end

function Ring:Show(appliedTime, expirationTime)
    self.edge:Show()
    self.cooldown:SetCooldown(appliedTime, expirationTime - appliedTime)
end

function Ring:Hide()
    self.edge:Hide()
    self.cooldown:Hide()
end

--[[
    BORDER
]]--

local Border = {}
function Border:Create(button)
    local rings = {}
    --reverse rendering order to make sure they're z-ordered properly
    for i = 2, 0, -1 do
        local ring = Ring:New(button, 6 * i)
        rings[i] = ring
    end
    button.dr = rings
end

function Border:Show(button, level, appliedTime, expirationTime)
    for i = 0, 2 do
        local ring = button.dr[i]
        if i < level then
            ring:Show(appliedTime, expirationTime)
        else
            ring:Hide()
        end
    end
end

function Border:Hide(button)
    for i = 0, 2 do
        button.dr[i]:Hide()
    end
end

function Border:PauseExistingAnimations(button)
    if button.dr[0].edgeAnimations:IsPlaying() then
        for i = 0, 2 do
            button.dr[i].edgeAnimations:Stop()
            button.dr[i].cooldownAnimations:Stop()
        end
    end
end

function Border:StartExpirationTimer(button, expirationTime)
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

--[[
    FRAME MANAGER
]]--
FrameManager = {}
function FrameManager:ShowBorders(button, level, appliedTime, expirationTime)
    if button.dr == nil then Border:Create(button) end
    Border:PauseExistingAnimations(button)
    Border:Show(button, level, appliedTime, expirationTime)
    Border:StartExpirationTimer(button, expirationTime)
end

function FrameManager:HideBorders(button)
    if button.dr == nil then return end
    Border:Hide(button)
end