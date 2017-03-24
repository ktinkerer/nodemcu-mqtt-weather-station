local module = {}
function module.read()

    -- Rain sensor connections
    -- AO -> A0
    -- GND -> GND
    -- VCC -> D7 (Connecting VCC to a digital output and only turning it on when
    -- it is being used helps prolong the life of the sensor and prevent corrosion)

    gpio.mode(7, gpio.OUTPUT)
    gpio.write(7, gpio.HIGH)
    tmr.delay(5000)
    rainValue = adc.read(0)
    print("Rain: "..rainValue)
    tmr.delay(100)
    gpio.write(7, gpio.LOW)
    rainPercent = (1024 - rainValue) / 10.24
    return rainPercent

end

return module
