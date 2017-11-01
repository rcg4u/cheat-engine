-- created by mgr.inz.Player

aobscanOnce = {}
aobscanOnce.savedaobscans = {}

local function trim(s)
  return s:match'^()%s*$' and '' or s:match'^%s*(.*%S)'
end

function aobscanOnce.saveaobscan(uniqueName,address)
  local t = {}
  t.address = address
  t.intAddress = tonumber(address,16)
  if address~=' 00000000' then
    t.assert = readQword(t.intAddress)
  end
  aobscanOnce.savedaobscans[uniqueName] = t
end

function aobscanOnce.AAPrologue(script,syntaxcheck)

  local params
  local regulartoo=false
  local ID=getOpenedProcessID()

  local i=0
  while i<script.Count do

    local strLower = script[i]:lower()

    if not regulartoo and (strLower:match'{$scanonce}') then regulartoo=true end

    params = strLower:match'aobscan.-once%(.*%)'
        and script[i]:match'%((.*)%)'

    if (not params) and regulartoo then
    params = strLower:match'aobscan.-%(.*%)'
        and script[i]:match'%((.*)%)'
    end

    if params then
      local name  = trim(params:match'[^,]+')
      local unique = ID..'_'..stringToMD5String(params)..'_'..name
      local t=aobscanOnce.savedaobscans[unique]

      if t==nil or t.address==' 00000000' or (readQword(t.intAddress)~=t.assert)
      then script[i] = script[i]:gsub('once%(','(')
           script.insert(i+1, 'luacall(aobscanOnce.saveaobscan("'..unique..'","'..name..'"))')
           i=i+1
      else script[i] = 'define('..name..','..t.address..')'
      end
    end
    i=i+1
  end

  -- debugging
  -- if not syntaxcheck then print(script.Text) end
end

registerAutoAssemblerPrologue(aobscanOnce.AAPrologue)

-- just for AA highlighting
--  (those commands will be handled
--   with registered AA prologue and then replaced)
registerAutoAssemblerCommand('aobscanonce', function() end)
registerAutoAssemblerCommand('aobscanmoduleonce', function() end)
registerAutoAssemblerCommand('aobscanregiononce', function() end)
