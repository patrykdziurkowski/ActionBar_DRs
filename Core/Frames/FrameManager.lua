--[[
    DEPENDENCIES
]]--
Border = Border

--[[
    FRAME MANAGER
]]--
FrameManager = {}
do
    -- public methods
    function FrameManager:New(button, size, color, alpha, texturePath) end
    function FrameManager:ShowBorder(level, appliedTime, expirationTime) end
    function FrameManager:HideBorder() end
    function FrameManager:ChangeSize(size) end
    function FrameManager:ChangeBorderColor(color) end
    function FrameManager:ChangeCooldownAlpha(alpha) end
    function FrameManager:ChangeBorderTexture(texturePath) end

    -- private fields
    FrameManager._button = nil
    FrameManager._border = nil

    ----------------------------------------------
    -- IMPLEMENTATIONS
    ----------------------------------------------
    local function New(self, button, size, color, alpha, texturePath)
        local frameManager = {}
        setmetatable(frameManager, self)
        self.__index = self

        frameManager._button = button
        frameManager._border = Border:New(frameManager._button, size, color, alpha, texturePath)
        return frameManager
    end
    FrameManager.New = New

    local function ShowBorder(self, level, appliedTime, expirationTime)
        self._border:PauseExistingAnimations()
        self._border:Show(level, appliedTime, expirationTime)
        self._border:StartExpirationTimer(expirationTime)
    end
    FrameManager.ShowBorder = ShowBorder

    local function HideBorder(self)
        self._border:Hide()
    end
    FrameManager.HideBorder = HideBorder

    local function ChangeSize(self, size)
        self._border:ChangeSize(size)
    end
    FrameManager.ChangeSize = ChangeSize

    local function ChangeBorderColor(self, color)
        self._border:ChangeColor(color)
    end
    FrameManager.ChangeBorderColor = ChangeBorderColor

    local function ChangeCooldownAlpha(self, alpha)
        self._border:ChangeAlpha(alpha)
    end
    FrameManager.ChangeCooldownAlpha = ChangeCooldownAlpha

    local function ChangeBorderTexture(self, texturePath)
        self._border:ChangeTexture(texturePath)
    end
    FrameManager.ChangeBorderTexture = ChangeBorderTexture
end