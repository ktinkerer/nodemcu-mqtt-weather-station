-- file : config.lua
local module = {}

module.SSID = {}
-- MQTT setup
-- IP address and port of MQTT server
module.HOST = "IP_ADDRESS"
module.PORT = 1883

-- MQTT user and password
module.USER = "user"
module.PASSWORD = "password"

-- MQTT topic
module.MQTTTOPIC = "outsidenode1"

-- Retain MQTT messages 0=false 1=true
module.RETAIN = 1

module.ID = node.chipid()
return module
