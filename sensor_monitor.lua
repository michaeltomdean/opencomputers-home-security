-- Monitor player events and keep a log so that we can keep track of who is coming and going on the island

local event = require("event")
local os = require("os")
local internet = require("internet")
local io = require("io")
local component = require("component")
modem = component.modem


component.motion_sensor.setSensitivity(500)
hub_id = "d54cb33a-7367-4df1-abb9-a2690d6c0001"
port = 99
sensor_location = "Shared Workshop" -- Custom sensor location
ignored_entities = {"Michaelius", "EloItsMee", "Wolf"} -- Ignored players & entities.

print("Monitoring Sensors..")

function motionSensorEventHandler(event_name, sensor_id, rx, ry, rz, player_name)
  msg = sensor_location .. "," .. event_name .. "," .. sensor_id .. ",".. rx .. "," .. ry .. "," .. rz .. "," .. player_name .. "\n"
  for _, v in pairs(ignored_entities) do
    if v == player_name then
      return
    end
  end  
  modem.send(hub_id, port, msg)
end
    
function handleEvent(event_name, sensor_id, rx, ry, rz, player_name)
  if event_name == "motion" then
    motionSensorEventHandler(event_name, sensor_id, rx, ry, rz, player_name)
  end
end

while true do
  handleEvent(event.pull())
end