local json = {}

do
	local env = {}
	setmetatable( env, {__index = _G} )
	local response = http.get( "https://raw.githubusercontent.com/lupus590/CC-Hive/New-installer/src/Shared/json.lua" )
	if not response then
		error( "Could not get json.lua", 0 )
	end
	local func, err = loadstring( response.readAll() )
	setfenv( func, json )
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

local dirsToGet = {"https://api.github.com/repos/lupus590/CC-Hive/contents/src"}
local filesToGet = {}

local function scanDir( response )
	local f = json.decode( response.readAll() )
  	for k, v in pairs( f ) do
  		if v["type"] == "dir" then
  			dirsToGet[ #dirsToGet + 1 ] = v.url
  		elseif v["type"] == "file" then
	 		filesToGet[ #filesToGet + 1 ] = v.download_url
	 	end
	end
end

local function getFile()
	while(#filesToGet > 0 or #dirsToGet > 0)do
		local sPath = table.remove( filesToGet, 1 )
		local response
		repeat
			response = http.get( sPath )
		until response
		local file = fs.open( sPath:match( "/src/(.+)%.$" ), "w" )
		file.write( response.readAll() )
		file.close()
		response.close()
	end
end

local function getDir()
	while(#dirsToGet > 0)do
		local sPath = table.remove( dirsToGet, 1 )
		local response
		repeat
			response = http.get( sPath )
		until response
		fs.makeDir( sPath:match( "/src/(.+)" ) )
		scanDir( response )
	end
end

parallel.waitForAll( getFile, getFile, getFile, getDir, getDir )
