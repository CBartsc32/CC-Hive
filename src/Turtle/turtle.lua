
--constants
local HiveServerIDFile = "HiveServerID" --file path and name

--variables
local HiveServerID
local JoinMessage = textutils.serialize({command = "TURTLE_CONNECT"})

--load progutils API
--init
--load lama
--init lama
--load auto refuel
--init auto refuel
--load starnav?
--init starnav?



local function joinHiveServer()--connect to hive
  --presume that HiveServerID is valid or nil
  if HiveServerID then
    transmit.send(HiveServerID, JoinMessage, "hivesystem")
  else
    return false
  end
  local ServerID, msg = transmit.receive(2, "hivesystem")
  while ServerID ~= HiveServerID do
    ServerID, msg = transmit.receive(2, "hivesystem")
    end
    if not ServerID then
      return false
    end
  end
  encryptionKey = msg.data
  return true
end

local function rejoinHive()--read a file to rejoin last joined hive (defult option)
  if fs.exists(HiveServerIDFile) then
    local file = fs.open(HiveServerIDFile,"r")
    HiveServerID = tonumber(file.readAll())
    file.close()
    
end



--main loop
while true do
  --wait for task from hive server
  --run task

end
