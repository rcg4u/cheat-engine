--[====================================================================================================================[

I2 Cheat Engine Lua Script Template Generator

    Version: 1.0.1

	Author: Matt - TheyCallMeTim13 - MattI2.com

	Forked Version of:
		"Custom Lua Script Templates.lua":
			Author: predprey


	Features:
		- Allows for adding templates as tables or in a directory structure.

			- Load templates function can be called multiple time to allow for standard and game specific templates.

			- Template table structure sets the menu item structure created.

		- Generic place holder key replacement though standard input forms.

		- Gets the file version of the process's executable, for use in templates.



	For the default templates see:
		- CE Form >> Ctrl+M >> Ctrl+A >> Menu >> Templates >> I2 CEA Templates


	To add templates use:
		local TemplatesTable = {
		    ...
		}
		I2CELuaScriptTemplates.loadTemplates(TemplatesTable)



	To add templates from a directory:
		I2CELuaScriptTemplates.loadTemplatesDirectory([[x:\SomeOddDirectory]])



	Install / Setup Method 1:
		- Put file in CE autorun folder, run Cheat engine.
		
	Install / Setup Method 2:
		- Put in CE lua folder (it isn't created by default).
			And in a file in the CE autorun folder import and add tables.

		Example:
			local TemplatesTable = {
			    ...
			}

			local I2CELSTG = require 'pluginI2CELuaScriptTemplateGenerator'
			---- You could rename the file if you go this route.
			I2CELSTG.loadTemplates(TemplatesTable)



	Notes:
		- Has a translation function that just returns the string back, 
			I want to look into translation setup for CE / Lua.
					* See: 'TODO: Look into translation setup for CE.' / 'local function t(tanslationStr)'
					
		- For some reason when using from an address list script the script will not get added to the form's text edit.
			** Must use memory records to have added to address list for now (still figuring this out.)
				But only happens with address list scripts.



	Settings:

		UserNameEnvKey			: string - Environment variable key for user name.
									i.e.: 'CE_USERNAME' or 'HEYBUDDYWHATSTHENAME'
		UserName				: string - Used for overriding the system's user name from environment ('USERNAME').
					** See 'Environment Variable Keys' to override that way.

		DateFormat				: string - Lua date format string.

		AddMainSeperator		: boolean - Set to true to have a separator added to the menu before adding
									template menu items.

		PlaceHolderKey			: string - The Place holder key used in templates for generic replacement prompts.
					** See: 'Template Place Holders' for more info.

		AutoLoad				: boolean - Set to false to stop auto loading of templates.
		TemplatesDirectory		: string - The templates directory to use.
**					*** Template files use a unique format, (my change to template files matched with json files for 
						settings) so this should be in a unique spot (IT CAN CLASH with other template generators 
						if in same folder).


	Template Options:  Table of settings for template generating.
		Required Options:
			DisplayString			: string - The menu display string.

		Bound Required Options: One or the other.
			*	TemplateString		: string - The template string to use.
				TemplateFile		: string - The file path of the template.
					*** Do not use multi extension files. (still figuring this one out)
							i.e.: 'AOB_Injection.template.cea'
						Instead try:
							'AOB_Injection-template.cea '

		Name						: string - The name of the template.
					*** Used in menu item creation, also in injection information and logging.

		LineEnd						: string - The line end string. (i.e.: '\n' or '\r\n')

		Example Table:
			Templates = {
				Name = 'I2CELTemplates', 
				SectionDisplayString = 'I2 Lua Templates', 
				SectionName = 'miI2CELTemplatesSection', 
				{
					Name = 'I2CEL_Header', 
					DisplayString = 'Header', 
					TemplateString = I2_TEMPLATE_HEADER, 
				}, 
				'-----', ---- SEPERATOR
				{
					Name = 'I2CEL_Timer', 
					DisplayString = 'Timer', 
					TemplateString = I2_TEMPLATE_TIMER, 
				}, 
				{
					Name = 'I2CEL_BreakPoint', 
					DisplayString = 'Break Point', 
					TemplateString = I2_TEMPLATE_BREAK_POINT, 
				}, 
				{
					Name = 'I2CEL_Hotkey', 
					DisplayString = 'Hot-key', 
					TemplateString = I2_TEMPLATE_HOTKEY, 
				}, 
			}



	Template Keys:
			- Keys to be used in templates and memory record strings.
				format:
					${TemplateKey}

		ProcessName				- The process name.
		ProcessAddress			- The process address.

		Module					- The address's module, if it is in a module.
		ModuleAddress			- The address's module address, if it is in a module.
		ModuleSize				- The address's module size, if it is in a module.
		ModuleBitSize			- The address's module bit size, if it is in a module.
									i.e.: '(x32)' or '(x64)'
		ModuleStr				- Will be set to the word 'Module' if the address is in a module.
									* Used with aob scan.
										i.e.: 'aobScan${ModuleStr}(...'
		ModuleDecl				- Will be set to the module name with a comma in front, if the address is in a module.
									* Used with aob scans, and memory allocation.
										i.e.: 'aobScan${ModuleStr}(SomeUserSymbol${ModuleDecl}, bytes)'
										i.e.: 'alloc(SomeUserSymbol, 0x400${ModuleDecl})'

		Address					- The address, will be in module with offset format, if the address is in a module.
					* Pulled from disassembler view form selection.
		AddressHex				- The address in hex format, length is based on pointer size.

		Date					- The current date.
		Author					- The detected user name.
					*** Set global 'CE_USERNAME', or environment variable 'CE_USERNAME', to override 
								the windows user name.

		CEVersion				- Cheat Engine's version.
		PointerSize				- The processes pointer size.
									i.e.: x32 PointerSize is 4 and x64 PointerSize is 8.
		PointerFtmStr			- The processes pointer format string. (for lua use in templates)
									i.e.: x32 PointerFtmStr is '%08X' and x64 PointerFtmStr is '%016X'.
		PointerWordSize			- The processes pointer declaration word.
									i.e.: x32 PointerWordSize is 'dd' and x64 PointerWordSize is 'dq'.
		PointerDefault			- The processes pointer declaration with integer 0 value.
									i.e.: x32 PointerWordSize is 'dd 0' and x64 PointerWordSize is 'dq 0'.
		PointerDefaultFull		- The processes pointer declaration with hex 0 value.
									i.e.: x32 PointerDefaultFull is 'dd 00000000' and 
											x64 PointerDefaultFull is 'dq 0000000000000000'.
		GameTitle				- The game title. (See: 'Global Variables' for overriding process based value)
		GameVersion				- The game version. (See: 'Global Variables' for overriding determined value)

		BaseAddressRegistry		- Registry pulled form original code of the first line (uses lua matching).
		BaseAddressOffset		- Offset for registry pulled form original code of the first line (uses lua matching).
					* Looks for most instructions followed by brackets with a registry and offset. Kinda works!
								i.e.: mov eax,[rsi+10]
									BaseAddressRegistry will be 'rsi'
									BaseAddressOffset will be '10'



	Template Place Holders:
		- User will be prompted for replacement of key words, every thing after place holder key.
			* Key words are striped of underscores and title cased before prompt.
				i.e.:
					PlaceHolder_Some_Value  ->  "Some Value"
					PlaceHolder_the_ultimate_question  ->  "The Ultimate Question"

		Key Start:
			PlaceHolder_

		Example:
			local aTimer = nil
			local aTimerInterval = ${PlaceHolder_Timer_Interval}
			local aTimerTicks = 0
			local aTimerTickMax = ${PlaceHolder_Timer_Tick_Max}
			local function aTimer_tick(timer)
				if aTimerTickMax > 0 and aTimerTicks >= aTimerTickMax then
					timer.destroy()
				end
				aTimerTicks = aTimerTicks + 1
				-- body
			end
			aTimer = createTimer(getMainForm(), false)
			aTimer.Interval = aTimerInterval
			aTimer.OnTimer = aTimer_tick
			aTimer.Enabled = true



	Templates:
		Key Format:
			${TemplateKey}

		Example:
			local autoAttachTimer = nil
			local autoAttachTimerInterval = 100
			local autoAttachTimerTicks = 0
			local autoAttachTimerTickMax = 5000

			local function autoAttachTimer_tick(timer)
				if autoAttachTimerTickMax > 0 and autoAttachTimerTicks >= autoAttachTimerTickMax then
					timer.destroy()
				end
				if getProcessIDFromProcessName('${ProcessName}') ~= nil then
					timer.destroy()
					openProcess('${ProcessName}')
				end
				autoAttachTimerTicks = autoAttachTimerTicks + 1
			end

			autoAttachTimer = createTimer(getMainForm())
			autoAttachTimer.Interval = autoAttachTimerInterval
			autoAttachTimer.OnTimer = autoAttachTimer_tick



	Template Files:
		- Template files can be just a lua file or they can have a settings and template section
**			*** Must be just a lua file, or have '[SETTINGS]' then '[TEMPLATE]' section in that order.
				i.e.:
					|		Good	|		Good	|		Good	|		Bad		|
					|---------------|---------------|---------------|---------------|
					|	[SETTINGS]	|	[TEMPLATE]	|	...			|	[TEMPLATE]	|
					|	...			|	...			|	...			|	...			|
					|	[TEMPLATE]	|	...			|	...			|	[SETTINGS]	|
					|	...			|	...			|	...			|	...			|
					|---------------|---------------|---------------|---------------|


		Lua Files:
			- The standard lua format with templates keys, caption add menu section will be determinate by 
				file name and directory.
					i.e.: 'some_template.lua'  ->  'Some Template' - (Templates Menu)
					i.e.: 'some_section\some_template.lua'  ->  'Some Template' - 'Some Section' (miSomeSection)

		Settings:
			- Only allows basic setting (no nested settings at this point ?? json).
**			*** Settings and template section keys must be the only thing on that line.

		Template:
			- The template to use (reads to end of file).
**			*** Template and settings section keys must be the only thing on that line.

		Example:
			[SETTINGS]
				DisplayString = 'Some Template'
			[TEMPLATE]
				print('I Have The Power!!')



	Global Variables:
		GAME_TITLE			- The game title.
						* If not set process name with out extension will be used.
						** Manually set in table lua files, if needed.
		GAME_VERSION		- The game version.
						* If not set value from 'getFileVersion' on the first module will be used.
						** Manually set in table lua files, if needed.
		Global Variables (Overridden by Settings):
			[[ global 								- setting ]]
			CE_USERNAME								- UserName
			I2CELSTG_AUTO_LOAD						- AutoLoad
			I2CELSTG_TEMPLATES_DIRECTORY			- TemplatesDirectory
		Global Variables (Overridden by Template Options):
			[[ global 								- template option ]]
			I2CELSTG_LINE_END						- LineEnd
		


	Environment Variable Keys: (Overridden by global variables)
		CE_USERNAME			- The name used for 'Author' template key.



]====================================================================================================================]--





local NAME = 'I2 Cheat Engine Lua Script Template Generator'
local CLASS_NAME = 'I2CELuaScriptTemplates'
local VERSION = '1.0.1'
local AUTHOR = 'Matt Irwin; Matt.Irwin.US@Gmail.com'
local LICENSE = [=[MIT License

Copyright (c) 2017 Matt Irwin

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sub-license, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
]=]



local format = string.format

function getPath( ... )
	local pathseparator = package.config:sub(1,1)
	local elements = { ... }
	return table.concat(elements, pathseparator)
end

local function exists(path)
	if type(path) ~= 'string' then return end
	return os.rename(path, path) and true or false
end

local function isFile(path)
	if type(path) ~= 'string' then return end
	if not exists(path) then return false end
	local f = io.open(path)
	if f then
		f:close()
		return true
	end
	return false
end

local function isDirectory(path)
	return (exists(path) and not isFile(path))
end




--------
-------- Logger
--------
local Logger = { ClassName = 'I2Logger', Name = 'I2CELSTG_Logger' }
Logger.LEVELS = { OFF = 0, ERROR = 1, WARN = 2, INFO = 3, DEBUG = 4 }
Logger.Level = Logger.LEVELS.WARN
if DEBUG then Logger.Level = Logger.LEVELS.DEBUG end
Logger.print = print
function Logger.logEvent(level, msg, ex)
	if Logger.Level >= level then
		Logger.print(msg)
		if ex then Logger.print('Exception: ' .. tostring(ex)) end
	end
end
for k,v in pairs(Logger.LEVELS) do
	if v > 0 then
		Logger[k:lower()] = function(msg, ex) return Logger.logEvent(v, msg, ex) end
		Logger[k:lower() .. 'f'] = function(msg, ... ) return Logger.logEvent(v, format(msg, ... )) end
	end
end
Logger.debugf('I2CELSTG: %s: Loaded.', Logger.ClassName)




----
----
---- Translation function
----
local function t(tanslationStr)
	return tanslationStr
end


local MENU_CREATION_TIMER_INTERVALS = 500


local TEMPLATE_FILE_EXT = 'cea'

local FORM_CAPTION = 'Lua script: Cheat Table'



--------
-------- Header
--------
local I2_TEMPLATE_HEADER = [========[
--[[
--[========================================================================================================================[
	Process			: ${ProcessName}
	Game Title		: ${GameTitle}
	Game Version	: ${GameVersion}
	CE Version		: ${CEVersion}
	Script Version	: 0.0.1
	Date			: ${Date}
	Author			: ${Author}
]========================================================================================================================]--
]]
]========]
--------
-------- Timer
--------
local I2_TEMPLATE_TIMER = [========[
--------
-------- Timer
--------
local aTimer = nil
local aTimerInterval = ${PlaceHolder_Timer_Interval}
local aTimerTicks = 0
local aTimerTickMax = ${PlaceHolder_Timer_Tick_Max}
local function aTimer_tick(timer)
	if aTimerTickMax > 0 and aTimerTicks >= aTimerTickMax then
		timer.destroy()
	end
	aTimerTicks = aTimerTicks + 1
	-- body
end
aTimer = createTimer(getMainForm(), false)
aTimer.Interval = aTimerInterval
aTimer.OnTimer = aTimer_tick
aTimer.Enabled = true
]========]
--------
-------- Break Point
--------
local I2_TEMPLATE_BREAK_POINT = [========[
--------
-------- Break Point
--------
debug_setBreakpoint(${Address}, 1, bptExecute, function()
	debug_continueFromBreakpoint(co_run)
	-- body
	return 1
end)
]========]
--------
-------- Hot-key
--------
local I2_TEMPLATE_HOTKEY = [========[
--------
-------- Hot-key - ${PlaceHolder_Key_Combo_String}
--------
local function aHotkey_press()
	-- body
end
aHotkey = createHotkey(aHotkey_press, '${PlaceHolder_Key_Combo_String}')
]========]
--------
-------- Auto Attach
--------
local I2_TEMPLATE_AUTO_ATTACH = [========[
--------
-------- Auto Attach
--------
local autoAttachTimer = nil
local autoAttachTimerInterval = 100
local autoAttachTimerTicks = 0
local autoAttachTimerTickMax = 5000

local function autoAttachTimer_tick(timer)
	if autoAttachTimerTickMax > 0 and autoAttachTimerTicks >= autoAttachTimerTickMax then
		timer.destroy()
	end
	if getProcessIDFromProcessName('${ProcessName}') ~= nil then
		timer.destroy()
		openProcess('${ProcessName}')
	end
	autoAttachTimerTicks = autoAttachTimerTicks + 1
end

autoAttachTimer = createTimer(getMainForm())
autoAttachTimer.Interval = autoAttachTimerInterval
autoAttachTimer.OnTimer = autoAttachTimer_tick
]========]
--------
-------- Table Init
--------
local I2_TEMPLATE_TABLE_INIT = [========[
--------
-------- Table Init
--------
local tableInitTimer = nil
local tableInitTimerInterval = 100
local tableInitTimerTicks = 0
local tableInitTimerTickMax = 5000
local function tableInitTimer_tick(timer)
	if tableInitTimerTickMax > 0 and tableInitTimerTicks >= tableInitTimerTickMax then
		timer.destroy()
	end
	tableInitTimerTicks = tableInitTimerTicks + 1
	if process then
		timer.destroy()
		I2CETableHooks.Hooks.runAutoHook(true)
		setupTable()
	end
end
tableInitTimer = createTimer(getMainForm(), false)
tableInitTimer.Interval = tableInitTimerInterval
tableInitTimer.OnTimer = tableInitTimer_tick

function onOpenProcess()
	tableInitTimer.Enabled = true
end
]========]
--------
-------- Auto Deactivate On  Close
--------
local I2_TEMPLATE_AUTO_DEACTIVE_ON_CLOSE = [========[
--------
-------- Auto Deactivate On  Close
--------
local mainForm = getMainForm()
local mainForm_formClose = mainForm.OnClose
local function autoDeactivateOnClose_formClose(sender)
	local openedProcess = string.sub(getMainForm().ProcessLabel.Caption,10)
	local addressList = getAddressList()
	local activeScriptsLst = {}
	if process == nil then
		mainForm_formClose(sender)
		return
	end
	for i = 0, addressList.Count - 1 do
		if addressList[i].Active and addressList[i].Type == vtAutoAssembler then
			table.insert(activeScriptsLst, addressList[i].Description)
		end
	end
	if #activeScriptsLst > 0 then
		local msg = '%d scripts are still active:\n%s\nDo you wish to deactivate them before close?'
		msg = string.format(msg, #activeScriptsLst, table.concat(activeScriptsLst,'\n'))
		local dRst = messageDialog(msg, mtConfirmation, mbYes, mbNo, mbCancel)
		if dRst == mrYes then
			for i = addressList.Count - 1, 0, -1 do
				addressList[i].Active = false
			end
			mainForm_formClose(sender)
		elseif dRst == mrNo then
			mainForm_formClose(sender)
		end
	else
		mainForm_formClose(sender)
	end
end
mainForm.OnClose = autoDeactivateOnClose_formClose
]========]
--------
-------- Logger
--------
local I2_TEMPLATE_LOGGER = [========[
--------
-------- Logger
--------
local Logger = { ClassName = 'I2Logger', Name = 'I2CET_Logger' }
Logger.LEVELS = { OFF = 0, ERROR = 1, WARN = 2, INFO = 3, DEBUG = 4 }
Logger.Level = Logger.LEVELS.WARN
if DEBUG then Logger.Level = Logger.LEVELS.DEBUG end
Logger.print = print
function Logger.logEvent(level, msg, ex)
	if Logger.Level >= level then
		Logger.print(msg)
		if ex then Logger.print('Exception: ' .. tostring(ex)) end
	end
end
for k,v in pairs(Logger.LEVELS) do
	if v > 0 then
		Logger[k:lower()] = function(msg, ex) return Logger.logEvent(v, msg, ex) end
		Logger[k:lower() .. 'f'] = function(msg, ... ) return Logger.logEvent(v, format(msg, ... )) end
	end
end
]========]
--------
-------- CE Table Require
--------
local I2_TEMPLATE_CE_Table_Require = [========[
--------
-------- CE Table Require
--------
local TableLuaFilesDirectory = 'luaFiles'
function CETrequire(moduleStr)
	if moduleStr ~= nil then
		local localTableLuaFilePath = moduleStr
		if TableLuaFilesDirectory ~= nil or TableLuaFilesDirectory ~= '' then
			local sep = package.config:sub(1,1)
			localTableLuaFilePath = TableLuaFilesDirectory .. sep .. moduleStr
		end
		local f, err = io.open(localTableLuaFilePath)
		if f and not err then
			f:close()
			return require(localTableLuaFilePath)
		else
			local tableFile = findTableFile(moduleStr .. '.lua')
			if tableFile == nil then
				return nil
			end
			local stream = tableFile.getData()
			local fileStr = nil
			local bytes = stream.read(stream.Size)
			for i = 1, #bytes do
				if fileStr == nil then
					fileStr = ''
				end
				fileStr = fileStr .. string.char(bytes[i])
			end
			if fileStr then
				return assert(loadstring(fileStr))()
			end
		end
	end
	return nil
end
]========]
--------
-------- CE Table Tweaks
--------
local I2_TEMPLATE_CE_Table_Tweaks = [========[
--------
-------- CE Table Tweaks
--------
local function getFileVersionStr(path)
	if path == nil then return end
	local i, vt = getFileVersion(path)
	if i and vt then
		return string.format('%s.%s.%s.%s', vt.major, vt.minor, vt.release, vt.build)
	end
	return nil
end
function getPointerSize()
	aasStr = [====[
		globalAlloc(memPointerTest, 0x8)
		memPointerTest:
			db FF FF FF FF FF FF FF FF
	]====]
	local assembled = autoAssemble(aasStr)
	if assembled then
		local p1 = readQword('memPointerTest')
		local p2 = readPointer('memPointerTest')
		if p1 == p2 then
			return 0x8
		else
			return 0x4
		end
	end
	return nil
end
function getRegistrySizeStr()
	if getPointerSize() == 0x4 then
		return '(x32)'
	else
		return '(x64)'
	end
end
function getGameVersion()
	local modules = enumModules()
	if modules == nil or modules[1] == nil then return end
	return getFileVersion(modules[1].PathToFile)
end
function getGameVersionStr()
	local modules = enumModules()
	if modules == nil or modules[1] == nil then return end
	return getFileVersionStr(modules[1].PathToFile)
end
function disableCompactMode()
	local mainForm = getMainForm()
	control_setVisible(wincontrol_getControl(mainForm, 0), true)
	control_setVisible(wincontrol_getControl(mainForm, 2), true)
	control_setVisible(wincontrol_getControl(mainForm, 3), true)
end
function enableCompactMode()
	local mainForm = getMainForm()
	control_setVisible(wincontrol_getControl(mainForm, 0), false)
	control_setVisible(wincontrol_getControl(mainForm, 2), false)
	control_setVisible(wincontrol_getControl(mainForm, 3), false)
end
function disableHeaderSorting()
	local addressList = getAddressList()
	local addressListHeader = component_getComponent(addressList, 1)
	setMethodProperty(addressListHeader, 'OnSectionClick', nil)
end
function disableDragDrop()
	local addressList = getAddressList()
	local addressListTreeview = component_getComponent(addressList, 0)
	setMethodProperty(addressListTreeview, 'OnDragOver', nil)
	setMethodProperty(addressListTreeview, 'OnDragDrop', nil)
	setMethodProperty(addressListTreeview, 'OnEndDrag', nil)
end
function setTitle(tableTitle, tableVersion, gameTitle, gameVersion, registrySizeStr)
	if tableTitle == nil or tableTitle == '' then
		tableTitle = TABLE_TITLE or 'TABLE_TITLE'
	end
	if tableVersion == nil or tableVersion == '' then
		tableVersion = TABLE_VERSION or 'TABLE_VERSION'
	end
	if gameTitle == nil or gameTitle == '' then
		gameTitle = GAME_TITLE or process or 'GAME_TITLE'
		gameTitle = gameTitle:gsub('.exe', ''):gsub('.EXE', '')
	end
	if gameVersion == nil or gameVersion == '' then
		gameVersion = GAME_VERSION or getGameVersionStr() or 'GAME_VERSION'
	end
	if registrySizeStr == nil or registrySizeStr == '' then
		registrySizeStr = getRegistrySizeStr()
	end
	local ceRegistrySizeStr = (cheatEngineIs64Bit() and '(x64)') or '(x32)'
	local titleStr = string.format('%s %s v: %s - %s v: %s - CE %s v: %s', 
							gameTitle, registrySizeStr, gameVersion, 
							tableTitle, tableVersion, 
							ceRegistrySizeStr, getCEVersion())
	local mainForm = getMainForm()
	mainForm.Caption = titleStr
	-- control_setCaption(mainForm, titleStr)
	return titleStr
end
function setupTable(compactMode, tableTitle, tableVersion, gameTitle, gameVersion, registrySizeStr)
	if compactMode then
		enableCompactMode()
	end
	disableHeaderSorting()
	setTitle(tableTitle, tableVersion, gameTitle, gameVersion, registrySizeStr)
end
---- Move to 'TableInit'
setupTable()
]========]
--------
-------- I2 CE Table Hooks
--------
local I2_TEMPLATE_I2_CE_TABLE_HOOKS = [========[
--------
-------- I2 CE Table Hooks
--------
require 'I2CETableHooks'
I2CETableHooks.Hooks.new('${PlaceHolder_Hook_Name}', true, '${PlaceHolder_Hook_File}')
]========]








local I2_TEMPLATES = {
	Name = 'I2CELTemplates', 
	SectionDisplayString = t('I2 Lua Templates'), 
	SectionName = 'miI2CELTemplatesSection', 
	{
		Name = 'I2CEL_Header', 
		DisplayString = t('Header'), 
		TemplateString = I2_TEMPLATE_HEADER, 
	}, 
	'-----', ---- SEPERATOR
	{
		Name = 'I2CEL_Timer', 
		DisplayString = t('Timer'), 
		TemplateString = I2_TEMPLATE_TIMER, 
	}, 
	{
		Name = 'I2CEL_BreakPoint', 
		DisplayString = t('Break Point'), 
		TemplateString = I2_TEMPLATE_BREAK_POINT, 
	}, 
	{
		Name = 'I2CEL_Hotkey', 
		DisplayString = t('Hot-key'), 
		TemplateString = I2_TEMPLATE_HOTKEY, 
	}, 
	'-----', ---- SEPERATOR
	{
		Name = 'I2CEL_AutoAttach', 
		DisplayString = t('Auto Attach'), 
		TemplateString = I2_TEMPLATE_AUTO_ATTACH, 
	}, 
	{
		Name = 'I2CEL_TableInit', 
		DisplayString = t('Auto Attach'), 
		TemplateString = I2_TEMPLATE_TABLE_INIT, 
	}, 
	-- {
	-- 	Name = 'I2CEL_AutoDeactivateOnClose', 
	-- 	DisplayString = t('Auto Deactivate On Close'), 
	-- 	TemplateString = I2_TEMPLATE_AUTO_DEACTIVE_ON_CLOSE, 
	-- }, 
	'-----', ---- SEPERATOR
	{
		Name = 'I2CEL_Logger', 
		DisplayString = t('Logger'), 
		TemplateString = I2_TEMPLATE_LOGGER, 
	}, 
	{
		Name = 'I2CEL_CETableRequire', 
		DisplayString = t('CE Table Require'), 
		TemplateString = I2_TEMPLATE_CE_Table_Require, 
	}, 
	{
		Name = 'I2CEL_CETableTweaks', 
		DisplayString = t('CE Table Tweaks'), 
		TemplateString = I2_TEMPLATE_CE_Table_Tweaks, 
	}, 
	'-----', ---- SEPERATOR
	{
		Name = 'I2CEL_I2CETableHooks', 
		DisplayString = t('I2 CE Table Hooks'), 
		TemplateString = I2_TEMPLATE_I2_CE_TABLE_HOOKS, 
	}, 
}




---- Defaults
	---- I2CELSTG_DATE_FORMAT
		local default_DateFormat = '%x'
		
	---- Has Tables Overrides:
		---- LineEnd - I2CELSTG_LINE_END
		local default_LineEnd = '\n'


---- Settings
	---- I2CELSTG_AUTO_LOAD
	local AutoLoad = true

	---- I2CELSTG_DATE_FORMAT
	local DateFormat = default_DateFormat

	---- I2CELSTG_TEMPLATES_DIRECTORY
	local TemplatesDirectory = getPath(os.getenv('HOMEPATH') or os.getenv('HOME'), t('My Cheat Tables'), '~I2Templates')

	---- I2CELSTG_ADD_MAIN_SEPERATOR
	local AddMainSeperator = true

	---- I2CELSTG_PLACE_HOLDER_KEY
	local PlaceHolderKey = t('PlaceHolder_')

	local UserNameEnvKey = 'CE_USERNAME'
	---- CE_USER_NAME
	local UserName = os.getenv(UserNameEnvKey) or os.getenv('USERNAME') or 'USERNAME'



----
----
---- Class / Base table
----
I2CELuaScriptTemplates = {
	Name = NAME, 
	ClassName = CLASS_NAME, 
	Version = VERSION, 
	Author = AUTHOR, 
	License = LICENSE, 
}



--------
--------
--------
----------------
---------------- Templates START
----------------
I2CELuaScriptTemplates.Templates = {
	I2_TEMPLATES, 
	-- '-----', ---- SEPERATOR
	-- {
	-- 	Name = 'I2CEL_Timer', 
	-- 	DisplayString = 'Timer', 
	-- 	TemplateString = I2_TEMPLATE_TIMER, 
	-- }, 
	-- {
	-- 	Name = 'I2CEL_BreakPoint', 
	-- 	DisplayString = 'Break Point', 
	-- 	TemplateString = I2_TEMPLATE_BREAK_POINT, 
	-- }, 
	-- {
	-- 	Name = 'I2CEL_Hotkey', 
	-- 	DisplayString = 'Hot-key', 
	-- 	TemplateString = I2_TEMPLATE_HOTKEY, 
	-- }, 
}
----------------
---------------- Templates END
----------------
--------
--------
--------



--------
--------
-------- Helpers
--------
local function getFileVersionStr(path)
	if path == nil then return end
	local i, vt = getFileVersion(path)
	if i and vt then
		return format('%s.%s.%s.%s', vt.major, vt.minor, vt.release, vt.build)
	end
	return nil
end


function getGameVersionStr()
	local modules = enumModules()
	if modules == nil or modules[1] == nil then return end
	return getFileVersionStr(modules[1].PathToFile)
end


local function getPointerSize()
	aasStr = [====[
		globalAlloc(memPointerTest, 0x8)
		memPointerTest:
			db FF FF FF FF FF FF FF FF
	]====]
	local assembled = autoAssemble(aasStr)
	if assembled then
		local p1 = readQword('memPointerTest')
		local p2 = readPointer('memPointerTest')
		if p1 == p2 then
			return 0x8
		else
			return 0x4
		end
	end
	return nil
end



local function interp(s, tbl)
	return (s:gsub('($%b{})', function(w) return tbl[w:sub(3, -2)] or w end))
end


local function titleCase(s, s_char)
	if type(s) ~= 'string' then return nil end
	local patt = '%S+' -- match every thing but spaces.
	local char = ' '
	if s_char == '_' then
		patt = '[^_]+' -- match every thing but underscores.
		char = '_'
	elseif s_char == '.' then
		patt = '[^\\.]+' -- match every thing but periods.
		char = '.'
	elseif s_char == 'p' then
		patt = '%P+' -- match every thing but punctuation.
		char = '.'
	end
	local r = ''
	for w in s:gfind(patt) do
		local f = w:sub(1, 1)
		if #r > 0 then r = r..char end
		r = r..f:upper()..w:sub(2):lower()
	end
	if #r < 1 then r = s end
	return r
end

local function padR(str, len, char)
	if str == nil then return end
    if char == nil then char = ' ' end
    return str .. string.rep(char, len - #str)
end



--------
--------
-------- Functions
--------
local function getMenuItemForm(menuItem)
	local form = nil
	local item = menuItem
	for i = 0, 100 do
		if item.Caption == FORM_CAPTION or item.Caption == t(FORM_CAPTION) then
			Logger.debugf('I2CELSTG: getMenuItemForm: form found, steps: %s', i)
			return item
		elseif item.Owner == nil then
			return
		else
			item = item.Owner
		end
	end
end



--------
--------
-------- Generate
--------
function I2CELuaScriptTemplates.generate(menuItem, templateTbl)
	Logger.debugf('I2CELSTG: generate: generating template: "%s".', templateTbl.Name or templateTbl.DisplayString)

	local form = getMenuItemForm(menuItem)
	local origScript = ''
	if form ~= nil then
		origScript = form.Assemblescreen.Lines.Text
	end

	local le = templateTbl.LineEnd or I2CELSTG_LINE_END or default_LineEnd or '\n'

	local pointerSize = getPointerSize()
	local pointerSizeStr = format('0x%X', pointerSize or 0x8)
	local pointerFtmStr = '%016X'
	local pointerWordSize = 'dq'
	local pointerDefaultStr = 'dq 0'
	if pointerSize == 0x4 then
		pointerFtmStr = '%08X'
		pointerWordSize = 'dd'
		pointerDefaultStr = 'dd 0'
	end
	Logger.infof('I2CELSTG: generate: pointer size set: %s', pointerSizeStr)

	local template = nil
	if templateTbl.TemplateFile ~= nil then
		local f, err = io.open(templateTbl.TemplateFile, 'r')
		if not err and f then
			template = f:read()
		end
	elseif templateTbl.TemplateString ~= nil then
		template = templateTbl.TemplateString
	else
		local msg = 'Template was NOT found: "%s"'
		Logger.errorf('I2CELSTG: generate: ' .. msg, templateTbl.Name)
		showMessage(format('ERROR: ' .. t(msg), templateTbl.DisplayString))
		return nil, nil
	end

	local mv = getMemoryViewForm()
	local dv = memoryview_getDisassemblerView(mv)
	local dv_address1 = dv.SelectedAddress
	local dv_address2 = dv.SelectedAddress2
	local address = dv_address1
	local addressStr = getNameFromAddress(address) or address

	if templateTbl.GetAddress then
		local addressStr = inputQuery(t('Injection Address') .. '?', t('Inject at this address') .. ':', addressStr)
		if addressStr == nil then
			Logger.warn('I2CELSTG: generate: got nil for address.')
			if form ~= nil then
				form.Assemblescreen.Lines.Text = origScript
			end
			return nil, nil ---- Exit generating template if prompt canceled.
		else
			Logger.debugf('I2CELSTG: generate: got address: %s.', addressStr)
			address = getAddress(addressStr)
		end
	end
	Logger.infof('I2CELSTG: generate: using address: %X.', address)

	local moduleName = ''
	local moduleStr = ''
	local moduleDeclStr = ''
	local moduleAddressStr = ''
	local moduleSizeStr = ''
	local moduleBitSizeStr = ''
	if process then
		if inModule(address) then
			local tbl = enumModules()
			if tbl ~= nil then
				for i = 1, #tbl - 1 do
					if not inSystemModule(tbl[i].Address) 
					and tbl[i].Address < address 
					and (address + getModuleSize(tbl[i].Name)) > address then
						moduleName = tbl[i].Name
						moduleStr = 'Module'
						moduleDeclStr = ', ' .. moduleName
						moduleAddressStr = format(pointerFtmStr, tbl[i].Address)
						moduleSizeStr = format(pointerFtmStr, getModuleSize(tbl[i].Name))
						if tbl[i].Is64Bit then
							moduleBitSizeStr = '(x64)'
						else
							moduleBitSizeStr = '(x32)'
						end
						-- break
					end
				end
			end
		end
	end


	local userName = CE_USERNAME or UserName
	local placeholderKey = I2CELSTG_PLACE_HOLDER_KEY or PlaceHolderKey

	local gameTitle = GAME_TITLE or 'GAME_TITLE' ---- To be set in tables lua file
	local gameVersion = GAME_VERSION or 'GAME_VERSION' ---- To be set in tables lua file
	local processAddres = 0
	local processAddresStr = ''

	if process then
		gameTitle = GAME_TITLE  or process:gsub('.exe', '') or 'GAME_TITLE' ---- To be set in tables lua file
		gameVersion = GAME_VERSION or getGameVersionStr() or 'GAME_VERSION' ---- To be set in tables lua file
		processAddres = getAddress(process) or 0
		processAddresStr = format(pointerFtmStr, processAddres)
	end

	local valueTbl = {
		ProcessName = process or '', 
		ProcessAddress = processAddresStr or '', 
		Module = moduleName or '', 
		ModuleStr = moduleStr or '', 
		ModuleDecl = moduleDeclStr or '', 
		ModuleAddress = moduleAddressStr or '', 
		ModuleSize = moduleSizeStr or '', 
		ModuleBitSize = moduleBitSizeStr or '', 
		Date = os.date(I2CELSTG_DATE_FORMAT or DateFormat) or '', 
		Author = userName or '', 
		Address = addressStr or '', 
		AddressHex = format(pointerFtmStr, address), 
		CEVersion = tostring(getCEVersion() or 0), 
		PointerSize = pointerSizeStr, 
		PointerFtmStr = pointerFtmStr or '%016X', 
		PointerWordSize = pointerWordSize or 'dq', 
		PointerDefault = pointerDefaultStr or 'dq 0', 
		PointerDefaultFull = format(pointerWordSize .. ' ' .. pointerFtmStr, 0x0), 
		GameTitle = gameTitle or '', 
		GameVersion = gameVersion or '', 
	}
	local parsedTemplate = interp(template, valueTbl)

	while (parsedTemplate:find('${' .. placeholderKey .. '.-}') ~= nil) do
		local placeholderFull, placeholderName = parsedTemplate:match('(${' .. placeholderKey .. '(.-)})')
		placeholderName = titleCase(placeholderName:gsub('_', ' '))
		local placeholderReplace = inputQuery(placeholderName .. '?',
											  t('Enter replacement for keyword') .. ' "' .. placeholderName .. '":', 
											  '')
		if placeholderReplace == nil then
			Logger.warnf('I2CELSTG: generate: got nil for key word replacement: kw: "%s", n: "%s".', 
							placeholderFull, placeholderName)
			form.Assemblescreen.Lines.Text = origScript
			return nil, nil ---- Exit generating template if prompt canceled
		end
		Logger.debugf('I2CELSTG: generate: got key word replacement: kw: "%s", n: "%s", r: "%s".', 
						placeholderFull, placeholderName, placeholderReplace)
		if placeholderReplace == '' then
			placeholderReplace = placeholderFull
		end
		parsedTemplate = parsedTemplate:gsub(placeholderFull, placeholderReplace)
		valueTbl[placeholderKey] = placeholderReplace
	end

	Logger.infof('I2CELSTG: generate: template generated: "%s".', templateTbl.Name or templateTbl.DisplayString)
	local logMsg, _ = parsedTemplate:gsub('\r\n', '\n')
	logMsg, _ = parsedTemplate:gsub('\n', '\r\n')
	Logger.debug('------------------------------------------------------------')
	Logger.debug(logMsg)
	Logger.debug('------------------------------------------------------------')

	if type(origScript) == 'string' and #origScript > 2 then
		origScript = origScript .. le .. le
	else
		origScript = ''
	end

	if form ~= nil then
		form.Assemblescreen.Lines.Text = origScript .. parsedTemplate
	end
	return parsedTemplate, mrTbl
end



--------
--------
--------
-------- Setup and Load:
--------
function I2CELuaScriptTemplates.createTelplateMenuItem(menu, tbl)
	if menu == nil or tbl == nil then return end
	if type(tbl) == 'string' then
		local mi = createMenuItem(menu)
		mi.Caption = '-'
		menu.add(mi)
	elseif type(tbl.SectionDisplayString) == 'string' then
		local name = 'mi' .. titleCase(tbl.SectionDisplayString:gsub('_', ' ')):gsub(' ', '')
		if type(tbl.SectionName) == 'string' then
			name = tbl.SectionName
			if name:lower():sub(1, 2) ~= 'mi' then
				name = 'mi' .. name
			end
		end
		for i = 1, menu.Count - 1 do
			if menu[i].Name == name then
				return
			end
		end
		local sectionMenuItem = createMenuItem(menu)
		sectionMenuItem.Name = name
		sectionMenuItem.Caption = tbl.SectionDisplayString
		if sectionMenuItem then
			Logger.debugf('I2CELSTG: createTelplateMenuItem: Template Section Menu Item Created: "%s".', 
							sectionMenuItem.Name)
		end
		for i = 1, #tbl do
			I2CELuaScriptTemplates.createTelplateMenuItem(sectionMenuItem, tbl[i])
		end
		menu.add(sectionMenuItem)
	elseif type(tbl.DisplayString) == 'string' then
		local name = 'mi' .. titleCase(tbl.DisplayString:gsub('_', ' ')):gsub(' ', '')
		if type(tbl.Name) == 'string' then
			name = tbl.Name
			if name:lower():sub(1, 2) ~= 'mi' then
				name = 'mi' .. name
			end
		end
		for i = 1, menu.Count - 1 do
			if menu[i].Name == name then
				return
			end
		end
		local function mi_click(menuItem)
			Logger.debugf('I2CELSTG: createTelplateMenuItem: Template Menu Item Clicked: "%s".', menuItem.Name)
			I2CELuaScriptTemplates.generate(menuItem, tbl)
		end
		local menuItem = createMenuItem(menu)
		menuItem.Name = name
		menuItem.OnClick = mi_click
		menuItem.Caption = tbl.DisplayString
		menu.add(menuItem)
		if menuItem then
			Logger.debugf('I2CELSTG: createTelplateMenuItem: Template Menu Item Created: "%s".', menuItem.Name)
		end
		return menuItem
	end
end


function I2CELuaScriptTemplates.createMenuItems(menu)
	if I2CELuaScriptTemplates.Templates == nil then return end
	if menu == nil then return end
	if I2CELSTG_ADD_MAIN_SEPERATOR or (I2CELSTG_ADD_MAIN_SEPERATOR == nil and AddMainSeperator) then
		local mi = createMenuItem(menu)
		mi.Caption = '-'
		menu.add(mi)
	end
	for i = 1, #I2CELuaScriptTemplates.Templates do
		if I2CELuaScriptTemplates.Templates[i] ~= nil then
			local menuItem = I2CELuaScriptTemplates.createTelplateMenuItem(menu, 
									I2CELuaScriptTemplates.Templates[i])
		end
	end
end



function I2CELuaScriptTemplates.loadTemplateDir(path, tbl)
	if not exists(path) or tbl == nil then return end
	for k, l in pairs(getFileList(path)) do
		local path, filename, ext = l:match([==[(.-)([^\/]-%.?([^%.\/]*))$]==])
		if ext:lower() == TEMPLATE_FILE_EXT:lower() then
			local strLst = createStringlist()
			strLst.loadFromFile(l)
			local templateStr = strLst.Text
			local tempTbl = {
				DisplayString = titleCase(filename:sub(0, -5):gsub('_', ' ')),
				TemplateString = templateStr, 
			}
			local secs = {
				start = 0, 
				settings = 1, 
				template = 2, 
			}
			local sec = secs.start
			for i = 0, strLst.count - 1 do
				if strLst[i]:upper() == '[SETTINGS]' 
				or strLst[i]:upper() == '[SETTINGS]\n' 
				or strLst[i]:upper() == '[SETTINGS]\r\n' then
					sec = secs.settings
				elseif strLst[i]:upper() == '[TEMPLATE]' 
				or strLst[i]:upper() == '[TEMPLATE]\n' 
				or strLst[i]:upper() == '[TEMPLATE]\r\n' then
					sec = secs.template
					templateStr = ''
				elseif sec == secs.settings then
						local rStr1 = [==[^[%s]*([%a_]+[%a%d_%-]*)[%s]*=[%s]*([%a%d_%-]*)[%s]*$]==]
						local rStr2 = [==[^[%s]*([%a_]+[%a%d_%-]*)[%s]*=[%s]*["|']([%a%d%s_%-]*)["|'][%s]*$]==]
						local key, value = strLst[i]:match(rStr1)
						local isStr = false
						if value == nil then
							key, value = strLst[i]:match(rStr2)
							if value ~= nil then
								isStr = true
							end
						end
						if value ~= nil then
							if isStr then
								value = value
							elseif value:lower() == 'true' or value:lower() == 'yes' or value:lower() == 'on' then
								value = true
							elseif value:lower() == 'false' or value:lower() == 'no' or value:lower() == 'off' then
								value = false
							elseif tonumber(value) ~= nil then
								value = tonumber(value)
							end
							tempTbl[key] = value
						end
				elseif sec == secs.template then
					local le = tempTbl.LineEnd or I2CELSTG_LINE_END or default_LineEnd or '\n'
					templateStr = templateStr .. strLst[i] .. le
				end
			end
			if sec == secs.template then
				tempTbl.TemplateString = templateStr
			end
			table.insert(tbl, tempTbl)
		end
	end
end


function I2CELuaScriptTemplates.loadTemplatesDirectory(path, tbl)
	if type(path) ~= 'string' then return end
	if tbl == nil then
		tbl = I2CELuaScriptTemplates.Templates
	end
	if isDirectory(path) then
		I2CELuaScriptTemplates.loadTemplateDir(path, tbl)
		for i, j in pairs(getDirectoryList(path)) do
			local dirPath, dirName = j:match([==[(.-)([^\/]-%.?([^%.\/]*))$]==])
			local secTbl = {
				DisplayString = dirName:gsub('_', ' '), 
			}
			I2CELuaScriptTemplates.loadTemplateDir(dirPath, secTbl)
			table.insert(tbl, secTbl)
		end

	end
	Logger.debug('I2CELSTG: loadTemplatesDirectory: loading templates directory.')
	I2CELuaScriptTemplates.loadTemplateDir(dirPath, tbl)
end


function I2CELuaScriptTemplates.loadTemplates(templates)
	if templates ~= nil then
		if templates.DisplayString ~= nil then
			templates = { templates }
		end
		for i = 1, #templates do
			table.insert(I2CELuaScriptTemplates.Templates, templates[i])
		end
	end
	Logger.debug('I2CELSTG: loadTemplates: loading templates.')
	I2CELuaScriptTemplates.loadTemplatesDirectory(I2CELSTG_TEMPLATES_DIRECTORY or TemplatesDirectory)
	I2CELuaScriptTemplates.setupMenu()
end


function I2CELuaScriptTemplates.setupMenu()
	local ticks = 0
	local intervals = MENU_CREATION_TIMER_INTERVALS or 500 ---- Set timer a little higher to keep menu items in same spot.
	---- If Runs before others using
	local timer = createTimer(getMainForm())
	timer.Interval = intervals
	local function setupMenuTimer_tick(timer)
		ticks = ticks + 1
		local form = nil
		for i = 0, getFormCount() - 1 do
			if getForm(i).Caption == FORM_CAPTION then
				form = getForm(i)
			end
		end
		if form == nil or form.Menu == nil then return end
		timer.destroy()
		Logger.debugf('I2CELSTG: setupMenu: creating menu items, ' .. 
						'timer KILLED. Interval: %d, Ticks: %d.', intervals, ticks)
		local name = 'miLuaScriptTemplates'
		local miTemplate = nil
		for i = 1, form.Menu.Items.Count - 1 do
			if form.Menu.Items[i].Name == name then
				miTemplate = form.Menu.Items[i]
				break
			end
		end
		if miTemplate == nil then
			miTemplate = createMenuItem(form.Menu.Items)
			miTemplate.Name = name
			miTemplate.Caption = 'Template'
			form.Menu.Items.add(miTemplate)
		end
		I2CELuaScriptTemplates.createMenuItems(miTemplate)
	end
	timer.OnTimer = setupMenuTimer_tick
end


local function loadI2CELuaScriptTemplates()
	local function loadTemplatesTimer_tick(timer)
		timer.destroy()
		if (I2CELSTG_AUTO_LOAD ~= nil and I2CELSTG_AUTO_LOAD) 
		or (I2CELSTG_AUTO_LOAD == nil and AutoLoad) then
			I2CELuaScriptTemplates.loadTemplates()
		end
	end
	---- Use timer to allow other files to load templates and keep menu items in same spot.
	local intervals = 300
	local timer = createTimer(getMainForm())
	timer.Interval = intervals
	timer.OnTimer = loadTemplatesTimer_tick
end

loadI2CELuaScriptTemplates()

Logger.debugf('I2CELSTG: %s: Loaded.', I2CELuaScriptTemplates.ClassName)
return I2CELuaScriptTemplates