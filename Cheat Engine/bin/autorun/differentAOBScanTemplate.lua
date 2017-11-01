function formCreateNotify(form)
  if form.className~="TfrmAutoInject" then return end

  local timer=createTimer()
  timer.Interval=100
  timer.OnTimer = function (t) if (form.Menu==nil) then return end t.destroy() addMenuEntry(form) end
end

function addMenuEntry(form)
  local m=form.emplate1
  local mi = createMenuItem(m); m.add(mi)
  mi.onClick = myAOBScanTemplate
  mi.Caption = 'Alternative AOB template'
  mi.Name = 'miAlternativeAOBtemplate'

  mi = createMenuItem(m); m.add(mi)
  mi.onClick = myAOBScanWithStealthTemplate
  mi.Caption = 'Alternative AOB with stealth template'
  mi.Name = 'miAlternativeAOBwithstealthtemplate'
end


function myAOBScanTemplate(sender)

  local origScript, newScript, bytesAndCodePart, enablePart, disablePart
  local form=sender.Owner.Owner

  origScript = form.Assemblescreen.Lines.Text

  form.Assemblescreen.Lines.Text = '' -- clear
  form.menuAOBInjection.doClick()
  processMessages()
  newScript = form.Assemblescreen.Lines.Text
  form.Assemblescreen.Lines.Text = origScript

  if newScript=='' then return end

  --parse new script
  local cheatName2 = newScript:match('aobscan.-%(%s*(.-)%s*,')
  local cheatName=cheatName2

  if cheatName=='INJECTION_POINT' then return end

  while cheatName=='INJECT' do
    cheatName=inputQuery('Caution!', 'Ugly name. Change it.', cheatName)
    if cheatName==nil then return end
  end

  while origScript:match('aobscan.-%(%s*aob_'..cheatName..'%s*,')~=nil do
    cheatName=inputQuery('Caution!', 'This name already exists. Change it.', cheatName)
    if cheatName==nil then return end
  end

  infoPart    = newScript:match('(.*)%[ENABLE]')
  bytesAndCodePart = newScript:match('...// ORIGINAL CODE %- INJECTION POINT.*$')

  enablePart  = newScript:match('%[ENABLE](.*)%[DISABLE]')
  disablePart = newScript:match('%[DISABLE](.*)ORIGINAL CODE %- INJECTION POINT'):sub(1,-10)

  enablePart = enablePart:gsub(cheatName2,'aob_'..cheatName)
  enablePart = enablePart:gsub('newmem','newmem'..'_'..cheatName)
  enablePart = enablePart:gsub('code','code'..'_'..cheatName)
  enablePart = enablePart:gsub('return','return'..'_'..cheatName)

  disablePart = disablePart:gsub(cheatName2,'aob_'..cheatName)
  disablePart = disablePart:gsub('newmem','newmem'..'_'..cheatName)

  local pos=origScript:find('%[DISABLE]')

  if pos then newScript=origScript:sub(1,pos-1)..enablePart..origScript:sub(pos)..disablePart
  else        newScript='[ENABLE]'..enablePart..'\n[DISABLE]'..disablePart
  end

  if pos==nil then newScript=infoPart..newScript end

  if messageDialog('Add detailed comments?', mtConfirmation, mbYes, mbNo)==mrYes then
    newScript=newScript..bytesAndCodePart
  end

  form.Assemblescreen.Lines.Text = newScript -- update
end

function myAOBScanWithStealthTemplate(sender)

  local origScript, newScript, bytesAndCodePart, enablePart, disablePart
  local form=sender.Owner.Owner

  origScript = form.Assemblescreen.Lines.Text

  form.Assemblescreen.Lines.Text = '' -- clear
  form.menuAOBInjection.doClick()
  processMessages()
  newScript = form.Assemblescreen.Lines.Text
  form.Assemblescreen.Lines.Text = origScript

  if newScript=='' then return end

  --parse new script
  local cheatName2 = newScript:match('aobscan.-%(%s*(.-)%s*,')
  local cheatName=cheatName2

  if cheatName=='INJECTION_POINT' then return end

  while cheatName=='INJECT' do
    cheatName=inputQuery('Caution!', 'Ugly name. Change it.', cheatName)
    if cheatName==nil then return end
  end

  while origScript:match('aobscan.-%(%s*aob_'..cheatName..'%s*,')~=nil do
    cheatName=inputQuery('Caution!', 'This name already exists. Change it.', cheatName)
    if cheatName==nil then return end
  end


  infoPart    = newScript:match('(.*)%[ENABLE]')
  bytesAndCodePart = newScript:match('...// ORIGINAL CODE %- INJECTION POINT.*$')

  enablePart  = newScript:match('%[ENABLE](.*)%[DISABLE]')
  disablePart = newScript:match('%[DISABLE](.*)ORIGINAL CODE %- INJECTION POINT'):sub(1,-10)

  enablePart = enablePart:gsub(cheatName2,'aob_'..cheatName)

  local seline = 'stealthedit(se_'..cheatName..','..'aob_'..cheatName..',32)\n'
  seline = seline..'label(se_r_'..cheatName..')\n'
  seline = seline..'registersymbol(se_r_'..cheatName..')'
  enablePart = enablePart:gsub('alloc%(newmem', seline..'\nalloc(newmem')

  enablePart = enablePart:gsub('aob_'..cheatName..':','se_'..cheatName..':\nse_r_'..cheatName..':')
  enablePart = enablePart:gsub('registersymbol%(aob_'..cheatName..'%)..','')

  enablePart = enablePart:gsub('newmem','newmem'..'_'..cheatName)
  enablePart = enablePart:gsub('code','code'..'_'..cheatName)
  enablePart = enablePart:gsub('return','return'..'_'..cheatName)

  disablePart = disablePart:gsub(cheatName2,'se_r_'..cheatName)
  disablePart = disablePart:gsub('newmem','newmem'..'_'..cheatName)

  local pos=origScript:find('%[DISABLE]')

  if pos then newScript=origScript:sub(1,pos-1)..enablePart..origScript:sub(pos)..disablePart
  else        newScript='[ENABLE]'..enablePart..'\n[DISABLE]'..disablePart
  end

  if pos==nil then newScript=infoPart..newScript end

  if messageDialog('Add detailed comments?', mtConfirmation, mbYes, mbNo)==mrYes then
    newScript=newScript..bytesAndCodePart
  end

  form.Assemblescreen.Lines.Text = newScript -- update
end

registerFormAddNotification("formCreateNotify")
