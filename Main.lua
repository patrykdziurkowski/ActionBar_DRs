print("ActionBar DRs loaded!")

local drList = LibStub:GetLibrary("DRList-1.0")
for k,v in pairs(drList:GetCategories()) do
    
    print(v)
end