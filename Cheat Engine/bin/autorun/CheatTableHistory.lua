-- #### create onPostLoadTable function
oltcManual = 0
oltcLua    = 1

if not actOpenExecute then actOpenExecute = getMainForm().Load1.OnClick end -- manually
if not LuaLoadTable then   LuaLoadTable   = loadTable                   end -- lua

function openWithButtonOrMenu(sender)
 local drOffset = cheatEngineIs64Bit() and 0xB8 or 0x64
 actOpenExecute(sender)

 --mrOK, mrCancel
 local dialogResult = readIntegerLocal(userDataToInteger(getMainForm().OpenDialog1)+drOffset)
 local filename = getMainForm().OpenDialog1.Filename
 onPostLoadTable(filename,oltcManual,dialogResult)
end

function openWithLua(filename,merge)
 local result = LuaLoadTable(filename,merge)
 onPostLoadTable(filename,oltcLua,result)
 return result
end

getMainForm().LoadButton.OnClick = openWithButtonOrMenu  -- button
getMainForm().Load1.OnClick = openWithButtonOrMenu       -- menu

getMainForm().LoadButton.Action = nil
getMainForm().Load1.Action = nil
loadTable = openWithLua

function onPostLoadTable(filename,oltc,result)
  if     oltc==oltcLua then

    -- result can be true or false (true=loaded successfuly, false=fail)
    -- yourcode here

  elseif oltc==oltcManual then

    -- result can mrOK and mrCancel
    -- yourcode here

  end
end

-- ###









-- ### The History of opened files list
function insertHistoryMenuItem(parent,position,caption)
  if parent==nil then return nil end

  local newItem = createMenuItem(parent)
  parent.insert(position,newItem)
  newItem.Caption = caption

  collectedMenuItems[#collectedMenuItems+1] = newItem
  return newItem
end

function destroyHistoryMenuItems()
  for _,v in ipairs(collectedMenuItems) do
    v.destroy()
  end
  collectedMenuItems = {}
end

collectedMenuItems = {}
historyTable = {}
tmpTable = {}

function showHistory()

  -- I don't know any better method than deleting all new menu items and create them from the scratch
  -- to achieve new ordering

  destroyHistoryMenuItems()

  if #tmpTable==0 then return end

  local FileMenuItem = getMainForm().Menu.Items[0]

  insertHistoryMenuItem(FileMenuItem,13,'-')

  insertHistoryMenuItem(FileMenuItem,13,'Clear Recent File List').OnClick =
        function (sender)
          historyTable = {}
          saveHistory()
        end

  local from = math.min(#tmpTable,historyHowMany)

  for i=from,1,-1 do
    insertHistoryMenuItem(FileMenuItem,13,tmpTable[i].k).OnClick =
        function (sender)
          local file = io.open( utf8ToAnsi(tmpTable[i].k) ,'r')
          if file==nil then
            messageDialog("File "..tmpTable[i].k.." doesn't exist. Entry will be removed from list.", mtInformation,mbOK)
            historyTable[tmpTable[i].k] = nil
            saveHistory()
            return
          else file:close() end

          local dir = tmpTable[i].k:match([[.*%\]])
          local filename = tmpTable[i].k:sub(#dir+1)
          local filenameNoExt = filename:match('(.+)%.')
          local filter = getMainForm().OpenDialog1.Filter

          --getMainForm().OpenDialog1.Filter='similar name|'..filenameNoExt..'*.CT;'..filenameNoExt..'*.CETRAINER|'..filter
          getMainForm().OpenDialog1.Filename = filename --filenameNoExt..'*'
          getMainForm().OpenDialog1.InitialDir=dir
          --getMainForm().Load1.doClick()
          getMainForm().LoadButton.doClick()
        end
  end
end

function saveHistory()
  local file = io.open(getCheatEngineDir()..historyFileName,"w")

  if file then -- file exist?

    tmpTable = {}
    for k,v in pairs(historyTable) do
      tmpTable[#tmpTable+1] = {['k']=k,['v']=v}
    end
    table.sort(tmpTable, function (a,b) return a.v < b.v end)

    if #tmpTable==0 then file:write('') end

    local upto = math.min(#tmpTable,historyHowMany+5) -- save extra 5 (just in case)

    for i=1,upto do
      file:write(tmpTable[i].k.."\n")
    end

    file:close()
  end

  showHistory()
end

function loadHistory()
  local file = io.open(getCheatEngineDir()..historyFileName, "r")
  if not file then return end

  local pos = 1
  for line in file:lines() do
    historyTable[line] = pos
    pos = pos + 1
  end
  file:close()

  tmpTable = {}
  for k,v in pairs(historyTable) do
    tmpTable[v] = {['k']=k,['v']=v}
  end

  showHistory()
end

function onPostLoadTable(filename,oltc,result)
  if (oltc == oltcLua) or (result == mrCancel) then return end  -- skip if oltcLua or if canceled opendialog
  if filename == ''  then return end                            -- skip

  if historyIgnoreCETRAINER and filename:sub(-3):upper()~='.CT' then return end -- also skip


  for k,v in pairs(historyTable) do
    if k~=filename then historyTable[k] = v + 1 end -- update positions
  end
  historyTable[filename] = 1   -- bring to front

  saveHistory()
end

-- settings
historyFileName = 'CheatTableHistory.txt'
historyHowMany = 25
historyIgnoreCETRAINER = false

loadHistory()
