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

-- Set up variables
hivedata = {
	["buffer"] = {};
	["config"] = {
		["modemSide"] = "top";
		["type"] = "server:solo";
		["name"] = "CC-Hive Server";
	};
	["trusted"] = {};
	["status"] = {
		["server"] = "OKAY";
		["buffer"] = "OKAY";
		["requests"] = {
			["total"] = 0;
			["session"] = 0;
		};
	};
}

function cchive.main()

	local ok, err = pcall( function() 

		-- Initialise Hive
		cchive.init()

		-- Initialise Screen
		cchive.screen()

		-- Load Configs
		cchive.config()

		cchive.event()

	end)
	if not ok then
		col.screen("white")
		local text = "Thanks for using CC-Hive, it seems an error has occured, forcing the system to halt, please choose the appropriate option."
		for k,v in ipairs(data.wordwrap(text, 40)) do
			draw.textc(v, k+4, false, "grey", "white")
		end
		draw.textc("---------- Error Message ----------", 11, false, "grey", "white")
		for k,v in ipairs(data.wordwrap(err, 45)) do
			draw.textc(v, k+12, false, "red", "white")
		end
		sleep(2)
		draw.cscreen()
	else
		col.screen("white")
		local text = "Thanks for using CC-Hive, this software is developed and maintained by Lupus590, DannySMc and KingofGamesYami."
		for k,v in ipairs(data.wordwrap(text, 40)) do
			draw.textc(v, k+15, false, "grey", "white")
		end
		local logo = paintutils.loadImage("CC-Hive/src/Assets/logo.lua")
		paintutils.drawImage(logo, 8, 2)
		sleep(2)
		draw.cscreen()
	end
end

function cchive.init()

end

function cchive.screen()
	col.screen("white")
	draw.box(1, 51, 1, 1, " ", "grey", "grey")
	draw.textl("CC-Hive", 1, false, "cyan", "grey")
	draw.textr(misc.time(), 1, false, "lime", "grey")
	draw.texta("[SERVER]: " .. hivedata.status.server, 1, 4, false, "grey", "white")
	draw.texta("[BUFFER]: " .. hivedata.status.buffer.. " - ("..#hivedata.buffer..")", 1, 5, false, "grey", "white")
	draw.texta("[REQUES]: Session("..hivedata.status.requests.session..") - Total("..hivedata.status.requests.total..")", 1, 6, false, "grey", "white")
end

function cchive.config()

end

function cchive.event()
	while true do
		local args = { os.pullEvent() }
		if args[1] == "timer" then
			draw.textr(misc.time(), 1, false, "lime", "grey")
		elseif args[1] == "rednet_message" then
			-- Check if reply is trusted
			for _, v in ipairs(hivedata.trusted) do
				if v.id == args[2] then

					-- Do main code parsing here.
					-- Add a transmit.decode() function to API to streamline this?
					local request = basesf.decode(args[3])
					local request1 = convert.bintotxt(request)
					request = textutils.unserialize(request)
					
					if request.command == "FINISHED" then
						-- Turtle Command

					elseif request.command == "WORKING" then
						-- Turtle Command

					elseif request.command == "ERROR" then
						-- Turtle Command

					elseif request.command == "RUN_JOB" then
						-- Turtle Command

					elseif request.command == "CLIENT_CONNECT" then
						-- Client Command
							-- Add to trusted,
							-- Administer encryption keys
						-- Same thing for turtles initially connecting
						
					elseif request.command == "NEW_JOB" then
						-- Client Command

					elseif request.command == "DEL_JOB" then
						-- Client Command

					end
					hivedata.status.requests.session = hivedata.status.requests.session + 1
					hivedata.status.requests.total = hivedata.status.requests.total + 1
				end
			end
		elseif args[1] == "char" then
			break
		end
	end
end


















--[[

	REQUESTS:
		CLIENT:
			+ JOB_NEW
			+ JOB_DEL
			+ JOB_EDT
	
		TURTLE:
			+ TASK_NEW
			+ TASK_DEL
			+ TASK

		MONITOR:
			+ MON_STATUS
			+ MON_STATUS_TURTLE
			+ MON_JOBS

]]





---------------------------------------- START CC-HIVE SYSTEM SERVER ----------------------------------------
if downloadapi then
	cchive.main()
else
	error("CC-Hive\'s server has crashed! :(")
end
