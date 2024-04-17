--[[
    DEPDENDENCIES
]]--
Ring = Ring

--[[
    BORDER
]]--
Border = {}
function Border:New(button, borderSize, color, alpha, texturePath)
    local border = {}
    border.rings = {}

    setmetatable(border, self)
    self.__index = self

    --reverse rendering order to make sure they're z-ordered properly
    for i = 2, 0, -1 do
        local size = Border:CalculateSize(borderSize, i)
        border.rings[i] = Ring:New(button, size, i, color, alpha, texturePath)
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

function Border:ChangeTexture(texturePath)
    self:ForEachRing(function(ring)
        ring.edge:SetTexture(texturePath)
        ring.cooldown:SetSwipeTexture(texturePath)
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