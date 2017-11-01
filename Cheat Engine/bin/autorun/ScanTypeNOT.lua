ScanTypeNOT = {}

function ScanTypeNOT.injectAAScript()

  local CEVer = getCEVersion()
  local is64bit = cheatEngineIs64Bit()
  if not (CEVer>=6.4 and CEVer<=6.51) then return false end

  if CEVer==6.4  then VariableTypeOffset=is64bit and '1D9' or '131'
                 else VariableTypeOffset=is64bit and '1F9' or '149' end

  local script,AOB32bit='',''

  if is64bit then -- now handle 64bit versions,

    -- it works for 64bit CE6.4, 6.5 and 6.5.1
    script = [[
aobscanmodule(address,cheatengine-x86_64.exe,48 8B 45 F8 48 8D 88 00 01 00 00 48)
alloc(newmem,$1000,cheatengine-x86_64.exe)
label(code)
label(return)
label(OrigCheckRoutine)
label(CheckRoutine)
label(NOTSCAN_Enabled)
registersymbol(NOTSCAN_Enabled)
newmem:
OrigCheckRoutine:
  dq 0
NOTSCAN_Enabled:
  dd 0
CheckRoutine:
  lea rsp,[rsp-28]
  call [OrigCheckRoutine]
  lea rsp,[rsp+28]
  xor al,01
  ret
code:
  mov rax,[rbp-08]
  cmp [NOTSCAN_Enabled],0    // alter it?
  je @f

  mov cl,[rax+VariableTypeOffset] // only for certain VariableType, not for below types
  sub cl,06       // 6 vtString
  jz @f
  sub cl,01       // 7 vtUnicodeString
  jz @f
  sub cl,01       // 8 vtByteArray
  jz @f
  sub cl,02       // 10 vtAll
  jz @f
  sub cl,04       // 14 vtGrouped
  jz @f
  sub cl,01       // 15 vtByteArrays
  jz @f

  // still here, alter it
  mov rcx,[rax+58]
  mov [OrigCheckRoutine],rcx
  mov rcx,CheckRoutine
  mov [rax+58],rcx

  @@:
  lea rcx,[rax+00000100]
  jmp return
address:
  jmp code
  db 90 90 90 90 90 90
return:]]



  else -- now handle 32bit versions

    if CEVer==6.4 then AOB32bit=[[8B 55 FC 8D 8A A0 00 00 00]]     -- CE6.4
                  else AOB32bit=[[8B 45 FC 05 A8 00 00 00 8B]] end -- CE6.5 and CE6.5.1

    script = [[
aobscanmodule(address,cheatengine-i386.exe,]]..AOB32bit..[[)//
alloc(newmem,$1000)
label(code)
label(return)
label(OrigCheckRoutine)
label(CheckRoutine)
label(NOTSCAN_Enabled)
registersymbol(NOTSCAN_Enabled)
newmem:
OrigCheckRoutine:
  dd 0
NOTSCAN_Enabled:
  dd 0
CheckRoutine:
  call [OrigCheckRoutine]
  xor al,01
  ret
code:
  mov reg1,[ebp-04]
  cmp [NOTSCAN_Enabled],0    // alter it?
  je @f

  mov reg2,[reg1+VariableTypeOffset] // only for certain VariableType, not for below types
  sub reg2,06       // 6 vtString
  jz @f
  sub reg2,01       // 7 vtUnicodeString
  jz @f
  sub reg2,01       // 8 vtByteArray
  jz @f
  sub reg2,02       // 10 vtAll
  jz @f
  sub reg2,04       // 14 vtGrouped
  jz @f
  sub reg2,01       // 15 vtByteArrays
  jz @f

  // still here, alter it
  mov reg2,[reg1+checkRoutineOffest]
  mov [OrigCheckRoutine],reg2
  mov reg2,CheckRoutine
  mov [reg1+checkRoutineOffest],reg2]]


    if CEVer==6.4 then -- CE6.4, epilogue
      script=script..[[//
  @@:
  lea ecx,[edx+000000A0]
  jmp return
address:
  jmp code
  db 90 90 90 90
return:]]
      script=script:gsub('reg1','edx'):gsub('reg2','ecx'):gsub('checkRoutineOffest','28')


    else -- CE6.5 and CE6.5.1, epilogue
      script=script..[[//
  @@:
  add eax,000000A8
  //mov edx,[ebp-000000DC]
  jmp return
address:
  jmp code
  db 90 90 90
return:]]
      script=script:gsub('reg1','eax'):gsub('reg2','edx'):gsub('checkRoutineOffest','30')
    end
  end

  script=script:gsub('VariableTypeOffset',VariableTypeOffset)

  ScanTypeNOT.InjectedAAScript = autoAssemble(script,true)
  return ScanTypeNOT.InjectedAAScript
end

function ScanTypeNOT.status()
  return readIntegerLocal('NOTSCAN_Enabled')==1
end

function ScanTypeNOT.toggle(sender)
  if not ScanTypeNOT.InjectedAAScript then if not ScanTypeNOT.injectAAScript() then return end end

  if ScanTypeNOT.status() then
    writeIntegerLocal('NOTSCAN_Enabled',0)
    sender.Checked = false
    ScanTypeNOT.lblScanType.Caption = ScanTypeNOT.origCaption
  else
    writeIntegerLocal('NOTSCAN_Enabled',1)
    sender.Checked = true
    ScanTypeNOT.lblScanType.Caption = ScanTypeNOT.origCaption .. " ~"
    ScanTypeNOT.Timer.Enabled=true
  end

end

function ScanTypeNOT.checkCurrentVarType(timer)
  if (ScanTypeNOT.cbVarType.ItemIndex>=7 and ScanTypeNOT.cbVarType.ItemIndex<=10) then
    if ScanTypeNOT.status() then ScanTypeNOT.toggle(ScanTypeNOT.miToggle) end
    ScanTypeNOT.miToggle.Enabled=false
  else
    ScanTypeNOT.miToggle.Enabled=true
  end
end

function ScanTypeNOT.init()
  local mf = getMainForm()
  ScanTypeNOT.cbVarType   = mf.VarType
  ScanTypeNOT.lblScanType = mf.lblScanType

  if ScanTypeNOT.lblScanType.PopupMenu==nil then
     ScanTypeNOT.lblScanType.PopupMenu=createPopupMenu(ScanTypeNOT.lblScanType)
  end

  ScanTypeNOT.origCaption=ScanTypeNOT.lblScanType.Caption

  ScanTypeNOT.miToggle = createMenuItem(ScanTypeNOT.lblScanType.PopupMenu)
  ScanTypeNOT.miToggle.Caption="ScanType: not ..."
  ScanTypeNOT.miToggle.OnClick=ScanTypeNOT.toggle
  ScanTypeNOT.lblScanType.PopupMenu.Items.add(ScanTypeNOT.miToggle)

  ScanTypeNOT.Timer=createTimer(mf,false)
  ScanTypeNOT.Timer.Interval=500
  ScanTypeNOT.Timer.OnTimer=ScanTypeNOT.checkCurrentVarType

  ScanTypeNOT.InjectedAAScript = false
end

ScanTypeNOT.init()
