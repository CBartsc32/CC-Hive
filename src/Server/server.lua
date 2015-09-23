--[[

	Name: Hive -> Turtle Automation System
	Type: Server
	Author: DannySMc
	Platform: Lua Virtual Machine
	CCType: Advanced Computer
	Dependencies: Wireless Modem, HTTP Enabled.

	Shared Database Store:
	+ hive -> list = Will list all jobs saved to the job store.
	+ hive -> download = Will download a job and save it to the server.
	+ hive -> upload = Will allow you to upload a job from the server to the job store.

	Server Connections API:
	(FORMAT: function name -> args -> output)
	+ hive_core_connect -> username, password -> "false" (failed) clienthash if worked.
	+ hive_core_disconnect -> clienthash -> "true" or "false"
	+ 

]]

---------------------------------------- INITIALISATION OF VARIABLES AND NAMING CONVENTIONS ----------------------------------------
cchive = {}
cchive.__index = cchive
cchive.draw = {}
cchive.draw.__index = cchive.draw
cchive.core = {}
cchive.core.__index = cchive.core


-------------------------------------- END INITIALISATION OF VARIABLES AND NAMING CONVENTIONS ----------------------------------------

-- Download my API
local downloadapi = false
local nTries = 0
while not downloadapi do
	local ok, err = pcall( function()
		if http then
		    aa = aa or {}
		    local a = http.get("https://api.dannysmc.com/files/apis/progutils.lua")
		    a = a.readAll()
		    local env = {}
		    a = loadstring(a)
		    local env = getfenv()
		    setfenv(a,env)
		    local status, err = pcall(a, unpack(aa))
		    if (not status) and err then
		        printError("Error loading api")
		        return false
		    end
		    local returned = err
		    env = env
		    _G["progutils"] = env
		end
	end)
	if not ok then
		term.clear()
		term.setCursorPos(1,1)
		print("Download API (Attempt: "..nTries.."/".."5)")
		if nTries >= 5 then
			shell.run("shell")
		end
	else
		downloadapi = true
	end
end

function cchive.init()
	
end




























---------------------------------------- START CC-HIVE SYSTEM SERVER ----------------------------------------
if downloadapi then
	cchive.init()
else
	error("CC-Hive\'s server has crashed! :(")
end