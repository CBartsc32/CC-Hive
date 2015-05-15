--this is an improved installer which will remove the need to track file paths
--eventually it will allow updates without redownloading the entire repository
--author: KingofGamesYami


--loading json
local json = {}

do
        local env = {} --weird meta enviorment stuffs
        setmetatable( env, {__index = _G} )
        local response = http.get( "https://raw.githubusercontent.com/lupus590/CC-Hive/New-installer/src/Shared/json.lua" )
        if not response then
                error( "Could not get json.lua", 0 )
        end
        local func, err = loadstring( response.readAll(), "json" )
        setfenv( func, env )
        if func then
                local ok, err = pcall( func )
                if not ok then
                        error( err, 0 )
                end
        else
                error( err, 0 )
        end
        for k, v in pairs( env ) do
                json[ k ] = v
        end
end

local dirsToGet = { {url="https://api.github.com/repos/lupus590/CC-Hive/contents/src/Shared", path="Shared" } }

if turtle then --setting up places to scan
        table.insert( dirsToGet, {url="https://api.github.com/repos/lupus590/CC-Hive/contents/src/Turtle", path="Turtle"} )
else
        table.insert( dirsToGet, {url="https://api.github.com/repos/lupus590/CC-Hive/contents/src/Client", path="Client"} )
end

local filesToGet = {} --a table of files we need to download
local isRunning = true

local installed = {}

local function scanDir( str ) --#a function for scanning a directory and allocating it's contents to the above tables
        local f = json.decode( str )
        for k, v in pairs( f ) do
                if v["type"] == "dir" then
                        table.insert( dirsToGet, {url = v.url, path = v.path:match( "src/(.+)" ) } )
                elseif v["type"] == "file" and v.name:match("%.(.-)$") == "lua" then
                        table.insert( filesToGet, {url = v.download_url, path = v.path:match( "src/(.+)%.lua" ) } )
                        installed[ v.path:match( "src/(.+)%.lua" ) ] = v.sha
                end
        end
end

local function getFile() --a function that downloads a single file at a time
        while isRunning or #filesToGet > 0 do
                if #filesToGet > 0 then
                        local toGet = table.remove( filesToGet, 1 )
                        local r
                        repeat
                                print( "Downloading " .. toGet.path )
                                r = http.get( toGet.url )
                        until r
                        print( "Downloaded " .. toGet.path )
                        local file = fs.open( toGet.path, "w" )
                        file.write( r.readAll() )
                        file.close()
                else
                        sleep( 0.1 )
                end
        end
end

local function getDir() --a function that makes directories
        while(#dirsToGet > 0)do
                local sPath = table.remove( dirsToGet, 1 )
                local response
                repeat
                        response = http.get( sPath.url )
                until response
                fs.makeDir( sPath.path )
                scanDir( response.readAll() )
                response.close()
        end
        isRunning = false
end

local function installDefault()
  parallel.waitForAll( getDir, getFile, getFile, getFile ) --runs 3 getFiles, 1 getDirs at once!
  print( "Done!" )
  local file = fs.open( "installed", "w" )
  for k, v in pairs( installed ) do
    file.writeLine( k .. " : " .. v )
  end
  file.close()
end

local function getRemaining( t )
  local i = 0
  for k, v in pairs( t ) do
    i = i + 1
  end
  return i
end

local function searchForFiles( ... )
  local tSearching = {}
  for i, v in ipairs( { ... } ) do
    tSearching[ v ] = true
  end
  local dirs = { "https://api.github.com/repos/lupus590/CC-Hive/contents/src" }
  local files_found = {}
  while getRemaining( tSearching ) > 0 do
    if #dirs == 0 then
      error( "Could not find all files: invalid input", 0 )
    end
    local dir = table.remove( dirs, 1 )
    local h
    repeat
      h = http.get( dir )
    until h
    local f = json.decode( h.readAll() )
    for k, v in pairs( f ) do
      local name = v.name:match( "(.+)%.lua )
      print( name )
      if v.type == "dir" then
        table.insert( dirs, v.url )
      elseif v.type == "file" and tSearching[ name ] then
        files_found[ name ] = v.download_url
        tSearching[ name ] = nil
      end
    end
  end
  for k, v in pairs( files_found ) do
    local h
    repeat
      h = http.get( v )
    until h
    local file = fs.open( k, "w" )
    file.write( h.readAll() )
    file.close()
  end
end

local tArgs = {...}
if #tArgs == 0 then
  installDefault()
else
  searchForFiles( ... )
end
