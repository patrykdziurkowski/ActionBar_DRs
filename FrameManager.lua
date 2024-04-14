local Edge = {}
function Edge:New(button, size, color)
    local edge = button:CreateTexture()
    edge:SetSize(size, size)
    edge:SetDesaturation(1)
    edge:SetDrawLayer("OVERLAY")
    edge:SetPoint("CENTER", button)
    edge:SetTexture("interface\\addons\\actionbar_drs\\textures\\lootgreatvault.png")
    edge:SetVertexColor(color.r, color.g, color.b, 1)
    edge:Hide()

    return edge
end

local Cooldown = {}
function Cooldown:New(button, edge, alpha)
    local cooldown = CreateFrame("Cooldown", nil, button, "CooldownFrameTemplate")
    cooldown:SetSwipeTexture("interface\\addons\\actionbar_drs\\textures\\lootgreatvault.png")
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
local Ring = {}
function Ring:New(button, size, level, color, alpha)
    local ring = {}
    setmetatable(ring, self)
    self.__index = self

    ring.edge = Edge:New(button, size, color)
    ring.cooldown = Cooldown:New(button, ring.edge, alpha)
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






--[[
    BORDER
]]--
local Border = {}
function Border:New(button, borderSize, color, alpha)
    local border = {}
    border.rings = {}

    setmetatable(border, self)
    self.__index = self

    --reverse rendering order to make sure they're z-ordered properly
    for i = 2, 0, -1 do
        local size = Border:CalculateSize(borderSize, i)
        border.rings[i] = Ring:New(button, size, i, color, alpha)
    end
    return border
end

function Border:Show(level, appliedTime, expirationTime)
    self:ForEachRing(function(ring)
        if ring.level < level then
            ring:Show(appliedTime, expirationTime)
        else
            ring:Hide()
        end
    end)
end

function Border:Hide()
    self:ForEachRing(function(ring)
        ring:Hide()
    end)
end

function Border:ChangeColor(color)
    self:ForEachRing(function(ring)
        ring.edge:SetVertexColor(color.r, color.g, color.b, 1)
    end)
end

function Border:ChangeAlpha(alpha)
    self:ForEachRing(function(ring)
        ring.cooldown:SetAlpha(alpha)
    end)
end

function Border:ChangeSize(borderSize)
    for i = 2, 0, -1 do
        local size = Border:CalculateSize(borderSize, i)
        self.rings[i]:ChangeSize(size)
    end
end

function Border:CalculateSize(size, ringLevel)
    return size - ringLevel * size / 5
end

function Border:PauseExistingAnimations()
    if self.rings[0].edgeAnimations:IsPlaying() then
        self:ForEachRing(function(ring)
            ring.edgeAnimations:Stop()
            ring.cooldownAnimations:Stop()
        end)
    end
end

function Border:StartExpirationTimer(expirationTime)
    local expiresIn = expirationTime - GetTime()
    -- Cancel any existing timers to avoid early showing of a border
    if self.timer ~= nil then self.timer:Cancel() end
    self.timer = C_Timer.NewTicker(expiresIn, function()
        self:ForEachRing(function(ring)
            ring.edgeAnimations:Play()
            ring.cooldownAnimations:Play()
            ring.edgeAnimations:SetScript("OnFinished", function()
                ring:Hide()
            end)
        end)
    end, 1)
end

function Border:ForEachRing(func)
    for i = 0, 2 do
        func(self.rings[i])
    end
end






--[[
    FRAME MANAGER
]]--
FrameManager = {}
function FrameManager:ShowBorder(button, level, appliedTime, expirationTime, size, color, alpha)
    if button.dr == nil then button.dr = Border:New(button, size, color, alpha) end
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