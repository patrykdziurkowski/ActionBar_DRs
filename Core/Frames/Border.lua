--[[
    DEPDENDENCIES
]]--
Ring = Ring

--[[
    BORDER
]]--
Border = {}
do
    -- public fields
    Border.rings = {}

    -- public methods
    function Border:New(button, borderSize, color, alpha, texturePath) end
    function Border:Show(level, appliedTime, expirationTime) end
    function Border:Hide() end
    function Border:ChangeTexture(texturePath) end
    function Border:ChangeColor(color) end
    function Border:ChangeAlpha(alpha) end
    function Border:ChangeSize(borderSize) end
    function Border:PauseExistingAnimations() end
    function Border:StartExpirationTimer(expirationTime) end
    function Border:ForEachRing(func) end

    -- private methods
    function Border:_CalculateSize(size, ringLevel) end

    ----------------------------------------------
    -- IMPLEMENTATIONS
    ----------------------------------------------
    local function New(self, button, borderSize, color, alpha, texturePath)
        local border = {}
        border.rings = {}

        setmetatable(border, self)
        self.__index = self

        --reverse rendering order to make sure they're z-ordered properly
        for i = 2, 0, -1 do
            local size = self:_CalculateSize(borderSize, i)
            local ring = Ring:New(button, size, i, color, alpha, texturePath)
            border.rings[i] = ring
        end

        return border
    end
    Border.New = New

    local function Show(self, level, appliedTime, expirationTime)
        self:ForEachRing(function(ring)
            if ring.level < level then
                ring:Show(appliedTime, expirationTime)
            else
                ring:Hide()
            end
        end)
    end
    Border.Show = Show

    local function Hide(self)
        self:ForEachRing(function(ring)       
            ring:Hide()
        end)
    end
    Border.Hide = Hide

    local function ChangeTexture(self, texturePath)
        self:ForEachRing(function(ring)
            ring.edge:SetTexture(texturePath)
            ring.cooldown:SetSwipeTexture(texturePath)
        end)
    end
    Border.ChangeTexture = ChangeTexture

    local function ChangeColor(self, color)
        self:ForEachRing(function(ring)
            ring.edge:SetVertexColor(color.r, color.g, color.b, 1)
        end)
    end
    Border.ChangeColor = ChangeColor

    local function ChangeAlpha(self, alpha)
        self:ForEachRing(function(ring)
            ring.cooldown:SetAlpha(alpha)
        end)
    end
    Border.ChangeAlpha = ChangeAlpha

    local function ChangeSize(self, borderSize)
        for i = 2, 0, -1 do
            local size = self:_CalculateSize(borderSize, i)
            self.rings[i]:ChangeSize(size)
        end
    end
    Border.ChangeSize = ChangeSize

    local function PauseExistingAnimations(self)
        if self.rings[0].edgeAnimations:IsPlaying() then
            self:ForEachRing(function(ring)
                ring.edgeAnimations:Stop()
                ring.cooldownAnimations:Stop()
            end)
        end
    end
    Border.PauseExistingAnimations = PauseExistingAnimations

    local function StartExpirationTimer(self, expirationTime)
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
    Border.StartExpirationTimer = StartExpirationTimer

    local function ForEachRing(self, func)
        for i = 0, 2 do
            func(self.rings[i])
        end
    end
    Border.ForEachRing = ForEachRing

    local function _CalculateSize(self, size, ringLevel)
        return size - ringLevel * size / 5
    end
    Border._CalculateSize = _CalculateSize
end