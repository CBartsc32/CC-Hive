--constants
local HiveServerIDFile = "HiveServerID" --file path and name

--variables
local HiveServerID
local JoinMessage = table.serilise({messageType = "turtleJoin", })

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
    rednet.send(HiveServerID, JoinMessage)
  else
    return false
  end
  
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