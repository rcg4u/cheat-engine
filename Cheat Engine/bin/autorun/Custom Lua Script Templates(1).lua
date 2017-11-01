local myLuaScriptTemplates = {}

myLuaScriptTemplates.Templates = {

{
displayName = "Auto-attach to target process",
templateSection =
[==[
function myattach(timer)
	if getProcessIDFromProcessName("%processName%") ~= nil then
		object_destroy(timer)
		openProcess("%processName%")
	end
end

t=createTimer(nil)
timer_setInterval(t,10)
timer_onTimer(t,myattach)
]==]
},

{
displayName = "Timer Template",
templateSection =
[==[
mytimer=createTimer(nil, false)
mytimer.Interval = %placeholder_Timer_Interval%
mytimer.OnTimer = function(timer)
  -- insert code here
end
mytimer.Enabled = true
]==]
},

{
displayName = "Breakpoint Template",
templateSection =
[==[
debug_setBreakpoint(address, 1, bptExecute,
function()
	debug_continueFromBreakpoint(co_run)
	return 1
end)
]==]
},

{
displayName = "Auto-activate scripts on attach",
templateSection =
[==[
function onOpenProcess()
	local timer = createTimer(nil, false)
	timer.Interval = 500
	timer.OnTimer = function(timer)
		local list = getAddressList()
		list.getMemoryRecordByDescription("%placeholder_Script_Name%").Active = true
		timer.Destroy()
	end
	timer.Enabled = true
end
]==]
},

{
displayName = "Hotkey Template",
templateSection =
[==[
myhotkey = createHotkey(function()
  -- insert code here
end, %placeholder_Key_Combo%) -- define key here
]==]
},

}

-- load scripts stored in templates folder
for i,j in pairs(getFileList(getCheatEngineDir()..[[\autorun\templates\]])) do
	local path,filename,ext = j:match("(.-)([^\\/]-%.?([^%.\\/]*))$")
	if ext == "lua" then
		local fileIn = createStringlist()
		fileIn.loadFromFile(j)
		myLuaScriptTemplates.Templates[#myLuaScriptTemplates.Templates+1] =
		{
			displayName = filename:sub(0,-5),
			templateSection = fileIn.Text
		}
	end
end
-- load scripts stored in subfolders in templates folder
for i,j in pairs(getDirectoryList(getCheatEngineDir()..[[\autorun\templates\]])) do
	local dirPath,dirName = j:match("(.-)([^\\/]-%.?([^%.\\/]*))$")
	local curTemplateIndex = #myLuaScriptTemplates.Templates+1 -- store index for later use when adding sub-entry templates
	myLuaScriptTemplates.Templates[curTemplateIndex] = -- create template group
	{
		displayName = dirName
	}
	for k,l in pairs(getFileList(j)) do
		local path,filename,ext = l:match("(.-)([^\\/]-%.?([^%.\\/]*))$")
		if ext == "lua" then
			local fileIn = createStringlist()
			fileIn.loadFromFile(l)
			myLuaScriptTemplates.Templates[curTemplateIndex][#myLuaScriptTemplates.Templates[curTemplateIndex]+1] =
			{
				displayName = filename:sub(0,-5),
				templateSection = fileIn.Text
			}
		end
	end
end

local timer=createTimer()
timer.Interval=100
timer.OnTimer =
function (t)
	local form
	for i=0,getFormCount()-1 do
		if getForm(i).Caption == "Lua script: Cheat Table" then form = getForm(i) end
	end
	if (form.Menu==nil) then return end
	t.destroy()
	myLuaScriptTemplates.addMenuEntries(form)
end

function myLuaScriptTemplates.addMenuEntries(form)
	local menu = createMenuItem(form.Menu.Items)
	menu.Name = "miLuaScriptTemplates"
	menu.Caption = "Template"
	form.Menu.Items.add(menu)
	local entryCount,groupCount = 1,1
	for i=1,#myLuaScriptTemplates.Templates do
		if myLuaScriptTemplates.Templates[i].templateSection == nil then --checks whether index is a template group
			local groupMenuItem = createMenuItem(menu)
			menu.add(groupMenuItem)
			groupMenuItem.Caption = myLuaScriptTemplates.Templates[i].displayName
			groupMenuItem.Name = 'miLuaScriptTemplateGroup'..groupCount
			groupCount = groupCount + 1
			for j=1,#myLuaScriptTemplates.Templates[i] do --adds sub-entry templates
				local menuItem = createMenuItem(groupMenuItem)
				groupMenuItem.add(menuItem)
				menuItem.OnClick =
				function (sender)
					myLuaScriptTemplates.generate(sender.Owner,myLuaScriptTemplates.Templates[i][j].templateSection)
				end
				menuItem.Caption = myLuaScriptTemplates.Templates[i][j].displayName
				menuItem.Name = 'miLuaScriptTemplate'..entryCount
				entryCount = entryCount + 1
			end
		else -- not a template group
			local menuItem = createMenuItem(menu)
			menu.add(menuItem)
			menuItem.OnClick =
			function (sender)
				myLuaScriptTemplates.generate(sender,myLuaScriptTemplates.Templates[i].templateSection)
			end
			menuItem.Caption = myLuaScriptTemplates.Templates[i].displayName
			menuItem.Name = 'miLuaScriptTemplate'..entryCount
			entryCount = entryCount + 1
		end
	end
end

function myLuaScriptTemplates.generate(sender,template)
	local form = sender.Owner.Owner.Owner.Owner
	local origScript = form.Assemblescreen.Lines.Text

	if origScript == '\r\n' then origScript = '' end -- after manually deleting all lines, there's always one empty line

	-- use the template
	local processName = getProcessList()[getOpenedProcessID()]
	if processName == nil then processName = '' end
	template = template:gsub("%%processName%%", processName)
	-- prompt and replace %placeholder_XXX% keyword
	while (template:find("%%placeholder_.-%%") ~= nil) do
		local placeholderFull, placeholderName = template:match("(%%placeholder_(.-)%%)")
		placeholderName = placeholderName:gsub("_"," ")
		local placeholderReplace = inputQuery("Keyword Replacement","Enter replacement for keyword \""..placeholderName.."\":","")
		if placeholderReplace == nil then return end -- exits generating template if prompt canceled
		template = template:gsub("%"..placeholderFull.."%", placeholderReplace)
	end

	local newScript = origScript..template
	form.Assemblescreen.Lines.Text = newScript -- update
end