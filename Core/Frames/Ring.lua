local Edge = {}
function Edge:New(button, size, color, texturePath)
    local edge = button:CreateTexture()
    edge:SetSize(size, size)
    edge:SetDesaturation(1)
    edge:SetDrawLayer("OVERLAY")
    edge:SetPoint("CENTER", button)
    edge:SetTexture(texturePath)
    edge:SetVertexColor(color.r, color.g, color.b, 1)
    edge:Hide()

    return edge
end

local Cooldown = {}
function Cooldown:New(button, edge, alpha, texturePath)
    local cooldown = CreateFrame("Cooldown", nil, button, "CooldownFrameTemplate")
    cooldown:SetSwipeTexture(texturePath)
    cooldown:SetAllPoints(edge)
    cooldown:SetDrawEdge(false)
    cooldown:SetReverse(true)
    cooldown:SetAlpha(alpha)
    cooldown:SetPoint("CENTER", button)
    cooldown:Hide()

    return cooldown
end



--[[
    RING
]]--
Ring = {}
function Ring:New(button, size, level, color, alpha, texturePath)
    local ring = {}
    setmetatable(ring, self)
    self.__index = self

    ring.edge = Edge:New(button, size, color, texturePath)
    ring.cooldown = Cooldown:New(button, ring.edge, alpha, texturePath)
    ring.edgeAnimations = ring.edge:CreateAnimationGroup()
    ring.cooldownAnimations = ring.cooldown:CreateAnimationGroup()
    ring.level = level

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

function Ring:ChangeSize(size)
    self.edge:SetSize(size, size)
    self.cooldown:SetAllPoints(self.edge)
end