local a=script_key or""if a==""then return end

-- Properly decrypted URLs
local function b(c)local d=""for e=1,#c do d=d..string.char(c[e])end return d end
local f=b({104,116,116,112,58,47,47,49,50,55,46,48,46,48,46,49,58,53,48,48,48})
local g=b({104,116,116,112,115,58,47,47,114,97,119,46,103,105,116,104,117,98,117,115,101,114,99,111,110,116,101,110,116,46,99,111,109,47,48,120,82,45,82,117,100,100,115,47,112,101,116,121,97,120,45,97,112,105,45,116,101,115,116,47,109,97,105,110,47,115,114,99,47,109,97,105,110,46,108,117,97})

local h={}
h.i=a 
h.j=f 
h.k=g

function h:l()
    local m=game:GetService("RbxAnalyticsService"):GetClientId()or"unknown"
    local n=getexecutorname and getexecutorname()or"unknown"
    return"machine_"..m.."|executor_"..n
end

function h:o()
    if not h.i:match("PXL")then return false end
    local p=h:l()
    local q,r=pcall(function()
        return game:HttpGet(h.j.."/verify?key="..h.i.."&hwid="..p)
    end)
    if not q then return false end
    local s,t=pcall(function()
        return game:GetService("HttpService"):JSONDecode(r)
    end)
    if not s then return false end
    return t.success
end

function h:u()
    local v,w=pcall(function()
        local x=game:HttpGet(h.k)
        loadstring(x)()
    end)
    return v
end

if h:o()then 
    h:u()
end
