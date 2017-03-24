-- file : espmqtt.lua
local module = {}
mqtt_connected = false
m = nil

local function m_close()
    m:close()
end

local function register_myself()
    m:subscribe(config.MQTTTOPIC.."/#",0, function(client)
        print("Registered")
        mqtt_connected = true
    end)
end

local function fetch_results()
    rainValue = rain.read()
    dhtResults = {doDHT.taketemp()}
    temp, humidity = unpack(dhtResults)
    light = bhp.read()
    espmqtt.send(config.MQTTTOPIC.."/temperature", temp)
    espmqtt.send(config.MQTTTOPIC.."/humidity", humidity)
    espmqtt.send(config.MQTTTOPIC.."/rain", rainValue)
    espmqtt.send(config.MQTTTOPIC.."/lux", light )
    resultsString = rainValue..","..temp..","..humidity..","..light
    espmqtt.send(config.MQTTTOPIC.."/results", resultsString)
end

local function mqtt_start()
    print("Connecting to MQTT")
    if m ~= nil then
        s,err = pcall(m_close)
        if s then
            print("No errors closing m")
        else
            print("Error closing m: "..err)
        end
    end
    m = mqtt.Client(config.ID, 200, config.USER, config.PASSWORD)
    -- Connect to broker
    m:on("message", function(conn, topic, data)
      if data ~= nil then
        print(topic .. ": " .. data)
        if topic == config.MQTTTOPIC.."/pingreply" then
            print("Pingreply")
            reply = true
        elseif topic == config.MQTTTOPIC.."/read" then
            fetch_results()
        elseif topic == config.MQTTTOPIC.."/sleep" then
            milliseconds = data * 1000000
            print("Sleeping for "..data.." seconds")
            node.dsleep(milliseconds)
        end
      end
    end)
    m:lwt("lwt/"..config.MQTTTOPIC, "offline", 0, 0)
    m:on("offline", function(m)
    print("disconnected from mqtt server")
    mqtt_connected = false
    end)
    m:connect(config.HOST, config.PORT, 0, 0, function(m)
    register_myself()
    end)
end

-- Sends a simple ping to the broker
local function send_ping()
    print("Sending ping")
    m:publish(config.MQTTTOPIC.."/ping","ping",0,0, function(client) end)
end

-- The MQTT offline callback does not seem to work so instead the nodemcu pings
-- the server and restarts if it does not receive a reply after 30 seconds
-- REQUIRES THE SERVER TO BE SET UP TO REPLY TO A MESSAGE WITH THE TOPIC "ping"
-- which replies with the topic "pingreply"
-- you can disable this function in the init.lua file

function module.check_alive()
    if mqtt_connected == false then
        print("Not connected")
        mqtt_start()
    else
        reply = false
        count = 0
        send_ping()
        tmr.alarm(1,1000,tmr.ALARM_AUTO,function()
            count = count + 1
            print("Waiting for ping" .. count)
            if reply == true then
                print("Ping received")
                tmr.unregister(1)
            end
            if count == 30 then
                print("No ping received, restarting")
                mqtt_connected = false
                tmr.unregister(1)
                mqtt_start()
            end
        end)
    end
end

function module.send(topic, message)
  if mqtt_connected == false then
    mqtt_start()
  end
  m:publish(topic,message,0,config.RETAIN, function(client) end)
end

function module.start()
    print("Starting")
  mqtt_start()
end

function module.disconnect()
    m:close()
end
return module
