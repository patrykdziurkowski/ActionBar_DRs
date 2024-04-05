local DrList = LibStub:GetLibrary("DRList-1.0")
local DrTracker = DrTracker

C_Timer.NewTicker(2, function()
    if UnitExists("target") then
        print(DrTracker:GetDrInfo(UnitGUID("target"), 15487))
        DrTracker:AddDr(UnitGUID("target"), "silence", 5)
    end
end)
