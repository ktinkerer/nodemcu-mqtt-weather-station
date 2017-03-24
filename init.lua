-- file : init.lua

connect = require("connect")
espmqtt = require("espmqtt")
config = require("config")
doDHT = require("DHT")
bhp = require("bhp")
rain = require("rain")

connect.start()

tmr.alarm(0,5000,1,function()
  print(wifi.sta.getip())
  if wifi.sta.getip()~=nil then
    espmqtt.start()
    tmr.unregister(0)
    end
end)

-- timer to check whether MQTT is still connected
tmr.alarm(3,60000,1,function()
  print("Checking MQTT connection")
  espmqtt.check_alive()
end)
