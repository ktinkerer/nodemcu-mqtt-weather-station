--file : DHT.lua
local module = {}
function module.taketemp()
    pin = 1
    status, temp, humi, temp_dec, humi_dec = dht.readxx(pin)
    if status == dht.OK then

        print("DHT Temperature:"..temp..";".."Humidity:"..humi)

    elseif status == dht.ERROR_CHECKSUM then
        print( "DHT Checksum error." )
    elseif status == dht.ERROR_TIMEOUT then
        print( "DHT timed out." )
    end

    return temp, humi

end
return module
