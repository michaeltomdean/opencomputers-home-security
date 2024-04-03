-- Hub Lua Script. Run on the hub server that is storing the data
-- from your sensors.

local event = require("event")
local os = require("os")
local internet = require("internet")
local io = require("io")
local component = require("component")
local filesystem = require("filesystem")
modem = component.modem
modem.open(99)

path = "/home/monitor_players/data/log.txt" --Log file path
max_size = 3175000 -- Max file size before the log file is erased.

function split (inputstr, sep)
  local t = {}
  for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
    table.insert(t, str)
  end
  return t
end

function writeData(datetime, modem_msg)
  file = io.open(path,"a")
  str = datetime .. "," .. modem_msg
  file:write(str)
  file:close()  
end

function getRealTime() -- Change based on your time zone
  response = internet.request("http://worldtimeapi.org/api/timezone/Europe/London.txt")
  local body = ""
  for chunk in response do
    body = body .. chunk
  end
  t = split(body, "\n")
  return t[3]
end

while true do
  event_id, hub_id, sender_id, port, _, msg = event.pull("modem")
  filesize = filesystem.size(path)
  print("Log size: ", filesize)
  if filesize > max_size then
    file = io.open(path, "w")
    file:close()
  end
  datetime = getRealTime()
  writeData(datetime, msg)
  print(datetime, msg)
end