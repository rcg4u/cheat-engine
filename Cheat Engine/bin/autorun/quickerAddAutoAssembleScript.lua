function quickAddAAScriptInit()
  local mf = getMainForm()
  local btnAddAddressManually = mf.btnAddAddressManually

  if btnAddAddressManually.PopupMenu==nil then
     btnAddAddressManually.PopupMenu=createPopupMenu(btnAddAddressManually)
  end

  local mi = createMenuItem(btnAddAddressManually.PopupMenu)
  mi.Caption="Add Address Manually"
  mi.OnClick=btnAddAddressManually.OnClick
  btnAddAddressManually.PopupMenu.Items.add(mi)

  mi = createMenuItem(btnAddAddressManually.PopupMenu)
  mi.Caption="Add Auto Assemble Script"
  mi.OnClick=function ()
               local mr = getAddressList().createMemoryRecord()
               mr.Type = vtAutoAssembler
               mr.Script = '[ENABLE]\n\n[DISABLE]\n\n'
               mr.Description = 'Auto Assemble script'
             end
  btnAddAddressManually.PopupMenu.Items.add(mi)
  
    mi = createMenuItem(btnAddAddressManually.PopupMenu)
  mi.Caption="Add Create Thread Script"
  mi.OnClick=function ()
               local mr = getAddressList().createMemoryRecord()
               mr.Type = vtAutoAssembler
               mr.Script = '[ENABLE]\n\nalloc(thread,248)\ncreatethread(thread)\n\nthread:\n\nret\n\n[DISABLE]\n\n'
               mr.Description = 'Create Thread Script'
             end
  btnAddAddressManually.PopupMenu.Items.add(mi)
end

quickAddAAScriptInit()