if getCEVersion() < 6.6 then showMessage('WatchChangesToAddresses Lua extention could not be loaded: outdated CE version. Please upgrade to CE 6.6 or later.') return end

local memviewform = getMemoryViewForm()
local miWatchChangesToAddress = createMenuItem(memviewform.Extra1)
miWatchChangesToAddress.Caption = 'Watch changes to addresses'
memviewform.Extra1.insert(memviewform.Watchmemoryallocations1.MenuIndex+1, miWatchChangesToAddress)
miWatchChangesToAddress.OnClick = function()
--[[
    Place GUI elements
  ]]

  local form = createForm(false)
  form.Height = 300
  form.Width = 400
  form.Caption = 'Watch Changes to Addresses'
  form.Constraints.MinHeight = 300
  form.Constraints.MinWidth = 400
  form.BorderStyle = bsSizeable
  form.Position = poScreenCenter

  local pnlOptions = createPanel(form)
  pnlOptions.Align = alLeft
  pnlOptions.Width = 150
  pnlOptions.BevelOuter = bvNone

  local lblInterval = createLabel(pnlOptions)
  lblInterval.AnchorSideLeft.Control = pnlOptions
  lblInterval.AnchorSideTop.Control = pnlOptions
  lblInterval.BorderSpacing.Left = 10
  lblInterval.BorderSpacing.Top = 10
  lblInterval.Caption = 'Interval'

  local edtInterval = createEdit(pnlOptions)
  edtInterval.AnchorSideLeft.Control = lblInterval
  edtInterval.AnchorSideTop.Control = lblInterval
  edtInterval.AnchorSideTop.Side = asrBottom
  edtInterval.BorderSpacing.Top = 5
  edtInterval.Text = getFreezeTimer().Interval

  local rbLogUpdate = createComponentClass('TRadioButton',pnlOptions)
  rbLogUpdate.parent = pnlOptions
  rbLogUpdate.AnchorSideLeft.Control = lblInterval
  rbLogUpdate.AnchorSideTop.Control = edtInterval
  rbLogUpdate.AnchorSideTop.Side = asrBottom
  rbLogUpdate.BorderSpacing.Top = 20
  rbLogUpdate.Caption = 'Log On Update'
  rbLogUpdate.Checked = true

  local cbBreakpoints = createCheckBox(pnlOptions)
  cbBreakpoints.AnchorSideLeft.Control = rbLogUpdate
  cbBreakpoints.AnchorSideTop.Control = rbLogUpdate
  cbBreakpoints.AnchorSideTop.Side = asrBottom
  cbBreakpoints.BorderSpacing.Left = 15
  cbBreakpoints.BorderSpacing.Top = 5
  cbBreakpoints.Hint = 'Use HW breakpoints to watch for any write to the addresses.\r\nThis will not function properly if all debug registers are in use.'
  cbBreakpoints.Caption = 'Use Breakpoints'
  cbBreakpoints.ParentShowHint = false
  cbBreakpoints.ShowHint = true

  local rbLogPeriodic = createComponentClass('TRadioButton',pnlOptions)
  rbLogPeriodic.parent = pnlOptions
  rbLogPeriodic.AnchorSideLeft.Control = lblInterval
  rbLogPeriodic.AnchorSideTop.Control = cbBreakpoints
  rbLogPeriodic.AnchorSideTop.Side = asrBottom
  rbLogPeriodic.BorderSpacing.Top = 5
  rbLogPeriodic.Caption = 'Log Periodically'
  rbLogPeriodic.Checked = false

  local cbLimitLogCount = createCheckBox(pnlOptions)
  cbLimitLogCount.AnchorSideLeft.Control = lblInterval
  cbLimitLogCount.AnchorSideTop.Control = rbLogPeriodic
  cbLimitLogCount.AnchorSideTop.Side = asrBottom
  cbLimitLogCount.BorderSpacing.Top = 20
  cbLimitLogCount.Caption = 'Limit Max Log Count'

  local edtMaxLogCount = createEdit(pnlOptions)
  edtMaxLogCount.AnchorSideLeft.Control = cbLimitLogCount
  edtMaxLogCount.AnchorSideTop.Control = cbLimitLogCount
  edtMaxLogCount.AnchorSideTop.Side = asrBottom
  edtMaxLogCount.BorderSpacing.Left = 15
  edtMaxLogCount.BorderSpacing.Top = 3
  edtMaxLogCount.Enabled = false
  edtMaxLogCount.Text = '100'

  local cbReplaceOld = createCheckBox(pnlOptions)
  cbReplaceOld.AnchorSideLeft.Control = edtMaxLogCount
  cbReplaceOld.AnchorSideTop.Control = edtMaxLogCount
  cbReplaceOld.AnchorSideTop.Side = asrBottom
  cbReplaceOld.BorderSpacing.Top = 3
  cbReplaceOld.Caption = 'Replace old entries'
  cbReplaceOld.Enabled = false

  local tbStart = createToggleBox(pnlOptions)
  tbStart.AnchorSideLeft.Control = pnlOptions
  tbStart.Align = alBottom
  tbStart.Height = 40
  tbStart.Caption = 'Start'

  local lvResults = createListView(form)
  lvResults.AnchorSideLeft.Control = pnlOptions
  lvResults.AnchorSideLeft.Side = asrBottom
  lvResults.Align = alRight
  lvResults.Anchors = '[akLeft]'
  lvResults.AutoSort = false
  lvResults.HideSelection = false
  lvResults.MultiSelect = true
  lvResults.ReadOnly = true
  lvResults.RowSelect = true
  lvResults.ViewStyle = vsReport
  lvResults.Columns.add().Caption = 'Time'


  local mainMenu = createMainMenu(form)

  local fileMenu = createMenuItem(mainMenu)
  fileMenu.Caption = 'File'
  mainMenu.Items.add(fileMenu)

  local miNewWindow = createMenuItem(fileMenu)
  miNewWindow.Caption = 'New Window'
  miNewWindow.ShortCut = 16462
  fileMenu.add(miNewWindow)


  local editMenu = createMenuItem(mainMenu)
  editMenu.Caption = 'Edit'
  mainMenu.Items.add(editMenu)

  local miCopy = createMenuItem(editMenu)
  miCopy.Caption = 'Copy'
  miCopy.ShortCut = 16451
  editMenu.add(miCopy)

  local miSelectAll = createMenuItem(editMenu)
  miSelectAll.Caption = 'Select All'
  miSelectAll.ShortCut = 16449
  editMenu.add(miSelectAll)

  local miRemoveSelection = createMenuItem(editMenu)
  miRemoveSelection.Caption = 'Remove Selection'
  miRemoveSelection.ShortCut = 46
  editMenu.add(miRemoveSelection)

  local miEditSeparator1 = createMenuItem(editMenu)
  miEditSeparator1.Caption = '-'
  editMenu.add(miEditSeparator1)

  local miAddAddress = createMenuItem(editMenu)
  miAddAddress.Caption = 'Add Address'
  miAddAddress.ShortCut = 16468
  editMenu.add(miAddAddress)

  local miRemoveAddress = createMenuItem(editMenu)
  miRemoveAddress.Caption = 'Remove Address'
  miRemoveAddress.Enabled = false
  editMenu.add(miRemoveAddress)


  local pmListView = createPopupMenu(form)
  lvResults.PopupMenu = pmListView

  local pmiPause = createMenuItem(pmListView)
  pmiPause.AutoCheck = true
  pmiPause.Caption = 'Pause'
  pmiPause.Enabled = false
  pmListView.Items.add(pmiPause)

  local pmiAddAddress = createMenuItem(pmListView)
  pmiAddAddress.Caption = 'Add Address'
  pmListView.Items.add(pmiAddAddress)

  local pmiRemoveAddress = createMenuItem(pmListView)
  pmiRemoveAddress.Caption = 'Remove Address'
  pmiRemoveAddress.Enabled = false
  pmListView.Items.add(pmiRemoveAddress)


--[[
    End placement of GUI, begin implementation
  ]]

  --[['addresses' = array of tables with keys:
    (int) address : location in memory,
    (vtType) type : value type,
    (string) typeName: value type as string (for custom types)
    (table) prevBytes : AoB,  -- if #prevBytes == 0, error in reading data
    (int) size : value size,
    (bool) hex : hexadecimal value,
    (bool) signed : signed value
    (int) index : identifier (which column)
  ]]
  local addresses = {add = function(self, t)
      self[#self+1] = t
      t.index = #self

      local mi = createMenuItem(pmiRemoveAddress)
      mi.Caption = string.format('%08X', t.address or 0)
      mi.OnClick = function() self:remove(t.index) end
      pmiRemoveAddress.add(mi)

      local c = lvResults.Columns.add()
      c.Caption = mi.Caption
      c.Width = 70

      miRemoveAddress.Enabled = true
      pmiRemoveAddress.Enabled = true

      return t
    end,

    remove = function(self, i)
      table.remove(self,i)
      for j=i,#self do
        self[j].index = j
      end

      pmiRemoveAddress[i-1].destroy()

      lvResults.Columns[i].destroy()

      if #self == 0 then
        lvResults.Items.clear()
        miRemoveAddress.Enabled = false
        pmiRemoveAddress.Enabled = false
      else
        for j=0, lvResults.Items.Count-1 do
          lvResults.Items[j].SubItems.remove(i-1)
        end
      end
    end
  }

  local aobmt = {
    __eq = function(lhs,rhs)
      if #lhs ~= #rhs then return false end
      for i=1,#lhs do
        if lhs[i] ~= rhs[i] then return false end
      end
      return true
    end
  }
  local addrmt = {
    __tostring = function(self)
      if #self.prevBytes == 0 then
        return 'Err'
      end
      local ret
      if self.type == vtByte then
        ret = self.prevBytes[1]
      elseif self.type == vtWord then
        ret = byteTableToWord(self.prevBytes)
      elseif self.type == vtDword then
        ret = byteTableToDword(self.prevBytes)
      elseif self.type == vtQword then
        ret = byteTableToQword(self.prevBytes)
      elseif self.type == vtSingle then
        return tostring(byteTableToFloat(self.prevBytes))
      elseif self.type == vtDouble then
        return tostring(byteTableToDouble(self.prevBytes))
      elseif self.type == vtString then
        return byteTableToString(self.prevBytes)
      elseif self.type == vtUnicodeString then
        return byteTableToWideString(self.prevBytes)
      elseif self.type == vtByteArray then
        local format = self.hex and '%02X' or '%d'
        ret = {}
        for i,v in ipairs(self.prevBytes) do
          ret[i] = string.format(format, self.signed and v - ((v & 128) << 1) or v)
        end
        return table.concat(ret, ' ')
      elseif self.type == vtCustom then
        -- assumed that mgr.inz.Player's customTypesExt is loaded
        local t = getCustomType(self.typeName)
        ret = t.getValue(self.address)
        if t.usesFloat then return tostring(ret) end
      else
        error('Value associated with an unknown type')
      end

      -- integral types (including non-float custom types) return here
      return self.hex and string.format('%X',ret) or tostring(self.signed and (ret & (1 << self.size*8)-1) - ((ret & 1 << self.size*8-1) << 1) or ret)
    end
  }


  local mainTimer = createTimer(form, false)
  mainTimer.Interval = tonumber(edtInterval.Text) or 100
  mainTimer.OnTimer = function(timer)
    if pmiPause.Checked then return end
    local newitem  -- potential new item in the ListView

    for i,v in ipairs(addresses) do
      local bytes = setmetatable(readBytes(v.address, v.size, true) or {}, aobmt)
      if newitem then
        -- another address updated, copy this one regardless
        v.prevBytes = bytes
        newitem.SubItems.add(tostring(v))
      elseif bytes ~= v.prevBytes or rbLogPeriodic.Checked then
        -- first changed address (or log periodic); create new entry
        v.prevBytes = bytes

        newitem = lvResults.Items.add()
        newitem.Caption = os.date('%X')

        if cbLimitLogCount.Checked then
          if cbReplaceOld.Checked then
            if lvResults.Items.Count > tonumber(edtMaxLogCount.Text) then
              lvResults.Items[0].delete()
            end
          elseif lvResults.Items.Count >= tonumber(edtMaxLogCount.Text) then
            tbStart.Checked = false
          end
        end

        for j = 1, i do      -- add addresses before this one as well
          newitem.SubItems.add(tostring(addresses[j]))
        end
      end
    end -- end loop through addresses
  end -- end mainTimer.OnTimer

--[[
    End main implementation, begin GUI events
  ]]
  form.OnClose = function(sender)
    return caFree
  end


  edtInterval.OnExit = function(sender)
    local i = tonumber(sender.Text)
    if i and i >= 1 then
      mainTimer.Interval = math.floor(i)
    end
    sender.Text = mainTimer.Interval
  end

  rbLogUpdate.OnChange = function(sender)
    if sender.Checked then
      cbBreakpoints.Enabled = true
      edtInterval.Text = tonumber(getFreezeTimer().Interval)
    end
  end

  cbBreakpoints.OnChange = function(sender)
    lblInterval.Enabled = not sender.Checked
    edtInterval.Enabled = not sender.Checked
  end


  rbLogPeriodic.OnChange = function(sender)
    if sender.Checked then
      cbBreakpoints.Enabled = false
      edtInterval.Text = tonumber(getUpdateTimer().Interval)
    end
    lblInterval.Enabled = sender.Checked or not cbBreakpoints.Checked
    edtInterval.Enabled = sender.Checked or not cbBreakpoints.Checked
  end

  cbLimitLogCount.OnChange = function(sender)
    edtMaxLogCount.Enabled = sender.Checked
    cbReplaceOld.Enabled = sender.Checked
  end

  edtMaxLogCount.OnExit = function(sender)
    local n = tonumber(sender.Text)
    sender.Text = n and n >= 1 and math.floor(n) or '100'
  end

  tbStart.OnChange = function(sender)
    if sender.Checked then
      if lvResults.Items.Count > 0 and mrYes ~= messageDialog('Starting will clear the current results. Continue?', mtWarning, mbYes, mbCancel) then
        sender.Checked = false
        return
      end
      sender.Caption = 'Stop'

      mainTimer.Interval = tonumber(edtInterval.Text)

      lvResults.Items.clear()
      local firstitem = lvResults.Items.add()
      firstitem.Caption = os.date('%X')

      for i,v in ipairs(addresses) do
        v.prevBytes = setmetatable(readBytes(v.address, v.size, true) or {}, aobmt)
        firstitem.SubItems.add(tostring(v))
      end

      lblInterval.Enabled = false
      edtInterval.Enabled = false
      rbLogUpdate.Enabled = false
      cbBreakpoints.Enabled = false
      rbLogPeriodic.Enabled = false
      cbLimitLogCount.Enabled = false
      edtMaxLogCount.Enabled = false
      cbReplaceOld.Enabled = false
      pmiPause.Enabled = true

      if rbLogUpdate.Checked and cbBreakpoints.Checked then
        --setup breakpoints
        if not debug_isDebugging() then debugProcess() end

        for _,v in ipairs(addresses) do
          debug_setBreakpoint(v.address, v.size, bptWrite, bpmDebugRegister, function()
            if pmiPause.Checked then return end
            v.prevBytes = setmetatable(readBytes(v.address, v.size, true), aobmt)
            local newitem = lvResults.Items.add()
            newitem.Caption = os.date('%X')

            if cbLimitLogCount.Checked then
              if cbReplaceOld.Checked then
                if lvResults.Items.Count > tonumber(edtMaxLogCount.Text) then
                  lvResults.Items[0].delete()
                end
              elseif lvResults.Items.Count >= tonumber(edtMaxLogCount.Text) then
                tbStart.Checked = false
              end
            end

            for _,v2 in ipairs(addresses) do
              newitem.SubItems.add(tostring(v2))
            end

            debug_continueFromBreakpoint(co_run)
            return 0
          end)
        end
      else
        mainTimer.Enabled = true
      end
    else
      sender.Caption = 'Start'
      if rbLogUpdate.Checked and cbBreakpoints.Checked then
        for _,v in ipairs(addresses) do
          debug_removeBreakpoint(v.address)
        end
      else
        mainTimer.Enabled = false
      end

      lblInterval.Enabled = true
      edtInterval.Enabled = true
      rbLogUpdate.Enabled = true
      cbBreakpoints.Enabled = rbLogUpdate.Checked
      rbLogPeriodic.Enabled = true
      cbLimitLogCount.Enabled = true
      edtMaxLogCount.Enabled = cbLimitLogCount.Checked
      cbReplaceOld.Enabled = cbLimitLogCount.Checked
      pmiPause.Enabled = false
      pmiPause.Checked = false
    end
  end


  miNewWindow.OnClick = function(sender)
    miWatchChangesToAddress.DoClick()
  end

  miCopy.OnClick = function(sender)
    local ret = {}
    for i=0, lvResults.Items.Count - 1 do
      if lvResults.Items[i].Selected then
        ret[#ret+1] = lvResults.Items[i].Caption .. '\t' .. lvResults.Items[i].SubItems.Text:gsub('\r\n(.)','\t%1')
      end
    end
    writeToClipboard(table.concat(ret))
  end

  miSelectAll.OnClick = function(sender)
    for i=0, lvResults.Items.Count - 1 do
      lvResults.Items[i].Selected = true
    end
  end

  miRemoveSelection.OnClick = function(sender)
    for i = lvResults.Items.Count - 1, 0, -1 do
      if lvResults.Items[i].Selected then
        lvResults.Items[i].destroy()
      end
    end
  end

  miAddAddress.OnClick = function(sender)
    -- create GUI
    local addAddressForm = createForm(false)
    addAddressForm.Height = 165
    addAddressForm.Width = 220
    addAddressForm.BorderIcons = '[biSystemMenu, biMinimize]'
    addAddressForm.BorderStyle = bsSingle
    addAddressForm.Caption = 'Add Address'
    addAddressForm.Position = poScreenCenter

    local edtAddress = createEdit(addAddressForm)
    edtAddress.AnchorSideTop.Control = addAddressForm
    edtAddress.AnchorSideRight.Control = addAddressForm
    edtAddress.AnchorSideRight.Side = asrBottom
    edtAddress.Height = 23
    edtAddress.Width = 130
    edtAddress.Anchors = '[akTop, akRight]'
    edtAddress.BorderSpacing.Top = 9
    edtAddress.BorderSpacing.Right = 10

    local cmbValueType = createComboBox(addAddressForm)
    cmbValueType.AnchorSideLeft.Control = edtAddress
    cmbValueType.AnchorSideTop.Control = edtAddress
    cmbValueType.AnchorSideTop.Side = asrBottom
    cmbValueType.AnchorSideRight.Control = addAddressForm
    cmbValueType.AnchorSideRight.Side = asrBottom
    cmbValueType.Height = 23
    cmbValueType.Anchors = '[akTop, akLeft, akRight]'
    cmbValueType.BorderSpacing.Top = 10
    cmbValueType.BorderSpacing.Right = 10
    cmbValueType.ItemHeight = 15

    local edtValueSize = createEdit(addAddressForm)
    edtValueSize.AnchorSideLeft.Control = edtAddress
    edtValueSize.AnchorSideLeft.Side = asrCenter
    edtValueSize.AnchorSideTop.Control = cmbValueType
    edtValueSize.AnchorSideTop.Side = asrBottom
    edtValueSize.AnchorSideRight.Control = addAddressForm
    edtValueSize.AnchorSideRight.Side = asrBottom
    edtValueSize.Height = 23
    edtValueSize.Anchors = '[akTop, akLeft, akRight]'
    edtValueSize.BorderSpacing.Top = 10
    edtValueSize.BorderSpacing.Right = 10
    edtValueSize.Enabled = false
    edtValueSize.Text = '4'

    local lblAddress = createLabel(addAddressForm)
    lblAddress.AnchorSideTop.Control = edtAddress
    lblAddress.AnchorSideTop.Side = asrCenter
    lblAddress.AnchorSideRight.Control = edtAddress
    lblAddress.Anchors = '[akTop, akRight]'
    lblAddress.BorderSpacing.Right = 10
    lblAddress.Caption = 'Address:'

    local lblValueType = createLabel(addAddressForm)
    lblValueType.AnchorSideTop.Control = cmbValueType
    lblValueType.AnchorSideTop.Side = asrCenter
    lblValueType.AnchorSideRight.Control = cmbValueType
    lblValueType.Anchors = '[akTop, akRight]'
    lblValueType.BorderSpacing.Right = 10
    lblValueType.Caption = 'Value Type:'

    local lblValueSize = createLabel(addAddressForm)
    lblValueSize.AnchorSideTop.Control = edtValueSize
    lblValueSize.AnchorSideTop.Side = asrCenter
    lblValueSize.AnchorSideRight.Control = edtValueSize
    lblValueSize.Anchors = '[akTop, akRight]'
    lblValueSize.BorderSpacing.Right = 10
    lblValueSize.Caption = 'Value Size:'
    lblValueSize.Enabled = false

    local cbHex = createCheckBox(addAddressForm)
    cbHex.AnchorSideLeft.Control = addAddressForm
    cbHex.AnchorSideTop.Control = lblValueSize
    cbHex.AnchorSideTop.Side = asrBottom
    cbHex.BorderSpacing.Left = 20
    cbHex.BorderSpacing.Top = 15
    cbHex.Caption = 'Hexadecimal'

    local cbSigned = createCheckBox(addAddressForm)
    cbSigned.AnchorSideLeft.Control = cbHex
    cbSigned.AnchorSideLeft.Side = asrBottom
    cbSigned.AnchorSideTop.Control = cbHex
    cbSigned.AnchorSideTop.Side = asrCenter
    cbSigned.BorderSpacing.Left = 18
    cbSigned.Caption = 'Signed'
    cbSigned.Checked = getSettingsForm().cbShowAsSigned.Checked
    cbHex.Enabled = not cbSigned.Checked

    local cbWChar = createCheckBox(addAddressForm)
    cbWChar.AnchorSideLeft.Control = cbHex
    cbWChar.AnchorSideTop.Control = cbHex
    cbWChar.AnchorSideTop.Side = asrBottom
    cbWChar.BorderSpacing.Top = 5
    cbWChar.Caption = 'UTF-16'
    cbWChar.Enabled = false

    local btnOK = createButton(addAddressForm)
    btnOK.AnchorSideRight.Control = addAddressForm
    btnOK.AnchorSideRight.Side = asrBottom
    btnOK.AnchorSideBottom.Control = addAddressForm
    btnOK.AnchorSideBottom.Side = asrBottom
    btnOK.Height = 25
    btnOK.Width = 75
    btnOK.Anchors = '[akRight, akBottom]'
    btnOK.BorderSpacing.Right = 20
    btnOK.BorderSpacing.Bottom = 5
    btnOK.Caption = 'OK'

    -- types
    types = {'Byte','2 Bytes','4 Bytes','8 Bytes','Float','Double','String','Array of Bytes'}

    -- support for mgr.inz.Player's customTypesExt

    if customTypesExt and getCustomTypeCount and getCustomType then
      customTypesExt.refresh()
      for _,v in ipairs(customTypesExt.customTypes) do
        types[#types+1] = v.name
      end
    end

    cmbValueType.Items.Text = table.concat(types,'\r\n')
    cmbValueType.ItemIndex = 2

    -- GUI events

    addAddressForm.OnClose = function(sender)
      return caFree
    end

    cmbValueType.OnChange = function(sender)
      local i = sender.ItemIndex
      cbWChar.Enabled = false
      cbWChar.Checked = false
      cbHex.Checked = false
      cbSigned.Checked = false
      cbHex.Enabled = true
      cbSigned.Enabled = true
      if i < 4 then  --integral
        cbSigned.Checked = getSettingsForm().cbShowAsSigned.Checked
        edtValueSize.Enabled = false
        edtValueSize.Text = tostring(1 << i)
      elseif i < 6 then -- float
        cbSigned.Checked = true
        cbSigned.Enabled = false
        edtValueSize.Enabled = false
        edtValueSize.Text = tostring(1 << i-2)
      elseif i > 7 then -- vtCustom
        edtValueSize.Text = getCustomType(types[i+1]).bytesize
      else  --string / AoB
        edtValueSize.Enabled = true
        edtValueSize.Text = '10'
        if i == 6 then
          cbHex.Enabled = false
          cbSigned.Enabled = false
          cbWChar.Enabled = true
        else  -- i == 7
          cbHex.Checked = true
        end
      end
      lblValueSize.Enabled = edtValueSize.Enabled
    end

    edtValueSize.OnExit = function(sender)
      sender.Text = tonumber(sender.Text) or '10'
    end

    cbHex.OnChange = function(sender)
      cbSigned.Enabled = not sender.Checked
      if sender.Checked then
        cbSigned.Checked = false
      end
    end

    cbSigned.OnChange = function(sender)
      cbHex.Enabled = not sender.Checked
      if sender.Checked then
        cbHex.Checked = false
      end
    end

    btnOK.OnClick = function(sender)
      local err = errorOnLookupFailure(false)
      local addr = getAddress(edtAddress.Text)
      if addr == 0 then
        showMessage('Could not determine what "'..edtAddress.Text..'" means.')
        return
      end
      errorOnLookupFailure(err)

      local vi = cmbValueType.ItemIndex
      local addr = addresses:add(setmetatable({address = addr, type = 0, typeName = types[vi+1], size = tonumber(edtValueSize.Text) * (cbWChar.Checked and 2 or 1), hex = cbHex.Checked, signed = cbSigned.Checked}, addrmt))

      if vi == 0 then
        addr.type = vtByte
      elseif  vi == 1 then
        addr.type = vtWord
      elseif  vi == 2 then
        addr.type = vtDword
      elseif  vi == 3 then
        addr.type = vtQword
      elseif  vi == 4 then
        addr.type = vtSingle
      elseif  vi == 5 then
        addr.type = vtDouble
      elseif  vi == 6 then
        addr.type = cbWChar.Checked and vtUnicodeString or vtString
      elseif  vi == 7 then
        addr.type = vtByteArray
      else
        addr.type = vtCustom
      end

      addAddressForm.close()
    end

    addAddressForm.showModal()
  end

  miRemoveAddress.OnClick = function(sender)
    local err = errorOnLookupFailure(false)
    local addr = getAddress(inputQuery('Remove Address','Which address should be removed?',''))
    errorOnLookupFailure(err)
    if addr == 0 then return end
    for i,v in ipairs(addresses) do
      if v.address == addr then
        addresses:remove(v.index)
      end
    end
  end

  pmiAddAddress.OnClick = miAddAddress.OnClick

  form.show()
end