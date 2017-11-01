--Initialization------------------------------------------------------------------------------------
math.randomseed(os.time())

--Local Functions Declaration
local makeString
local extEditOnClick
local extEditCheckChange
local changeExtEditor

local CEApplication = getApplication()
local mainForm = getMainForm()
local addressList = getAddressList()
local extEditSrcPath = getCheatEngineDir()..[[autorun\External Editor.lua]]
local extEditor = [[C:\Program Files (x86)]]
local extEditorDir,extEditorFileName = extEditor:match("(.-)([^\\/]-%.?([^%.\\/]*))$")
local extEditing = {}

--Library Functions---------------------------------------------------------------------------------
function makeString(len)
  if len < 1 then return nil end -- Check for len < 1
  local string = ""
  for i = 1, len do
    local switch = math.random(0,1)
    if switch == 0 then string = string..string.char(math.random(65,90))
    elseif switch == 1 then string = string..string.char(math.random(48,57)) end
  end
  return string
end

function extEditOnClick()
  if extEditor == "" then
    changeExtEditor()
  end
  local selectedRecords = addressList.getSelectedRecords()
  for i,j in pairs(selectedRecords) do
    if j.Script ~= nil then
      if extEditing[j.ID] == nil then
        extEditing[j.ID] = {}
        extEditing[j.ID].fileName = makeString(5)..[[.CEA]]
        local checkTimer = createTimer()
        extEditing[j.ID].Timer = checkTimer
        checkTimer.Interval = 1000
        checkTimer.onTimer =
        function()
          extEditCheckChange(j.ID)
        end
      end
      local filePath = os.getenv("TEMP")..[[\Cheat Engine\]]..extEditing[j.ID].fileName
      local scriptString = createStringlist()
      scriptString.Text = j.Script
      scriptString.saveToFile(filePath)
      extEditing[j.ID].MD5Hash = md5file(filePath)
      shellExecute(extEditor,'"'..filePath:gsub('"','')..'"')
      if extEditing[j.ID].PID == nil then
        local PIDtimer = createTimer()
        PIDtimer.Interval = 500
        PIDtimer.onTimer =
        function()
          PIDtimer.destroy()
          extEditing[j.ID].PID = getProcessIDFromProcessName(extEditorFileName)
        end
      end
    end
  end
end

function extEditCheckChange(extEditingIndex)
  local checkEnable, errMsgEnable = autoAssembleCheck(scriptString.Text, true)
  local checkDisable, errMsgDisable = autoAssembleCheck(scriptString.Text, false)
  if not checkEnable then
      showMessage(errMsgEnable)
  elseif not checkDisable then
      showMessage(errMsgDisable)
  end
  local filePath = os.getenv("TEMP")..[[\Cheat Engine\]]..extEditing[extEditingIndex].fileName
  local newHash = md5file(filePath)
  if extEditing[extEditingIndex].MD5Hash ~= newHash then
    local memoryRecord = addressList.getMemoryRecordByID(extEditingIndex)
    extEditing[extEditingIndex].MD5Hash = newHash
    local scriptString = createStringlist()
    scriptString.loadFromFile(filePath)
    if messageDialog("ID"..extEditingIndex..": "..memoryRecord.Description.."\n\nThis script has been modified by another program.\nDo you want to reload it?",mtConfirmation,mbYes,mbNo) == 6 then
      memoryRecord.Script = scriptString.Text
    end
  end
  if extEditing[extEditingIndex] ~= nil and getProcesslist()[extEditing[extEditingIndex].PID] == nil then
    os.remove(filePath)
    extEditing[extEditingIndex].Timer.destroy()
    extEditing[extEditingIndex] = nil
    return
  end
end

function changeExtEditor()
	local selectEditorDialog = createOpenDialog()
  selectEditorDialog.Title = [[Change External Editor]]
  selectEditorDialog.execute()
  extEditor = selectEditorDialog.FileName
  extEditorDir,extEditorFileName = extEditor:match("(.-)([^\\/]-%.?([^%.\\/]*))$")
  local extLuaFileContent = createStringlist()
  extLuaFileContent.loadFromFile(extEditSrcPath)
  for i = 0,extLuaFileContent.Count-1 do
    if extLuaFileContent[i]:find([[local extEditor = ]]) ~= nil then
      extLuaFileContent[i] = [[local extEditor = ]].."[["..extEditor.."]]"
      break
    end
  end
  extLuaFileContent.saveToFile(extEditSrcPath)
end

--Add Menu Items------------------------------------------------------------------------------------
local extEditBtn = createMenuItem(mainForm)
extEditBtn.Caption = [[Change script with external editor]]
extEditBtn.onClick = extEditOnClick
mainForm.PopupMenu2.Items.insert(15,extEditBtn)

local mainMenu = mainForm.Menu.Items
local miExtra
--Find "Extra" item in main menu. Create one if not found.
for i=0,mainMenu.Count-1 do
	if mainMenu[i].Name == 'miExtra' then miExtra = mainMenu[i] end
end
if miExtra == nil then
	miExtra = createMenuItem(mainForm)
	miExtra.Name = 'miExtra'
	miExtra.Caption = 'Extra'
	mainMenu.insert(mainMenu.Count-2,miExtra)
end
--Add "Change External Editor" item to "Extra" submenu.
local miChangeExtEditor = createMenuItem(miExtra)
miChangeExtEditor.Caption = 'Change External Editor'
miChangeExtEditor.onClick = changeExtEditor
miExtra.add(miChangeExtEditor)

--Events--------------------------------------------------------------------------------------------
local oldPopupFunc = mainForm.PopupMenu2.OnPopup
mainForm.PopupMenu2.OnPopup =
function()
  synchronize(oldPopupFunc)
  extEditBtn.Visible = mainForm.Changescript1.Visible
end
