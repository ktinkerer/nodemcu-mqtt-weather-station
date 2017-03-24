local module = {}
function module.read()

    SDA_PIN = 6
    SCL_PIN = 5 

    bh1750 = require("bh1750")
    bh1750.init(SDA_PIN, SCL_PIN)
    bh1750.read(OSS)
    l = bh1750.getlux()/100
    print("lux: "..l.." lx")
    -- release module
    bh1750 = nil
    package.loaded["bh1750"]=nil

    return l

end

return module
