#### Lamaedit Usage:

```lua
if not lamaedit then --check if the api is loaded.  Bad things happen if it is.
  os.loadAPI( "lamaedit" ) --load the api
  lamaedit.overwrite() --overwrite _G.turtle, will overwrite a table instead if given one
end

--use turtle commands normally, _G.turtle has been overwritten

--Get the position of the turtle
local x, y, z, facing = lamaedit.getPosition() 

--Set the position of the turtle (facing is optional)
lamaedit.setPosition( x, y, z[, facing] )
```
#### For more information:
https://github.com/lupus590/CC-Hive/wiki/Lamaedit
