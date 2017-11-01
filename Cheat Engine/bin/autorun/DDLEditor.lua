--Initializer--------------------------------------------------------------------------------------

local DDLForm = createFormFromFile(getCheatEngineDir()..[[\autorun\forms\DDLEditor.frm]])

local mf = getMainForm().Menu.Items
local miExtra
--Find "Extra" item in main menu. Create one if not found.
for i=0,mf.Count-1 do
	if mf[i].Name == 'miExtra' then miExtra = mf[i] end
end
if miExtra == nil then
	miExtra = createMenuItem(mf)
	miExtra.Name = 'miExtra'
	miExtra.Caption = 'Extra'
	mf.insert(mf.Count-2,miExtra)
end
--Add "Dropdown List Editor" item to "Extra" submenu.
local miDDL = createMenuItem(miExtra)
miDDL.Caption = 'Dropdown List Editor'
miDDL.onClick =
function()
	DDLEditor.show()
	DDLEditor.lastSelected = DDLEditor.cbDropDownList.ItemIndex
end
miExtra.add(miDDL)

--Variables----------------------------------------------------------------------------------------

DDLEditor.OutputLog = false
DDLEditor.Prefix = 'myDropDownList_'
DDLEditor.NamesPrefix = 'myDropDownListName_'
DDLEditor.OptionsPrefix = 'myDropDownListOptions_'
									
--Library Functions--------------------------------------------------------------------------------

--Local Functions Declaration
local getLuaScript
local addToLuaScript
local queryName
local toBoolean
local toStringList
local isDuplicate
local updateConfig
local loadConfig
local saveConfig
local boldSaveBtn
local checkPendingSave
local resetSaveBtn
local DDLEditor_populateComboBox
local DDLEditor_refresh
local DDLEditor_add
local DDLEditor_save
local DDLEditor_delete
local DDLEditor_loadList
local DDLEditor_loadNames
local DDLEditor_loadOptions
local DDEditor_execute
local DDLEditor_saveConfirm
local DDLEditor_rename
local DDLEditor_changePrefix
local DDLEditor_changeNamesPrefix
local DDLEditor_changeOptionsPrefix
local addScripts
local DDLEditor_close

--Gets Lua script Form
function getLuaScript()
	for i=0,getFormCount()-1 do
		local form = getForm(i)
		if form.Name == 'frmAutoInject' then
			return form
		end
	end
end

--Concatenate string to Lua script. Can concatenate to start or end of script.
function addToLuaScript(string,addToTop,spacingCount)
	local luaScript = getLuaScript()
	--Sets spacing
	local spacing = ''
	if spacingCount == nil then spacingCount = 1 end
	--Mandatory newline when adding to top
	if addToTop ~= false then spacing = '\r\n' end
	for i=2,spacingCount do	spacing = spacing..'\r\n' end
	--Concatenate
	if addToTop == false then
		luaScript.assemblescreen.Lines.Text = luaScript.assemblescreen.Lines.Text..spacing..string
	else
		luaScript.assemblescreen.Lines.Text = string..spacing..luaScript.assemblescreen.Lines.Text
	end
end

--Input Query for name
function queryName(mode)
	local itemName = ''
	while itemName == '' do
		if mode == nil then
			itemName = inputQuery('Add Dropdown List','Give the list a name:','')
		else
			itemName = inputQuery('Rename Dropdown List','Give the list a name:','')
		end
	end
	if itemName == nil then return end
	--Replace spaces with underscores
	itemName = itemName:gsub("%s","_")
	--Duplicate Name Check
	local luaScript = getLuaScript()
	while isDuplicate(DDLEditor.Prefix..itemName..'%s*=',luaScript.assemblescreen.Lines) do
		itemName = ''
		while itemName == '' do
			if mode == nil then
				itemName = inputQuery('Add Dropdown List','Duplicate found. Give another name:','')
			else
				itemName = inputQuery('Rename Dropdown List','Duplicate found. Give another name:','')
			end
		end
		if itemName == nil then return end
		--Replace spaces with underscores
		itemName = itemName:gsub("%s","_")
	end
	return itemName
end
--Converts 'true/false' string to boolean.
function toBoolean(string)
	if string == 'true' then
		return true
	end
	return false
end

--Convert string to stringlist.
function toStringList(string)
         local stringList = createStringlist()
         stringList.Text = string
         return stringList
end

--Finds string in stringList and returns whether there is a duplicate.
function isDuplicate(string,stringList)
	for i=0,stringList.Count-1 do
		if string.find(stringList[i],string) ~= nil then
			return true
		end
	end
	return false
end

--Update config strings
function updateConfig()
	DDLEditor.configFile.Text = [[]] --Reset strings to build config file anew, removes any redundant lines
	DDLEditor.configFile.add(0,"DDLEditor.OutputLog = "..tostring(DDLEditor.OutputLog))
	DDLEditor.configFile.add(1,"DDLEditor.Prefix = "..DDLEditor.Prefix:sub(0,string.len(DDLEditor.Prefix)-1))
	DDLEditor.configFile.add(2,"DDLEditor.NamesPrefix = "..DDLEditor.NamesPrefix:sub(0,string.len(DDLEditor.NamesPrefix)-1))
	DDLEditor.configFile.add(3,"DDLEditor.OptionsPrefix = "..DDLEditor.OptionsPrefix:sub(0,string.len(DDLEditor.OptionsPrefix)-1))
end

--Load config file
function loadConfig()
	local loadResult = DDLEditor.configFile.loadFromFile(getCheatEngineDir()..[[\autorun\DDLEditor.cfg]])
	if loadResult then
		local readOutputLog = DDLEditor.configFile.Text:match("DDLEditor%.OutputLog%s*=%s*(%a*)")
		local readPrefix = DDLEditor.configFile.Text:match("DDLEditor%.Prefix%s*=%s*(%S*)").."_"
		local readNamesPrefix = DDLEditor.configFile.Text:match("DDLEditor%.NamesPrefix%s*=%s*(%S*)").."_"
		local readOptionsPrefix = DDLEditor.configFile.Text:match("DDLEditor%.OptionsPrefix%s*=%s*(%S*)").."_"
		if readOutputLog ~= nil then
			DDLEditor.OutputLog = toBoolean(readOutputLog)
			DDLEditor.chkOutputLog.Checked = toBoolean(readOutputLog)
		end
		if readPrefix ~= nil then DDLEditor.Prefix = readPrefix end
		if readNamesPrefix ~= nil then DDLEditor.NamesPrefix = readNamesPrefix end
		if readOptionsPrefix ~= nil then DDLEditor.OptionsPrefix = readOptionsPrefix end
	end
	return loadResult
end

--Save config strings to file
function saveConfig()
	updateConfig()
	return DDLEditor.configFile.saveToFile(getCheatEngineDir()..[[\autorun\DDLEditor.cfg]])
end

--Bold save button
function boldSaveBtn()
	DDLEditor.btnSaveDropDown.Font.Style = '[fsBold]'
	DDLEditor.btnSaveDropDown.Font.Size = 10
end

--Check if save button is bold
function checkPendingSave()
	if DDLEditor.btnSaveDropDown.Font.Style:find("fsBold") ~= nil then return true end
	return false
end

--Reset save button
function resetSaveBtn()
	DDLEditor.btnSaveDropDown.Font.Style = ''
	DDLEditor.btnSaveDropDown.Font.Size = 0
end

--Button Functions---------------------------------------------------------------------------------

function DDLEditor_populateComboBox()
	local luaScript = getLuaScript()
	local n = 0
	if luaScript ~= nil then
		for i=0,luaScript.assemblescreen.Lines.Count-1 do
			--Searches Lua script for droplist prefix and adds name to combobox
			if string.find(luaScript.assemblescreen.Lines[i],DDLEditor.Prefix..'.*%s*%=%s*%[%[') ~= nil then
				DDLEditor.cbDropDownList.Items[n] = string.match(luaScript.assemblescreen.Lines[i],DDLEditor.Prefix..'(.-)%s*%=%s*%[%[')
				n = n+1
			end
		end
	end
end

function DDLEditor_refresh()
	--Clears all entries and checkboxes
	DDLEditor.cbDropDownList.Items.clear()
	DDLEditor.mmList.Lines.clear()
	DDLEditor.mmMatch.Lines.clear()
	DDLEditor.chkReadOnly.Checked = false
	DDLEditor.chkDescriptionOnly.Checked = false
	DDLEditor.chkDisplayLike.Checked = false
	--Searches for any dropdown lists again
	DDLEditor_populateComboBox()
	--Reset combo box's selected index to the first entry if available
	DDLEditor.cbDropDownList.ItemIndex = 0
	--Reload dropdown list and match list to the first entry if available
	DDLEditor_loadList()
	DDLEditor_loadNames()
	DDLEditor_loadOptions()
	--Reset save button if it was bold
	resetSaveBtn()
	DDLEditor.lastSelected = DDLEditor.cbDropDownList.ItemIndex
end

function DDLEditor_add()
	local itemName = queryName()
	if itemName ~= nil then
		--Add empty Dropdown list to Lua script
		addToLuaScript(DDLEditor.Prefix..itemName..' = [[]]',true,2)
		DDLEditor_refresh()
	end
end

function DDLEditor_save()
	local subName
	--Queries for name to save new list under, when there were no items(lists) in combobox previously.
	if DDLEditor.cbDropDownList.ItemIndex == -1 then
		subName = queryName()
		if subName == nil then return false end
	else
	--Gets name of currently selected dropdown list.
		subName = DDLEditor.cbDropDownList.Items.String[DDLEditor.cbDropDownList.ItemIndex]
	end
	--[Table Order]-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	--Dropdown List
	--Names List
	--Options List
	----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	local itemName = {
		DDLEditor.Prefix..subName,
		DDLEditor.NamesPrefix..subName,
		DDLEditor.OptionsPrefix..subName
	}
	local findPattern = {
		itemName[1]..'%s*=%s*%[%[.-%]%]%s*',
		itemName[2]..'%s*=%s*%[%[.-%]%]%s*',
		itemName[3]..'%s*=%s*%{.-%}%s*'
	}
	
	local replacePattern = {}
	replacePattern[1] = itemName[1]..' = [['..DDLEditor.mmList.Lines.Text..']]'
	--Blankout replace pattern if content is empty, effectively, deleting old strings.----
	--(Applies to NameList and OptionsList only.)-----------------------------------------
	if DDLEditor.mmMatch.Lines.Text ~= '' then
		replacePattern[2] = itemName[2]..' = [['..DDLEditor.mmMatch.Lines.Text..']]'
	else
		replacePattern[2] = ''	end
	if not (DDLEditor.chkReadOnly.Checked == false and
		DDLEditor.chkDescriptionOnly.Checked == false and
		DDLEditor.chkDisplayLike.Checked == false)
	then replacePattern[3] = itemName[3]..' = {'..tostring(DDLEditor.chkReadOnly.Checked)..','..tostring(DDLEditor.chkDescriptionOnly.Checked)..','..tostring(DDLEditor.chkDisplayLike.Checked)..'}'
	else replacePattern[3] = ''	end
	----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	
	--Saving Lua script---
	local luaScript = getLuaScript()
	for i=3,1,-1 do
		--Find old string in Lua script and replace with new string if found.
		if string.find(luaScript.assemblescreen.Lines.Text,findPattern[i]) ~= nil then
			--Double Spacing----------------------------------------------------
			if replacePattern[i] ~= '' then replacePattern[i] = replacePattern[i]..'\r\n\r\n' end
			
			luaScript.assemblescreen.Lines.Text = string.gsub(luaScript.assemblescreen.Lines.Text,findPattern[i],replacePattern[i],1)
		else
			--Adds new strings to Lua script if no old strings found, only if new string is not empty.
			if not (i ~= 1 and replacePattern[i] == '') then
				addToLuaScript(replacePattern[i],true,2)
			end
		end
	end
	--Refresh if there was no lists previously
	if DDLEditor.cbDropDownList.ItemIndex == -1 then DDLEditor_refresh() end
	return true
end

function DDLEditor_delete()
	local confirm = messageDialog('Are you sure?',mtConfirmation,mbYes,mbNo)
	if confirm == mrYes then
		if DDLEditor.cbDropDownList.ItemIndex ~= -1 then
			--[Table Order]---------------------------------------------------------------------------------------
			--Dropdown List
			--Names List
			--Options List
			------------------------------------------------------------------------------------------------------
			local itemName = {
				DDLEditor.Prefix..DDLEditor.cbDropDownList.Items.String[DDLEditor.cbDropDownList.ItemIndex],
				DDLEditor.NamesPrefix..DDLEditor.cbDropDownList.Items.String[DDLEditor.cbDropDownList.ItemIndex],
				DDLEditor.OptionsPrefix..DDLEditor.cbDropDownList.Items.String[DDLEditor.cbDropDownList.ItemIndex]
			}
			local findPattern = {
				itemName[1]..'%s*=%s*%[%[.-%]%]%s*',
				itemName[2]..'%s*=%s*%[%[.-%]%]%s*',
				itemName[3]..'%s*=%s*%{.-%}%s*'
			}
			------------------------------------------------------------------------------------------------------
			local luaScript = getLuaScript()
			for i=1,3 do
				luaScript.assemblescreen.Lines.Text = string.gsub(luaScript.assemblescreen.Lines.Text,findPattern[i],'',1)
			end
			DDLEditor_refresh()
		end
	end
end

function DDLEditor_loadList()
	if DDLEditor.cbDropDownList.ItemIndex ~= -1 then
		local itemName = DDLEditor.cbDropDownList.Items.String[DDLEditor.cbDropDownList.ItemIndex]
		local luaScript = getLuaScript()
		local tmp = string.match(luaScript.assemblescreen.Lines.Text,DDLEditor.Prefix..itemName..'%s*=%s*%[%[(.-)%]%]')
		DDLEditor.mmList.Lines.Text = tmp
	end
end

function DDLEditor_loadNames()
	if DDLEditor.cbDropDownList.ItemIndex ~= -1 then
		local itemName = DDLEditor.cbDropDownList.Items.String[DDLEditor.cbDropDownList.ItemIndex]
		local luaScript = getLuaScript()
		local tmp = string.match(luaScript.assemblescreen.Lines.Text,DDLEditor.NamesPrefix..itemName..'%s*=%s*%[%[(.-)%]%]')
		DDLEditor.mmMatch.Lines.Text = tmp
	end
end

function DDLEditor_loadOptions()
	if DDLEditor.cbDropDownList.ItemIndex ~= -1 then
		local itemName = DDLEditor.cbDropDownList.Items.String[DDLEditor.cbDropDownList.ItemIndex]
		local luaScript = getLuaScript()
		local tmp = string.match(luaScript.assemblescreen.Lines.Text,DDLEditor.OptionsPrefix..itemName..'%s*=%s*%{(.-)%}')
		--Checks if options list exists, else creates an empty one--------
		if tmp == nil then tmp = 'false,false,false' end
		local a,b,c = string.match(tmp,'%s*(%a*)%s*,%s*(%a*)%s*,%s*(%a*)')
		------------------------------------------------------------------
		DDLEditor.chkReadOnly.Checked = toBoolean(a)
		DDLEditor.chkDescriptionOnly.Checked = toBoolean(b)
		DDLEditor.chkDisplayLike.Checked = toBoolean(c)
	end
end

function DDEditor_execute()
	for v=0,DDLEditor.cbDropDownList.Items.Count-1 do
		local luaScript = getLuaScript()
		local itemName = DDLEditor.cbDropDownList.Items[v]
		--Get dropdown list, name list and options list
		local list = string.match(luaScript.assemblescreen.Lines.Text,DDLEditor.Prefix..itemName..'%s*=%s*%[%[(.-)%]%]')
		local listName = string.match(luaScript.assemblescreen.Lines.Text,DDLEditor.NamesPrefix..itemName..'%s*=%s*%[%[(.-)%]%]')
		local listOptions = string.match(luaScript.assemblescreen.Lines.Text,DDLEditor.OptionsPrefix..itemName..'%s*=%s*%{(.-)%}')
		--Convert listName to Stringlist----
		listName = toStringList(listName)
		------------------------------------
		--Load Options from listOptions string---
		local a,b,c
		if listOptions ~= nil then
			a,b,c = string.match(listOptions,'%s*(%a*)%s*,%s*(%a*)%s*,%s*(%a*)')
		else
			a,b,c = false,false,false
		end
		-----------------------------------------
		local al=getAddressList()
		for i=0,al.Count-1 do
			for j = 0, listName.Count-1 do
				--No Parent String Found
				if string.find(listName[j],':') == nil then
					if al[i].Description:match(listName[j]) then
						--Output Log--------------------------------------------------------------------------
						if DDLEditor.OutputLog == true then
							local a = string.format("%-15s %s","Match Found @","\""..al[i].Description.."\"")
							local b = string.format("%-15s %s","Matched Name:","\""..listName[j].."\"\r\n")
							print(a)
							print(b)
						end
						--------------------------------------------------------------------------------------
						al[i].DropDownList.Text = list
						al[i].DropDownReadOnly = toBoolean(a)
						al[i].DropDownDescriptionOnly = toBoolean(b)
						al[i].DisplayAsDropDownListItem = toBoolean(c)
					end
				else
				--Parent String Found
					if al[i].Parent ~= nil then
						local splitName = listName[j]:match('(.*):')
						local splitParent = listName[j]:match(':(.*)')
						if al[i].Parent.Description:match(splitParent) and al[i].Description:match(splitName) then
							--Output Log--------------------------------------------------------------------------
							if DDLEditor.OutputLog == true then
								local a = string.format("%-15s %s","Match Found @","\""..al[i].Description.."\"")
								local b = string.format("%-15s %s","Matched Name:","\""..splitName.."\"")
								local c = string.format("%-25s %s","Parent:","\""..al[i].Parent.Description.."\"\r\n")
								print(a)
								print(b)
								print(c)
							end
							--------------------------------------------------------------------------------------
							al[i].DropDownList.Text = list
							al[i].DropDownReadOnly = toBoolean(a)
							al[i].DropDownDescriptionOnly = toBoolean(b)
							al[i].DisplayAsDropDownListItem = toBoolean(c)
						end
					end
				end
			end
		end
	end
end

function DDLEditor_saveConfirm()
	local subName
	if DDLEditor.cbDropDownList.ItemIndex == -1 then
	--Sets name for new dropdown list.
		subName = 'Untitled'
	else
	--Gets name of currently selected dropdown list.
		subName = DDLEditor.cbDropDownList.Items.String[DDLEditor.lastSelected]
	end
	--Prompts whether to save when there are pending changes.
	if checkPendingSave() then
		--Backup new dropdown list index and change index to last selected to save.
		local indexNew = DDLEditor.cbDropDownList.ItemIndex
		DDLEditor.cbDropDownList.ItemIndex = DDLEditor.lastSelected
		local confirm = messageDialog("Do you want to save changes to "..subName,mtConfirmation,mbYes,mbNo,mbCancel)
		--Breaks and returns false if confirmation prompt or save dialog is canceled.
		if confirm == mrYes then
			if DDLEditor_save() then
				resetSaveBtn()
			else
				--Restore new index
				DDLEditor.cbDropDownList.ItemIndex = indexNew
				return false
			end
		elseif confirm == mrCancel then
			--Restore new index
			DDLEditor.cbDropDownList.ItemIndex = indexNew
			return false
		end
		--Restore new index
		DDLEditor.cbDropDownList.ItemIndex = indexNew
	end
	return true
end

function DDLEditor_rename()
	local newName
	if DDLEditor.cbDropDownList.ItemIndex ~= -1 then
		newName = queryName(1)
		if newName ~= nil then
			local luaScript = getLuaScript()
			luaScript.assemblescreen.Lines.Text = luaScript.assemblescreen.Lines.Text:gsub(DDLEditor.Prefix..DDLEditor.cbDropDownList.Items[DDLEditor.cbDropDownList.ItemIndex],DDLEditor.Prefix..newName)
			luaScript.assemblescreen.Lines.Text = luaScript.assemblescreen.Lines.Text:gsub(DDLEditor.NamesPrefix..DDLEditor.cbDropDownList.Items[DDLEditor.cbDropDownList.ItemIndex],DDLEditor.NamesPrefix..newName)
			luaScript.assemblescreen.Lines.Text = luaScript.assemblescreen.Lines.Text:gsub(DDLEditor.OptionsPrefix..DDLEditor.cbDropDownList.Items[DDLEditor.cbDropDownList.ItemIndex],DDLEditor.OptionsPrefix..newName)
			DDLEditor.cbDropDownList.Items[DDLEditor.cbDropDownList.ItemIndex] = newName
		end
	end
end

function DDLEditor_changePrefix()
	local newPrefix
	local promptFlag = 0
	while true do
		--Query for new prefix
		if promptFlag == 0 then
			newPrefix = inputQuery("Change dropdown list prefix", "Enter new prefix:", DDLEditor.Prefix:sub(0,string.len(DDLEditor.Prefix)-1))
		elseif promptFlag == 1 then
			newPrefix = inputQuery("Change dropdown list prefix", "Only spaces detected. Re-enter new prefix:", DDLEditor.Prefix:sub(0,string.len(DDLEditor.Prefix)-1))
		elseif promptFlag == 2 then
			newPrefix = inputQuery("Change dropdown list prefix", "Duplicate prefix. Re-enter new prefix:", DDLEditor.Prefix:sub(0,string.len(DDLEditor.Prefix)-1))
		end
		--Break if inputQuery was canceled
		if newPrefix == nil then
			promptFlag = nil
			break
		elseif newPrefix:match("%S") == nil then --Set prompt to give another name
			promptFlag = 1
		end
		--Concatenate underscore to new prefix
		newPrefix = newPrefix.."_"
		if
			newPrefix:find(DDLEditor.NamesPrefix) ~= nil or
			newPrefix:find(DDLEditor.OptionsPrefix) ~= nil or
			DDLEditor.NamesPrefix:find(newPrefix) ~= nil or
			DDLEditor.OptionsPrefix:find(newPrefix) ~= nil
		then
			promptFlag = 2
		else --Replaces any spaces in new prefix with underscores and break
			newPrefix:gsub("%s","_")
			break
		end
	end
	if newPrefix ~= nil then
		local luaScript = getLuaScript()
		luaScript.assemblescreen.Lines.Text = luaScript.assemblescreen.Lines.Text:gsub(DDLEditor.Prefix,newPrefix)
		DDLEditor.Prefix = newPrefix
	end
end

function DDLEditor_changeNamesPrefix()
	local newPrefix
	local promptFlag = 0
	while true do
		--Query for new prefix
		if promptFlag == 0 then
			newPrefix = inputQuery("Change names prefix", "Enter new prefix:", DDLEditor.NamesPrefix:sub(0,string.len(DDLEditor.NamesPrefix)-1))
		elseif promptFlag == 1 then
			newPrefix = inputQuery("Change names prefix", "Only spaces detected. Re-enter new prefix:", DDLEditor.NamesPrefix:sub(0,string.len(DDLEditor.NamesPrefix)-1))
		elseif promptFlag == 2 then
			newPrefix = inputQuery("Change names prefix", "Duplicate prefix. Re-enter new prefix:", DDLEditor.NamesPrefix:sub(0,string.len(DDLEditor.NamesPrefix)-1))
		end
		--Break if inputQuery was canceled
		if newPrefix == nil then
			promptFlag = nil
			break
		elseif newPrefix:match("%S") == nil then --Set prompt to give another name
			promptFlag = 1
		end
		--Concatenate underscore to new prefix
		newPrefix = newPrefix.."_"
		if
				newPrefix:find(DDLEditor.Prefix) ~= nil or
				newPrefix:find(DDLEditor.OptionsPrefix) ~= nil or
				DDLEditor.Prefix:find(newPrefix) ~= nil or
				DDLEditor.OptionsPrefix:find(newPrefix) ~= nil
			then
			promptFlag = 2
		else --Replaces any spaces in new prefix with underscores and break
			newPrefix:gsub("%s","_")
			break
		end
	end
	if newPrefix ~= nil then
		local luaScript = getLuaScript()
		luaScript.assemblescreen.Lines.Text = luaScript.assemblescreen.Lines.Text:gsub(DDLEditor.NamesPrefix,newPrefix)
		DDLEditor.NamesPrefix = newPrefix
	end
end

function DDLEditor_changeOptionsPrefix()
	local newPrefix
	local promptFlag = 0
	while true do
		--Query for new prefix
		if promptFlag == 0 then
			newPrefix = inputQuery("Change options prefix", "Enter new prefix:", DDLEditor.OptionsPrefix:sub(0,string.len(DDLEditor.OptionsPrefix)-1))
		elseif promptFlag == 1 then
			newPrefix = inputQuery("Change options prefix", "Only spaces detected. Re-enter new prefix:", DDLEditor.OptionsPrefix:sub(0,string.len(DDLEditor.OptionsPrefix)-1))
		elseif promptFlag == 2 then
			newPrefix = inputQuery("Change options prefix", "Duplicate prefix. Re-enter new prefix:", DDLEditor.OptionsPrefix:sub(0,string.len(DDLEditor.OptionsPrefix)-1))
		end
		--Break if inputQuery was canceled
		if newPrefix == nil then
			promptFlag = nil
			break
		elseif newPrefix:match("%S") == nil then --Set prompt to give another name
			promptFlag = 1
		end
		--Concatenate underscore to new prefix
		newPrefix = newPrefix.."_"
		if
				newPrefix:find(DDLEditor.Prefix) ~= nil or
				newPrefix:find(DDLEditor.NamesPrefix) ~= nil or
				DDLEditor.Prefix:find(newPrefix) ~= nil or
				DDLEditor.NamesPrefix:find(newPrefix) ~= nil
			then
			promptFlag = 2
		else --Replaces any spaces in new prefix with underscores and break
			newPrefix:gsub("%s","_")
			break
		end
	end
	if newPrefix ~= nil then
		local luaScript = getLuaScript()
		luaScript.assemblescreen.Lines.Text = luaScript.assemblescreen.Lines.Text:gsub(DDLEditor.OptionsPrefix,newPrefix)
		DDLEditor.OptionsPrefix = newPrefix
	end
end

function addScripts()
	local luaScript = getLuaScript()
	--Deletes any addDropDownList calls
	luaScript.assemblescreen.Lines.Text = string.gsub(luaScript.assemblescreen.Lines.Text,'addDropDownList%([^l][^i][^s][^t].[^%.][^%.][^%.]%S*%s*','')
	if DDLEditor.cbDropDownList.Items.Count > 0 and luaScript.assemblescreen.Lines.Text:find(DDLEditor.NamesPrefix) ~= nil then
		local tmp = [[
function addDropDownList(list,...)
	local listName, listOptions = ...
	if listName == nil then return end
	if listOptions == nil then listOptions = {false,false,false} end
	--Convert listName to Stringlist---
    local tmp = createStringlist()
	tmp.Text = listName
	listName = tmp
	-----------------------------------
	local al = getAddressList()
	for i=0,al.Count-1 do
		for j = 0, listName.Count-1 do
			--No Parent String Found
			if string.find(listName[j],':') == nil then
				if al[i].Description:match(listName[j]) then
					--Output Log--------------------------------------------------------------------------
					if DDLEditor ~= nil and  DDLEditor.OutputLog == true then
						local a = string.format("%-15s %s","Match Found @","\""..al[i].Description.."\"")
						local b = string.format("%-15s %s","Matched Name:","\""..listName[j].."\"\r\n")
						print(a)
						print(b)
					end
					--------------------------------------------------------------------------------------
					al[i].DropDownList.Text = list
					al[i].DropDownReadOnly = listOptions[1]
					al[i].DropDownDescriptionOnly = listOptions[2]
					al[i].DisplayAsDropDownListItem = listOptions[3]
				end
			else
			--Parent String Found
				if al[i].Parent ~= nil then
					local splitName = listName[j]:match('(.*):')
					local splitParent = listName[j]:match(':(.*)')
					if al[i].Parent.Description:match(splitParent) and al[i].Description:match(splitName) then
						--Output Log--------------------------------------------------------------------------
						if DDLEditor ~= nil and DDLEditor.OutputLog == true then
							local a = string.format("%-15s %s","Match Found @","\""..al[i].Description.."\"")
							local b = string.format("%-15s %s","Matched Name:","\""..splitName.."\"")
							local c = string.format("%-25s %s","Parent:","\""..al[i].Parent.Description.."\"\r\n")
							print(a)
							print(b)
							print(c)
						end
						--------------------------------------------------------------------------------------
						al[i].DropDownList.Text = list
						al[i].DropDownReadOnly = listOptions[1]
						al[i].DropDownDescriptionOnly = listOptions[2]
						al[i].DisplayAsDropDownListItem = listOptions[3]
					end
				end
			end
		end
	end
end

]]
		--Adds standalone addDropDownList Lua function to script
		if string.find(luaScript.assemblescreen.Lines.Text,'function addDropDownList%(list,...%)') == nil then
			addToLuaScript(tmp,false)
		end
		--Adds standalone addDropDownList commands
		for i=0,DDLEditor.cbDropDownList.Items.Count-1 do
			local a = DDLEditor.Prefix..DDLEditor.cbDropDownList.Items[i]
			local b = DDLEditor.NamesPrefix..DDLEditor.cbDropDownList.Items[i]
			local c = DDLEditor.OptionsPrefix..DDLEditor.cbDropDownList.Items[i]
			if luaScript.assemblescreen.Lines.Text:find(b) ~= nil then
				if luaScript.assemblescreen.Lines.Text:find(c) ~= nil then
					addToLuaScript('addDropDownList('..a..','..b..','..c..')\r\n',false)
				else
					addToLuaScript('addDropDownList('..a..','..b..')\r\n',false)
				end
			end
		end
	else
		--Deletes all addDropDownList function if no dropdown lists or no name lists found
		luaScript.assemblescreen.Lines.Text = string.gsub(luaScript.assemblescreen.Lines.Text,'%s*function%s*addDropDownList.-end.-end.-end.-end.-end.-end.-end.-end.-end.-end.-end%s*','')
	end
end

--Main---------------------------------------------------------------------------------------------

--Create combo box popup menu
local cbDropDownListPopupMenu = createPopupMenu(DDLEditor)
local renameBtn = createMenuItem(cbDropDownListPopupMenu)
local prefixBtn = createMenuItem(cbDropDownListPopupMenu)
local namesPrefixBtn = createMenuItem(cbDropDownListPopupMenu)
local optionsPrefixBtn = createMenuItem(cbDropDownListPopupMenu)
renameBtn.Caption = 'Rename'
prefixBtn.Caption = 'Change dropdown list prefix'
namesPrefixBtn.Caption = 'Change names prefix'
optionsPrefixBtn.Caption = 'Change options prefix'
DDLEditor.cbDropDownList.PopupMenu = cbDropDownListPopupMenu
cbDropDownListPopupMenu.Items.add(renameBtn)
cbDropDownListPopupMenu.Items.add(prefixBtn)
cbDropDownListPopupMenu.Items.add(namesPrefixBtn)
cbDropDownListPopupMenu.Items.add(optionsPrefixBtn)

--Load config file. Create new one if not exists.
DDLEditor.configFile = createStringlist()
local loadResult = loadConfig()
if not loadResult then
	saveConfig()
end

--Events-------------------------------------------------------------------------------------------

DDLEditor.onShow = DDLEditor_refresh

---------------

DDLEditor.cbDropDownList.onChange = 
function()
	if not DDLEditor_saveConfirm() then
		DDLEditor.cbDropDownList.ItemIndex = DDLEditor.lastSelected
		return
	end
	DDLEditor_loadList()
	DDLEditor_loadNames()
	DDLEditor_loadOptions()
	resetSaveBtn()
	DDLEditor.lastSelected = DDLEditor.cbDropDownList.ItemIndex
end
renameBtn.onClick = DDLEditor_rename
prefixBtn.onClick = DDLEditor_changePrefix
namesPrefixBtn.onClick = DDLEditor_changeNamesPrefix
optionsPrefixBtn.onClick = DDLEditor_changeOptionsPrefix

---------------

DDLEditor.btnRefreshDropDown.onClick =
function()
	if not DDLEditor_saveConfirm() then return end
	DDLEditor_refresh()
end
DDLEditor.btnSaveDropDown.onClick =
function()
	if DDLEditor_save() then resetSaveBtn() end
end
DDLEditor.btnAddDropDown.onClick =
function()
	if not DDLEditor_saveConfirm() then return end
	DDLEditor_add()
end
DDLEditor.btnDeleteDropDown.onClick = 
function()
	if DDLEditor.cbDropDownList.ItemIndex ~= -1 then DDLEditor_delete() end
end

---------------

DDLEditor.btnExecute.onClick =
function()
	if not DDLEditor_saveConfirm() then return end
	DDEditor_execute()
end
function DDLEditor_close()
	if not DDLEditor_saveConfirm() then return end
	addScripts()
	saveConfig()
	DDLEditor.hide()
end
DDLEditor.btnDone.onClick = DDLEditor_close
DDLEditor.onClose = DDLEditor_close

---------------

DDLEditor.mmList.onChange = boldSaveBtn
DDLEditor.mmMatch.onChange = boldSaveBtn
DDLEditor.chkReadOnly.onChange = boldSaveBtn
DDLEditor.chkDescriptionOnly.onChange = boldSaveBtn
DDLEditor.chkDisplayLike.onChange = boldSaveBtn
DDLEditor.chkOutputLog.onChange =
function()
	DDLEditor.OutputLog = DDLEditor.chkOutputLog.Checked
end