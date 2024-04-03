local DrList = LibStub:GetLibrary("DRList-1.0")
local DrTracker = DrTracker

C_Timer.NewTicker(2, function()
    DrTracker:AddDr(UnitGUID("target"), "silence", 5)
    print(DrTracker:GetDrInfo(UnitGUID("target"), 15487))
end)
