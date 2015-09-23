--[[
    
    Name: Programming Utilities
    Author: DannySMc (dannysmc95)
    Platform: Lua JVM

    License:
        This API is CAN be distributed with your programs, editing it and then redistributing is prohibited and/or claiming it as yours. If you use my API, I would like credit for making it and that can go in the credits section of your program, or on the CCForums Post.

    Links / Contact:
        Email: danny.smc95@gmail.com
        Website: https://dannysmc.com/
        Github: https://github.com/dannysmc95
        Donatations are not begged for, if you want you can just by me a drink. They are givable on my website

    Terms & Conditions:
        By using this software you agree to the following rules:
        1: I am not liable to any problems it causes or harm.
        2: You agree to not redistribute the software giving credit to me.
            2.1: Credit can be given in the following formats: on the website / post / topic / or in the software of where it is being used.
            2.2: Redstributing is prohibited if modified.
            2.3: Redistribution can only be done with STRICT permission of the licensor/author.
        3: Updates happen regularly, this CAN break your current program, currently there is no ideas to change the current API, just be aware.
        4: You are best to use an auto updating system, like require(), to keep the API up-to-date to make sure that security problems are sorted before hand.

    Small Note:
    If you are using this then thank you, this is a compiled API of everything that I have found useful on my applications. If you wish to add something to it then please by all means contact me and I can see what you propose, even add you to the credits if your contribution is of great use.
]]

-- Binary Conversions (To/From Binary)
convert = {}
convert.__index = convert

-- AES Cryprography
aes = {}
aes.__index = aes

-- XML Parsing Library
parse = {}
parse.__index = parse

-- Base64 Encode and Decode
basesf = {}
basesf.__index = basesf

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

-- Popup functions
popup ={}
popup.__index = popup

-- Secure Rednet Transmission Functions
transmit = {}
transmit.__index = transmit

-- Set MT Vars:
parentTerm = term.current()
bufferWidth, bufferHeight = parentTerm.getSize()
threads = {}
currentThread = nil
userEvents = { -- okay
    ["char"] = true;
    ["mouse_click"] = true;
    ["mouse_scroll"] = true;
    ["mouse_drag"] = true;
    ["key"] = true;
    ["timer"] = true;
}
--/ Set MT Vars

thread = {
    find = function( self, name )
        for i, thread in ipairs(threads) do
            if thread.name == name then
                return true
            end
        end
    end,
    create = function( self, name, func )
        threads[#threads + 1] = {
            name = name,
            func = func,
            co = coroutine.create(func),
            buffer = window.create(parentTerm, 1, 1, bufferWidth, bufferHeight, false),
            filter = nil,
        }
    end,
    remove = function( self, name )
        local toRemove = {}
        for i, thread in ipairs(threads) do
            if thread.name == name then
                toRemove[#toRemove + 1] = i
            end
        end
        for i = #toRemove, 1, -1 do
            table.remove(threads, toRemove[i])
        end
    end,
    switch = function( self, name )
        for i, thread in ipairs(threads) do
            if thread.name == name then
                if currentThread then
                    currentThread.buffer.setVisible(false)
                end
                thread.buffer.setVisible(true)
                currentThread = thread
                break
            end
        end
    end,
    run = function( self )
        local e, event = {}, nil
        while #threads > 0 do
            local toRemove = {}
            local _currentThread = currentThread
            for i, thread in ipairs(threads) do
                if (not userEvents[event] or _currentThread == thread) and (event == "terminate" or thread.filter == nil or thread.filter == event) then
                    term.redirect(thread.buffer)
                    local ok, filter = coroutine.resume(thread.co, unpack(e))
                    if not ok then
                        error(filter, 2)
                    end
                    if coroutine.status(thread.co) == "dead" then
                        toRemove[#toRemove + 1] = i
                    end
                    thread.filter = filter
                end
            end
            for i = #toRemove, 1, -1 do
                table.remove(threads, toRemove[i])
            end
            if #threads == 0 then
                break
            end
            e = {os.pullEventRaw()}
            event = e[1]
        end
    end,
}

function parse.xml(s)
    local function parseargs(s)
        local arg = {}
            string.gsub(s, "([%-%w]+)=([\"'])(.-)%2", function (w, _, a)
            arg[w] = a
        end)
        return arg
    end
    local stack = {}
    local top = {}
    table.insert(stack, top)
    local ni,c,label,xarg, empty
    local i, j = 1, 1
    while true do
        ni,j,c,label,xarg, empty = string.find(s, "<(%/?)([%w:]+)(.-)(%/?)>", i)
        if not ni then break end
        local text = string.sub(s, i, ni-1)
        if not string.find(text, "^%s*$") then
            table.insert(top, text)
        end
        if empty == "/" then  -- empty element tag
            table.insert(top, {label=label, xarg=parseargs(xarg), empty=1})
        elseif c == "" then   -- start tag
            top = {label=label, xarg=parseargs(xarg)}
            table.insert(stack, top)   -- new level
        else  -- end tag
            local toclose = table.remove(stack)  -- remove top
            top = stack[#stack]
            if #stack < 1 then
                error("nothing to close with "..label)
            end
            if toclose.label ~= label then
                error("trying to close "..toclose.label.." with "..label)
            end
            table.insert(top, toclose)
        end
        i = j+1
    end
    local text = string.sub(s, i)
    if not string.find(text, "^%s*$") then
        table.insert(stack[#stack], text)
    end
    if #stack > 1 then
        error("unclosed "..stack[#stack].label)
    end
    return stack[1][1]
end

function popup.alert(text)
    if text then
        draw.box(1, 51, 9, 1, " ", "grey", "grey")
        draw.textc(" "..text, 9, false, "white", "grey")
    end
end

function popup.input(text, mask)
    draw.box(1, 51, 9, 2, " ", "grey", "grey")
    draw.box(1, 51, 11, 2, " ", "grey", "grey")
    draw.textc(text, 9, false, "white", "grey")
    draw.box(3, 47, 11, 1, " ", "cyan", "cyan")
    col.set("white", "cyan")
    term.setCursorPos(3,11)
    write("> ")
    local input = tostring(read(mask))
    return input
end

function basesf.lsh(value,shift)
    return (value*(2^shift)) % 256
end

-- shift right
function basesf.rsh(value,shift)
    return math.floor(value/2^shift) % 256
end

-- return single bit (for OR)
function basesf.bit(x,b)
    return (x % 2^b - x % 2^(b-1) > 0)
end

-- logic OR for number values
function basesf.lor(x,y)
    result = 0
    for p=1,8 do result = result + (((basesf.bit(x,p) or basesf.bit(y,p)) == true) and 2^(p-1) or 0) end
    return result
end

local base64chars = {[0]='A',[1]='B',[2]='C',[3]='D',[4]='E',[5]='F',[6]='G',[7]='H',[8]='I',[9]='J',[10]='K',[11]='L',[12]='M',[13]='N',[14]='O',[15]='P',[16]='Q',[17]='R',[18]='S',[19]='T',[20]='U',[21]='V',[22]='W',[23]='X',[24]='Y',[25]='Z',[26]='a',[27]='b',[28]='c',[29]='d',[30]='e',[31]='f',[32]='g',[33]='h',[34]='i',[35]='j',[36]='k',[37]='l',[38]='m',[39]='n',[40]='o',[41]='p',[42]='q',[43]='r',[44]='s',[45]='t',[46]='u',[47]='v',[48]='w',[49]='x',[50]='y',[51]='z',[52]='0',[53]='1',[54]='2',[55]='3',[56]='4',[57]='5',[58]='6',[59]='7',[60]='8',[61]='9',[62]='-',[63]='_'}

function basesf.encode(data)
    local bytes = {}
    local result = ""
    for spos=0,string.len(data)-1,3 do
        for byte=1,3 do bytes[byte] = string.byte(string.sub(data,(spos+byte))) or 0 end
        result = string.format('%s%s%s%s%s',result,base64chars[basesf.rsh(bytes[1],2)],base64chars[basesf.lor(basesf.lsh((bytes[1] % 4),4), basesf.rsh(bytes[2],4))] or "=",((#data-spos) > 1) and base64chars[basesf.lor(basesf.lsh(bytes[2] % 16,2), basesf.rsh(bytes[3],6))] or "=",((#data-spos) > 2) and base64chars[(bytes[3] % 64)] or "=")
    end
    return result
end

local base64bytes = {['A']=0,['B']=1,['C']=2,['D']=3,['E']=4,['F']=5,['G']=6,['H']=7,['I']=8,['J']=9,['K']=10,['L']=11,['M']=12,['N']=13,['O']=14,['P']=15,['Q']=16,['R']=17,['S']=18,['T']=19,['U']=20,['V']=21,['W']=22,['X']=23,['Y']=24,['Z']=25,['a']=26,['b']=27,['c']=28,['d']=29,['e']=30,['f']=31,['g']=32,['h']=33,['i']=34,['j']=35,['k']=36,['l']=37,['m']=38,['n']=39,['o']=40,['p']=41,['q']=42,['r']=43,['s']=44,['t']=45,['u']=46,['v']=47,['w']=48,['x']=49,['y']=50,['z']=51,['0']=52,['1']=53,['2']=54,['3']=55,['4']=56,['5']=57,['6']=58,['7']=59,['8']=60,['9']=61,['-']=62,['_']=63,['=']=nil}
function basesf.decode(data)
    local chars = {}
    local result=""
    for dpos=0,string.len(data)-1,4 do
        for char=1,4 do chars[char] = base64bytes[(string.sub(data,(dpos+char),(dpos+char)) or "=")] end
        result = string.format('%s%s%s%s',result,string.char(basesf.lor(basesf.lsh(chars[1],2), basesf.rsh(chars[2],4))),(chars[3] ~= nil) and string.char(basesf.lor(basesf.lsh(chars[2],4), basesf.rsh(chars[3],2))) or "",(chars[4] ~= nil) and string.char(basesf.lor(basesf.lsh(chars[3],6) % 192, (chars[4]))) or "")
    end
    return result
end

function require(path)
    aa = aa or {}
    if fs.exists(path) then
        a = fs.open(path, "r")
    else
        a = http.get(textutils.urlEncode(tostring(path)))
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

imgColours = {
    "white",
    "orange",
    "magenta",
    "lightBlue",
    "yellow",
    "lime",
    "pink",
    "grey",
    "lightGrey",
    "cyan",
    "purple",
    "blue",
    "brown",
    "green",
    "red",
    "black",
}



function image.draw(tablename, intx, inty)
    if tablename then
        if type(tablename) == "table" then
            for k1, v1 in ipairs(tablename) do
                for k2, v2 in ipairs(tablename[k1]) do
                    local bc = v2:sub(1, 2)-9
                    local tc = v2:sub(4, 5)-9
                    local char = v2:sub(7)
                    term.setBackgroundColour(colours[imgColours[bc]])
                    term.setTextColour(colours[imgColours[tc]])
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

function draw.textr(Text, Line, NextLine, Colour, BkgColour)
    local x, y = term.getSize()
    if Colour and BkgColour then
        col.set(Colour, BkgColour)
    end
    local n = Text:len()
    local xpos = 51 - n + 1
    term.setCursorPos(xpos, Line)
    term.write(Text)
    if NextLine then
        term.setCursorPos(1, NextLine)
    end
    if Colour then
        col.reset(Colour, BkgColour)
    end
    return true
end

function draw.textl(Text, Line, NextLine, Colour, BkgColour)
    term.setCursorPos(1, Line)
    if Colour then
        col.set(Colour, BkgColour)
    end
    term.write(Text)
    if NextLine then
        term.setCursorPos(1, NextLine)
    end
    if Colour then
        col.reset(Colour, BkgColour)
    end
    return true
end

function draw.textc(Text, Line, NextLine, Color, BkgColor)
    local x, y = term.getSize()
    tlen = Text:len()
    newx = 51 - tlen
    x = newx / 2 + 1
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

function misc.locate()
    local req = http.post("https://ccsystems.dannysmc.com/ccsystems.php", "ccsys=misc&cccmd=locate")
    req = textutils.unserialize(req.readAll())
    return req
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

function misc.irltimezones()
    local req = http.post("https://ccsystems.dannysmc.com/ccsystems.php", "ccsys=misc&cccmd=irltimezones")
    assert(type(req) == "table")
    req = textutils.unserialize(req.readAll())
    return req
end

function misc.irltime(zone)
    url = "https://ccsystems.dannysmc.com/ccsystems.php"
    querystring = "ccsys=misc&cccmd=irltime"
    local req = http.post(url, querystring)
    assert(type(req) == "table")
    return textutils.unserialize(req.readAll())
end

function misc.irltimeauto()
    url = "https://ccsystems.dannysmc.com/ccsystems.php"
    querystring = "ccsys=misc&cccmd=irltimeauto"
    local req = http.post(url, querystring)
    assert(type(req) == "table")
    return textutils.unserialize(req.readAll())
end

function misc.irltimeasync(zone)
    url = "https://ccsystems.dannysmc.com/ccsystems.php"
    querystring = "ccsys=misc&cccmd=irltime"
    local req = http.request(url, querystring)
end

function misc.time()
    local nTime = textutils.formatTime(os.time(), true)
    if string.len(nTime) == 4 then
        nTime = "0"..nTime
    end
    os.startTimer(1)
    return nTime
end

function misc.irltimeformat(time, format)
    tFormats = {year="Y", month="m", day="d", seconds="s", minutes="i", hours="H"}
    local l = {}
    for i=1, #format do
        table.insert(l, format:sub(i,i))
    end
    newtime = ""
    for _,v in ipairs(l) do
        for n,k in pairs(tFormats) do
            if v == k then
                --print(newtime)
                print(time[n])
                newtime = newtime..""..time[n]
            else
                newtime = newtime..""..v
            end
        end
    end
    return newtime
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

function data.convertTable(tData)
    local res = {}; 
    for k, v in pairs(t) do 
        res[#res + 1] = textutils.urlEncode(tostring(k) .. "=" .. tostring(v)) 
    end
    str = table.concat(res, "&")
    str = str:gsub("%%3D", "=")
    return str
end

function convert.split(str, delimiter)
    local result = { }
    local from = 1
    local delim_from, delim_to = string.find( str, delimiter, from )
    while delim_from do
        table.insert( result, string.sub( str, from , delim_from-1 ) )
        from = delim_to + 1
        delim_from, delim_to = string.find( str, delimiter, from )
    end
    table.insert( result, string.sub( str, from  ) )
    return result
end

function convert.toBits(num)
    local t={}
    while num>0 do
        rest=math.fmod(num,2)
        t[#t+1]=rest
        num=(num-rest)/2
    end
    return t
end

function convert.makeEight( t )
    return ("0"):rep( 8 - #t ) .. t
end

function convert.txttobin( txt2 )
    local txt = ""
    for i=1, #txt2 do
            txt = txt .. convert.makeEight( table.concat( convert.toBits( string.byte( txt2:sub( i, i ) ) ) ):reverse() )
            sleep(0)
    end
    return txt
end

function convert.bintotxt( txt )
    local txt2 = ""
    local t = convert.split( txt, "\n" )
    for k, v in pairs( t ) do
        q = 1
        for i=1, #v / 8 do
            txt2 = txt2 .. string.char( tonumber( v:sub( q, q + 7), 2 ) )
            q = q + 8
        end
        sleep(0)
    end
    return txt2
end

function transmit.send(id, strdata, protocol)
    -- This is just a more safer way to send data using binary, base64 encoding, it isn't super safe, but it is a lot safer than normal rednet, if possible I would suggest using my given ECHHE_RSA system for sharing id's and use RC4 (Arc4) or RES 128 GCM for transfering, this kind of system protects from simple eaves dropping.
    strdata1 = basesf.encode(strdata)
    strdata2 = convert.txttobin(strdata)
    if type(id) == "string" then
        id = tonumber(id)
    end
    if protocol then
        rednet.send(id, strdata2, protocol)
        return true
    else
        rednet.send(id, strdata2)
        return true
    end
end

function transmit.sendmulti(tID, strdata, protocol)
    -- Firstly iterate over ID's and make sure they are a number type
    for i=1, #tID do
        if type(tID[i]) == "string" then
            tID[i] = tonumber(tID[i])
        end
    end
    -- Encode data
    strdata1 = basesf.encode(strdata)
    strdata2 = convert.txttobin(strdata)
    for i=1, #tID do
        if protocol then
            rednet.send(tID[i], strdata2, protocol)
        else
            rednet.send(tID[i], strdata2)
        end
    end
    return true, #tID
end

function transmit.broadcast(strdata, protocol)
    strdata1 = basesf.encode(strdata)
    strdata2 = convert.txttobin(strdata)
    if protocol then
        rednet.broadcast(strdata2, protocol)
        return true
    else
        rednet.broadcast(strdata2)
        return true
    end
end

function transmit.receive(timeout, protocol)
    if timeout == "" then
        timeout = nil
    end
    if protocol == "" then
        protocol = nil
    end
    if timeout then
        id, msg2, protocol1 = rednet.receive(timeout)
    else
        id, msg2, protocol1 = rednet.receive()
    end
    if protocol1 then
        if protocol1 == protocol then
            msg1 = basesf.decode(msg2)
            msg = convert.bintotxt(msg1)
            return id, msg, protocol1
        end
    end
end

function parse.html(strtoparse)
    entity = {
      nbsp = " ",
      lt = "<",
      gt = ">",
      quot = "\"",
      amp = "&",
    }

    -- keep unknown entity as is
    setmetatable(entity, {
      __index = function (t, key)
        return "&" .. key .. ";"
      end
    })

    block = {
      "address",
      "blockquote",
      "center",
      "dir", "div", "dl",
      "fieldset", "form",
      "h1", "h2", "h3", "h4", "h5", "h6", "hr", 
      "isindex",
      "menu",
      "noframes",
      "ol",
      "p",
      "pre",
      "table",
      "ul",
    }

    inline = {
      "a", "abbr", "acronym", "applet",
      "b", "basefont", "bdo", "big", "br", "button",
      "cite", "code",
      "dfn",
      "em",
      "font",
      "i", "iframe", "img", "input",
      "kbd",
      "label",
      "map",
      "object",
      "q",
      "s", "samp", "select", "small", "span", "strike", "strong", "sub", "sup",
      "textarea", "tt",
      "u",
      "var",
    }

    tags = {
      a = { empty = false },
      abbr = {empty = false} ,
      acronym = {empty = false} ,
      address = {empty = false} ,
      applet = {empty = false} ,
      area = {empty = true} ,
      b = {empty = false} ,
      base = {empty = true} ,
      basefont = {empty = true} ,
      bdo = {empty = false} ,
      big = {empty = false} ,
      blockquote = {empty = false} ,
      body = { empty = false, },
      br = {empty = true} ,
      button = {empty = false} ,
      caption = {empty = false} ,
      center = {empty = false} ,
      cite = {empty = false} ,
      code = {empty = false} ,
      col = {empty = true} ,
      colgroup = {
        empty = false,
        optional_end = true,
        child = {"col",},
      },
      dd = {empty = false} ,
      del = {empty = false} ,
      dfn = {empty = false} ,
      dir = {empty = false} ,
      div = {empty = false} ,
      dl = {empty = false} ,
      dt = {
        empty = false,
        optional_end = true,
        child = {
          inline,
          "del",
          "ins",
          "noscript",
          "script",
        },
      },
      em = {empty = false} ,
      fieldset = {empty = false} ,
      font = {empty = false} ,
      form = {empty = false} ,
      frame = {empty = true} ,
      frameset = {empty = false} ,
      h1 = {empty = false} ,
      h2 = {empty = false} ,
      h3 = {empty = false} ,
      h4 = {empty = false} ,
      h5 = {empty = false} ,
      h6 = {empty = false} ,
      head = {empty = false} ,
      hr = {empty = true} ,
      html = {empty = false} ,
      i = {empty = false} ,
      iframe = {empty = false} ,
      img = {empty = true} ,
      input = {empty = true} ,
      ins = {empty = false} ,
      isindex = {empty = true} ,
      kbd = {empty = false} ,
      label = {empty = false} ,
      legend = {empty = false} ,
      li = {
        empty = false,
        optional_end = true,
        child = {
          inline,
          block,
          "del",
          "ins",
          "noscript",
          "script",
        },
      },
      link = {empty = true} ,
      map = {empty = false} ,
      menu = {empty = false} ,
      meta = {empty = true} ,
      noframes = {empty = false} ,
      noscript = {empty = false} ,
      object = {empty = false} ,
      ol = {empty = false} ,
      optgroup = {empty = false} ,
      option = {
        empty = false,
        optional_end = true,
        child = {},
      },
      p = {
        empty = false,
        optional_end = true,
        child = {
          inline,
          "del",
          "ins",
          "noscript",
          "script",
        },
      } ,
      param = {empty = true} ,
      pre = {empty = false} ,
      q = {empty = false} ,
      s =  {empty = false} ,
      samp = {empty = false} ,
      script = {empty = false} ,
      select = {empty = false} ,
      small = {empty = false} ,
      span = {empty = false} ,
      strike = {empty = false} ,
      strong = {empty = false} ,
      style = {empty = false} ,
      sub = {empty = false} ,
      sup = {empty = false} ,
      table = {empty = false} ,
      tbody = {empty = false} ,
      td = {
        empty = false,
        optional_end = true,
        child = {
          inline,
          block,
          "del",
          "ins",
          "noscript",
          "script",
        },
      },
      textarea = {empty = false} ,
      tfoot = {
        empty = false,
        optional_end = true,
        child = {"tr",},
      },
      th = {
        empty = false,
        optional_end = true,
        child = {
          inline,
          block,
          "del",
          "ins",
          "noscript",
          "script",
        },
      },
      thead = {
        empty = false,
        optional_end = true,
        child = {"tr",},
      },
      title = {empty = false} ,
      tr = {
        empty = false,
        optional_end = true,
        child = {
          "td", "th",
        },
      },
      tt = {empty = false} ,
      u = {empty = false} ,
      ul = {empty = false} ,
      var = {empty = false} ,
    }

    setmetatable(tags, {
      __index = function (t, key)
        return {empty = false}
      end
    })

    -- string buffer implementation
    function newbuf ()
      local buf = {
        _buf = {},
        clear =   function (self) self._buf = {}; return self end,
        content = function (self) return table.concat(self._buf) end,
        append =  function (self, s)
          self._buf[#(self._buf) + 1] = s
          return self
        end,
        set =     function (self, s) self._buf = {s}; return self end,
      }
      return buf
    end

    -- unescape character entities
    function unescape (s)
      function entity2string (e)
        return entity[e]
      end
      return s.gsub(s, "&(#?%w+);", entity2string)
    end

    -- iterator factory
    function makeiter (f)
      local co = coroutine.create(f)
      return function ()
        local code, res = coroutine.resume(co)
        return res
      end
    end

    -- constructors for token
    function Tag (s) 
      return string.find(s, "^</") and
        {type = "End",   value = s} or
        {type = "Start", value = s}
    end

    function Text (s)
      local unescaped = unescape(s) 
      return {type = "Text", value = unescaped} 
    end

    -- lexer: text mode
    function text (f, buf)
      local c = f:read(1)
      if c == "<" then
        if buf:content() ~= "" then coroutine.yield(Text(buf:content())) end
        buf:set(c)
        return tag(f, buf)
      elseif c then
        buf:append(c)
        return text(f, buf)
      else
        if buf:content() ~= "" then coroutine.yield(Text(buf:content())) end
      end
    end

    -- lexer: tag mode
    function tag (f, buf)
      local c = f:read(1)
      if c == ">" then
        coroutine.yield(Tag(buf:append(c):content()))
        buf:clear()
        return text(f, buf)
      elseif c then
        buf:append(c)
        return tag(f, buf)
      else
        if buf:content() ~= "" then coroutine.yield(Tag(buf:content())) end
      end
    end

    function parse_starttag(tag)
      local tagname = string.match(tag, "<%s*(%w+)")
      local elem = {_attr = {}}
      elem._tag = tagname
      for key, _, val in string.gmatch(tag, "(%w+)%s*=%s*([\"'])(.-)%2", i) do
        local unescaped = unescape(val)
        elem._attr[key] = unescaped
      end
      return elem
    end

    function parse_endtag(tag)
      local tagname = string.match(tag, "<%s*/%s*(%w+)")
      return tagname
    end

    -- find last element that satisfies given predicate
    function rfind(t, pred)
      local length = #t
      for i=length,1,-1 do
        if pred(t[i]) then
          return i, t[i]
        end
      end
    end

    function flatten(t, acc)
      acc = acc or {}
      for i,v in ipairs(t) do
        if type(v) == "table" then
          flatten(v, acc)
        else
          acc[#acc + 1] = v
        end
      end
      return acc
    end

    function optional_end_p(elem)
      if tags[elem._tag].optional_end then
        return true
      else
        return false
      end
    end

    function valid_child_p(child, parent)
      local schema = tags[parent._tag].child
      if not schema then return true end

      for i,v in ipairs(flatten(schema)) do
        sleep(0)
        if v == child._tag then
          return true
        end
      end

      return false
    end

    -- tree builder
    function parse(f)
    sleep(0)
      local root = {_tag = "#document", _attr = {}}
      local stack = {root}
      for i in makeiter(function () return text(f, newbuf()) end) do
        if i.type == "Start" then
          local new = parse_starttag(i.value)
          local top = stack[#stack]

          while
            top._tag ~= "#document" and 
            optional_end_p(top) and
            not valid_child_p(new, top)
          do
            stack[#stack] = nil 
            top = stack[#stack]
            sleep(0)
          end

          top[#top+1] = new -- appendchild
          if not tags[new._tag].empty then 
            stack[#stack+1] = new -- push
          end
        elseif i.type == "End" then
          local tag = parse_endtag(i.value)
          local openingpos = rfind(stack, function(v) 
              if v._tag == tag then
                return true
              else
                return false
              end
            end)
          if openingpos then
            local length = #stack
            for j=length,openingpos,-1 do
              table.remove(stack, j)
            end
          end
        else -- Text
          local top = stack[#stack]
          top[#top+1] = i.value
        end
      end
      return root
    end

    function parsestr(s)
      local handle = {
        _content = s,
        _pos = 1,
        read = function (self, length)
          if self._pos > string.len(self._content) then return end
          local ret = string.sub(self._content, self._pos, self._pos + length - 1)
          self._pos = self._pos + length
          return ret
        end
      }
      return parse(handle)
    end

    return parsestr(strtoparse)
end

local function _W(f) local e=setmetatable({}, {__index = getfenv()}) return setfenv(f,e)() or e end
bit=_W(function()
--[[
    This bit API is designed to cope with unsigned integers instead of normal integers

    To do this we
]]

local floor = math.floor

local bit_band, bit_bxor = bit.band, bit.bxor
local function band(a, b)
    if a > 2147483647 then a = a - 4294967296 end
    if b > 2147483647 then b = b - 4294967296 end
    return bit_band(a, b)
end

local function bxor(a, b)
    if a > 2147483647 then a = a - 4294967296 end
    if b > 2147483647 then b = b - 4294967296 end
    return bit_bxor(a, b)
end

local lshift, rshift

rshift = function(a,disp)
    return floor(a % 4294967296 / 2^disp)
end

lshift = function(a,disp)
    return (a * 2^disp) % 4294967296
end

return {
    -- bit operations
    bnot = bit.bnot,
    band = band,
    bor  = bit.bor,
    bxor = bxor,
    rshift = rshift,
    lshift = lshift,
}
end)
gf=_W(function()
-- finite field with base 2 and modulo irreducible polynom x^8+x^4+x^3+x+1 = 0x11d
local bxor = bit.bxor
local lshift = bit.lshift

-- private data of gf
local n = 0x100
local ord = 0xff
local irrPolynom = 0x11b
local exp = {}
local log = {}

--
-- add two polynoms (its simply xor)
--
local function add(operand1, operand2)
    return bxor(operand1,operand2)
end

--
-- subtract two polynoms (same as addition)
--
local function sub(operand1, operand2)
    return bxor(operand1,operand2)
end

--
-- inverts element
-- a^(-1) = g^(order - log(a))
--
local function invert(operand)
    -- special case for 1
    if (operand == 1) then
        return 1
    end
    -- normal invert
    local exponent = ord - log[operand]
    return exp[exponent]
end

--
-- multiply two elements using a logarithm table
-- a*b = g^(log(a)+log(b))
--
local function mul(operand1, operand2)
    if (operand1 == 0 or operand2 == 0) then
        return 0
    end

    local exponent = log[operand1] + log[operand2]
    if (exponent >= ord) then
        exponent = exponent - ord
    end
    return  exp[exponent]
end

--
-- divide two elements
-- a/b = g^(log(a)-log(b))
--
local function div(operand1, operand2)
    if (operand1 == 0)  then
        return 0
    end
    -- TODO: exception if operand2 == 0
    local exponent = log[operand1] - log[operand2]
    if (exponent < 0) then
        exponent = exponent + ord
    end
    return exp[exponent]
end

--
-- print logarithmic table
--
local function printLog()
    for i = 1, n do
        print("log(", i-1, ")=", log[i-1])
    end
end

--
-- print exponentiation table
--
local function printExp()
    for i = 1, n do
        print("exp(", i-1, ")=", exp[i-1])
    end
end

--
-- calculate logarithmic and exponentiation table
--
local function initMulTable()
    local a = 1

    for i = 0,ord-1 do
        exp[i] = a
        log[a] = i

        -- multiply with generator x+1 -> left shift + 1
        a = bxor(lshift(a, 1), a)

        -- if a gets larger than order, reduce modulo irreducible polynom
        if a > ord then
            a = sub(a, irrPolynom)
        end
    end
end

initMulTable()

return {
    add = add,
    sub = sub,
    invert = invert,
    mul = mul,
    div = dib,
    printLog = printLog,
    printExp = printExp,
}
end)
util=_W(function()
-- Cache some bit operators
local bxor = bit.bxor
local rshift = bit.rshift
local band = bit.band
local lshift = bit.lshift

local sleepCheckIn
--
-- calculate the parity of one byte
--
local function byteParity(byte)
    byte = bxor(byte, rshift(byte, 4))
    byte = bxor(byte, rshift(byte, 2))
    byte = bxor(byte, rshift(byte, 1))
    return band(byte, 1)
end

--
-- get byte at position index
--
local function getByte(number, index)
    if (index == 0) then
        return band(number,0xff)
    else
        return band(rshift(number, index*8),0xff)
    end
end


--
-- put number into int at position index
--
local function putByte(number, index)
    if (index == 0) then
        return band(number,0xff)
    else
        return lshift(band(number,0xff),index*8)
    end
end

--
-- convert byte array to int array
--
local function bytesToInts(bytes, start, n)
    local ints = {}
    for i = 0, n - 1 do
        ints[i] = putByte(bytes[start + (i*4)    ], 3)
                + putByte(bytes[start + (i*4) + 1], 2)
                + putByte(bytes[start + (i*4) + 2], 1)
                + putByte(bytes[start + (i*4) + 3], 0)

        if n % 10000 == 0 then sleepCheckIn() end
    end
    return ints
end

--
-- convert int array to byte array
--
local function intsToBytes(ints, output, outputOffset, n)
    n = n or #ints
    for i = 0, n do
        for j = 0,3 do
            output[outputOffset + i*4 + (3 - j)] = getByte(ints[i], j)
        end

        if n % 10000 == 0 then sleepCheckIn() end
    end
    return output
end

--
-- convert bytes to hexString
--
local function bytesToHex(bytes)
    local hexBytes = ""

    for i,byte in ipairs(bytes) do
        hexBytes = hexBytes .. string.format("%02x ", byte)
    end

    return hexBytes
end

--
-- convert data to hex string
--
local function toHexString(data)
    local type = type(data)
    if (type == "number") then
        return string.format("%08x",data)
    elseif (type == "table") then
        return bytesToHex(data)
    elseif (type == "string") then
        local bytes = {string.byte(data, 1, #data)}

        return bytesToHex(bytes)
    else
        return data
    end
end

local function padByteString(data)
    local dataLength = #data

    local random1 = math.random(0,255)
    local random2 = math.random(0,255)

    local prefix = string.char(random1,
                               random2,
                               random1,
                               random2,
                               getByte(dataLength, 3),
                               getByte(dataLength, 2),
                               getByte(dataLength, 1),
                               getByte(dataLength, 0))

    data = prefix .. data

    local paddingLength = math.ceil(#data/16)*16 - #data
    local padding = ""
    for i=1,paddingLength do
        padding = padding .. string.char(math.random(0,255))
    end

    return data .. padding
end

local function properlyDecrypted(data)
    local random = {string.byte(data,1,4)}

    if (random[1] == random[3] and random[2] == random[4]) then
        return true
    end

    return false
end

local function unpadByteString(data)
    if (not properlyDecrypted(data)) then
        return nil
    end

    local dataLength = putByte(string.byte(data,5), 3)
                     + putByte(string.byte(data,6), 2)
                     + putByte(string.byte(data,7), 1)
                     + putByte(string.byte(data,8), 0)

    return string.sub(data,9,8+dataLength)
end

local function xorIV(data, iv)
    for i = 1,16 do
        data[i] = bxor(data[i], iv[i])
    end
end

-- Called every
local push, pull, time = os.queueEvent, coroutine.yield, os.time
local oldTime = time()
local function sleepCheckIn()
    local newTime = time()
    if newTime - oldTime >= 0.03 then -- (0.020 * 1.5)
        oldTime = newTime
        push("sleep")
        pull("sleep")
    end
end

local function getRandomData(bytes)
    local char, random, sleep, insert = string.char, math.random, sleepCheckIn, table.insert
    local result = {}

    for i=1,bytes do
        insert(result, random(0,255))
        if i % 10240 == 0 then sleep() end
    end

    return result
end

local function getRandomString(bytes)
    local char, random, sleep, insert = string.char, math.random, sleepCheckIn, table.insert
    local result = {}

    for i=1,bytes do
        insert(result, char(random(0,255)))
        if i % 10240 == 0 then sleep() end
    end

    return table.concat(result)
end

return {
    byteParity = byteParity,
    getByte = getByte,
    putByte = putByte,
    bytesToInts = bytesToInts,
    intsToBytes = intsToBytes,
    bytesToHex = bytesToHex,
    toHexString = toHexString,
    padByteString = padByteString,
    properlyDecrypted = properlyDecrypted,
    unpadByteString = unpadByteString,
    xorIV = xorIV,

    sleepCheckIn = sleepCheckIn,

    getRandomData = getRandomData,
    getRandomString = getRandomString,
}
end)
aes=_W(function()
-- Implementation of AES with nearly pure lua
-- AES with lua is slow, really slow :-)

local putByte = util.putByte
local getByte = util.getByte

-- some constants
local ROUNDS = 'rounds'
local KEY_TYPE = "type"
local ENCRYPTION_KEY=1
local DECRYPTION_KEY=2

-- aes SBOX
local SBox = {}
local iSBox = {}

-- aes tables
local table0 = {}
local table1 = {}
local table2 = {}
local table3 = {}

local tableInv0 = {}
local tableInv1 = {}
local tableInv2 = {}
local tableInv3 = {}

-- round constants
local rCon = {
    0x01000000,
    0x02000000,
    0x04000000,
    0x08000000,
    0x10000000,
    0x20000000,
    0x40000000,
    0x80000000,
    0x1b000000,
    0x36000000,
    0x6c000000,
    0xd8000000,
    0xab000000,
    0x4d000000,
    0x9a000000,
    0x2f000000,
}

--
-- affine transformation for calculating the S-Box of AES
--
local function affinMap(byte)
    mask = 0xf8
    result = 0
    for i = 1,8 do
        result = bit.lshift(result,1)

        parity = util.byteParity(bit.band(byte,mask))
        result = result + parity

        -- simulate roll
        lastbit = bit.band(mask, 1)
        mask = bit.band(bit.rshift(mask, 1),0xff)
        if (lastbit ~= 0) then
            mask = bit.bor(mask, 0x80)
        else
            mask = bit.band(mask, 0x7f)
        end
    end

    return bit.bxor(result, 0x63)
end

--
-- calculate S-Box and inverse S-Box of AES
-- apply affine transformation to inverse in finite field 2^8
--
local function calcSBox()
    for i = 0, 255 do
    if (i ~= 0) then
        inverse = gf.invert(i)
    else
        inverse = i
    end
        mapped = affinMap(inverse)
        SBox[i] = mapped
        iSBox[mapped] = i
    end
end

--
-- Calculate round tables
-- round tables are used to calculate shiftRow, MixColumn and SubBytes
-- with 4 table lookups and 4 xor operations.
--
local function calcRoundTables()
    for x = 0,255 do
        byte = SBox[x]
        table0[x] = putByte(gf.mul(0x03, byte), 0)
                          + putByte(             byte , 1)
                          + putByte(             byte , 2)
                          + putByte(gf.mul(0x02, byte), 3)
        table1[x] = putByte(             byte , 0)
                          + putByte(             byte , 1)
                          + putByte(gf.mul(0x02, byte), 2)
                          + putByte(gf.mul(0x03, byte), 3)
        table2[x] = putByte(             byte , 0)
                          + putByte(gf.mul(0x02, byte), 1)
                          + putByte(gf.mul(0x03, byte), 2)
                          + putByte(             byte , 3)
        table3[x] = putByte(gf.mul(0x02, byte), 0)
                          + putByte(gf.mul(0x03, byte), 1)
                          + putByte(             byte , 2)
                          + putByte(             byte , 3)
    end
end

--
-- Calculate inverse round tables
-- does the inverse of the normal roundtables for the equivalent
-- decryption algorithm.
--
local function calcInvRoundTables()
    for x = 0,255 do
        byte = iSBox[x]
        tableInv0[x] = putByte(gf.mul(0x0b, byte), 0)
                             + putByte(gf.mul(0x0d, byte), 1)
                             + putByte(gf.mul(0x09, byte), 2)
                             + putByte(gf.mul(0x0e, byte), 3)
        tableInv1[x] = putByte(gf.mul(0x0d, byte), 0)
                             + putByte(gf.mul(0x09, byte), 1)
                             + putByte(gf.mul(0x0e, byte), 2)
                             + putByte(gf.mul(0x0b, byte), 3)
        tableInv2[x] = putByte(gf.mul(0x09, byte), 0)
                             + putByte(gf.mul(0x0e, byte), 1)
                             + putByte(gf.mul(0x0b, byte), 2)
                             + putByte(gf.mul(0x0d, byte), 3)
        tableInv3[x] = putByte(gf.mul(0x0e, byte), 0)
                             + putByte(gf.mul(0x0b, byte), 1)
                             + putByte(gf.mul(0x0d, byte), 2)
                             + putByte(gf.mul(0x09, byte), 3)
    end
end


--
-- rotate word: 0xaabbccdd gets 0xbbccddaa
-- used for key schedule
--
local function rotWord(word)
    local tmp = bit.band(word,0xff000000)
    return (bit.lshift(word,8) + bit.rshift(tmp,24))
end

--
-- replace all bytes in a word with the SBox.
-- used for key schedule
--
local function subWord(word)
    return putByte(SBox[getByte(word,0)],0)
        + putByte(SBox[getByte(word,1)],1)
        + putByte(SBox[getByte(word,2)],2)
        + putByte(SBox[getByte(word,3)],3)
end

--
-- generate key schedule for aes encryption
--
-- returns table with all round keys and
-- the necessary number of rounds saved in [ROUNDS]
--
local function expandEncryptionKey(key)
    local keySchedule = {}
    local keyWords = math.floor(#key / 4)


    if ((keyWords ~= 4 and keyWords ~= 6 and keyWords ~= 8) or (keyWords * 4 ~= #key)) then
        print("Invalid key size: ", keyWords)
        return nil
    end

    keySchedule[ROUNDS] = keyWords + 6
    keySchedule[KEY_TYPE] = ENCRYPTION_KEY

    for i = 0,keyWords - 1 do
        keySchedule[i] = putByte(key[i*4+1], 3)
                       + putByte(key[i*4+2], 2)
                       + putByte(key[i*4+3], 1)
                       + putByte(key[i*4+4], 0)
    end

    for i = keyWords, (keySchedule[ROUNDS] + 1)*4 - 1 do
        local tmp = keySchedule[i-1]

        if ( i % keyWords == 0) then
            tmp = rotWord(tmp)
            tmp = subWord(tmp)

            local index = math.floor(i/keyWords)
            tmp = bit.bxor(tmp,rCon[index])
        elseif (keyWords > 6 and i % keyWords == 4) then
            tmp = subWord(tmp)
        end

        keySchedule[i] = bit.bxor(keySchedule[(i-keyWords)],tmp)
    end

    return keySchedule
end

--
-- Inverse mix column
-- used for key schedule of decryption key
--
local function invMixColumnOld(word)
    local b0 = getByte(word,3)
    local b1 = getByte(word,2)
    local b2 = getByte(word,1)
    local b3 = getByte(word,0)

    return putByte(gf.add(gf.add(gf.add(gf.mul(0x0b, b1),
                                             gf.mul(0x0d, b2)),
                                             gf.mul(0x09, b3)),
                                             gf.mul(0x0e, b0)),3)
         + putByte(gf.add(gf.add(gf.add(gf.mul(0x0b, b2),
                                             gf.mul(0x0d, b3)),
                                             gf.mul(0x09, b0)),
                                             gf.mul(0x0e, b1)),2)
         + putByte(gf.add(gf.add(gf.add(gf.mul(0x0b, b3),
                                             gf.mul(0x0d, b0)),
                                             gf.mul(0x09, b1)),
                                             gf.mul(0x0e, b2)),1)
         + putByte(gf.add(gf.add(gf.add(gf.mul(0x0b, b0),
                                             gf.mul(0x0d, b1)),
                                             gf.mul(0x09, b2)),
                                             gf.mul(0x0e, b3)),0)
end

--
-- Optimized inverse mix column
-- look at http://fp.gladman.plus.com/cryptography_technology/rijndael/aes.spec.311.pdf
-- TODO: make it work
--
local function invMixColumn(word)
    local b0 = getByte(word,3)
    local b1 = getByte(word,2)
    local b2 = getByte(word,1)
    local b3 = getByte(word,0)

    local t = bit.bxor(b3,b2)
    local u = bit.bxor(b1,b0)
    local v = bit.bxor(t,u)
    v = bit.bxor(v,gf.mul(0x08,v))
    w = bit.bxor(v,gf.mul(0x04, bit.bxor(b2,b0)))
    v = bit.bxor(v,gf.mul(0x04, bit.bxor(b3,b1)))

    return putByte( bit.bxor(bit.bxor(b3,v), gf.mul(0x02, bit.bxor(b0,b3))), 0)
         + putByte( bit.bxor(bit.bxor(b2,w), gf.mul(0x02, t              )), 1)
         + putByte( bit.bxor(bit.bxor(b1,v), gf.mul(0x02, bit.bxor(b0,b3))), 2)
         + putByte( bit.bxor(bit.bxor(b0,w), gf.mul(0x02, u              )), 3)
end

--
-- generate key schedule for aes decryption
--
-- uses key schedule for aes encryption and transforms each
-- key by inverse mix column.
--
local function expandDecryptionKey(key)
    local keySchedule = expandEncryptionKey(key)
    if (keySchedule == nil) then
        return nil
    end

    keySchedule[KEY_TYPE] = DECRYPTION_KEY

    for i = 4, (keySchedule[ROUNDS] + 1)*4 - 5 do
        keySchedule[i] = invMixColumnOld(keySchedule[i])
    end

    return keySchedule
end

--
-- xor round key to state
--
local function addRoundKey(state, key, round)
    for i = 0, 3 do
        state[i] = bit.bxor(state[i], key[round*4+i])
    end
end

--
-- do encryption round (ShiftRow, SubBytes, MixColumn together)
--
local function doRound(origState, dstState)
    dstState[0] =  bit.bxor(bit.bxor(bit.bxor(
                table0[getByte(origState[0],3)],
                table1[getByte(origState[1],2)]),
                table2[getByte(origState[2],1)]),
                table3[getByte(origState[3],0)])

    dstState[1] =  bit.bxor(bit.bxor(bit.bxor(
                table0[getByte(origState[1],3)],
                table1[getByte(origState[2],2)]),
                table2[getByte(origState[3],1)]),
                table3[getByte(origState[0],0)])

    dstState[2] =  bit.bxor(bit.bxor(bit.bxor(
                table0[getByte(origState[2],3)],
                table1[getByte(origState[3],2)]),
                table2[getByte(origState[0],1)]),
                table3[getByte(origState[1],0)])

    dstState[3] =  bit.bxor(bit.bxor(bit.bxor(
                table0[getByte(origState[3],3)],
                table1[getByte(origState[0],2)]),
                table2[getByte(origState[1],1)]),
                table3[getByte(origState[2],0)])
end

--
-- do last encryption round (ShiftRow and SubBytes)
--
local function doLastRound(origState, dstState)
    dstState[0] = putByte(SBox[getByte(origState[0],3)], 3)
                + putByte(SBox[getByte(origState[1],2)], 2)
                + putByte(SBox[getByte(origState[2],1)], 1)
                + putByte(SBox[getByte(origState[3],0)], 0)

    dstState[1] = putByte(SBox[getByte(origState[1],3)], 3)
                + putByte(SBox[getByte(origState[2],2)], 2)
                + putByte(SBox[getByte(origState[3],1)], 1)
                + putByte(SBox[getByte(origState[0],0)], 0)

    dstState[2] = putByte(SBox[getByte(origState[2],3)], 3)
                + putByte(SBox[getByte(origState[3],2)], 2)
                + putByte(SBox[getByte(origState[0],1)], 1)
                + putByte(SBox[getByte(origState[1],0)], 0)

    dstState[3] = putByte(SBox[getByte(origState[3],3)], 3)
                + putByte(SBox[getByte(origState[0],2)], 2)
                + putByte(SBox[getByte(origState[1],1)], 1)
                + putByte(SBox[getByte(origState[2],0)], 0)
end

--
-- do decryption round
--
local function doInvRound(origState, dstState)
    dstState[0] =  bit.bxor(bit.bxor(bit.bxor(
                tableInv0[getByte(origState[0],3)],
                tableInv1[getByte(origState[3],2)]),
                tableInv2[getByte(origState[2],1)]),
                tableInv3[getByte(origState[1],0)])

    dstState[1] =  bit.bxor(bit.bxor(bit.bxor(
                tableInv0[getByte(origState[1],3)],
                tableInv1[getByte(origState[0],2)]),
                tableInv2[getByte(origState[3],1)]),
                tableInv3[getByte(origState[2],0)])

    dstState[2] =  bit.bxor(bit.bxor(bit.bxor(
                tableInv0[getByte(origState[2],3)],
                tableInv1[getByte(origState[1],2)]),
                tableInv2[getByte(origState[0],1)]),
                tableInv3[getByte(origState[3],0)])

    dstState[3] =  bit.bxor(bit.bxor(bit.bxor(
                tableInv0[getByte(origState[3],3)],
                tableInv1[getByte(origState[2],2)]),
                tableInv2[getByte(origState[1],1)]),
                tableInv3[getByte(origState[0],0)])
end

--
-- do last decryption round
--
local function doInvLastRound(origState, dstState)
    dstState[0] = putByte(iSBox[getByte(origState[0],3)], 3)
                + putByte(iSBox[getByte(origState[3],2)], 2)
                + putByte(iSBox[getByte(origState[2],1)], 1)
                + putByte(iSBox[getByte(origState[1],0)], 0)

    dstState[1] = putByte(iSBox[getByte(origState[1],3)], 3)
                + putByte(iSBox[getByte(origState[0],2)], 2)
                + putByte(iSBox[getByte(origState[3],1)], 1)
                + putByte(iSBox[getByte(origState[2],0)], 0)

    dstState[2] = putByte(iSBox[getByte(origState[2],3)], 3)
                + putByte(iSBox[getByte(origState[1],2)], 2)
                + putByte(iSBox[getByte(origState[0],1)], 1)
                + putByte(iSBox[getByte(origState[3],0)], 0)

    dstState[3] = putByte(iSBox[getByte(origState[3],3)], 3)
                + putByte(iSBox[getByte(origState[2],2)], 2)
                + putByte(iSBox[getByte(origState[1],1)], 1)
                + putByte(iSBox[getByte(origState[0],0)], 0)
end

--
-- encrypts 16 Bytes
-- key           encryption key schedule
-- input         array with input data
-- inputOffset   start index for input
-- output        array for encrypted data
-- outputOffset  start index for output
--
local function encrypt(key, input, inputOffset, output, outputOffset)
    --default parameters
    inputOffset = inputOffset or 1
    output = output or {}
    outputOffset = outputOffset or 1

    local state = {}
    local tmpState = {}

    if (key[KEY_TYPE] ~= ENCRYPTION_KEY) then
        print("No encryption key: ", key[KEY_TYPE])
        return
    end

    state = util.bytesToInts(input, inputOffset, 4)
    addRoundKey(state, key, 0)

    local checkIn = util.sleepCheckIn

    local round = 1
    while (round < key[ROUNDS] - 1) do
        -- do a double round to save temporary assignments
        doRound(state, tmpState)
        addRoundKey(tmpState, key, round)
        round = round + 1

        doRound(tmpState, state)
        addRoundKey(state, key, round)
        round = round + 1
    end

    checkIn()

    doRound(state, tmpState)
    addRoundKey(tmpState, key, round)
    round = round +1

    doLastRound(tmpState, state)
    addRoundKey(state, key, round)

    return util.intsToBytes(state, output, outputOffset)
end

--
-- decrypt 16 bytes
-- key           decryption key schedule
-- input         array with input data
-- inputOffset   start index for input
-- output        array for decrypted data
-- outputOffset  start index for output
---
local function decrypt(key, input, inputOffset, output, outputOffset)
    -- default arguments
    inputOffset = inputOffset or 1
    output = output or {}
    outputOffset = outputOffset or 1

    local state = {}
    local tmpState = {}

    if (key[KEY_TYPE] ~= DECRYPTION_KEY) then
        print("No decryption key: ", key[KEY_TYPE])
        return
    end

    state = util.bytesToInts(input, inputOffset, 4)
    addRoundKey(state, key, key[ROUNDS])

    local checkIn = util.sleepCheckIn

    local round = key[ROUNDS] - 1
    while (round > 2) do
        -- do a double round to save temporary assignments
        doInvRound(state, tmpState)
        addRoundKey(tmpState, key, round)
        round = round - 1

        doInvRound(tmpState, state)
        addRoundKey(state, key, round)
        round = round - 1

        if round % 32 == 0 then
            checkIn()
        end
    end

    checkIn()

    doInvRound(state, tmpState)
    addRoundKey(tmpState, key, round)
    round = round - 1

    doInvLastRound(tmpState, state)
    addRoundKey(state, key, round)

    return util.intsToBytes(state, output, outputOffset)
end

-- calculate all tables when loading this file
calcSBox()
calcRoundTables()
calcInvRoundTables()

return {
    ROUNDS = ROUNDS,
    KEY_TYPE = KEY_TYPE,
    ENCRYPTION_KEY = ENCRYPTION_KEY,
    DECRYPTION_KEY = DECRYPTION_KEY,

    expandEncryptionKey = expandEncryptionKey,
    expandDecryptionKey = expandDecryptionKey,
    encrypt = encrypt,
    decrypt = decrypt,
}
end)
buffer=_W(function()
local function new ()
    return {}
end

local function addString (stack, s)
    table.insert(stack, s)
    for i = #stack - 1, 1, -1 do
        if #stack[i] > #stack[i+1] then
                break
        end
        stack[i] = stack[i] .. table.remove(stack)
    end
end

local function toString (stack)
    for i = #stack - 1, 1, -1 do
        stack[i] = stack[i] .. table.remove(stack)
    end
    return stack[1]
end

return {
    new = new,
    addString = addString,
    toString = toString,
}
end)
ciphermode=_W(function()
local public = {}

--
-- Encrypt strings
-- key - byte array with key
-- string - string to encrypt
-- modefunction - function for cipher mode to use
--
function public.encryptString(key, data, modeFunction)
    local iv = iv or {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0}
    local keySched = aes.expandEncryptionKey(key)
    local encryptedData = buffer.new()

    for i = 1, #data/16 do
        local offset = (i-1)*16 + 1
        local byteData = {string.byte(data,offset,offset +15)}

        modeFunction(keySched, byteData, iv)

        buffer.addString(encryptedData, string.char(unpack(byteData)))
    end

    return buffer.toString(encryptedData)
end

--
-- the following 4 functions can be used as
-- modefunction for encryptString
--

-- Electronic code book mode encrypt function
function public.encryptECB(keySched, byteData, iv)
    aes.encrypt(keySched, byteData, 1, byteData, 1)
end

-- Cipher block chaining mode encrypt function
function public.encryptCBC(keySched, byteData, iv)
    util.xorIV(byteData, iv)

    aes.encrypt(keySched, byteData, 1, byteData, 1)

    for j = 1,16 do
        iv[j] = byteData[j]
    end
end

-- Output feedback mode encrypt function
function public.encryptOFB(keySched, byteData, iv)
    aes.encrypt(keySched, iv, 1, iv, 1)
    util.xorIV(byteData, iv)
end

-- Cipher feedback mode encrypt function
function public.encryptCFB(keySched, byteData, iv)
    aes.encrypt(keySched, iv, 1, iv, 1)
    util.xorIV(byteData, iv)

    for j = 1,16 do
        iv[j] = byteData[j]
    end
end

--
-- Decrypt strings
-- key - byte array with key
-- string - string to decrypt
-- modefunction - function for cipher mode to use
--
function public.decryptString(key, data, modeFunction)
    local iv = iv or {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0}

    local keySched
    if (modeFunction == public.decryptOFB or modeFunction == public.decryptCFB) then
        keySched = aes.expandEncryptionKey(key)
    else
        keySched = aes.expandDecryptionKey(key)
    end

    local decryptedData = buffer.new()

    for i = 1, #data/16 do
        local offset = (i-1)*16 + 1
        local byteData = {string.byte(data,offset,offset +15)}

        iv = modeFunction(keySched, byteData, iv)

        buffer.addString(decryptedData, string.char(unpack(byteData)))
    end

    return buffer.toString(decryptedData)
end

--
-- the following 4 functions can be used as
-- modefunction for decryptString
--

-- Electronic code book mode decrypt function
function public.decryptECB(keySched, byteData, iv)

    aes.decrypt(keySched, byteData, 1, byteData, 1)

    return iv
end

-- Cipher block chaining mode decrypt function
function public.decryptCBC(keySched, byteData, iv)
    local nextIV = {}
    for j = 1,16 do
        nextIV[j] = byteData[j]
    end

    aes.decrypt(keySched, byteData, 1, byteData, 1)
    util.xorIV(byteData, iv)

    return nextIV
end

-- Output feedback mode decrypt function
function public.decryptOFB(keySched, byteData, iv)
    aes.encrypt(keySched, iv, 1, iv, 1)
    util.xorIV(byteData, iv)

    return iv
end

-- Cipher feedback mode decrypt function
function public.decryptCFB(keySched, byteData, iv)
    local nextIV = {}
    for j = 1,16 do
        nextIV[j] = byteData[j]
    end

    aes.encrypt(keySched, iv, 1, iv, 1)

    util.xorIV(byteData, iv)

    return nextIV
end

return public
end)
--@require lib/ciphermode.lua
--@require lib/util.lua
--
-- Simple API for encrypting strings.
--
AES128 = 16
AES192 = 24
AES256 = 32

ECBMODE = 1
CBCMODE = 2
OFBMODE = 3
CFBMODE = 4

local function pwToKey(password, keyLength)
    local padLength = keyLength
    if (keyLength == AES192) then
        padLength = 32
    end
    
    if (padLength > #password) then
        local postfix = ""
        for i = 1,padLength - #password do
            postfix = postfix .. string.char(0)
        end
        password = password .. postfix
    else
        password = string.sub(password, 1, padLength)
    end
    
    local pwBytes = {string.byte(password,1,#password)}
    password = ciphermode.encryptString(pwBytes, password, ciphermode.encryptCBC)
    
    password = string.sub(password, 1, keyLength)
   
    return {string.byte(password,1,#password)}
end

--
-- Encrypts string data with password password.
-- password  - the encryption key is generated from this string
-- data      - string to encrypt (must not be too large)
-- keyLength - length of aes key: 128(default), 192 or 256 Bit
-- mode      - mode of encryption: ecb, cbc(default), ofb, cfb 
--
-- mode and keyLength must be the same for encryption and decryption.
--
function aes.encrypt(password, data, keyLength, mode)
    assert(password ~= nil, "Empty password.")
    assert(password ~= nil, "Empty data.")
     
    local mode = mode or CBCMODE
    local keyLength = keyLength or AES128

    local key = pwToKey(password, keyLength)

    local paddedData = util.padByteString(data)
    
    if (mode == ECBMODE) then
        return ciphermode.encryptString(key, paddedData, ciphermode.encryptECB)
    elseif (mode == CBCMODE) then
        return ciphermode.encryptString(key, paddedData, ciphermode.encryptCBC)
    elseif (mode == OFBMODE) then
        return ciphermode.encryptString(key, paddedData, ciphermode.encryptOFB)
    elseif (mode == CFBMODE) then
        return ciphermode.encryptString(key, paddedData, ciphermode.encryptCFB)
    else
        return nil
    end
end




--
-- Decrypts string data with password password.
-- password  - the decryption key is generated from this string
-- data      - string to encrypt
-- keyLength - length of aes key: 128(default), 192 or 256 Bit
-- mode      - mode of decryption: ecb, cbc(default), ofb, cfb 
--
-- mode and keyLength must be the same for encryption and decryption.
--
function aes.decrypt(password, data, keyLength, mode)
    local mode = mode or CBCMODE
    local keyLength = keyLength or AES128

    local key = pwToKey(password, keyLength)
    
    local plain
    if (mode == ECBMODE) then
        plain = ciphermode.decryptString(key, data, ciphermode.decryptECB)
    elseif (mode == CBCMODE) then
        plain = ciphermode.decryptString(key, data, ciphermode.decryptCBC)
    elseif (mode == OFBMODE) then
        plain = ciphermode.decryptString(key, data, ciphermode.decryptOFB)
    elseif (mode == CFBMODE) then
        plain = ciphermode.decryptString(key, data, ciphermode.decryptCFB)
    end
    
    result = util.unpadByteString(plain)
    
    if (result == nil) then
        return nil
    end
    
    return result
end
return {}