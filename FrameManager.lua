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
function Ring:New(button, inset, level)
    inset = inset or 0

    local ring = {}
    setmetatable(ring, self)
    self.__index = self

    ring.edge = Edge:New(button, inset)
    ring.cooldown = Cooldown:New(button, inset)
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

function Ring:ChangeInset(button, inset)
    self.edge:SetPoint("TOPLEFT", button, "TOPLEFT", -3 + inset, 3 - inset)
    self.edge:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", 4 - inset, -3 + inset)

    self.cooldown:SetPoint("TOPLEFT", button, "TOPLEFT", -3 + inset, 3 - inset)
    self.cooldown:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", 4 - inset, -3 + inset)
end



--[[
    BORDER
]]--
local Border = {}
function Border:New(button, insetFactor)
    local border = {}
    border.rings = {}

    setmetatable(border, self)
    self.__index = self

    --reverse rendering order to make sure they're z-ordered properly
    for i = 2, 0, -1 do
        border.rings[i] = Ring:New(button, insetFactor + (6 * i) + (insetFactor / 3), i)
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

function Border:ChangeInset(button, insetFactor)
    for i = 2, 0, -1 do
        local inset = insetFactor + (6 * i) + (insetFactor / 3)
        self.rings[i]:ChangeInset(button, inset + (6 * i) + (inset / 3))
    end
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
function FrameManager:ShowBorder(button, level, appliedTime, expirationTime, inset)
    if button.dr == nil then button.dr = Border:New(button, inset) end
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

function FrameManager:ChangeInset(button, insetFactor)
    if button.dr == nil then return end
    local border = button.dr
    border:ChangeInset(button, insetFactor)
end