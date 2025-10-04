local a=script_key or""if a==""then return end
-- Encrypted URLs
local b=string.char(104,116,116,112,58,47,47,49,50,55,46,48,46,48,46,49,58,53,48,48,48)
local c=string.char(104,116,116,112,115,58,47,47,114,97,119,46,103,105,116,104,117,98,117,115,101,114,99,111,110,116,101,110,116,46,99,111,109,47,48,120,82,45,82,117,100,100,115,47,112,101,116,121,97,120,45,97,112,105,45,116,101,115,116,47,109,97,105,110,47,115,114,99,47,109,97,105,110,46,108,117,97)

local d={}
d.e=a 
d.f=b 
d.g=c

function d:h()
    local i=game:GetService("RbxAnalyticsService"):GetClientId()or"unknown"
    local j=getexecutorname and getexecutorname()or"unknown"
    return"machine_"..i.."|executor_"..j
end

function d:k()
    if not d.e:match("PXL")then return false end
    local l=d:h()
    local m,n=pcall(function()
        return game:HttpGet(d.f.."/verify?key="..d.e.."&hwid="..l)
    end)
    if not m then return false end
    local o,p=pcall(function()
        return game:GetService("HttpService"):JSONDecode(n)
    end)
    if not o then return false end
    return p.success
end

function d:q()
    local r,s=pcall(function()
        local t=game:HttpGet(d.g)
        loadstring(t)()
    end)
    return r
end

if d:k()then 
    d:q()
end
