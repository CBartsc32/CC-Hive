-- Draw Functions
draw = {}
draw.__index = draw

-- Configurations Functions
config = {}
config.__index = config

-- Database Functions
db = {}
db.__index = db

-- Encryption, Decryption and Hashing Functions
crypt = {}
crypt.__index = crypt

-- Colour Functions
col = {}
col.__index = col

-- Misc Functions
misc = {}
misc.__index = misc

-- Data Manipulation Functions
data = {}
data.__index = data

-- Help Functions
help = {}
help.__index = help

-- Image Manipulation Functions
image = {}
image.__index = image

-- Auto Load API's (on-the-fly) Functions
apis = {}
apis.__index = apis

function apis.load(urlcode)
    aa = aa or {}
    if urlcode:len() == 8 then
        local a = http.get("http://pastebin.com/raw.php?i="..textutils.urlEncode(tostring(urlcode)))
    else
        local a = http.get(textutils.urlEncode(tostring(urlcode)))
    end
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
    _G["snet"] = env
end

function config.save(table, file)
  fConfig = fs.open(file, "w") or error("Cannot open file "..file, 2)
  fConfig.write(textutils.serialize(table))
  fConfig.close()
end

function config.load(file)
  fConfig = fs.open(file, "r")
  ret = textutils.unserialize(fConfig.readAll())
  return ret
end

function image.draw(tablename, intx, inty)
    if tablename then
        if type(tablename) == "table" then
            for k1, v1 in ipairs(tablename) do
                for k2, v2 in ipairs(tablename[k1]) do
                    local bc = v2:sub(1, 2)
                    local tc = v2:sub(4, 5)
                    local char = v2:sub(7)
                    for k,v in ipairs(imgColours[1]) do
                        if v == bc then
                            bc = imgColours[2][k]
                        end
                        if v == tc then
                            tc = imgColours[2][k]
                        end
                    end
                    term.setBackgroundColour(colours[bc])
                    term.setTextColour(colours[tc])
                    term.setCursorPos(k2+intx-1, k1+inty-1)
                    write(char)
                end
            end
        end
    end
end

function image.save(tablename, filepath)
    if fs.exists(filepath) then
        print("[ERROR]: file already exists.")
    else
        local imgfile = fs.open(filepath, "w")
        imgfile.write(textutils.serialize(tablename))
        imgfile.close()
    end
end

function image.load(filepath)
    local imgfile = fs.open(filepath, "r")
    imgfile = imgfile.readAll()
    imgfile.close()
    return imgfile
end

function draw.cscreen()
    term.clear()
    term.setCursorPos(1,1)
    return
end

function draw.textc(Text, Line, NextLine, Color, BkgColor)
    local x, y = term.getSize()
    x = x/2 - #Text/2
    term.setCursorPos(x, Line)
    if Color then 
        col.set(Color, BkgColor) 
    end
    term.write(Text) 
    if NextLine then
        term.setCursorPos(1, NextLine) 
    end
    if Color then 
        col.reset(Color, BkgColor) 
    end
    return true  
end

function draw.texta(Text, xx, yy, NextLine, Color, BkgColor)
    term.setCursorPos(xx,yy)
    if Color then 
        col.set(Color, BkgColor) 
    end
    term.write(Text)
    if NextLine then  
        term.setCursorPos(1, NextLine) 
    end
    if Color then 
        col.reset(Color, BkgColor) 
    end
    return true  
end

function draw.cline(Line, NextLine)
    local x, y = term.getSize()
    for i = 1, x do
        term.setCursorPos(i, Line)
        term.write(" ")
    end  
    if not NextLine then  
        x, y = term.getCursorPos()
        term.setCursorPos(1, y+1) 
    end
    return true  
end

function draw.popup(text)
    draw.box(1, 51, 8, 1, " ", "lime", "red")
    draw.textc(text, 8, false, "lime", "red")
    sleep(1.5)
end

function draw.box(StartX, lengthX, StartY, lengthY, Text, Color, BkgColor)
    local x, y = term.getSize()
    if Color then 
        col.set(Color, BkgColor) 
    end
    if not Text then 
        Text = "*" 
    end
    lengthX = lengthX - 1 
    lengthY = lengthY - 1
    EndX = StartX + lengthX  
    EndY = StartY + lengthY
    term.setCursorPos(StartX, StartY)
    term.write(string.rep(Text, lengthX))
    term.setCursorPos(StartX, EndY)
    term.write(string.rep(Text, lengthX)) 
    for i = StartY, EndY do
        term.setCursorPos(StartX, i)
        term.write(Text)
        term.setCursorPos(EndX, i)    
        term.write(Text)
    end
    col.reset(Color, BkgColor)
    return true  
end

function db.delete(Filename)
    if fs.exists(Filename) then
        fs.delete(Filename)
        return true
    end
    return false
end

function db.load(Filename) 
    if not fs.exists(Filename) then
        local F = fs.open(Filename, "w")
        F.write("{}")
        F.close()
    end
    local F = fs.open(Filename, "r")
    local Data = F.readAll()
    F.close()
    Data = textutils.unserialize(Data)
    return Data
end

function db.save(Filename, ATable) 
    local Data = textutils.serialize(ATable)
    local F = fs.open(Filename, "w")
    F.write(Data)
    F.close()
    return true
end

function db.search(searchstring, ATable)
    for i, V in pairs(ATable) do
        if tostring(ATable[i]) == tostring(searchstring) then
            return i
        end
    end 
    return 0
end

function db.removeString(Filename, AString)
    local TempT = db.load(Filename)
    if type(TempT) ~= "table" then 
        return false 
    end
    local Pos = db.search(AString, TempT)
    if Pos > 0 then
        table.remove(TempT, Pos)
        db.save(Filename, TempT)
        return true
    else
        return false
    end
end

function db.insertString(Filename, AString)
    local TempT = db.load(Filename)
    if type(TempT) ~= "table" then 
        TempT = {} 
    end
    table.insert(TempT, AString)
    db.save(Filename, TempT)
    return true
end

local MOD = 2^32
local MODM = MOD-1
local function memoize(f)
    local mt = {}
    local t = setmetatable({}, mt)
    function mt:__index(k)
        local v = f(k)
        t[k] = v
        return v
    end
    return t
end
local function make_bitop_uncached(t, m)
    local function bitop(a, b)
        local res,p = 0,1
        while a ~= 0 and b ~= 0 do
            local am, bm = a % m, b % m
            res = res + t[am][bm] * p
            a = (a - am) / m
            b = (b - bm) / m
            p = p*m
        end
        res = res + (a + b) * p
        return res
    end
    return bitop
end
local function make_bitop(t)
    local op1 = make_bitop_uncached(t,2^1)
    local op2 = memoize(function(a) return memoize(function(b) return op1(a, b) end) end)
    return make_bitop_uncached(op2, 2 ^ (t.n or 1))
end
local bxor1 = make_bitop({[0] = {[0] = 0,[1] = 1}, [1] = {[0] = 1, [1] = 0}, n = 4})
local function bxor(a, b, c, ...)
    local z = nil
    if b then
        a = a % MOD
        b = b % MOD
        z = bxor1(a, b)
        if c then z = bxor(z, c, ...) end
        return z
    elseif a then return a % MOD
    else return 0 end
end
local function band(a, b, c, ...)
    local z
    if b then
        a = a % MOD
        b = b % MOD
        z = ((a + b) - bxor1(a,b)) / 2
        if c then z = bit32_band(z, c, ...) end
        return z
    elseif a then return a % MOD
    else return MODM end
end
local function bnot(x) return (-1 - x) % MOD end
local function rshift1(a, disp)
    if disp < 0 then return lshift(a,-disp) end
    return math.floor(a % 2 ^ 32 / 2 ^ disp)
end
local function rshift(x, disp)
    if disp > 31 or disp < -31 then return 0 end
    return rshift1(x % MOD, disp)
end
local function lshift(a, disp)
    if disp < 0 then return rshift(a,-disp) end 
    return (a * 2 ^ disp) % 2 ^ 32
end
local function rrotate(x, disp)
    x = x % MOD
    disp = disp % 32
    local low = band(x, 2 ^ disp - 1)
    return rshift(x, disp) + lshift(low, 32 - disp)
end
local k = {
    0x428a2f98, 0x71374491, 0xb5c0fbcf, 0xe9b5dba5,
    0x3956c25b, 0x59f111f1, 0x923f82a4, 0xab1c5ed5,
    0xd807aa98, 0x12835b01, 0x243185be, 0x550c7dc3,
    0x72be5d74, 0x80deb1fe, 0x9bdc06a7, 0xc19bf174,
    0xe49b69c1, 0xefbe4786, 0x0fc19dc6, 0x240ca1cc,
    0x2de92c6f, 0x4a7484aa, 0x5cb0a9dc, 0x76f988da,
    0x983e5152, 0xa831c66d, 0xb00327c8, 0xbf597fc7,
    0xc6e00bf3, 0xd5a79147, 0x06ca6351, 0x14292967,
    0x27b70a85, 0x2e1b2138, 0x4d2c6dfc, 0x53380d13,
    0x650a7354, 0x766a0abb, 0x81c2c92e, 0x92722c85,
    0xa2bfe8a1, 0xa81a664b, 0xc24b8b70, 0xc76c51a3,
    0xd192e819, 0xd6990624, 0xf40e3585, 0x106aa070,
    0x19a4c116, 0x1e376c08, 0x2748774c, 0x34b0bcb5,
    0x391c0cb3, 0x4ed8aa4a, 0x5b9cca4f, 0x682e6ff3,
    0x748f82ee, 0x78a5636f, 0x84c87814, 0x8cc70208,
    0x90befffa, 0xa4506ceb, 0xbef9a3f7, 0xc67178f2,
}
local function str2hexa(s)
    return (string.gsub(s, ".", function(c) return string.format("%02x", string.byte(c)) end))
end
local function num2s(l, n)
    local s = ""
    for i = 1, n do
        local rem = l % 256
        s = string.char(rem) .. s
        l = (l - rem) / 256
    end
    return s
end
local function s232num(s, i)
    local n = 0
    for i = i, i + 3 do n = n*256 + string.byte(s, i) end
    return n
end
local function preproc(msg, len)
    local extra = 64 - ((len + 9) % 64)
    len = num2s(8 * len, 8)
    msg = msg .. "\128" .. string.rep("\0", extra) .. len
    assert(#msg % 64 == 0)
    return msg
end
local function initH256(H)
    H[1] = 0x6a09e667
    H[2] = 0xbb67ae85
    H[3] = 0x3c6ef372
    H[4] = 0xa54ff53a
    H[5] = 0x510e527f
    H[6] = 0x9b05688c
    H[7] = 0x1f83d9ab
    H[8] = 0x5be0cd19
    return H
end
local function digestblock(msg, i, H)
    local w = {}
    for j = 1, 16 do w[j] = s232num(msg, i + (j - 1)*4) end
    for j = 17, 64 do
        local v = w[j - 15]
        local s0 = bxor(rrotate(v, 7), rrotate(v, 18), rshift(v, 3))
        v = w[j - 2]
        w[j] = w[j - 16] + s0 + w[j - 7] + bxor(rrotate(v, 17), rrotate(v, 19), rshift(v, 10))
    end
    local a, b, c, d, e, f, g, h = H[1], H[2], H[3], H[4], H[5], H[6], H[7], H[8]
    for i = 1, 64 do
        local s0 = bxor(rrotate(a, 2), rrotate(a, 13), rrotate(a, 22))
        local maj = bxor(band(a, b), band(a, c), band(b, c))
        local t2 = s0 + maj
        local s1 = bxor(rrotate(e, 6), rrotate(e, 11), rrotate(e, 25))
        local ch = bxor (band(e, f), band(bnot(e), g))
        local t1 = h + s1 + ch + k[i] + w[i]
        h, g, f, e, d, c, b, a = g, f, e, d + t1, c, b, a, t1 + t2
    end
    H[1] = band(H[1] + a)
    H[2] = band(H[2] + b)
    H[3] = band(H[3] + c)
    H[4] = band(H[4] + d)
    H[5] = band(H[5] + e)
    H[6] = band(H[6] + f)
    H[7] = band(H[7] + g)
    H[8] = band(H[8] + h)
end
function crypt.sha256(msg)
    msg = preproc(msg, #msg)
    local H = initH256({})
    for i = 1, #msg, 64 do digestblock(msg, i, H) end
    return str2hexa(num2s(H[1], 4) .. num2s(H[2], 4) .. num2s(H[3], 4) .. num2s(H[4], 4) ..
        num2s(H[5], 4) .. num2s(H[6], 4) .. num2s(H[7], 4) .. num2s(H[8], 4))
end

local function zfill(N)
    N=string.format("%X",N)
    Zs=""
    if #N==1 then
        Zs="0"
    end
    return Zs..N
end

local function serializeImpl(t) 
    local sType = type(t)
    if sType == "table" then
        local lstcnt=0
        for k,v in pairs(t) do
            lstcnt = lstcnt + 1
        end
        local result = "{"
        local aset=1
        for k,v in pairs(t) do
            if k==aset then
                result = result..serializeImpl(v)..","
                aset=aset+1
            else
                result = result..("["..serializeImpl(k).."]="..serializeImpl(v)..",")
            end
        end
        result = result.."}"
        return result
    elseif sType == "string" then
        return string.format("%q",t)
    elseif sType == "number" or sType == "boolean" or sType == "nil" then
        return tostring(t)
    elseif sType == "function" then
        local status,data=pcall(string.dump,t)
        if status then
            return 'func('..string.format("%q",data)..')'
        else
            error()
        end
    else
        error()
    end
end

local function split(T,func)
    if func then
        T=func(T)
    end
    local Out={}
    if type(T)=="table" then
        for k,v in pairs(T) do
            Out[split(k)]=split(v)
        end
    else
        Out=T
    end
    return Out
end

local function serialize( t )
    t=split(t)
    return serializeImpl( t, tTracking )
end

local function unserialize( s )
    local func, e = loadstring( "return "..s, "serialize" )
    local funcs={}
    if not func then
        return e
    end
    setfenv( func, {
        func=function(S)
            local new={}
            funcs[new]=S
            return new
        end,
    })
    return split(func(),function(val)
        if funcs[val] then
            return loadstring(funcs[val])
        else
            return val
        end
    end)
end

local function sure(N,n)
    if (l2-n)<1 then N="0" end
    return N
end

local function splitnum(S)
    Out=""
    for l1=1,#S,2 do
        l2=(#S-l1)+1
        CNum=tonumber("0x"..sure(string.sub(S,l2-1,l2-1),1) .. sure(string.sub(S,l2,l2),0))
        Out=string.char(CNum)..Out
    end
    return Out
end

local function wrap(N)
    return N-(math.floor(N/256)*256)
end

function checksum(S,num) -- args strInput and intPassNumber
    local sum=0
    for char in string.gmatch(S,".") do
        for l1=1,(num or 1) do
            math.randomseed(string.byte(char)+sum)
            sum=sum+math.random(0,9999)
        end
    end
    math.randomseed(sum)
    return sum
end

local function genkey(len,psw)
    checksum(psw)
    local key={}
    local tKeys={}
    for l1=1,len do
        local num=math.random(1,len)
        while tKeys[num] do
            num=math.random(1,len)
        end
        tKeys[num]=true
        key[l1]={num,math.random(0,255)}
    end
    return key
end

function crypt.encrypt(data,psw) -- args strInput and strPassword
    data=serialize(data)
    local chs=checksum(data)
    local key=genkey(#data,psw)
    local out={}
    local cnt=1
    for char in string.gmatch(data,".") do
        table.insert(out,key[cnt][1],zfill(wrap(string.byte(char)+key[cnt][2])),chars)
        cnt=cnt+1
    end
    return string.sub(serialize({chs,table.concat(out)}),2,-3)
end

function crypt.decrypt(data,psw) -- args strInput and strPassword
    local oData=data
    data=unserialize("{"..data.."}")
    if type(data)~="table" then
        return oData
    end
    local chs=data[1]
    data=data[2]
    local key=genkey((#data)/2,psw)
    local sKey={}
    for k,v in pairs(key) do
        sKey[v[1]]={k,v[2]}
    end
    local str=splitnum(data)
    local cnt=1
    local out={}
    for char in string.gmatch(str,".") do
        table.insert(out,sKey[cnt][1],string.char(wrap(string.byte(char)-sKey[cnt][2])))
        cnt=cnt+1
    end
    out=table.concat(out)
    if checksum(out or "")==chs then
        return unserialize(out)
    end
    return oData,out,chs
end

function col.set(textColour, backgroundColour)
    if textColour and backgroundColour then
        if term.isColour() then
            term.setTextColour(colours[textColour])
            term.setBackgroundColour(colours[backgroundColour])
            return true
        else
            return false
        end
    else
        return false
    end
end

function col.screen(colour)
    intX = 1
    intY = 1
    col.set(colour, colour)
    repeat
        intX = 1
        repeat
            term.setCursorPos(intX, intY)
            write(" ")
            intX = intX + 1
        until intX == 52
        intY = intY + 1
    until intY == 20
end
 
function col.reset()
    if term.isColour then
        term.setTextColour(colours.white)
        term.setBackgroundColour(colours.black)
        return true
    else
        return false
    end
end

function misc.find(Perihp)
  for _,s in ipairs(rs.getSides()) do
    if peripheral.isPresent(s) and peripheral.getType(s) == Perihp then
      return s   
    end
  end
  return false
end

function misc.serialgen(digits)
  local serial
  for i = 1, digits do
    if i == 1 then
      serial = math.random(9)
    else
      serial = serial.. math.random(9)
    end
  end
  serial = tonumber(serial)
  return serial
end

function misc.time()
    local nTime = textutils.formatTime(os.time(), true)
    if string.len(nTime) == 4 then
        nTime = "0"..nTime
    end
    os.startTimer(1)
    return nTime
end

function data.wordwrap(str, limit)
  limit = limit or 72
  local here = 1
  local buf = ""
  local t = {}
  str:gsub("(%s*)()(%S+)()",
  function(sp, st, word, fi)
        if fi-here > limit then
           --# Break the line
           here = st
           table.insert(t, buf)
           buf = word
        else
           buf = buf..sp..word  --# Append
        end
  end)
  --# Tack on any leftovers
  if(buf ~= "") then
        table.insert(t, buf)
  end
  return t
end