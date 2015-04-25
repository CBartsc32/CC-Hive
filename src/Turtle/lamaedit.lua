local turtle = {}
for k, v in pairs( _G.turtle ) do
	turtle[ k ] = v
end

local env = getfenv()

--Fuel tracking
local fuel = {}
fuel.load = function()
	if fs.exists( ".fuel" ) then
		local file = fs.open( ".fuel", "r" )
		fuel.amount = file.readAll():match( "%S+$" )
		file.close()
	else
		fuel.amount = turtle.getFuelLevel()
	end
	fuel.file = fs.open( ".fuel", "w" )
end

fuel.save = function()
	fuel.file.write( " " .. fuel.amount )
	fuel.file.flush()
end

--facing tracking
local facing = {}
facing.turnRight = function()
	if facing.face == "north" then
		facing.face = "east"
	elseif facing.face == "east" then
		facing.face = "south"
	elseif facing.face == "south" then
		facing.face = "west"
	elseif facing.face == "west" then
		facing.face = "north"
	end
end

facing.save = function()
	facing.file.write( textutils.serialize( {facing.face, facing.direction} ) )
	facing.file.flush()
end

facing.load = function()
	if fs.exists( ".facing" ) then
		local file = fs.open( ".facing", "r" )
		facing.face, facing.direction = unpack( textutils.unserialize( file.readAll():match( "{.-}$" ) ) )
		file.close()
	else
		facing.face = "north"
	end
	facing.file = fs.open( ".facing", "w" )
end

--position tracking
local position = {}
position.save = function()
	position.update()
	position.file.write( textutils.serialize( { position.x, position.y, position.z } ) )
	position.file.flush()
end
position.load = function()
	if fs.exists( ".position" ) then
		local file = fs.open( ".position", "r" )
		position.x, position.y, position.z = unpack( textutils.unserialize( file.readAll():match("{.-}$") ) )
		file.close()
	else
		position.x, position.y, position.z = 1, 1, 1
	end
	position.file = fs.open( ".position", "w" )
end

position.update = function()
	local diff = fuel.amount - turtle.getFuelLevel()
	if diff > 0 then
		if facing.direction == 'north' then
			position.x = position.x + diff
		elseif facing.direction == "south" then
			position.x = position.x - diff
		elseif facing.direction == "east" then
			position.z = position.z + diff
		elseif facing.direction == "west" then
			position.z = position.z - diff
		elseif facing.direction == "up" then
			position.y = position.y + diff
		elseif facing.direction == "down" then
			position.y = position.y - diff
		end
	end
	fuel.amount = turtle.getFuelLevel()
end

local opposite = {
	["north"] = "south",
	["south"] = "north",
	["east"] = "west",
	["west"] = "east",
}

env.forward = function()
	if facing.direction ~= facing.face then
		position.save()
		facing.direction = facing.face
		facing.save()
	end
	return turtle.forward()
end

env.back = function()
	if facing.direction ~= opposite[ facing.face ] then
		position.save()
		facing.direction = opposite[ facing.face ]
		facing.save()
	end
	return turtle.back()
end

env.up = function()
	if facing.direction ~= "up" then
		position.update()
		facing.direction = "up"
		facing.save()
	end
	return turtle.up()
end

env.down = function()
	if facing.direction ~= "down" then
		position.update()
		facing.direction = "down"
		facing.save()
	end
	return turtle.down()
end

env.turnRight = function()
	position.update()
	facing.turnRight()
	facing.save()
	position.save()
	return turtle.turnRight()
end

env.turnLeft = function()
	position.update()
	facing.turnRight()
	facing.turnRight()
	facing.turnRight()
	facing.save()
	position.save()
	return turtle.turnRight()
end

env.refuel = function( n )
	position.update()
	if turtle.refuel( n ) then
		fuel.amount = turtle.getFuelLevel()
		fuel.save()
		return true
	end
	return false
end

env.overwrite = function( t )
	for k, v in pairs( env ) do
		t[ k ] = v
	end
end

env.getPosition = function()
	return position.x, position.y, position.z, facing.face
end

env.setPosition = function( x, y, z, face )
	position.x = x
	position.y = y
	position.z = z
	facing.face = face or facing.face
	position.save()
	facing.save()
end

facing.load()
position.load()
fuel.load()
position.update()
