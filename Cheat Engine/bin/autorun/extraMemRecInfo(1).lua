local mf = getMainForm()
local al = getAddressList()

local function tohexwithsign(a)
  if type(a)=='number' then
    return (a>=0 and string.format('+%X',a) or string.format('-%X',-a))
  else
    return a:sub(1,1)=='-' and a or ('+'..a)
  end
end

--panel
local panelFromExtraMemRecInfo = createPanel(mf)
panelFromExtraMemRecInfo.BevelOuter = 'bvNone'
panelFromExtraMemRecInfo.Name = 'pnlExtraMemRecInfo'
panelFromExtraMemRecInfo.Caption = ''
panelFromExtraMemRecInfo.Align = alBottom
panelFromExtraMemRecInfo.Height = 1

--splitter
local splitterFromExtraMemRecInfo = createSplitter(mf)
splitterFromExtraMemRecInfo.Align = alBottom
splitterFromExtraMemRecInfo.Height = 5
splitterFromExtraMemRecInfo.MinSize = 50 --standardize with MainForm.Splitter1.MinSize

--label
local labelFromExtraMemRecInfo = createLabel(panelFromExtraMemRecInfo)
labelFromExtraMemRecInfo.Align = alClient
labelFromExtraMemRecInfo.BorderSpacing.Around = 5

--set proper minimal size
--splitterFromExtraMemRecInfo.MinSize = labelFromExtraMemRecInfo.Canvas.getTextHeight('DdGgJjQqWwXxYy')+10

--splitter double click
local splitterDblClick = false
splitterFromExtraMemRecInfo.OnMoved = function ()
                                        --set new panel height if double click flag has not yet expire
                                        if splitterDblClick then
                                          if panelFromExtraMemRecInfo.Height == 1 then --open panel if closed
                                            panelFromExtraMemRecInfo.Height = labelFromExtraMemRecInfo.Canvas.getTextHeight('DdGgJjQqWwXxYy')*3+10
                                          else --close panel if opened
                                            panelFromExtraMemRecInfo.Height = 1
                                          end
                                          --refresh panel position else it bugs out and appear underneath bottom bar
                                          panelFromExtraMemRecInfo.Top = 0 
                                          splitterFromExtraMemRecInfo.Top = 0
                                        else
                                          splitterDblClick = true
                                          local dblClickInterval = createTimer()
                                          dblClickInterval.Interval = 500
                                          dblClickInterval.OnTimer = function () --reset double click flag after double click interval
                                                            splitterDblClick = false
                                                            dblClickInterval.destroy()
                                                          end
                                        end
                                      end

--pop-up menu
labelFromExtraMemRecInfo.PopupMenu=createPopupMenu(labelFromExtraMemRecInfo)
local pm=labelFromExtraMemRecInfo.PopupMenu
local pmi=pm.Items
local mi1=createMenuItem(pmi); pmi.add(mi1); mi1.Caption = 'Copy ID'
local mi2=createMenuItem(pmi); pmi.add(mi2); mi2.Caption = 'Copy pointer string'

mi1.OnClick = function () writeToClipboard(al.SelectedRecord.ID) end
mi2.OnClick = function ()
                local mr=al.SelectedRecord
                local pointerStr = mr.Address
                  for i=mr.OffsetCount-1,0,-1 do
                    pointerStr = '['..pointerStr..']'..tohexwithsign(mr.Offset[i])
                  end
                writeToClipboard(pointerStr)
              end

pm.OnPopup = function ()
               if al.SelectedRecord==nil then
                 mi1.Enabled=false
                 mi2.Enabled=false
               else
                 mi1.Enabled=true
                 mi2.Enabled=(al.SelectedRecord.Address~='')
               end
             end

-- timer
local function timerFuncFromExtraMemRecInfo(t)
  local mr,str = al.SelectedRecord,''
  if mr~=nil then
    str = str..'index: '..mr.Index
    str = str..'    id: '..mr.ID
    str = str..'    childrens: '..mr.Count
   if not mr.IsGroupHeader then
    str = str..'    hotkeys: '..mr.HotkeyCount
   end

    local pointerStr = mr.Address
    if pointerStr~='' and not (mr.Type==vtAutoAssembler) then
      for i=mr.OffsetCount-1,0,-1 do
        pointerStr = '['..pointerStr..']'..tohexwithsign(mr.Offset[i])
      end
      str = str..'    address: '..pointerStr
    end

    if mr.Type==vtAutoAssembler then
      if mr.Async then str = str..'\r\nasynchronous: true'
      else             str = str..'\r\nasynchronous: false' end
    elseif not mr.IsGroupHeader then
      if mr.DropDownCount>0 then str = str..'\r\ndropdown list: true'
                                 str = str..'    md5: '..stringToMD5String(mr.DropDownList.Text):upper()
      else                       str = str..'\r\ndropdown list: false' end
      if mr.DropDownReadOnly then str = str..'\r\ndropdown list options: true'
      else                        str = str..'\r\ndropdown list options: false' end
      if mr.DropDownDescriptionOnly then str = str..' true'
      else                        str = str..' false' end
      if mr.DisplayAsDropDownListItem then str = str..' true'
      else                        str = str..' false' end
    end

  end
  labelFromExtraMemRecInfo.Caption=str
end

timerFromExtraMemRecInfo = createTimer(panelFromExtraMemRecInfo)
timerFromExtraMemRecInfo.OnTimer = timerFuncFromExtraMemRecInfo
timerFromExtraMemRecInfo.Interval = 100

createTimer(nil).OnTimer = function (t) if mf.Visible then t.destroy() splitterFromExtraMemRecInfo.Top = 0 end end
