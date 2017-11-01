function restoreOrigBytes(sender)
  selectedAddress_redo = disassemblerview_getSelectedAddress(redo_dv)
  if origBytesTable[selectedAddress_redo]==nil then return end

  local bytes={}
  local start=origBytesTable[selectedAddress_redo].startaddress
  local size=origBytesTable[selectedAddress_redo].size

  --prepare subset
  for i=1,size do bytes[#bytes+1]=origBytesTable[start+i-1].byte end

  local script=string.format('%X',start)..':\r\n'..'db '..'#'..(table.concat(bytes,' #'))

  skip_myAssemblerWithRedo=true
  if not autoAssemble(script) then return nil end
  skip_myAssemblerWithRedo=false
end

skip_myAssemblerWithRedo=false
function myAssemblerWithRedo(addr,inst)

  if skip_myAssemblerWithRedo               -- forced skip?
     or
     origBytesTable[addr]~=nil   -- we already have collected orig bytes
  then return nil end

  local origsize=getInstructionSize(addr)
  local sizes={}
  local tmpVar=0

  -- get sizes of those next lines
  for i=1,20 do
    sizes[i]=getInstructionSize(addr+tmpVar)
    tmpVar=tmpVar+sizes[i]
  end

  --get bytes of those next lines
  local originalbytes=readBytes(addr,tmpVar,true)
  if originalbytes==nil then return nil end

  -- save original bytes if not already saved
  tmpVar=1
  for i=1,20 do
    for j=1,sizes[i] do
      local tmp={startaddress=addr, byte=originalbytes[tmpVar], size=sizes[i]}
      if not origBytesTable[addr+j-1] then origBytesTable[addr+j-1]=tmp end
      tmpVar=tmpVar+1
    end
    addr=addr+sizes[i]
  end

  return nil
end

getVisibleDisassembler().OnDisassembleOverride =
function (vd, a, ldd)
  if origBytesTable[a]==nil then return nil,nil end -- 100% not changed

  disAsm_redo.syntaxhighlighting=vd.syntaxhighlighting
  disAsm_redo.disassemble(a)

  local modified=false
  local startbyte=origBytesTable[a].startaddress
  local endbyte=startbyte+origBytesTable[a].size-1

  -- search for differences
  for i=startbyte,endbyte do
    if disAsm_redo.LastDisassembleData.bytes[i-origBytesTable[a].startaddress+1]~=
       origBytesTable[i].byte
    then modified=true break end
  end

  if not modified then return nil,nil end -- bytes the same, not modified

  for k,v in pairs(disAsm_redo.LastDisassembleData) do ldd[k]=v end

  ldd.opcode='  '..ldd.opcode -- add few spaces at the beginning
  return ldd.opcode,ldd.description
end

function addRedoMenuItem()
  redo_dv=getMemoryViewForm().DisassemblerView

  if redoMenuItem==nil then
   local pmenu=redo_dv.PopupMenu
   redoMenuItem=createMenuItem(pmenu)
   pmenu.Items.add(redoMenuItem)
  end
  redoMenuItem.Caption='Restore Original Bytes'
  redoMenuItem.Shortcut='Alt+R'
  redoMenuItem.OnClick=restoreOrigBytes
end

if myAssemblerWithRedo_ID==nil then myAssemblerWithRedo_ID=registerAssembler(myAssemblerWithRedo) end
if disAsm_redo==nil then disAsm_redo=createDisassembler() end
if origBytesTable==nil then origBytesTable={} end

addRedoMenuItem()