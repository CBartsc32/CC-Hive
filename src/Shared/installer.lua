if not http then
  error("This installer requires the http API, check your config files or ask your server owner to enable http.",0)
end

local repo = "https://raw.githubusercontent.com/lupus590/CC-Hive/master/src/"

local directories = { --list of folders to create
  "Assets",
  "Client",
  "Logs",
  "Pocket",
  "Server",
  "Shared",
  "Shared/nsh",
  "Turtle",
  "Turtle/starNav",
  "Turtle/lama",
}

local files = { --list of files to get
  "Assets/jobstore.lua",
  "Assets/logo.lua",
  "Assets/progutils.lua",
  "Client/client.lua",
  "Server/server.lua",
  "Shared/AutoLabel.lua",
  "Shared/HiveLauncher.lua",
  "Shared/nsh/binget.lua",
  "Shared/nsh/binput.lua",
  "Shared/nsh/framebuffer.lua",
  "Shared/nsh/get.lua",
  "Shared/nsh/nsh.lua",
  "Shared/nsh/put.lua",
  "Shared/nsh/vncd.lua",
  "Turtle/AutoFuel.lua",
  "Turtle/lama/lama.lua",
  "Turtle/starNav/map.lua",
  "Turtle/starNav/pqueue.lua",
  "Turtle/starNav/starnav.lua",
  "Turtle/starNav/starnav_-_goto.lua",
}


local function installEverything()
  for _, dir in ipairs( directories ) do -- make the directories
    fs.makeDir( dir )
  end

  for k, v in pairs( files ) do
    local response = http.get( repo .. v ) -- get the file (v)
    if response then -- if we got it
      local file = fs.open( v, "w" ) -- save it
      file.write( response.readAll() )
      file.close()
      response.close()
    else -- otherwise, error
      error( "Failed to get file: " .. file, 0 )
    end
  end
end

local function installLama()
  local response = http.get( repo .. "Turtle/lama/lama.lua" ) -- get the file
  if response then -- if we got it
    local file = fs.open( "lama", "w" ) -- save it
    file.write( response.readAll() )
    file.close()
    response.close()
  else -- otherwise, error
    error( "Failed to get file: " .. file, 0 )
  end
end


local args = {...}

if #args == 0 then
 --ask for args
end

if args[1] = "lama" then
  installLama()
end



