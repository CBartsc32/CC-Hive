 --[[
 Make a docker image!

 Author: Jared Allard <rainbowdashdc@pony.so>
 License: MIT
 Version: 0.0.1
]]

-- fcs16
local fcs16 = {}

fcs16["table"] = {
[0]=0, 4489, 8978, 12955, 17956, 22445, 25910, 29887,
35912, 40385, 44890, 48851, 51820, 56293, 59774, 63735,
4225, 264, 13203, 8730, 22181, 18220, 30135, 25662,
40137, 36160, 49115, 44626, 56045, 52068, 63999, 59510,
8450, 12427, 528, 5017, 26406, 30383, 17460, 21949,
44362, 48323, 36440, 40913, 60270, 64231, 51324, 55797,
12675, 8202, 4753, 792, 30631, 26158, 21685, 17724,
48587, 44098, 40665, 36688, 64495, 60006, 55549, 51572,
16900, 21389, 24854, 28831, 1056, 5545, 10034, 14011,
52812, 57285, 60766, 64727, 34920, 39393, 43898, 47859,
21125, 17164, 29079, 24606, 5281, 1320, 14259, 9786,
57037, 53060, 64991, 60502, 39145, 35168, 48123, 43634,
25350, 29327, 16404, 20893, 9506, 13483, 1584, 6073,
61262, 65223, 52316, 56789, 43370, 47331, 35448, 39921,
29575, 25102, 20629, 16668, 13731, 9258, 5809, 1848,
65487, 60998, 56541, 52564, 47595, 43106, 39673, 35696,
33800, 38273, 42778, 46739, 49708, 54181, 57662, 61623,
2112, 6601, 11090, 15067, 20068, 24557, 28022, 31999,
38025, 34048, 47003, 42514, 53933, 49956, 61887, 57398,
6337, 2376, 15315, 10842, 24293, 20332, 32247, 27774,
42250, 46211, 34328, 38801, 58158, 62119, 49212, 53685,
10562, 14539, 2640, 7129, 28518, 32495, 19572, 24061,
46475, 41986, 38553, 34576, 62383, 57894, 53437, 49460,
14787, 10314, 6865, 2904, 32743, 28270, 23797, 19836,
50700, 55173, 58654, 62615, 32808, 37281, 41786, 45747,
19012, 23501, 26966, 30943, 3168, 7657, 12146, 16123,
54925, 50948, 62879, 58390, 37033, 33056, 46011, 41522,
23237, 19276, 31191, 26718, 7393, 3432, 16371, 11898,
59150, 63111, 50204, 54677, 41258, 45219, 33336, 37809,
27462, 31439, 18516, 23005, 11618, 15595, 3696, 8185,
63375, 58886, 54429, 50452, 45483, 40994, 37561, 33584,
31687, 27214, 22741, 18780, 15843, 11370, 7921, 3960 }

function fcs16.hash(str) -- Returns FCS16 Hash of @str
    local i
    local l=string.len(str)
    local uFcs16 = 65535
    for i = 1,l do
        uFcs16 = bit.bxor(bit.brshift(uFcs16,8), fcs16["table"][bit.band(bit.bxor(uFcs16, string.byte(str,i)), 255)])
    end
    return  bit.bxor(uFcs16, 65535)
end

-- Arguments
local Args = {...}

-- config
local server = "73.42.212.100"

local oprint = print
local write = term.write

-- quick colors hijack
local function print(msg, color)
  if color ~= nil then
    term.setTextColor(colors[color])
  end

  oprint(msg)

  if color ~= nil then
    term.setTextColor(colors.white)
  end
end

term.write = function (msg, color)
  if color ~= nil then
    term.setTextColor(colors[color])
  end

  write(msg)

  if color ~= nil then
    term.setTextColor(colors.white)
  end
end

local function doHelp()
  print("USAGE: ccdocker [OPTIONS] COMMAND [arg...]")
  print("")
  print("A self contained runtime for computercraft code.")
  print("")
  print("Commands: ")
  print(" pull     Pull an image from a ccDocker repository")
  print(" push     Push an image to a ccDocker repository")
  print(" build    Build an image.")
  print(" run      Run a command in a new container.")
  print(" register Register on a ccDocker repository.")
  print(" version  Show the ccdocker version.")
  print(" help     Show this help")
end

local function buildImage(image)
  if image == nil then
    error("missing param 1 (image)")
  end

  docker.makeImage(docker, image)
end

local function pullImage(url, image)
  if http == nil then
    error("http not enabled")
  end

  if url == nil then
    error("missing param 0 (url)")
  elseif image == nil then
    error("missing param 1 (image)")
  end

  -- use fs.combine to make parsing a bit easier.
  local url = "http://" .. fs.combine(tostring(url), "")
  local apiv = http.get(url.."/api/version")

  if apiv == nil then
    term.write("FATA", "red")
    print("[0001] Couldn't communicate with the API.")

    return false
  end

  -- determine if we were given a flag.
  local v = string.match(image, ".+:([0-9\.a-zA-Z]+)")
  local s = string.match(image, "(.+):[0-9\.a-zA-Z]+")

  if v == nil then
    vh = ""
    v = "latest"
    s = image
  else
    vh = v..": "
    image = s .. "/" .. v
  end

  local user = string.match(s, "(.+)/.+")
  local img = string.match(s, ".+/(.+)")

  print(vh.."Pulling image "..tostring(s))
  local fh = fs.open(image, "r")
  local r = http.get(url.."/pull/"..image)

  -- check if nil before attempting to parse it.
  if r == nil then
    term.write("FATA", "red")
    print("[0008] Error: image "..tostring(s).." not found")

    return false
  end

  -- newline
  print("")

  -- temporary notice about multiple fs layers not being supported
  term.write("NOTI", "cyan")
  print("[0001] Multiple FS layers is not currently supported.")

  -- check and make sure the result was not nil
  local fc = r.readAll()
  if tostring(fc) == "" then
    term.write("FATA", "red")
    print("[0004] Error: Image was blank.")

    return false
  end

  if fs.exists("/var/ccdocker") then
    fs.makeDir("/var")
    fs.makeDir("/var/ccdocker")
  end

  if fs.exists("/var/ccdocker/"..user.."/"..img.."/"..v.."/docker.fs") then
    fs.delete("/var/ccdocker/"..user.."/"..img.."/"..v.."/docker.fs")
  end

  local fh = fs.open("/var/ccdocker/"..user.."/"..img.."/"..v.."/docker.fs", "w")
  fh.write(fc)
  fh.close()

  local f16h = fcs16.hash(fc)
  print("")
  print("Digest: fcs16:"..f16h)
  print("Status: Downloaded newer image for "..tostring(img)..":"..tostring(v))

  return true
end

local function pushImage(url, image)
  if http == nil then
    error("http not enabled")
  end

  if url == nil then
    error("missing param 0 (url)")
  elseif image == nil then
    error("missing param 1 (image)")
  end

  if fs.exists(image) == false then
    error("image not found")
  end

  -- use fs.combine to make parsing a bit easier.
  local url = "http://" .. fs.combine(tostring(url), "")
  local apiv = http.get(url.."/api/version")

  if apiv == nil then
    term.write("FATA", "red")
    print("[0001] Couldn't communicate with the API.")

    return false
  end

  term.write("Username: ", "lightGray")
  local un = read()

  term.write("Password: ", "lightGray")
  local pass = read("*")

  term.write("checking credentials ... ")
  local r = http.post(url.."/auth", json:encode({
    username = un,
    password = sha256(pass)
  }))

  -- decode and then close the io stream
  local rf =  json:decode(r.readAll())
  r.close()

  if rf ~= nil then
    if rf.token ~= nil then
      print("OK", "green")
    else
      print("FAIL", "red")
      term.write("FATA", "red")
      print("[0009] Error: Couldn't authenticate. Wrong password?")

      return false
    end
  else
    print("FAIL", "red")
    term.write("FATA", "red")
    print("[0010] Bad API response.")

    return false
  end


  term.write("uploading image ... ")
  local fh = fs.open(image, "r")
  local r = http.post(url.."/push", un..":"..rf.token.."\n"..fh.readAll())

  -- preparse check
  if r == nil then
    print("FAIL", "red")
    term.write("FATA", "red")
    print("[0016] Failed to parse the APIs response")

    return false
  end

  -- parse the response
  local rj =  json:decode(r.readAll())

  r.close() -- close the handle
  if rj ~= nil then
    if rj.success == true then
      print("OK", "green")
    else
      print("FAIL", "red")
      term.write("FATA", "red")
      print("[" .. (rj.code or tostring("0011")) .. "] Error: "..rj.error)

      return false
    end
  else
    print("FAIL", "red")
    term.write("FATA", "red")
    print("[0014] Failed to parse the APIs response.")

    return false
  end

  term.write("verifying it was uploaded ... ")
  print("OK", "green")

  return true
end

local function register(url)
  -- use fs.combine to make parsing a bit easier.
  local url = "http://" .. fs.combine(tostring(url), "")
  local apiv = http.get(url.."/api/version")

  if apiv == nil then
    term.write("FATA", "red")
    print("[0001] Couldn't communicate with the API.")

    return false
  end

  term.write("Username: ", "lightGray")
  local un = read()

  term.write("Password: ", "lightGray")
  local pass = read("*")

  term.write("Confirm Password: ", "lightGray")
  local charpass = read("*")

  if pass ~= charpass then
    term.write("FATA", "red")
    print("[0000] Passwords do not match.")

    return false
  end

  term.write("attempting to register ... ")
  local r = http.post(url.."/register", json:encode({
    username = un,
    password = sha256(pass)
  }))

  local rj =  json:decode(r.readAll())

  if rj == nil then
    print("FAIL", "red")
    term.write("FATA", "red")
    print("[0015] Failed to parse the APIs response")

    return false
  end

  r.close() -- close the handle
  if rj ~= nil then
    if rj.success == true then
      print("OK", "green")
    else
      print("FAIL", "red")
      term.write("FATA", "red")
      print("[" .. (rj.code or '0011') .. "] Error: "..rj.error)

      return false
    end
  else
    print("FAIL", "red")
    term.write("FATA", "red")
    print("[0013] Failed to parse the APIs response.")

    return false
  end

end

local function runImage(server, image)
  if image == nil then
    error("missing param 1 (image)")
  end

  if fs.exists(image) == false then
    local v = string.match(image, ".+:([0-9\.a-zA-Z]+)")
    local s = string.match(image, "(.+):[0-9\.a-zA-Z]+")
    local user = string.match(s, "(.+)/.+")
    local img = string.match(s, ".+/(.+)")

    if fs.exists("/var/ccdocker/"..user.."/"..img.."/"..v.."/docker.fs") == false then
      print("Unable to find image '"..image.."' locally.")
      if pullImage(server, image) ~= true then
        return false
      end
    else
      term.write("NOTI", "cyan")
      print("[0002] Image exists locally.")
    end

    docker.chroot(docker, "/var/ccdocker/"..user.."/"..img.."/"..v.."/docker.fs")
  else
    docker.chroot(docker, image)
  end

  return true -- probably all went well.
end

if Args[1] == nil then
  doHelp()
  return
end

if Args[1] == "pull" then
  pullImage(server, Args[2])
elseif Args[1] == "push" then
  pushImage(server, Args[2])
elseif Args[1] == "run" then
  runImage(server, Args[2])
elseif Args[1] == "version" then
  print(docker.version)
elseif Args[1] == "build" then
  buildImage(Args[2])
elseif Args[1] == "register" then
  register(server)
elseif Args[1] == "rmi"  then
  removeImage(server, Args[2])
elseif Args[1] == "help" then
  doHelp()
  return
else
  doHelp()
end
