myAOBInjectionTemplates = {}

myAOBInjectionTemplates.Templates = {

{
displayName="Alternative AOB",
submenu='custom AOB Injection Templates',
templateSections=
[==[
<<INFO>>
// Game   : %processName%
// Version:
// Date   :
// Author : %authorName%
<<INFO_END>>

<<ENABLE>>
aobscan%isModuleScan%(aob_%cheatName%,%moduleNameC%%searchPattern%)
registersymbol(aob_%cheatName%)
alloc(newmem_%cheatName%,1024%CmoduleName%)
label(return_%cheatName%)

newmem_%cheatName%:
%_originalCodeLines%
  jmp return_%cheatName%

aob_%cheatName%%aobAdjust%:
  jmp newmem_%cheatName%
%_nopLines%
return_%cheatName%:

<<ENABLE_END>>

<<DISABLE>>
aob_%cheatName%%aobAdjust%:
  db %originalBytes%

unregistersymbol(aob_%cheatName%)
dealloc(newmem_%cheatName%)

%additionalInfo%
<<DISABLE_END>>
]==]
},

{
displayName="Rcg4u's AOB",
submenu="Rcg's Aob Injection Templates",
templateSections=
[==[
<<INFO>>
// Game   : %processName%
// Version:
// Date   :
// Author : %authorName%
<<INFO_END>>

<<ENABLE>>
aobscan%isModuleScan%(rcg%cheatName%,%moduleNameC%%searchPattern%)

alloc(newmem%cheatName%,4096,rcg%cheatName%)

label(rcg%cheatName%_r)
label(rcg%cheatName%_i)
registersymbol(rcg%cheatName%_r)
registersymbol(rcg%cheatName%_i)

label(lbl%cheatName%)
label(lbl%cheatName%Skip)
label(lbl%cheatName%Ret)

label(bEnable%cheatName%)
registersymbol(bEnable%cheatName%)

newmem%cheatName%:
bEnable%cheatName%:
dd 1

lbl%cheatName%:
%CoriginalCodeLines%
//db %originalBytes%
readmem(rcg%cheatName%%rcgAdjust%,%replacedInstructionsSize%)

cmp dword ptr [bEnable%cheatName%],1
jne short lbl%cheatName%Skip
// Place your code here

lbl%cheatName%Skip:
jmp lbl%cheatName%Ret
rcg%cheatName%_i:
readmem(rcg%cheatName%%rcgAdjust%,%replacedInstructionsSize%)

//%injectAddress%:
rcg%cheatName%%rcgAdjust%:
rcg%cheatName%_r:
jmp lbl%cheatName%
%nopLines%
lbl%cheatName%Ret:

<<ENABLE_END>>

<<DISABLE>>
//%injectAddress%:
%CoriginalCodeLines%
//db %originalBytes%
rcg%cheatName%_r:
readmem(rcg%cheatName%_i,%replacedInstructionsSize%)

unregistersymbol(rcg%cheatName%_r)
unregistersymbol(rcg%cheatName%_i)

unregistersymbol(bEnable%cheatName%)

dealloc(newmem%cheatName%)

%additionalInfo%
<<DISABLE_END>>
]==]
}, 

{
displayName="DarkIceCore mandarin",
templateSections=
[==[
<<INFO>>
// Game   : %processName%
// Date   : %Date%
<<INFO_END>>

<<ENABLE>>
aobscan%isModuleScan%(%cheatName%AOB,%moduleNameC%%searchPattern%)
registersymbol(%cheatName%AOB)
//%injectAddress%:
%cheatName%AOB%aobAdjust%:
  db %originalBytes%
//db %originalBytes%

////////////////////////
//%injectAddress%:
%CoriginalCodeLines%
//db %originalBytes%

<<ENABLE_END>>

<<DISABLE>>
%cheatName%AOB%aobAdjust%:
  db %originalBytes%

//%injectAddress%:
%CoriginalCodeLines%
//db %originalBytes%

unregistersymbol(%cheatName%AOB)

////////////////AOB manual adjust %cheatName%AOB//////////////////
//AOB +%aobAdjust% hex//RETURN +%replacedInstructionsSize% hex//
//%searchPattern%
//%searchPattern%
//


%additionalInfo%
<<DISABLE_END>>
]==]
}, 
{
displayName="DarkIceCore Small indi",
templateSections=
[==[
<<INFO>>
// Game   : %processName%
// Date   : %Date%
<<INFO_END>>

<<ENABLE>>
aobscan%isModuleScan%(%cheatName%AOB,%moduleNameC%%searchPattern%)
alloc(%cheatName%,1024%CmoduleName%) //%injectAddress%
///////////////////////////////////////
label(%cheatName%_indi)
//
registersymbol(%cheatName%)
registersymbol(%cheatName%AOB)
registersymbol(%cheatName%_indi)
////////////////////////////////////////
%cheatName%:
%_originalCodeLines%
  mov [%cheatName%_indi],[%regsOffset%]
  jmp %cheatName%AOB%aobAdjust%+%replacedInstructionsSize%
//

//db/dw/dd(float)/dq(double)//
%cheatName%_indi:
  dq 0
//

//AOB +%aobAdjust% hex//RETURN +%replacedInstructionsSize% hex//
%cheatName%AOB%aobAdjust%:
  jmp %cheatName%
%_nopLines%
  jmp %cheatName%AOB%aobAdjust%+%replacedInstructionsSize% 
// 

////////////////////////
//%injectAddress%:
%CoriginalCodeLines%
//db %originalBytes%

<<ENABLE_END>>

<<DISABLE>>
%cheatName%AOB%aobAdjust%:
  db %originalBytes%

//%injectAddress%:
%CoriginalCodeLines%
//db %originalBytes%

unregistersymbol(%cheatName%)
unregistersymbol(%cheatName%AOB)
unregistersymbol(%cheatName%_indi)
dealloc(%cheatName%)

////////////////AOB manual adjust %cheatName%AOB//////////////////
//AOB +%aobAdjust% hex//RETURN +%replacedInstructionsSize% hex//
//%searchPattern%
//%searchPattern%
//

%additionalInfo%
<<DISABLE_END>>
]==]
}, 
{
displayName="DarkIceCore Big chi",
templateSections=
[==[
<<INFO>>
// Game   : %processName%
// Date   : %Date%
<<INFO_END>>

<<ENABLE>>
aobscan%isModuleScan%(%cheatName%AOB,%moduleNameC%%searchPattern%)
alloc(%cheatName%,2048%CmoduleName%) //%injectAddress%
///////////////////////////////////////
label(%cheatName%_indi)
//label(%cheatName%_cmp)
//label(%cheatName%_org)
//
registersymbol(%cheatName%)
registersymbol(%cheatName%AOB)
registersymbol(%cheatName%_indi)
//registersymbol(%cheatName%_cmp)
//registersymbol(%cheatName%_org)
////////////////////////////////////////
%cheatName%:
%_originalCodeLines%
  mov [%cheatName%_indi],[%regsOffset%]
  jmp %cheatName%AOB%aobAdjust%+%replacedInstructionsSize%
//

//
//%cheatName%_cmp:
//cmp
//je/jne %cheatName%_org
//mov
%CoriginalCodeLines%
//jmp %cheatName%AOB%aobAdjust%+%replacedInstructionsSize%
//

//
//%cheatName%_org:
%CoriginalCodeLines%
//jmp %cheatName%AOB%aobAdjust%+%replacedInstructionsSize%
//

//db/dw/dd(float)/dq(double)//
%cheatName%_indi:
  dq 0
//

//AOB +%aobAdjust% hex//RETURN +%replacedInstructionsSize% hex//
%cheatName%AOB%aobAdjust%:
  jmp %cheatName%
%_nopLines%
  jmp %cheatName%AOB%aobAdjust%+%replacedInstructionsSize%
// 

////////////////////////
//%injectAddress%:
%CoriginalCodeLines%
//db %originalBytes%

<<ENABLE_END>>

<<DISABLE>>
%cheatName%AOB%aobAdjust%:
  db %originalBytes%

//%injectAddress%:
%CoriginalCodeLines%
//db %originalBytes%

unregistersymbol(%cheatName%)
unregistersymbol(%cheatName%AOB)
unregistersymbol(%cheatName%_indi)
//unregistersymbol(%cheatName%_cmp)
//unregistersymbol(%cheatName%_org)
dealloc(%cheatName%)

////////////////AOB manual adjust %cheatName%AOB//////////////////
//AOB +%aobAdjust% hex//RETURN +%replacedInstructionsSize% hex//
//%searchPattern%
//%searchPattern%
//


%additionalInfo%
<<DISABLE_END>>
]==]
}, 

{
displayName="Alternative AOB with bracketsRegsOffset",
submenu='custom AOB Injection Templates',
templateSections=
[==[
<<INFO>>
// Game   : %processName%
// Version:
// Date   :
// Author : %authorName%
<<INFO_END>>

<<ENABLE>>
aobscan%isModuleScan%(aob_%cheatName%,%moduleNameC%%searchPattern%)
registersymbol(aob_%cheatName%)
alloc(newmem_%cheatName%,1024%CmoduleName%)
label(return_%cheatName%)
label(set_%cheatName%)
label(quit_%cheatName%)

newmem_%cheatName%:
  jmp quit_%cheatName%

set_%cheatName%:
  mov %bracketsRegsOffset%,0
  //jmp quit_%cheatName%

quit_%cheatName%:
%_originalCodeLines%
  jmp return_%cheatName%

aob_%cheatName%%aobAdjust%:
  jmp newmem_%cheatName%
%_nopLines%
return_%cheatName%:

<<ENABLE_END>>

<<DISABLE>>
aob_%cheatName%%aobAdjust%:
  db %originalBytes%

unregistersymbol(aob_%cheatName%)
dealloc(newmem_%cheatName%)

%additionalInfo%
<<DISABLE_END>>
]==]
},




{
displayName="Alternative AOB with Stealth",
submenu='custom AOB Injection Templates',
templateSections=
[==[
<<INFO>>
// Game   : %processName%
// Version:
// Date   :
// Author : %authorName%
<<INFO_END>>

<<ENABLE>>
aobscan%isModuleScan%(aob_%cheatName%,%moduleNameC%%searchPattern%)
stealtheditex(See_%cheatName%,aob_%cheatName%%aobAdjust%,3)
label(SeeReg_%cheatName%)
registersymbol(SeeReg_%cheatName%)
alloc(newmem_%cheatName%,1024%CmoduleName%)
label(return_%cheatName%)

newmem_%cheatName%:
%_originalCodeLines%
  jmp return_%cheatName%

See_%cheatName%:
SeeReg_%cheatName%:
  jmp newmem_%cheatName%
%_nopLines%
return_%cheatName%:

<<ENABLE_END>>

<<DISABLE>>
SeeReg_%cheatName%:
  db %originalBytes%

unregistersymbol(SeeReg_%cheatName%)
dealloc(newmem_%cheatName%)

%additionalInfo%
<<DISABLE_END>>
]==]
},




{
displayName="predprey's Mono Inject",
submenu="predprey's AOB Injection Templates",
templateSections=
[==[
<<INFO>>
// Game   : %processName%
// Version:
// Date   :
// Author : %authorName%
<<INFO_END>>

<<ENABLE>>
alloc(newmem_%cheatName%,1024%CmoduleName%)
label(%cheatName%)
registersymbol(%cheatName%)
label(return_%cheatName%)

newmem_%cheatName%:
%_originalCodeLines%
  jmp return_%cheatName%

%monoAddress%:
%cheatName%:
  jmp newmem_%cheatName%
%_nopLines%
return_%cheatName%:

<<ENABLE_END>>

<<DISABLE>>
%cheatName%:
  db %originalBytes%

unregistersymbol(%cheatName%)
dealloc(newmem_%cheatName%)

%additionalInfo%
<<DISABLE_END>>
]==]
},




{
displayName="Csimbi's AOB",
submenu="Csimbi's AOB Injection Templates",
templateSections=
[==[
<<INFO>>
// Game   : %processName%
// Version:
// Date   :
// Author : %authorName%
<<INFO_END>>

<<ENABLE>>
aobscan%isModuleScan%(aob%cheatName%,%moduleNameC%%searchPattern%)

alloc(newmem%cheatName%,4096,aob%cheatName%)

label(aob%cheatName%_r)
label(aob%cheatName%_i)
registersymbol(aob%cheatName%_r)
registersymbol(aob%cheatName%_i)

label(lbl%cheatName%)
label(lbl%cheatName%Skip)
label(lbl%cheatName%Ret)

label(bEnable%cheatName%)
registersymbol(bEnable%cheatName%)

newmem%cheatName%:
bEnable%cheatName%:
dd 1

lbl%cheatName%:
%CoriginalCodeLines%
//db %originalBytes%
readmem(aob%cheatName%%aobAdjust%,%replacedInstructionsSize%)

cmp dword ptr [bEnable%cheatName%],1
jne short lbl%cheatName%Skip
// Place your code here

lbl%cheatName%Skip:
jmp lbl%cheatName%Ret
aob%cheatName%_i:
readmem(aob%cheatName%%aobAdjust%,%replacedInstructionsSize%)

//%injectAddress%:
aob%cheatName%%aobAdjust%:
aob%cheatName%_r:
jmp lbl%cheatName%
%nopLines%
lbl%cheatName%Ret:

<<ENABLE_END>>

<<DISABLE>>
//%injectAddress%:
%CoriginalCodeLines%
//db %originalBytes%
aob%cheatName%_r:
readmem(aob%cheatName%_i,%replacedInstructionsSize%)

unregistersymbol(aob%cheatName%_r)
unregistersymbol(aob%cheatName%_i)

unregistersymbol(bEnable%cheatName%)

dealloc(newmem%cheatName%)

%additionalInfo%
<<DISABLE_END>>
]==]
},




}

function myAOBInjectionTemplates.formCreateNotify(form)
  if form.ClassName~="TfrmAutoInject" then return end

  local timer=createTimer()
  timer.Interval=100
  timer.OnTimer = function (t)
                    if (form.Menu==nil) then return end
                    t.destroy()
                    myAOBInjectionTemplates.addMenuEntries(form)
                  end
end

function myAOBInjectionTemplates.addMenuEntries(form)
  local m,mi,sm=form.emplate1,nil,nil
  local createdSubmenus={}
  local lastMenuItemFromGroup={}
  local smIndex = 1

  mi = createMenuItem(m); m.add(mi); mi.Caption = '-' -- separator

  for i=1,#myAOBInjectionTemplates.Templates do
    local submenu = myAOBInjectionTemplates.Templates[i].submenu
    local group = myAOBInjectionTemplates.Templates[i].group
    local groupname=(submenu or '')..(group or '')

    if submenu~=nil then
      if createdSubmenus[submenu] then
        sm=createdSubmenus[submenu]
      else
        sm = createMenuItem(m); m.add(sm)
        sm.Caption = submenu
        sm.Name = 'miAlternativeAOBtemplateSubmenu'..smIndex; smIndex=smIndex+1
        createdSubmenus[submenu]=sm
      end
    else
      sm=m
    end

    if lastMenuItemFromGroup[groupname]==nil then
      if sm.Count>0 then
        mi = createMenuItem(m); sm.add(mi); mi.Caption = '-' -- separator
      end
      mi = createMenuItem(m); sm.add(mi)
      lastMenuItemFromGroup[groupname]=mi
    else
      mi = createMenuItem(m); sm.insert(lastMenuItemFromGroup[groupname].MenuIndex+1, mi)
      lastMenuItemFromGroup[groupname]=mi
    end

    mi.OnClick = function (sender)
                  myAOBInjectionTemplates.generate(sender,myAOBInjectionTemplates.Templates[i])
                 end
    mi.Caption = myAOBInjectionTemplates.Templates[i].displayName
    mi.Name = 'miAlternativeAOBtemplate'..i
  end
end

registerFormAddNotification(myAOBInjectionTemplates.formCreateNotify)



function myAOBInjectionTemplates.generate(sender,chosenTemplate)

  local displayName = chosenTemplate.displayName
  local cheatName = chosenTemplate.defaultSymbolName or 'example'
  local template = chosenTemplate.templateSections
  local form=sender.Owner.Owner
  local origScript = form.Assemblescreen.Lines.Text

  --gather existing names from origScript from registersymbol
  local existingNames = {}
  for existingName in origScript:gmatch('registersymbol%(%s*(.-)%s*%)') do
    existingNames[1+#existingNames] = existingName
  end
  -- also from define
  for existingName in origScript:gmatch('define%(%s*(.-)%s*,') do
    existingNames[1+#existingNames] = existingName
  end

  local function checkForCollides(str)
    for i,v in ipairs(existingNames) do
      if v:find(str, 1, true)~=nil then return 'Name "'..str..'" collides with existing "'..v..'"' end
      if str:find(v, 1, true)~=nil then return 'Existing "'..v..'" collides with name "'..str..'"' end
    end
    return nil
  end

  local function giveModuleAndOffset(address)
    local modulesTable,size = enumModules(),0
    for i,v in pairs(modulesTable) do
      size = getModuleSize(v.Name)
      if address>=v.Address and address<=v.Address+size
        then return '"'..v.Name..'"+'..string.format('%X',address-v.Address) end
    end
    return getNameFromAddress(address)
  end

  local selectedAddress = 0
  if form.owner.DisassemblerView then
    selectedAddress = giveModuleAndOffset(form.owner.DisassemblerView.SelectedAddress)
  else
    selectedAddress = giveModuleAndOffset(getMemoryViewForm().DisassemblerView.SelectedAddress)
  end

  selectedAddress=inputQuery(displayName,'On what address do you want the jump?', selectedAddress)
  if selectedAddress==nil then return end

  cheatName=inputQuery(displayName,'What do you want to name the symbol for the injection point?', cheatName)
  if cheatName==nil then return end

  ::setValidname:: --do not allow default name or those already existing/colliding or empty
  while cheatName:lower()=='inject' or
        cheatName=='' do
    cheatName=inputQuery('Caution!', 'Ugly name. Change it.', cheatName) or ''
    cheatName=cheatName:gsub('%s','') -- remove spaces
  end

  -- check if already exist or collides with each other
  local collides = checkForCollides(cheatName)
  if collides~=nil then
    cheatName=inputQuery('Caution!', collides..'. Change it.', cheatName) or ''
    cheatName=cheatName:gsub('%s','') -- remove spaces
    goto setValidname
  end

  local newScript_stringlist = createStringlist()
  local gaobisResult = generateAOBInjectionScript(newScript_stringlist, cheatName, selectedAddress)
  local newScript = newScript_stringlist.Text
  newScript_stringlist.destroy()

  -- it succeeded ?
  if newScript:match('No Process Selected') or
     newScript:match('Could not find unique AOB')
  then showMessage("No process selected or could not find unique AOB!") return end

  if not gaobisResult
  then showMessage("generateAOBInjectionScript raised exception!") return end


  -- note: 'origScript' and 'newScript' will have "carriage return & line feed" at the end of each line
  --       because it is taken from TStrings object.
  --       'template' has only "line feed"


  local authorName    = newScript:match('Author : (.-)\r\n')
  local processName   = newScript:match('Game   : (.-)\r\n')
  local isModuleScan  = newScript:match('aobscan(module)') or ''
  local searchPattern = newScript:match('aobscan.-%(.*,(.-)%).-should be unique')

  local moduleName, moduleName_comma, comma_moduleName

  if isModuleScan=='module' then
    moduleName = newScript:match('aobscan.-%('..cheatName..',(.-),')
    moduleName_comma = moduleName..','
    comma_moduleName = ','..moduleName
  else
    moduleName = ''
    moduleName_comma = ''
    comma_moduleName = ''
  end

  local _originalCodeLines = newScript:match('code:..(.-)..  jmp return')
  local aobAdjust          = newScript:match('code:.-'..cheatName..'(.-):')
  local _nopLines          = newScript:match('  jmp code..(.-)..return:') or ''

  if _nopLines=='' then  -- other case
        _nopLines          = newScript:match('  jmp newmem..(.-)..return:') or ''
  end

  local originalBytes      = newScript:match('  db (.-)\r\n')
  local additionalInfo     = newScript:match('...// ORIGINAL CODE %- INJECTION POINT.*')

  local origfirstLine = (_originalCodeLines..'\r\n'):match( "(.-)\r\n" )
  local bracketsRegsOffset  = origfirstLine:match('[dq]?word ptr %[.-%]')
                           or origfirstLine:match('byte ptr %[.-%]')
                           or origfirstLine:match('%[.-%]')
                           or ''
  local regsOffset = origfirstLine:match('%[(.-)%]') or ''

  local originalCodeLines = _originalCodeLines:sub(3):gsub('\r\n  ','\r\n')       -- indent less version
  local nopLines = _nopLines=='' and '' or _nopLines:sub(3):gsub('\r\n  ','\r\n') -- indent less version
  local db90s = _nopLines=='' and '' or 'db'..(nopLines..'\r\n'):gsub('nop\r\n',' 90')
  local CoriginalCodeLines = '//Alt: '.._originalCodeLines:sub(3):gsub('\r\n  ','\r\n//Alt: ')-- commented version

  local replacedInstructionsSize = 5 -- replacedInstructionsSize = jumpSize + NopCount; jumpSize is 5
  db90s:gsub(' 90',function (c) replacedInstructionsSize=replacedInstructionsSize+1 end) -- number of NOPs


  --Mono & Hook Address
  local injectAddress = newScript:match('INJECTING HERE %-%-%-%-%-%-%-%-%-%-\r\n(.-):')
  local injectAddressNum = getAddress(injectAddress)
  local monoAddress = ''
  if template:find('%%monoAddress%%') then -- remove lag for templates without mono
    if LaunchMonoDataCollector~=nil and LaunchMonoDataCollector()~=0 then
      monoAddress = mono_addressLookupCallback(injectAddressNum) or ''
    end
  end

  --reassembleReplacedInstructions
  local tmp = getInstructionSize(injectAddressNum)
  local reassembleReplacedInstructions = 'reassemble(~)'
  while tmp < replacedInstructionsSize do
    reassembleReplacedInstructions = reassembleReplacedInstructions .. '\nreassemble(~+'..string.format('%X',tmp)..')'
    tmp = tmp + getInstructionSize(injectAddressNum+tmp)
  end

  -- use the template
  template = template:gsub('%%cheatName%%', cheatName)
  template = template:gsub('%%authorName%%', authorName)
  template = template:gsub('%%processName%%', processName)
  template = template:gsub('%%isModuleScan%%', isModuleScan)
  template = template:gsub('%%searchPattern%%', searchPattern)
  template = template:gsub('%%CmoduleName%%', comma_moduleName)
  template = template:gsub('%%moduleNameC%%', moduleName_comma)
  template = template:gsub('%%moduleName%%', moduleName)
  template = template:gsub('%%replacedInstructionsSize%%', replacedInstructionsSize)
  template = template:gsub('%%_originalCodeLines%%', _originalCodeLines)
  template = template:gsub('%%originalCodeLines%%', originalCodeLines)
  template = template:gsub('%%CoriginalCodeLines%%', CoriginalCodeLines)
  template = template:gsub('%%originalBytes%%', originalBytes)
  template = template:gsub('%%aobAdjust%%', aobAdjust)
  template = template:gsub('%%additionalInfo%%', additionalInfo)
  template = template:gsub('%%bracketsRegsOffset%%', bracketsRegsOffset)
  template = template:gsub('%%regsOffset%%', regsOffset)
  template = template:gsub('%%injectAddress%%', injectAddress)
  template = template:gsub('%%monoAddress%%', monoAddress)
  template = template:gsub('%%reassembleReplacedInstructions%((.-)%)%%', function (a)
    return reassembleReplacedInstructions:gsub('~',a)
  end)

  if db90s~='' then
   template = template:gsub('%%nopLines%%', nopLines)
   template = template:gsub('%%_nopLines%%', _nopLines)
   template = template:gsub('%%db90s%%', db90s)
  else
   -- remove whole line when NOP'ing is not needed
   template = template:gsub('%%nopLines%%.-\n', '')
   template = template:gsub('%%_nopLines%%.-\n', '')
   template = template:gsub('%%db90s%%.-\n', '')
  end

  local enablePart  = template:match('<<ENABLE>>.(.*).<<ENABLE_END>>')
  local disablePart = template:match('<<DISABLE>>.(.*).<<DISABLE_END>>')
  local infoPart = template:match('<<INFO>>.(.*).<<INFO_END>>')

  if origScript=='\r\n' then origScript='' end --after manually deleting all lines, there's always one empty line

  local pos=origScript:find('%[DISABLE]')
  if pos then newScript=origScript:sub(1,pos-1)..'\r\n'..enablePart..'\r\n'..origScript:sub(pos)..'\r\n'..disablePart
         else newScript=origScript..'[ENABLE]\r\n'..enablePart..'\r\n[DISABLE]\r\n'..disablePart
  end

  if pos==nil and infoPart~=nil then newScript=infoPart..'\r\n'..newScript end

  form.Assemblescreen.Lines.Text = newScript -- update
end
