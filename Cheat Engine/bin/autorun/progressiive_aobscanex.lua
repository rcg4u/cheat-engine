local UID,fmt = function ()
  if type(_uidcounter)~='number' then _uidcounter=math.random(0xfffff,0x1fffff)end
  _uidcounter = _uidcounter + 1
  return _uidcounter
end, string.format

local function aa_aobScanEx(s,sc)
  local scanType,sym,param = 'Region',s:match"^%s*([_%a.][_%w.#:]*)%s*,%s*(.-)%s*$"
  if not sym then return nil, "No symbol in : "..s end
  if sym:find":" then
    local symbol,scantype = sym:match"^([_%a.][_%w.#]*)%s*:%s*([_%w.#]*)$"
    if not symbol then
      return nil,"Want to define a scan type, but not specified :"..s
    else
      sym,scanType = symbol,scantype
    end
  end
  local marker,result = fmt("%s_%X",sym,UID())
  if not sc and readInteger(process) and autoAssemble(fmt([[
    aobscan%s(%s,%s)
    registersymbol(%s)
]],scanType,marker,param,marker)) and readInteger(marker) then
    result = GetAddress(marker)
    unregisterSymbol(marker)
  elseif not sc and readInteger(process) then
    return nil,'no result :'..s
  end
  return fmt("define(%s,%X)",sym,result or 0x666)
end

function resetAobScanEx(newFunction)
  unregisterAutoAssemblerCommand('aobScanEx')
  registerAutoAssemblerCommand('aobScanEx',newFunction or aa_aobScanEx)
end
resetAobScanEx()