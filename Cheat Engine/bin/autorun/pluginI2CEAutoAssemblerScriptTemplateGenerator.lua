--[====================================================================================================================[

I2 Cheat Engine Auto Assembler Script Template Generator.
    And memory record creator.
	
	Version: 1.0.3

	Author: Matt - TheyCallMeTim13 - MattI2.com

	Forked Version of:
		"customAOBInjectionTemplates.lua":
			Author: mgr.inz.Player
		"Custom Lua Script Templates.lua":
			Author: predprey


	Features:
		- Allows for adding templates as tables or in a directory structure.

			- Load templates function can be called multiple time to allow for standard and game specific templates.

			- Allows for template tables to have memory records generated along with the template script.

				- Memory record string settings are parsed for template keys.

			- Template table structure sets the menu item structure created.

		- Generic place holder key replacement though standard input forms.

		- A Standard header can be set for use in templates.

		- Gets the file version of the process's executable, for use in templates.

		- Set the amount of data collected and put in injection information.


	For the default templates see:
		- CE Form >> Ctrl+M >> Ctrl+A >> Menu >> Templates >> I2 CEA Templates
		- CE Form >> Main Menu >> Extra >> I2 CEA Templates


	To add templates use:
		local TemplatesTable = {
		    ...
		}
		I2CEAutoAssemblerScriptTemplates.loadTemplates(TemplatesTable)



	To add templates from a directory:
		I2CEAutoAssemblerScriptTemplates.loadTemplatesDirectory([[x:\SomeOddDirectory]])



	Install / Setup Method 1:
		- Put file in CE autorun folder.

	Install / Setup Method 2:
		- Put in CE lua folder (it isn't created by default).
			And in a file in the CE autorun folder import and add tables.

		Example:
			local TemplatesTable = {
			    ...
			}
			local I2CEAASTG = require 'pluginI2CEAutoAssemblerScriptTemplateGenerator'
			---- You could rename the file if you go this route.
			I2CEAASTG.loadTemplates(TemplatesTable)



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

		InjectionInfoCount		: integer - The number of lines before and after injection point in injection info.
									i.e.: 10 will generate 21 lines of disassembler output.
											10 before (addresses less then injection address)
											1 injection point
											10 after (addresses greater then injection address)

		PlaceHolderKey			: string - The Place holder key used in templates for generic replacement prompts.
					** See: 'Template Place Holders' for more info.

		AOBSignatureMin			: integer - The minimum number of bytes for AOB signatures.
		AOBSignatureScanMax		: integer - The maximum number of instruction lines to read for a unique AOB signature.

		AutoLoad				: boolean - Set to false to stop auto loading of templates.
		TemplatesDirectory		: string - The templates directory to use.
**					*** Template files use a unique format, (my change to template files matched with json files for 
						settings) so this should be in a unique spot (IT CAN CLASH with other template generators 
						if in same folder).
		NopASM					: string - ASM for nops.
									i.e.: 'nop' or 'Nop' or 'nop //// No Operation'
					* There is a separate template key for nops as data bytes. (i.e.: 'db 90 90 90')



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

		GetAddress					: boolean - Set to true to be prompted for an address.
					* Address is pulled from disassembler view form selection. So this is a formality.

		IsFullHook					: boolean - Set to true to have no less then 5 bytes for a full jump.

		GetHookName					: boolean - Set to true to be prompted for a hook name.
					* All template hook keys will be empty strings if not set to true.
		HookTag						: string - The tag to use for prompts.
										i.e.: 'Hook', 'Hack', 'Cheat', 'Exploit', or what have you.
		AppendHookTag				: boolean - Set to true to have the hook tag appended to the hook name.
													Unless the hook tag is already in the hook name.
		FixInputData				: boolean - Set to true to fix sloppy input data.
					* Only affects hook name.
					* Title cases and removes spaces from input.

		GetAOBSignature				: boolean - Set to true to have an aob signature generated.

		Memory Records: 			: table - Table of settings for generating template memory records 
												to add to cheat table.
					* See: 'Template Memory Records'

		MemoryRecordsIncludeScript	: boolean - Set to true for prompt to say memory records include script.

		NopPaddingLeft				: string - The leading padding for nops lines.
										i.e.: '\t\t'
		OriginalCodePaddingLeft		: string - The leading padding for the original code lines.
										i.e.: '\t\t'

		LineEnd						: string - The line end string. (i.e.: '\n' or '\r\n')
		LineComment					: string - The line comment string. (i.e.: '////' or '//')
		InjectionInfoCommentType	: integer:CommentTypes : The injection info comment type.

		Example Table:
			Templates = {
				Name = 'I2CEATemplates', 
				SectionDisplayString = 'I2 CEA Templates', 
				SectionName = 'miI2CEATemplatesSection', 
				{
					DisplayString = 'Address Injection', 
					GetAddress = true, 
					GetHookName = true, 
					HookTag = 'Cheat', 
					AppendHookTag = true, 
					TemplateString = I2_TEMPLATE_ADDRESS_INJECTION, 
					MemoryRecordsIncludeScript = true, 
					MemoryRecords = {
						{
							Description = '${HookName}  ()->', 
							Type = vtAutoAssembler, 
							Color = Colors.Teal, 
						}, 
						{
							Description = '_[==  ${HookName}  ==]_', 
							IsGroupHeader = true, 
							MemoryRecords = {
								{
									Description = 'inj${HookNameParsed}', 
									Address = 'inj${HookNameParsed}', 
									Color = Colors.Red, 
									Type = vtByteArray, 
									Aob = {
										Size = 0, 
									}, 
									ShowAsHex = true, 
								}, 
							}, 
						},  
					}, 
				}, 
			}



	Template Memory Records:  Table of settings for memory record generating.
		ID							: integer - Unique ID
		Description					: string - The description of the memory record
		Address						: string - The interpretable address string.
		OffsetCount					: integer - The number of offsets. Set to 0 for a normal address
		Offset[] 					: array - integer - Array to access each offset
		OffsetText[] 				: array - string - Array to access each offset using the interpretable text style

		Type						: ValueType - The variable type of this record. See vtByte to vtCustom
**					*** Set to 'pointer' for a type value of vtQword or vtDword based on pointer size.
							i.e.: Type = 'POINTER', 

		*  If the type is vtString then the following properties are available:
			String  				: table - Table with key value pairs.
				Size				: integer - Number of characters in the string
				Unicode				: boolean

		*  If the type is vtBinary then the following properties are available
			Binary  				: table - Table with key value pairs.
				Startbit			: integer - First bit to start reading from
				Size				: integer - Number of bits

		*  If the type is vtByteArray then the following properties are available
			Aob  					: table - Table with key value pairs.
				Size				: integer - Number of bytes

		Script						: String - If the type is vtAutoAssembler this will contain the auto assembler script
**				*** If the type is vtAutoAssembler and no script is set the parsed template will be used.

		CustomTypeName				: string - If the type is vtCustomType this will contain the name of the CustomType

		Value						: string - The value in string form.
		Active						: boolean - Set to true to activate/freeze, false to deactivate/unfreeze
		Color						: integer
		ShowAsHex					: boolean - Self explanatory
		ShowAsSigned				: boolean - Self explanatory
		AllowIncrease				: boolean - Allow value increasing, unfreeze will reset it to false
		AllowDecrease				: boolean - Allow value decreasing, unfreeze will reset it to false
		Collapsed					: boolean - Set to true to collapse this record or false to expand it. 
												Use expand/collapse methods for recursive operations. 

		HotkeyCount					: integer - Number of hot-keys attached to this memory record
		Hotkey[]					: array - Array to index the hot-keys

		DontSave					: boolean - Don't save this memoryrecord and it's children

		OnActivate					: function(memoryrecord, before, currentstate)
										: boolean - The function to call when the memoryrecord will change 
											(or changed) Active to true. If before is true, not returning true 
											will cause the activation to stop.
		OnDeactivate				: function(memoryrecord, before, currentstate)
										: boolean - The function to call when the memoryrecord will change 
											(or changed) Active to false. If before is true, not returning true 
											will cause the deactivation to stop.
		OnDestroy					: function()
										: Called when the memoryrecord is destroyed.

		Example Table:
			MemoryRecords = {
				{
					Description = '_[==  ${HookName}  ==]_', 
					IsGroupHeader = true, 
					MemoryRecords = {
						{
							Description = 'inj${HookNameParsed}', 
							Address = 'inj${HookNameParsed}', 
							Color = Colors.Red, 
							Type = vtByteArray, 
							Aob = {
								Size = 0, 
							}, 
							ShowAsHex = true, 
						}, 
					}, 
				}, 
				{
					Description = 'flg${HookNameParsed}IsAssembled', 
					Address = 'flg${HookNameParsed}IsAssembled', 
					Color = Colors.Olive, 
					Type = vtByte, 
					DropDownList = {
						Text = '0:Not Assembled\n1:Assembled\n', 
					}, 
					DropDownReadOnly = true, ---- Disallow manual user input
					DropDownDescriptionOnly = true, ---- Only show the description part
					DisplayAsDropDownListItem = true, ---- Make the record display values like the dropdownlist
				}, 
				{
					Description = 'inj${HookNameParsed}', 
					Address = 'inj${HookNameParsed}', 
					Color = Colors.Red, 
					Type = vtByteArray, 
					Aob = {
						Size = 0, 
					}, 
					ShowAsHex = true, 
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

		HookTag					- The hook tag word.
										i.e.: 'Hook', 'Hack', 'Cheat', 'Exploit', or what have you.
		HookName				- The, human readable, hook name.
										i.e.: 'Ammo DEC Hook', or 'Ammo DEC'
		HookNameBase			- The hook name with out the hook tag appended.
					* Even if 'AppendHookTag' is set to 'true'.
					* If 'AppendHookTag' is set to 'false' it will be the same as 'HookName'.
		HookNameParsed			- The, machine readable, hook name.
										i.e.: 'AmmoDECHook', or 'AmmoDEC'
		HookNameParsedBase			- The parsed hook name with out the hook tag appended.
					* Even if 'AppendHookTag' is set to 'true'.
					* If 'AppendHookTag' is set to 'false' it will be the same as 'HookNameParsed'.

		AOBBytes				- AOB byte signature string.
		AOBMessage				- Used if more then one match was found.
					** Adds a new line character if there is a message.
									i.e.: '\n// Matches Found: 25'

		OriginalCode			- The original code (pulled from disassembler view form)
		OriginalBytes			- The original bytes (pulled from disassembler view form)
		InstNOPS				- Nops matching the original number of bytes.
		InstNOP90S				- Nops, in data byte format, matching the original number of bytes.
									i.e.: 'db 90 90 90'
		NOPS					- Used if nops are needed.
		NOP90S					- Used if nops are needed.

		InjectionInfo			- The injection information collected (the commented out disassembler output).

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



	Templates:
		Key Format:
			${TemplateKey}

		Example:
			${Header}
			define(bytes, ${OriginalBytes})
			define(address, ${Address})
			////
			//// ------------------------------ ENABLE ------------------------------
			[ENABLE]
			assert(address, bytes)
			////
			//// ---------- Injection Point ----------
			address:
				${InstNOPS}
			////
			//// ------------------------------ DISABLE ------------------------------
			[DISABLE]
			////
			//// ---------- Injection Point ----------
			address:
				db bytes
			${InjectionInfo}



	Template Files:
		- Template files can be just a CEA file or they can have a settings and template section
**			*** Must be just a CEA file, or have '[SETTINGS]' then '[TEMPLATE]' section in that order.
				i.e.:
					|		Good	|		Good	|		Good	|		Bad		|
					|---------------|---------------|---------------|---------------|
					|	[SETTINGS]	|	[TEMPLATE]	|	...			|	[TEMPLATE]	|
					|	...			|	...			|	...			|	...			|
					|	[TEMPLATE]	|	...			|	...			|	[SETTINGS]	|
					|	...			|	...			|	...			|	...			|
					|---------------|---------------|---------------|---------------|


		CEA Files:
			- The standard CEA format with templates keys, caption add menu section will be determinate by 
				file name and directory.
					i.e.: 'some_template.cea'  ->  'Some Template' - (Templates Menu)
					i.e.: 'some_section\some_template.cea'  ->  'Some Template' - 'Some Section' (miSomeSection)

		Settings:
			- Only allows basic setting (no nested settings at this point ?? json).
**			*** Settings and template section keys must be the only thing on that line.

		Template:
			- The template to use (reads to end of file).
**			*** Template and settings section keys must be the only thing on that line.

		Example:
			[SETTINGS]
				DisplayString = 'Some Template'
				GetAddress = true
				GetHookName = true
				GetAOBSignature = true
			[TEMPLATE]
				[ENABLE]
					{$lua}
					print('I Have The Power!!')
				[DISABLE]
					{$lua}
					print('Op, its gone.')



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
			I2CEAASTG_AUTO_LOAD						- AutoLoad
			I2CEAASTG_TEMPLATES_DIRECTORY			- TemplatesDirectory
			I2CEAASTG_NOP_ASM						- NopASM
			I2CEAASTG_TEMPLATE_MARKER_LINE			- TemplateMarkerLine
			I2CEAASTG_HEADER						- TemplateHeader
		Global Variables (Overridden by Template Options):
			[[ global 								- template option ]]
			I2CEAASTG_HOOK_TAG						- HookTag
			I2CEAASTG_NOP_PADDING_LEFT				- NopPaddingLeft
			I2CEAASTG_ORIGINAL_CODE_PADDING_LEFT	- OriginalCodePaddingLeft
			I2CEAASTG_LINE_END						- LineEnd
			I2CEAASTG_LINE_COMMENT					- LineComment
			I2CEAASTG_INJ_INFO_COMMENT_TYPE			- InjectionInfoCommentType
		


	Environment Variable Keys: (Overridden by global variables)
		CE_USERNAME			- The name used for 'Author' template key.



]====================================================================================================================]--





local NAME = 'I2 Cheat Engine Auto Assembler Script Template Generator'
local CLASS_NAME = 'I2CEAutoAssemblerScriptTemplates'
local VERSION = '1.0.2'
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
local Logger = { ClassName = 'I2Logger', Name = 'I2CEAASTG_Logger' }
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
Logger.debugf('I2CEAASTG: %s: Loaded.', Logger.ClassName)




------ TODO: Look into translation setup for CE.
----
----
---- Translation function
----
local function t(tanslationStr)
	return tanslationStr
end




--[[

-- local p = print
-- local f = string.format
-- local lst = {
-- 	'Black', 
-- 	'White', 
-- 	'Silver', 
-- 	'Grey', 
-- 	'Red', 
-- 	'Maroon', 
-- 	'Yellow', 
-- 	'Olive', 
-- 	'Lime', 
-- 	'Green', 
-- 	'Aqua', 
-- 	'Teal', 
-- 	'Blue', 
-- 	'Navy', 
-- 	'Fuchsia', 
-- 	'Purple', 
-- }
-- local al = getAddressList()
-- for i = 1, #lst do
-- 	local mr = al.getMemoryRecordByDescription(lst[i])
-- 	p(f('%s  -  %06X  -  %d', lst[i], mr.Color, mr.Color))
-- end

With CT: E:\Documents\My Cheat Tables\~CE-Tester\colors.CT

Output form Cheat Engine:
	Black  -  FFFFFFFF80000008  -  -2147483640 
	White  -  FFFFFF  -  16777215 
	Silver  -  C0C0C0  -  12632256 
	Grey  -  808080  -  8421504 
	Red  -  0000FF  -  255 
	Maroon  -  000080  -  128 
	Yellow  -  00FFFF  -  65535 
	Olive  -  008080  -  32896 
	Lime  -  00FF00  -  65280 
	Green  -  008000  -  32768 
	Aqua  -  FFFF00  -  16776960 
	Teal  -  808000  -  8421376 
	Blue  -  FF0000  -  16711680 
	Navy  -  800000  -  8388608 
	Fuchsia  -  FF00FF  -  16711935 
	Purple  -  800080  -  8388736 
]]--

local Colors = {
	Black = 0x000000, 
	White = 0xFFFFFF, 
	Silver = 0xC0C0C0, 
	Grey = 0x808080, 
	Red = 0x0000FF, -- 0xFF0000
	Maroon = 0x000080, -- 0x800000
	Yellow = 0x00FFFF, -- 0xFFFF00
	Olive = 0x008080, -- 0x808000
	Lime = 0x00FF00, 
	Green = 0x008000, 
	Aqua = 0xFFFF00, -- 0x00FFFF
	Teal = 0x808000, -- 0x008080
	Blue = 0xFF0000, -- 0x0000FF
	Navy = 0x800000, -- 0x000080
	Fuchsia = 0xFF00FF, 
	Purple = 0x800080,
}


local CommentTypes = {
	Block = 1,
	Line = 2, 
}




local CREATE_MAIN_FORM_MENU_ITEMS = true
local MAIN_FORM_PARENT_MENU_ITEM_NAME = 'miExtra'
local MAIN_FORM_PARENT_MENU_ITEM_CAPTION = 'Extra'


local MENU_CREATION_TIMER_INTERVALS = 500

local HOOK_TAG = 'Hook'

local IS_ASSEMBLED_FLAG_DROP_DOWN_TEXT = '0:' .. t('Not Assembled') .. '\n1:' .. t('Assembled') .. '\n'

local TEMPLATE_FILE_EXT = 'cea'
local FORM_CAPTION = 'Auto assemble'


local I2_TEMPLATE_MR_SEP = {
	Description = '--------------------------------------------------------------------------------' .. 
					'-------------------------', 
	Color = Colors.Silver, 
	IsGroupHeader = true, 
}
local I2_TEMPLATE_MR_GROUP_HEADER = '_[==  ${HookName}  ==========================================================' .. 
										'=========================]_'
local I2_TEMPLATE_MR_FLG_IS_ASSEMBLED = {
	Description = 'flg${HookNameParsed}IsAssembled', 
	Address = 'flg${HookNameParsed}IsAssembled', 
	Color = Colors.Olive, 
	Type = vtByte, 
	DropDownList = {
		Text = IS_ASSEMBLED_FLAG_DROP_DOWN_TEXT, 
	}, 
	DropDownReadOnly = true, ---- Disallow manual user input
	DropDownDescriptionOnly = true, ---- Only show the description part
	DisplayAsDropDownListItem = true, ---- Make the record display values like the dropdownlist
}
local I2_TEMPLATE_MR_AOB = {
	Description = 'aob${HookNameParsed}', 
	Address = 'aob${HookNameParsed}', 
	Color = Colors.Blue, 
	Type = vtByteArray, 
	Aob = {
		Size = 0, 
	}, 
	ShowAsHex = true, 
}
local I2_TEMPLATE_MR_INJ = {
	Description = 'inj${HookNameParsed}', 
	Address = 'inj${HookNameParsed}', 
	Color = Colors.Red, 
	Type = vtByteArray, 
	Aob = {
		Size = 0, 
	}, 
	ShowAsHex = true, 
}
local I2_TEMPLATE_MR_MRK_MEM_START = {
	Description = 'mrk${HookNameParsed}MemSTART', 
	Address = 'mrk${HookNameParsed}MemSTART', 
	Color = Colors.Green, 
	Type = vtByteArray, 
	Aob = {
		Size = 0, 
	}, 
	ShowAsHex = true, 
}
local I2_TEMPLATE_MR_MRK_MEM_END = {
	Description = 'mrk${HookNameParsed}MemEND', 
	Address = 'mrk${HookNameParsed}MemEND', 
	Color = Colors.Green, 
	Type = vtByteArray, 
	Aob = {
		Size = 0, 
	}, 
	ShowAsHex = true, 
}
local I2_TEMPLATE_MR_MEM_MIN = {
	Description = 'mem${HookNameParsed}', 
	Address = 'mem${HookNameParsed}', 
	Color = Colors.Green, 
	Type = vtByteArray, 
	Aob = {
		Size = 0, 
	}, 
	ShowAsHex = true, 
}
local I2_TEMPLATE_MR_MEM = I2_TEMPLATE_MR_MEM_MIN
I2_TEMPLATE_MR_MEM.MemoryRecords = {
	I2_TEMPLATE_MR_MRK_MEM_START, 
	I2_TEMPLATE_MR_MRK_MEM_END, 
}
local I2_TEMPLATE_MR_PTR = {
	Description = 'ptr${HookNameParsed}', 
	Address = 'ptr${HookNameParsed}', 
	Color = Colors.Grey, 
	Type = 'pointer', 
	ShowAsHex = true, 
}





local I2_MR_SCRIPT_COLOR = Colors.Teal



--------
--------
--------
--------
-------- I2 Templates START
-- local I2_TEMPLATE_ = [========[
-- ]========]
local I2_TEMPLATE_HEADER = [========[
{
	Process			: ${ProcessName}  -  ${ModuleBitSize}
	Module			: ${Module}  -  ${ModuleSize}
	Game Title		: ${GameTitle}
	Game Version	: ${GameVersion}
	CE Version		: ${CEVersion}
	Script Version	: 0.0.1
	Date			: ${Date}
	Author			: ${Author}
	Name			: ${HookNameParsed}

	${HookName}
}
]========]
----
---- Hook Disabler
----
local I2_TEMPLATE_HOOK_DISABLER = [========[
//// Hook: ${HookNameParsedBase}

{$asm}
////
//// ------------------------------ ENABLE ------------------------------
[ENABLE]



{$asm}
////
//// ------------------------------ DISABLE ------------------------------
[DISABLE]
{$lua}
if syntaxcheck then return end
I2CETableHooks.Hooks.${HookNameParsedBase}.disable()



]========]
----
---- Hook Enabler
----
local I2_TEMPLATE_HOOK_ENABLER = [========[
//// Hook: ${HookNameParsedBase}

{$asm}
////
//// ------------------------------ ENABLE ------------------------------
[ENABLE]
{$lua}
if syntaxcheck then return end
I2CETableHooks.Hooks.${HookNameParsedBase}.enable()



{$asm}
////
//// ------------------------------ DISABLE ------------------------------
[DISABLE]
{$lua}
if syntaxcheck then return end
I2CETableHooks.Hooks.${HookNameParsedBase}.disable()



]========]
local I2_TEMPLATE_HOOK_ENABLER__MRS_TBL = {
	{
		Description = '${HookName} - ' .. t('Enabler') .. '  ()->', 
		Type = vtAutoAssembler, 
		Color = I2_MR_SCRIPT_COLOR, 
	}, 
}
----
---- Cheat Table Framework
----
local I2_TEMPLATE_CHEAT_TABLE_FRAMEWORK = [========[
////
//// ------------------------------ ENABLE ------------------------------
[ENABLE]



////
//// ------------------------------ DISABLE ------------------------------
[DISABLE]



]========]
local I2_TEMPLATE_CHEAT_TABLE_FRAMEWORK__MRS_TBL = {
	{
		Description = t('New Cheat Table Framework Script') .. '  ()->', 
		Type = vtAutoAssembler, 
		Color = I2_MR_SCRIPT_COLOR, 
	}, 
}
----
---- Address Injection
----
local I2_TEMPLATE_ADDRESS_INJECTION = [========[
${Header}

define(bytes, ${OriginalBytes})
define(address, ${Address})


////
//// ------------------------------ ENABLE ------------------------------
[ENABLE]
define(inj${HookNameParsed}, address+0)
assert(inj${HookNameParsed}, bytes)
registerSymbol(inj${HookNameParsed})


////
//// ---------- Injection Point ----------
inj${HookNameParsed}:
	${InstNOP90S}



////
//// ------------------------------ DISABLE ------------------------------
[DISABLE]
////
//// ---------- Injection Point ----------
inj${HookNameParsed}:
	db bytes


unregisterSymbol(inj${HookNameParsed})


${InjectionInfo}

]========]
local I2_TEMPLATE_ADDRESS_INJECTION__MRS_TBL = {
	{
		Description = '${HookName}  ()->', 
		Type = vtAutoAssembler, 
		Color = I2_MR_SCRIPT_COLOR, 
	}, 
	{
		Description = I2_TEMPLATE_MR_GROUP_HEADER, 
		IsGroupHeader = true, 
		MemoryRecords = {
			I2_TEMPLATE_MR_INJ, 
		}, 
	},  
}
----
---- Address Injection Minimal
----
local I2_TEMPLATE_ADDRESS_INJECTION_MIN = [========[
${Header}

define(bytes, ${OriginalBytes})
define(address, ${Address})


////
//// ------------------------------ ENABLE ------------------------------
[ENABLE]
assert(address, bytes)


////
//// ---------- Injection Point ----------
address:
	${InstNOP90S}



////
//// ------------------------------ DISABLE ------------------------------
[DISABLE]
////
//// ---------- Injection Point ----------
address:
	db bytes

${InjectionInfo}

]========]
local I2_TEMPLATE_ADDRESS_INJECTION_MIN__MRS_TBL = {
	{
		Description = '${HookName}  ()->', 
		Type = vtAutoAssembler, 
		Color = I2_MR_SCRIPT_COLOR, 
	}, 
}
----
---- Address Full Injection
----
local I2_TEMPLATE_ADDRESS_FULL_INJECTION = [========[
${Header}

define(bytes, ${OriginalBytes})
define(address, ${Address})

globalAlloc(flg${HookNameParsed}IsAssembled, 0x1)


////
//// ------------------------------ ENABLE ------------------------------
[ENABLE]
define(inj${HookNameParsed}, address+0)
assert(inj${HookNameParsed}, bytes)
registerSymbol(inj${HookNameParsed})

alloc(mem${HookNameParsed}, 0x400${ModuleDecl})
registerSymbol(mem${HookNameParsed})
label(mrk${HookNameParsed}MemSTART)
registerSymbol(mrk${HookNameParsed}MemSTART)
label(mrk${HookNameParsed}MemEND)
registerSymbol(mrk${HookNameParsed}MemEND)

label(ptr${HookNameParsed})
registerSymbol(ptr${HookNameParsed})


label(n_code)
label(o_code)
label(exit)
label(return)

mem${HookNameParsed}:
	padding 16

	ptr${HookNameParsed}:
		${PointerDefault}

	padding 16
	mrk${HookNameParsed}MemSTART:

	n_code:
		//mov [ptr${HookNameParsed}],${BaseAddressRegistry}

	o_code:
${OriginalCode}

	exit:
		jmp return
	mrk${HookNameParsed}MemEND:



//// BaseAddressOffset: ${BaseAddressOffset}
//// ---------- Injection Point ----------
inj${HookNameParsed}:
	jmp n_code${NOPS}
	return:



flg${HookNameParsed}IsAssembled:
	db 01



////
//// ------------------------------ DISABLE ------------------------------
[DISABLE]
////
//// ---------- Injection Point ----------
inj${HookNameParsed}:
	db bytes


flg${HookNameParsed}IsAssembled:
	db 00


unregisterSymbol(inj${HookNameParsed})

unregisterSymbol(ptr${HookNameParsed})

dealloc(mem${HookNameParsed})
unregisterSymbol(mem${HookNameParsed})
unregisterSymbol(mrk${HookNameParsed}MemSTART)
unregisterSymbol(mrk${HookNameParsed}MemEND)

${InjectionInfo}

]========]
local I2_TEMPLATE_ADDRESS_FULL_INJECTION__MRS_TBL = {
	{
		Description = '${HookName}  ()->', 
		Type = vtAutoAssembler, 
		Color = I2_MR_SCRIPT_COLOR, 
	}, 
	{
		Description = I2_TEMPLATE_MR_GROUP_HEADER, 
		IsGroupHeader = true, 
		MemoryRecords = {
			I2_TEMPLATE_MR_FLG_IS_ASSEMBLED, 
			I2_TEMPLATE_MR_INJ, 
			I2_TEMPLATE_MR_MEM, 
			I2_TEMPLATE_MR_SEP, 
			I2_TEMPLATE_MR_PTR, 
		}, 
	}, 
}
----
---- Address Full Injection Minimal
----
local I2_TEMPLATE_ADDRESS_FULL_INJECTION_MIN = [========[
${Header}

define(bytes, ${OriginalBytes})
define(address, ${Address})


////
//// ------------------------------ ENABLE ------------------------------
[ENABLE]
assert(address, bytes)

alloc(mem${HookNameParsed}, 0x400${ModuleDecl})

label(ptr${HookNameParsed})
registerSymbol(ptr${HookNameParsed})


label(n_code)
label(o_code)
label(exit)
label(return)

mem${HookNameParsed}:
	ptr${HookNameParsed}:
		${PointerDefault}

	n_code:
		//mov [ptr${HookNameParsed}],${BaseAddressRegistry}

	o_code:
${OriginalCode}

	exit:
		jmp return



////
//// ---------- Injection Point ----------
address:
	jmp n_code${NOPS}
	return:



////
//// ------------------------------ DISABLE ------------------------------
[DISABLE]
////
//// ---------- Injection Point ----------
address:
	db bytes

dealloc(mem${HookNameParsed})

${InjectionInfo}

]========]
local I2_TEMPLATE_ADDRESS_FULL_INJECTION_MIN__MRS_TBL = {
	{
		Description = '${HookName}  ()->', 
		Type = vtAutoAssembler, 
		Color = I2_MR_SCRIPT_COLOR, 
	}, 
	I2_TEMPLATE_MR_PTR, 
}
----
---- AOB Injection
----
local I2_TEMPLATE_AOB_INJECTION = [========[
${Header}

define(bytes, ${OriginalBytes})
define(address, ${Address})

globalAlloc(flg${HookNameParsed}IsAssembled, 0x1)



////
//// ------------------------------ ENABLE ------------------------------
[ENABLE]
aobScan${ModuleStr}(aob${HookNameParsed}${ModuleDecl}, ${AOBBytes})${AOBMessage}
registerSymbol(aob${HookNameParsed})
define(inj${HookNameParsed}, aob${HookNameParsed}+0)
assert(inj${HookNameParsed}, bytes)
registerSymbol(inj${HookNameParsed})


////
//// ---------- Injection Point ----------
inj${HookNameParsed}:
	${InstNOP90S}



flg${HookNameParsed}IsAssembled:
	db 01



////
//// ------------------------------ DISABLE ------------------------------
[DISABLE]
////
//// ---------- Injection Point ----------
inj${HookNameParsed}:
	db bytes


flg${HookNameParsed}IsAssembled:
	db 00


unregisterSymbol(aob${HookNameParsed})
unregisterSymbol(inj${HookNameParsed})


${InjectionInfo}

]========]
local I2_TEMPLATE_AOB_INJECTION__MRS_TBL = {
	{
		Description = '${HookName}  ()->', 
		Type = vtAutoAssembler, 
		Color = I2_MR_SCRIPT_COLOR, 
	}, 
	{
		Description = I2_TEMPLATE_MR_GROUP_HEADER, 
		IsGroupHeader = true, 
		MemoryRecords = {
			{
				Description = '${HookName} - ' .. t('Disable') .. '  ()->', 
				Type = vtAutoAssembler, 
				Color = Colors.Fuchsia, 
				Script = I2_TEMPLATE_HOOK_DISABLER, 
			}, 
			I2_TEMPLATE_MR_SEP, 
			I2_TEMPLATE_MR_FLG_IS_ASSEMBLED, 
			I2_TEMPLATE_MR_AOB, 
			I2_TEMPLATE_MR_INJ, 
			I2_TEMPLATE_MR_SEP, 
			{
				Description = '${HookName} - ' .. t('Enabler') .. '  ()->', 
				Type = vtAutoAssembler, 
				Color = Colors.Fuchsia, 
				Script = I2_TEMPLATE_HOOK_ENABLER, 
			}, 
		}, 
	}, 
}
----
---- AOB Injection Minimal
----
local I2_TEMPLATE_AOB_INJECTION_MIN = [========[
${Header}

define(bytes, ${OriginalBytes})
define(address, ${Address})


////
//// ------------------------------ ENABLE ------------------------------
[ENABLE]
aobScan${ModuleStr}(aob${HookNameParsed}${ModuleDecl}, ${AOBBytes})${AOBMessage}
define(inj${HookNameParsed}, aob${HookNameParsed}+0)
assert(inj${HookNameParsed}, bytes)
registerSymbol(inj${HookNameParsed})


////
//// ---------- Injection Point ----------
inj${HookNameParsed}:
	${InstNOP90S}



////
//// ------------------------------ DISABLE ------------------------------
[DISABLE]
////
//// ---------- Injection Point ----------
inj${HookNameParsed}:
	db bytes

unregisterSymbol(inj${HookNameParsed})

${InjectionInfo}

]========]
local I2_TEMPLATE_AOB_INJECTION_MIN__MRS_TBL = {
	{
		Description = '${HookName}  ()->', 
		Type = vtAutoAssembler, 
		Color = I2_MR_SCRIPT_COLOR, 
	}, 
	I2_TEMPLATE_MR_INJ, 
}
----
---- AOB Full Injection
----
local I2_TEMPLATE_AOB_FULL_INJECTION = [========[
${Header}

define(bytes, ${OriginalBytes})
define(address, ${Address})

globalAlloc(flg${HookNameParsed}IsAssembled, 0x1)



////
//// ------------------------------ ENABLE ------------------------------
[ENABLE]
aobScan${ModuleStr}(aob${HookNameParsed}${ModuleDecl}, ${AOBBytes})${AOBMessage}
registerSymbol(aob${HookNameParsed})
define(inj${HookNameParsed}, aob${HookNameParsed}+0)
assert(inj${HookNameParsed}, bytes)
registerSymbol(inj${HookNameParsed})

alloc(mem${HookNameParsed}, 0x400${ModuleDecl})
registerSymbol(mem${HookNameParsed})
label(mrk${HookNameParsed}MemSTART)
registerSymbol(mrk${HookNameParsed}MemSTART)
label(mrk${HookNameParsed}MemEND)
registerSymbol(mrk${HookNameParsed}MemEND)

label(ptr${HookNameParsed})
registerSymbol(ptr${HookNameParsed})


label(n_code)
label(o_code)
label(exit)
label(return)

mem${HookNameParsed}:
	padding 16

	ptr${HookNameParsed}:
		${PointerDefault}

	padding 16
	mrk${HookNameParsed}MemSTART:

	n_code:
		//mov [ptr${HookNameParsed}],${BaseAddressRegistry}

	o_code:
${OriginalCode}

	exit:
		jmp return
	mrk${HookNameParsed}MemEND:



////
//// ---------- Injection Point ----------
inj${HookNameParsed}:
	jmp n_code${NOPS}
	return:



flg${HookNameParsed}IsAssembled:
	db 01



////
//// ------------------------------ DISABLE ------------------------------
[DISABLE]
////
//// ---------- Injection Point ----------
inj${HookNameParsed}:
	db bytes


flg${HookNameParsed}IsAssembled:
	db 00


unregisterSymbol(aob${HookNameParsed})
unregisterSymbol(inj${HookNameParsed})

unregisterSymbol(ptr${HookNameParsed})

dealloc(mem${HookNameParsed})
unregisterSymbol(mem${HookNameParsed})
unregisterSymbol(mrk${HookNameParsed}MemSTART)
unregisterSymbol(mrk${HookNameParsed}MemEND)

${InjectionInfo}

]========]
local I2_TEMPLATE_AOB_FULL_INJECTION__MRS_TBL = {
	{
		Description = '${HookName}  ()->',  
		Type = vtAutoAssembler, 
		Color = I2_MR_SCRIPT_COLOR, 
	}, 
	{
		Description = I2_TEMPLATE_MR_GROUP_HEADER, 
		IsGroupHeader = true, 
		MemoryRecords = {
			{
				Description = '${HookName} - Disable  ()->', 
				Type = vtAutoAssembler, 
				Color = Colors.Fuchsia, 
				Script = I2_TEMPLATE_HOOK_DISABLER, 
			}, 
			I2_TEMPLATE_MR_SEP, 
			I2_TEMPLATE_MR_FLG_IS_ASSEMBLED, 
			I2_TEMPLATE_MR_AOB, 
			I2_TEMPLATE_MR_INJ, 
			I2_TEMPLATE_MR_MEM, 
			I2_TEMPLATE_MR_SEP, 
			I2_TEMPLATE_MR_PTR, 
			I2_TEMPLATE_MR_SEP, 
			{
				Description = '${HookName} - Enabler  ()->', 
				Type = vtAutoAssembler, 
				Color = Colors.Fuchsia, 
				Script = I2_TEMPLATE_HOOK_ENABLER, 
			}, 
		}, 
	}, 
}
----
---- AOB Full Injection Minimal
----
local I2_TEMPLATE_AOB_FULL_INJECTION_MIN = [========[
${Header}

define(bytes, ${OriginalBytes})
define(address, ${Address})


////
//// ------------------------------ ENABLE ------------------------------
[ENABLE]
aobScan${ModuleStr}(aob${HookNameParsed}${ModuleDecl}, ${AOBBytes})${AOBMessage}
define(inj${HookNameParsed}, aob${HookNameParsed}+0)
assert(inj${HookNameParsed}, bytes)
registerSymbol(inj${HookNameParsed})

alloc(mem${HookNameParsed}, 0x400${ModuleDecl})

label(ptr${HookNameParsed})
registerSymbol(ptr${HookNameParsed})


label(n_code)
label(o_code)
label(exit)
label(return)

mem${HookNameParsed}:
	ptr${HookNameParsed}:
		${PointerDefault}

	n_code:
		//mov [ptr${HookNameParsed}],${BaseAddressRegistry}

	o_code:
${OriginalCode}

	exit:
		jmp return


////
//// ---------- Injection Point ----------
inj${HookNameParsed}:
	jmp n_code${NOPS}
	return:


////
//// ------------------------------ DISABLE ------------------------------
[DISABLE]
////
//// ---------- Injection Point ----------
inj${HookNameParsed}:
	db bytes

unregisterSymbol(inj${HookNameParsed})

unregisterSymbol(ptr${HookNameParsed})

dealloc(mem${HookNameParsed})

${InjectionInfo}

]========]
local I2_TEMPLATE_AOB_FULL_INJECTION_MIN__MRS_TBL = {
	{
		Description = '${HookName}  ()->', 
		Type = vtAutoAssembler, 
		Color = I2_MR_SCRIPT_COLOR, 
	}, 
	{
		Description = I2_TEMPLATE_MR_GROUP_HEADER, 
		IsGroupHeader = true, 
		MemoryRecords = {
			I2_TEMPLATE_MR_INJ, 
			I2_TEMPLATE_MR_SEP, 
			I2_TEMPLATE_MR_PTR, 
		}, 
	}, 
}
----
---- Create Thread
----
local I2_TEMPLATE_CREATE_THREAD = [========[
${Header}


////
//// ------------------------------ ENABLE ------------------------------
[ENABLE]
globalAlloc(memThreads, 0x200)

label(threadStart)
label(threadEnd)

memThreads:
	threadStart:
		nop

	threadEnd:
		ret


createThread(threadStart)

////
//// ------------------------------ DISABLE ------------------------------
[DISABLE]



]========]
local I2_TEMPLATE_CREATE_THREAD__MRS_TBL = {
	{
		Description = t('New Create Thread Script') .. '  ()->', 
		Type = vtAutoAssembler, 
		Color = I2_MR_SCRIPT_COLOR, 
	}, 
}
----
---- CEA Lua Base
----
local I2_TEMPLATE_CEA_LUA = [========[
{$asm}
////
//// ------------------------------ ENABLE ------------------------------
[ENABLE]
{$lua}
if syntaxcheck then return end


{$asm}
////
//// ------------------------------ DISABLE ------------------------------
[DISABLE]
{$lua}
if syntaxcheck then return end



]========]
local I2_TEMPLATE_CEA_LUA__MRS_TBL = {
	{
		Description = t('New CEA Lua Script') .. '  ()->', 
		Type = vtAutoAssembler, 
		Color = I2_MR_SCRIPT_COLOR, 
	}, 
}
----
----
----
---- I2 Templates
----
local I2_TEMPLATES = {
	Name = 'I2CEATemplates', 
	SectionDisplayString = t('I2 CEA Templates'), 
	SectionName = 'miI2CEATemplatesSection', 
	{
		Name = 'I2CEA_CheatTableFrameworkCode', 
		DisplayString = t('Cheat table framework code'), 
		TemplateString = I2_TEMPLATE_CHEAT_TABLE_FRAMEWORK,
		MemoryRecordsIncludeScript = true, 
		MemoryRecords = I2_TEMPLATE_CHEAT_TABLE_FRAMEWORK__MRS_TBL,
	}, 
	'-----', ---- SEPERATOR
	{
		Name = 'I2CEA_AddressInjectionMinimal', 
		DisplayString = t('Address Injection Minimal'), 
		GetAddress = true, 
		GetHookName = true, 
		HookTag = HOOK_TAG, 
		AppendHookTag = true, 
		TemplateString = I2_TEMPLATE_ADDRESS_INJECTION_MIN, 
		MemoryRecordsIncludeScript = true, 
		MemoryRecords = I2_TEMPLATE_ADDRESS_INJECTION_MIN__MRS_TBL, 
	}, 
	{
		Name = 'I2CEA_AddressFullInjectionMinimal', 
		DisplayString = t('Address Full Injection Minimal'), 
		GetAddress = true, 
		GetHookName = true, 
		HookTag = HOOK_TAG, 
		AppendHookTag = true, 
		IsFullHook = true, 
		TemplateString = I2_TEMPLATE_ADDRESS_FULL_INJECTION_MIN, 
		MemoryRecordsIncludeScript = true, 
		MemoryRecords = I2_TEMPLATE_ADDRESS_FULL_INJECTION_MIN__MRS_TBL, 
	}, 
	{
		Name = 'I2CEA_AOBInjectionMinimal', 
		DisplayString = t('AOB Injection Minimal'), 
		GetAddress = true, 
		GetHookName = true, 
		HookTag = HOOK_TAG, 
		AppendHookTag = true, 
		GetAOBSignature = true, 
		TemplateString = I2_TEMPLATE_AOB_INJECTION_MIN, 
		MemoryRecordsIncludeScript = true, 
		MemoryRecords = I2_TEMPLATE_AOB_INJECTION_MIN__MRS_TBL, 
	}, 
	{
		Name = 'I2CEA_AOBFullInjectionMinimal', 
		DisplayString = t('AOB Full Injection Minimal'), 
		GetAddress = true, 
		GetHookName = true, 
		HookTag = HOOK_TAG, 
		AppendHookTag = true, 
		GetAOBSignature = true, 
		IsFullHook = true, 
		TemplateString = I2_TEMPLATE_AOB_FULL_INJECTION_MIN, 
		MemoryRecordsIncludeScript = true, 
		MemoryRecords = I2_TEMPLATE_AOB_FULL_INJECTION_MIN__MRS_TBL, 
	}, 
	'-----', ---- SEPERATOR
	{
		Name = 'I2CEA_AddressInjection', 
		DisplayString = t('Address Injection'), 
		GetAddress = true, 
		GetHookName = true, 
		HookTag = HOOK_TAG, 
		AppendHookTag = true, 
		TemplateString = I2_TEMPLATE_ADDRESS_INJECTION, 
		MemoryRecordsIncludeScript = true, 
		MemoryRecords = I2_TEMPLATE_ADDRESS_INJECTION__MRS_TBL, 
	}, 
	{
		Name = 'I2CEA_AddressFullInjection', 
		DisplayString = t('Address Full Injection'), 
		GetAddress = true, 
		GetHookName = true, 
		HookTag = HOOK_TAG, 
		AppendHookTag = true, 
		IsFullHook = true, 
		TemplateString = I2_TEMPLATE_ADDRESS_FULL_INJECTION, 
		MemoryRecordsIncludeScript = true, 
		MemoryRecords = I2_TEMPLATE_ADDRESS_FULL_INJECTION__MRS_TBL, 
	}, 
	{
		Name = 'I2CEA_AOBInjection', 
		DisplayString = t('AOB Injection'), 
		GetAddress = true, 
		GetHookName = true, 
		HookTag = HOOK_TAG, 
		AppendHookTag = true, 
		GetAOBSignature = true, 
		TemplateString = I2_TEMPLATE_AOB_INJECTION, 
		MemoryRecordsIncludeScript = true, 
		MemoryRecords = I2_TEMPLATE_AOB_INJECTION__MRS_TBL, 
	}, 
	{
		Name = 'I2CEA_AOBFullInjection', 
		DisplayString = t('AOB Full Injection'), 
		GetAddress = true, 
		GetHookName = true, 
		HookTag = HOOK_TAG, 
		AppendHookTag = true, 
		GetAOBSignature = true, 
		IsFullHook = true, 
		TemplateString = I2_TEMPLATE_AOB_FULL_INJECTION, 
		MemoryRecordsIncludeScript = true, 
		MemoryRecords = I2_TEMPLATE_AOB_FULL_INJECTION__MRS_TBL, 
	}, 
	'-----', ---- SEPERATOR
	{
		Name = 'I2CEA_CreateThread', 
		DisplayString = t('Create Thread'), 
		TemplateString = I2_TEMPLATE_CREATE_THREAD, 
		MemoryRecordsIncludeScript = true, 
		MemoryRecords = I2_TEMPLATE_CREATE_THREAD__MRS_TBL, 
	}, 
	'-----', ---- SEPERATOR
	{
		Name = 'I2CEA_Lua',
		SectionDisplayString = t('CEA Lua'),
		SectionName = 'miI2LuaTemplatesSection',
		{
			Name = 'I2CEA_Lua_CEALuaBase', 
			DisplayString = t('CEA Lua Base'), 
			TemplateString = I2_TEMPLATE_CEA_LUA, 
			MemoryRecordsIncludeScript = true, 
			MemoryRecords = I2_TEMPLATE_CEA_LUA__MRS_TBL, 
		}, 
		{
			Name = 'I2CEA_Lua_HookEnabler', 
			DisplayString = t('Hook Enabler'), 
			GetHookName = true, 
			HookTag = HOOK_TAG, 
			AppendHookTag = false, 
			TemplateString = I2_TEMPLATE_HOOK_ENABLER, 
			MemoryRecordsIncludeScript = true, 
			MemoryRecords = I2_TEMPLATE_HOOK_ENABLER__MRS_TBL, 
		}, 
	}, 
}
-------- I2 Templates END
--------
--------
--------
--------





---- Defaults
	---- I2CEAASTG_OPCODE_PADDING_RIGHT
	local default_OpcodePaddingRight = 35
	
	---- I2CEAASTG_BYTES_PADDING_RIGHT
	local default_BytesPaddingRight = 26
	
	---- I2CEAASTG_TEMPLATE_MARKER_LINE
	local default_TemplateMarkerLine = '//// ------------------------------------------------------------' .. 
											'----------------------'
	---- I2_TEMPLATE_HEADER
	local default_TemplateHeader = I2_TEMPLATE_HEADER
	
	---- I2CEAASTG_DATE_FORMAT
	local default_DateFormat = '%x'
	
	---- Has Tables Overrides:
		---- HookTag - I2CEAASTG_HOOK_TAG
		local default_HookTag = HOOK_TAG
		
		---- AppendHookTag - I2CEAASTG_APPEND_HOOK_TAG
		local default_AppendHookTag = true
		
		---- InjectionInfoCommentType - I2CEAASTG_INJ_INFO_COMMENT_TYPE
		local default_InjectionInfoCommentType = CommentTypes.Block
		
		---- LineComment - I2CEAASTG_LINE_COMMENT
		local default_LineComment = '//// '
		
		---- LineEnd - I2CEAASTG_LINE_END
		local default_LineEnd = '\n'
		
		---- NopPaddingLeft - I2CEAASTG_NOP_PADDING_LEFT
		local default_NopPaddingLeft = '\t'
		
		---- OriginalCodePaddingLeft - I2CEAASTG_ORIGINAL_CODE_PADDING_LEFT
		local default_OriginalCodePaddingLeft = '\t\t'
		
		---- FixInputData - I2CEAASTG_FIX_INPUT_DATA
		local default_FixInputData = true


---- Settings
	---- I2CEAASTG_AUTO_LOAD
	local AutoLoad = true

	---- I2CEAASTG_DATE_FORMAT
	local DateFormat = default_DateFormat

	---- I2CEAASTG_NOP_ASM
	local NopASM = 'nop'

	---- I2CEAASTG_TEMPLATES_DIRECTORY
	local TemplatesDirectory = getPath(os.getenv('HOMEPATH') or os.getenv('HOME'), t('My Cheat Tables'), '~I2Templates')

	---- I2CEAASTG_ADD_MAIN_SEPERATOR
	local AddMainSeperator = true

	---- I2CEAASTG_PLACE_HOLDER_KEY
	local PlaceHolderKey = t('PlaceHolder_')

	local UserNameEnvKey = 'CE_USERNAME'
	---- CE_USER_NAME
	local UserName = os.getenv(UserNameEnvKey) or os.getenv('USERNAME') or 'USERNAME'

	local InjectionInfoCount = 20

	local AOBSignatureScanMax = 10
	local AOBSignatureMin = 8

	---- I2CEAASTG_TEMPLATE_MARKER_LINE
	local TemplateMarkerLine = default_TemplateMarkerLine
	---- I2CEAASTG_HEADER
	local TemplateHeader = default_TemplateHeader



----
----
---- Class / Base table
----
I2CEAutoAssemblerScriptTemplates = {
	Name = NAME, 
	ClassName = CLASS_NAME, 
	Version = VERSION, 
	Author = AUTHOR, 
	License = LICENSE, 
	Colors = Colors, 
	CommentTypes = CommentTypes, 
}



--------
--------
--------
----------------
---------------- Templates START
----------------
I2CEAutoAssemblerScriptTemplates.Templates = {
	I2_TEMPLATES, 
	-- '-----', ---- SEPERATOR (any string)
	-- {
	-- 	DisplayString = 'Address Injection', 
	-- 	GetAddress = true, 
	-- 	GetHookName = true, 
	-- 	HookTag = 'Cheat', 
	-- 	AppendHookTag = true, 
	-- 	TemplateString = I2_TEMPLATE_ADDRESS_INJECTION, 
	-- 	MemoryRecordsIncludeScript = true, 
	-- 	MemoryRecords = {
	-- 		{
	-- 			Description = '${HookName}  ()->', 
	-- 			Type = vtAutoAssembler, 
	-- 			Color = Colors.Teal, 
	-- 		}, 
	-- 		{
	-- 			Description = '_[==  ${HookName}  ==]_', 
	-- 			IsGroupHeader = true, 
	-- 			MemoryRecords = {
	-- 				{
	-- 					Description = 'inj${HookNameParsed}', 
	-- 					Address = 'inj${HookNameParsed}', 
	-- 					Color = Colors.Red, 
	-- 					Type = vtByteArray, 
	-- 					Aob = {
	-- 						Size = 0, 
	-- 					}, 
	-- 					ShowAsHex = true, 
	-- 				}, 
	-- 			}, 
	-- 		},  
	-- 	}, 
	-- }, 
	-- {
	-- 	DisplayString = 'Address Full Injection', 
	-- 	GetAddress = true, 
	-- 	GetHookName = true, 
	-- 	HookTag = 'Cheat', 
	-- 	AppendHookTag = true, 
	-- 	IsFullHook = true, 
	-- 	TemplateString = I2_TEMPLATE_ADDRESS_FULL_INJECTION, 
	-- 	MemoryRecordsIncludeScript = true, 
	-- 	MemoryRecords = {
	-- 		{
	-- 			Description = '${HookName}  ()->', 
	-- 			Type = vtAutoAssembler, 
	-- 			Color = Colors.Teal, 
	-- 		}, 
	-- 		{
	-- 			Description = '_[==  ${HookName}  ==]_', 
	-- 			IsGroupHeader = true, 
	-- 			MemoryRecords = {
	-- 				{
	-- 					Description = 'flg${HookNameParsed}IsAssembled', 
	-- 					Address = 'flg${HookNameParsed}IsAssembled', 
	-- 					Color = Colors.Olive, 
	-- 					Type = vtByte, 
	-- 					DropDownList = {
	-- 						Text = '0:Not Assembled\n1:Assembled\n', 
	-- 					}, 
	-- 					DropDownReadOnly = true, ---- Disallow manual user input
	-- 					DropDownDescriptionOnly = true, ---- Only show the description part
	-- 					DisplayAsDropDownListItem = true, ---- Make the record display values like the dropdownlist
	-- 				}, 
	-- 				{
	-- 					Description = 'inj${HookNameParsed}', 
	-- 					Address = 'inj${HookNameParsed}', 
	-- 					Color = Colors.Red, 
	-- 					Type = vtByteArray, 
	-- 					Aob = {
	-- 						Size = 0, 
	-- 					}, 
	-- 					ShowAsHex = true, 
	-- 				}, 
	-- 				{
	-- 					Description = 'mem${HookNameParsed}', 
	-- 					Address = 'mem${HookNameParsed}', 
	-- 					Color = Colors.Green, 
	-- 					Type = vtByteArray, 
	-- 					Aob = {
	-- 						Size = 0, 
	-- 					}, 
	-- 					ShowAsHex = true, 
	-- 					MemoryRecords = {
	-- 						{
	-- 							Description = 'mrk${HookNameParsed}MemSTART', 
	-- 							Address = 'mrk${HookNameParsed}MemSTART', 
	-- 							Color = Colors.Green, 
	-- 							Type = vtByteArray, 
	-- 							Aob = {
	-- 								Size = 0, 
	-- 							}, 
	-- 							ShowAsHex = true, 
	-- 						}, 
	-- 						{
	-- 							Description = 'mrk${HookNameParsed}MemEND', 
	-- 							Address = 'mrk${HookNameParsed}MemEND', 
	-- 							Color = Colors.Green, 
	-- 							Type = vtByteArray, 
	-- 							Aob = {
	-- 								Size = 0, 
	-- 							}, 
	-- 							ShowAsHex = true, 
	-- 						}, 
	-- 					},
	-- 				}, 
	-- 				{
	-- 					Description = '------------------------------------------------------------',  
	-- 					Color = Colors.Silver, 
	-- 					IsGroupHeader = true, 
	-- 				}, 
	-- 				{
	-- 					Description = 'ptr${HookNameParsed}', 
	-- 					Address = 'ptr${HookNameParsed}', 
	-- 					Color = Colors.Grey, 
	-- 					Type = 'pointer', 
	-- 					ShowAsHex = true, 
	-- 				}, 
	-- 				{
	-- 					Description = '${HookNameParsedBase}  ()->', 
	-- 					Type = vtAutoAssembler, 
	-- 					Color = Colors.Teal, 
	-- 					Script = "[ENABLE]\n{$lua}\nprint('I Have The Power!!')\n[DISABLE]\n{$lua}\nprint('Op. Its gone.')\n", 
	-- 				}, 
	-- 			}, 
	-- 		}, 
	-- 	}, 
	-- }, 
	-- '-----', ---- SEPERATOR
	-- {
	-- 	DisplayString = 'AOB Injection', 
	-- 	GetAddress = true, 
	-- 	GetHookName = true, 
	-- 	HookTag = 'Hack', 
	-- 	AppendHookTag = true, 
	-- 	GetAOBSignature = true, 
	-- 	TemplateFile = [=[E:\Documents\My Cheat Tables\~CE-Templates\AOB_Injection-template.cea]=], 
	-- 	MemoryRecordsIncludeScript = true, 
	-- 	MemoryRecords = I2_TEMPLATE_AOB_INJECTION__MRS_TBL, 
	-- }, 
	-- {
	-- 	DisplayString = 'AOB Full Injection', 
	-- 	GetAddress = true, 
	-- 	GetHookName = true, 
	-- 	HookTag = 'Hack', 
	-- 	AppendHookTag = true, 
	-- 	IsFullHook = true, 
	-- 	GetAOBSignature = true, 
	-- 	TemplateString = I2_TEMPLATE_AOB_FULL_INJECTION, 
	-- 	MemoryRecordsIncludeScript = true, 
	-- 	MemoryRecords = I2_TEMPLATE_AOB_FULL_INJECTION__MRS_TBL, 
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
local function parseBytesStr(str)
	str = str:gsub(' ', '')
	local rtn = ''
	for i = 1, #str, 2 do
		rtn = rtn .. ' ' .. str:sub(i, i) .. str:sub(i + 1, i + 1)
	end
	return rtn:sub(2)
end

local function parseDisassembledString(str)
	if not str then return end
	-- local address, bytes, opcode, extraField = splitDisassembledString(str)
	local extraField, opcode, bytes, address = splitDisassembledString(str)
	opcode = padR(opcode, I2CEAASTG_OPCODE_PADDING_RIGHT or default_OpcodePaddingRight)
	bytes = padR(bytes, I2CEAASTG_BYTES_PADDING_RIGHT or default_BytesPaddingRight)
	local addressStr = getNameFromAddress(address) or address
	return format('%s:  %s  -  %s%s', addressStr, bytes or '', opcode or '', extraField or '')
end


local function getMenuItemForm(menuItem)
	local form = nil
	local item = menuItem
	for i = 0, 100 do
		if item.Caption == FORM_CAPTION or item.Caption == t(FORM_CAPTION) then
			Logger.debugf('I2CEAASTG: getMenuItemForm: form found, steps: %s', i)
			return item
		elseif item.Owner == nil then
			return
		else
			item = item.Owner
		end
	end
end


local function getAOBSignature(address)
	local loopMax = AOBSignatureScanMax
	local sigMin = AOBSignatureMin
	local ad = address
	local is = getInstructionSize(ad)
	local bytes = readBytes(ad, is, true)
	local signature = ''
	local signatureLength = 0
	local scanCount = 0
	for i = 1, loopMax do
		for i = 1, #bytes do
			signature = signature .. format(' %02X', bytes[i])
			signatureLength = signatureLength + 1
		end
		local list = AOBScan(signature)
		scanCount = list.count
		if signatureLength > sigMin and scanCount == 1 then
			return signature, scanCount
		elseif scanCount > 0 then
			ad = ad + is
			is = getInstructionSize(ad)
			bytes = readBytes(ad, is, true)
		end
	end
	Logger.debugf('I2CEAASTG: getAOBSignature: %s, %d', signature, scanCount)
	return signature, scanCount
end


--------
--------
-------- Generate
--------
function I2CEAutoAssemblerScriptTemplates.generate(menuItem, templateTbl)
	Logger.debugf('I2CEAASTG: generate: generating template: "%s".', templateTbl.Name or templateTbl.DisplayString)

	local form = getMenuItemForm(menuItem)
	local origScript = ''
	if form ~= nil then
		origScript = form.Assemblescreen.Lines.Text
	end

	local le = templateTbl.LineEnd or I2CEAASTG_LINE_END or default_LineEnd or '\n'

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
	Logger.infof('I2CEAASTG: generate: pointer size set: %s', pointerSizeStr)

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
		Logger.errorf('I2CEAASTG: generate: ' .. msg, templateTbl.Name)
		showMessage(format('ERROR: ' .. t(msg), templateTbl.DisplayString))
		return nil, nil
	end

	local fixInputData = templateTbl.FixInputData
	if fixInputData == nil then
		fixInputData = I2CEAASTG_FIX_INPUT_DATA
	end
	if fixInputData == nil then
		fixInputData = default_FixInputData
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
			Logger.warn('I2CEAASTG: generate: got nil for address.')
			if form ~= nil then
				form.Assemblescreen.Lines.Text = origScript
			end
			return nil, nil ---- Exit generating template if prompt canceled.
		else
			Logger.debugf('I2CEAASTG: generate: got address: %s.', addressStr)
			address = getAddress(addressStr)
		end
	end
	Logger.infof('I2CEAASTG: generate: using address: %X.', address)

	local nameBase = ''
	local hookName = ''
	local hookNameParsed = ''
	local hookNameParsedBase = ''
	local hookTag = templateTbl.HookTag or I2CEAASTG_HOOK_TAG or default_HookTag or HOOK_TAG
	local appendHookTag = templateTbl.AppendHookTag
	if appendHookTag == nil then
		appendHookTag = I2CEAASTG_APPEND_HOOK_TAG
	end
	if appendHookTag == nil then
		appendHookTag = default_AppendHookTag
	end
	if templateTbl.GetHookName then
		local msg = t('Enter the name of the') .. ' ' .. hookTag:lower() .. ':'
		if appendHookTag then
			msg = msg .. '\n\n* "' .. hookTag .. '" ' .. t('will be appended to the name.')
		end
		hookName = inputQuery(hookTag .. ' ' .. t('Name') .. '?', msg, '')
		if hookName == nil then
			Logger.warn('I2CEAASTG: generate: got nil for ' .. hookTag:lower() .. ' name.')
			if form ~= nil then
				form.Assemblescreen.Lines.Text = origScript
			end
			return nil, nil ---- Exit generating template if prompt canceled.
		end
		if fixInputData then
			hookName = titleCase(hookName:gsub('_', ' '))
			hookName = hookName:gsub(' ' .. t('Dec'), ' ' .. t('DEC'))
			hookName = hookName:gsub(' ' .. t('Inc'), ' ' .. t('INC'))
		end
		hookNameParsed = hookName:gsub(' ', '')
		nameBase = hookName
		hookNameParsedBase = hookNameParsed
		if appendHookTag and not hookName:lower():match(hookTag:lower()) then
			hookName = hookName .. ' ' .. hookTag
			hookNameParsed = hookNameParsed .. hookTag
		end
		if hookNameParsedBase:lower():match(hookTag:lower()) then
			hookNameParsedBase = hookNameParsedBase:gsub(hookTag, '')
			hookNameParsedBase = hookNameParsedBase:gsub(hookTag:lower(), '')
			hookNameParsedBase = hookNameParsedBase:gsub(hookTag:upper(), '')
			hookNameParsedBase = hookNameParsedBase:gsub(titleCase(hookTag), '')
		end
		Logger.debugf('I2CEAASTG: generate: got ' .. hookTag:lower() .. ' name: "%s".', hookName)
		Logger.debugf('I2CEAASTG: generate: parsed ' .. hookTag:lower() .. ' name: "%s".', hookNameParsed)
		Logger.debugf('I2CEAASTG: generate: parsed base ' .. hookTag:lower() .. ' name: "%s".', hookNameParsed)
	end


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


	local nopASM = I2CEAASTG_NOP_ASM or NopASM or 'nop'
	local tempMarkerLine = I2CEAASTG_TEMPLATE_MARKER_LINE or TemplateMarkerLine or ''
	local headerString = I2CEAASTG_HEADER or TemplateHeader or 'I2CEAASTG_HEADER'
	local nopPaddingLeft = templateTbl.NopPaddingLeft or I2CEAASTG_NOP_PADDING_LEFT or default_NopPaddingLeft or ''
	local oCodePaddingLeft = templateTbl.OriginalCodePaddingLeft or I2CEAASTG_ORIGINAL_CODE_PADDING_LEFT 
								or default_OriginalCodePaddingLeft or ''
	local injCommentType = templateTbl.InjectionInfoCommentType or I2CEAASTG_INJ_INFO_COMMENT_TYPE 
								or default_InjectionInfoCommentType or 1
	local lineComment = templateTbl.LineComment or I2CEAASTG_LINE_COMMENT or default_LineComment or '//// '

	local userName = CE_USERNAME or UserName
	local placeholderKey = I2CEAASTG_PLACE_HOLDER_KEY or PlaceHolderKey

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

	local injectionInfo = ''
	local iils = lineComment
	if injCommentType == CommentTypes.Block then
		iils = ''
	end
	local ad = address
	for i = 1, InjectionInfoCount do
		ad = getPreviousOpcode(ad)
		injectionInfo = iils .. parseDisassembledString(disassemble(ad)) .. le .. injectionInfo
	end

	if moduleName and moduleName ~= '' then
		injectionInfo = iils .. '//// ' .. t('Module') .. ': ' .. moduleName .. '  -  ' .. moduleAddressStr .. le .. 
							injectionInfo
	end
	if process then
		injectionInfo = iils .. '//// ' .. t('Process') .. ': ' .. process .. '  -  ' .. processAddresStr .. le .. 
							injectionInfo
	end
	injectionInfo = iils .. '//// ' .. t('Injection Point') .. ': ' .. addressStr .. '  -  ' .. 
						format(pointerFtmStr, address) .. le .. injectionInfo
	if injCommentType == CommentTypes.Block then
		injectionInfo = '{' .. le .. injectionInfo
	end

	injectionInfo = injectionInfo .. iils .. '////  ' .. t('INJECTING') .. ' ' .. t('START') .. 
						'  ----------------------------------------------------------' .. le
	injectionInfo = injectionInfo .. iils .. parseDisassembledString(disassemble(address)) .. le

	local fullHook = templateTbl.IsFullHook or false

	local stop = math.max(dv_address1, dv_address2)
	local length = stop + getInstructionSize(stop) - address
	local extraField, opcode, bytes, disassembledAddress = splitDisassembledString(disassemble(address))
	local originalCode = oCodePaddingLeft .. opcode
	bytes = parseBytesStr(bytes)
	local originalBytesStr = bytes

	local ad = address
	local iSize = getInstructionSize(ad)
	local iSizeMin = iSize
	if fullHook then
		iSizeMin = 5
	end
	local opcodeCount = 1
	if length < iSizeMin then
		while iSize < iSizeMin do
			opcodeCount = opcodeCount + 1
			ad = ad + getInstructionSize(ad)
			local l = getInstructionSize(ad)
			iSize = iSize + l
			local extraField, opcode, bytes, disassembledAddress = splitDisassembledString(disassemble(ad))
			originalBytesStr = originalBytesStr .. parseBytesStr(bytes)
			originalCode = originalCode .. le .. oCodePaddingLeft .. opcode
		end
	end

	ad = address
	for i = 1, InjectionInfoCount do
		if opcodeCount == i then
			injectionInfo = injectionInfo .. iils .. '////  ' .. t('INJECTING') .. ' ' .. t('END') .. 
								'  ----------------------------------------------------------' .. le
		end
		ad = ad + getInstructionSize(ad)
		injectionInfo = injectionInfo .. iils .. parseDisassembledString(disassemble(ad)) .. le
	end

	injectionInfo = injectionInfo .. '//// ' .. t('Template') .. ': ' .. 
						(templateTbl.Name or templateTbl.DisplayString) .. le
	injectionInfo = injectionInfo .. '//// ' .. t('Generated with') .. ': ' .. NAME .. le
	injectionInfo = injectionInfo .. '//// ' .. t('Code Happy, Code Freely, Be Awesome.') .. le
	if injCommentType == CommentTypes.Block then
		injectionInfo = injectionInfo .. '}' .. le
	end

	local instNopStr = ''
	local instNop90sStr = ''
	for i = 1, iSize do
		if instNopStr == nil or instNopStr == '' then
			instNopStr = nopASM
		else
			instNopStr = instNopStr .. le .. nopPaddingLeft .. nopASM
		end
		if instNop90sStr == nil or instNop90sStr == '' then
			instNop90sStr = 'db'
		end
		instNop90sStr = instNop90sStr .. ' 90'
	end

	local nopStr = ''
	local nop90sStr = ''
	if iSize > iSizeMin then
		for i = 6, iSize do
			nopStr = nopStr .. le .. nopPaddingLeft .. nopASM
			if nop90sStr == nil or nop90sStr == '' then
				nop90sStr = le .. nopPaddingLeft .. 'db'
			end
			nop90sStr = nop90sStr .. ' 90'
		end
	end

	local aobMessage = ''
	local signatureBytesStr = ''
	if templateTbl.GetAOBSignature then
		local signature, signatureCount = getAOBSignature(address, pMsg)
		signatureBytesStr = signature
		signatureBytesStr = signatureBytesStr
		if signatureCount > 1 then
			aobMessage = le .. '//// ' .. t('AOB Matches Found') .. ': ' .. signatureCount
		end
	end

	local o_regStr = ''
	local o_offsetStr = ''
	if type(originalCode) == 'string' and originalCode ~= '' then
		local rStr = [=[[fld|fstp|lea|LEA|mov|MOV|add|ADD|sub|SUB|mul|MUL|div|DIV|inc|INC|dec|DEC][ss|SS]*[%s]+[dword|qword]*[%s]*[ptr]*[%s]*[%a|%d|,]*%[([%a]+)([%+|%*|%-][a-fA-F0-9]*)%]]=]
		o_regStr, o_offsetStr = originalCode:match(rStr)
	end

	local parsedTemplate = template
	local headerTbl = {
		Header = headerString or ''
	}
	parsedTemplate = interp(parsedTemplate, headerTbl)
	local valueTbl = {
		ProcessName = process or '', 
		ProcessAddress = processAddresStr or '', 
		Module = moduleName or '', 
		ModuleStr = moduleStr or '', 
		ModuleDecl = moduleDeclStr or '', 
		ModuleAddress = moduleAddressStr or '', 
		ModuleSize = moduleSizeStr or '', 
		ModuleBitSize = moduleBitSizeStr or '', 
		Date = os.date(I2CEAASTG_DATE_FORMAT or DateFormat) or '', 
		Author = userName or '', 
		HookTag = hookTag or '', 
		HookName = hookName or '', 
		HookNameBase = nameBase or '', 
		HookNameParsed = hookNameParsed or '', 
		HookNameParsedBase = hookNameParsedBase or '', 
		OriginalBytes = parseBytesStr(originalBytesStr) or '', 
		AOBBytes = parseBytesStr(signatureBytesStr) or '', 
		AOBMessage = aobMessage or '', 
		OriginalCode = originalCode or '', 
		Address = addressStr or '', 
		AddressHex = format(pointerFtmStr, address), 
		InjectionInfo = injectionInfo or '', 
		InstNOPS = instNopStr or '', 
		InstNOP90S = instNop90sStr or '', 
		NOPS = nopStr or '', 
		NOP90S = nop90sStr or '', 
		CEVersion = tostring(getCEVersion() or 0), 
		PointerSize = pointerSizeStr, 
		PointerFtmStr = pointerFtmStr or '%016X', 
		PointerWordSize = pointerWordSize or 'dq', 
		PointerDefault = pointerDefaultStr or 'dq 0', 
		PointerDefaultFull = format(pointerWordSize .. ' ' .. pointerFtmStr, 0x0), 
		GameTitle = gameTitle or '', 
		GameVersion = gameVersion or '', 
		BaseAddressRegistry = o_regStr or '', 
		BaseAddressOffset = o_offsetStr or '', 
	}
	parsedTemplate = interp(parsedTemplate, valueTbl)

	while (parsedTemplate:find('${' .. placeholderKey .. '.-}') ~= nil) do
		local placeholderFull, placeholderName = parsedTemplate:match('(${' .. placeholderKey .. '(.-)})')
		placeholderName = titleCase(placeholderName:gsub('_', ' '))
		local placeholderReplace = inputQuery(placeholderName .. '?',
											  t('Enter replacement for keyword') .. ' "' .. placeholderName .. '":', 
											  '')
		if placeholderReplace == nil then
			Logger.warnf('I2CEAASTG: generate: got nil for key word replacement: kw: "%s", n: "%s".', 
							placeholderFull, placeholderName)
			form.Assemblescreen.Lines.Text = origScript
			return nil, nil ---- Exit generating template if prompt canceled
		end
		Logger.debugf('I2CEAASTG: generate: got key word replacement: kw: "%s", n: "%s", r: "%s".', 
						placeholderFull, placeholderName, placeholderReplace)
		if placeholderReplace == '' then
			placeholderReplace = placeholderFull
		end
		parsedTemplate = parsedTemplate:gsub(placeholderFull, placeholderReplace)
		valueTbl[placeholderKey] = placeholderReplace
	end

	Logger.infof('I2CEAASTG: generate: template generated: "%s".', templateTbl.Name or templateTbl.DisplayString)
	local logMsg, _ = parsedTemplate:gsub('\r\n', '\n')
	logMsg, _ = parsedTemplate:gsub('\n', '\r\n')
	Logger.debug('------------------------------------------------------------')
	Logger.debug(logMsg)
	Logger.debug('------------------------------------------------------------')

	if type(origScript) == 'string' and #origScript > 2 then
		origScript = origScript .. le .. le .. tempMarkerLine .. le
	else
		origScript = ''
	end

	if form ~= nil then
		form.Assemblescreen.Lines.Text = origScript .. parsedTemplate
	end

	if templateTbl.MemoryRecords ~= nil then
		local sctMsg = '* ' .. t('The script is NOT included') .. '!!'
		if templateTbl.MemoryRecordsIncludeScript then
			sctMsg = t('The script is included') .. '.'
		end
		local msg = t('Would you like to add template memory records to the table?') .. '\n\n' .. sctMsg
		local mr = messageDialog(msg, mtConfirmation, mbYes, mbNo, mbCancel)
		if mr == mrYes then
			valueTbl.Script = parsedTemplate
			local mrTbl = I2CEAutoAssemblerScriptTemplates.createTemplateMemoryRecords(templateTbl, valueTbl)
		end
	end
	return parsedTemplate, mrTbl
end



--------
--------
-------- Create Memory Records
--------
function I2CEAutoAssemblerScriptTemplates.createTemplateMR(mrTbl, interpTbl, appendMr)
	if mrTbl == nil then return end
	local addressesList = getAddressList()
	local memoryRecord = addressesList.createMemoryRecord()
	local isScript = false
	local scriptStr = nil
	for k, v in pairs(mrTbl) do
		if k == 'MemoryRecords' and type(v) == 'table' then
			Logger.debug('I2CEAASTG: createTemplateMR: generating child memory records.')
			for i = 1, #v do
				local subMemoryRecord = I2CEAutoAssemblerScriptTemplates.createTemplateMR(v[i], interpTbl, memoryRecord)
			end
		else
			if type(v) == 'table' and memoryRecord[k] ~= nil 
			and (k ~= 'Offset' or k ~= 'OffsetText' or k ~= 'Hotkey') then
				for v_k, v_v in pairs(v) do
					memoryRecord[k][v_k] = v_v
				end
			else
				if k == 'Type' and v == vtAutoAssembler then
					isScript = true
				elseif k == 'Script' and type(v) == 'string' then
					scriptStr = interp(v, interpTbl)
				end
				if k == 'Type' and type(v) == 'string' 
				and (v:lower() == 'pointer' or v:lower() == 'ptr' or v:lower() == 'p') then
					if interpTbl.PointerSize == '0x4' then
						memoryRecord[k] = vtDword
					else
						memoryRecord[k] = vtQword
					end
				else
					if type(v) == 'string' then
						v = interp(v, interpTbl)
					end
					memoryRecord[k] = v
				end
			end
		end
	end
	if appendMr ~= nil then
		memoryRecord.appendToEntry(appendMr)
	end
	if isScript and scriptStr == nil then
		memoryRecord.Script = interpTbl.Script
	elseif scriptStr ~= nil then
		memoryRecord.Script = scriptStr
	end
	local lDStr = memoryRecord.Description:sub(1, 40)
	Logger.debugf('I2CEAASTG: createTemplateMR: memory record created: ID: % 3d, Type: % 2d, "%s".', 
						memoryRecord.ID, memoryRecord.Type, lDStr)
	return memoryRecord
end


function I2CEAutoAssemblerScriptTemplates.createTemplateMemoryRecords(templateTbl, interpTbl)
	Logger.info('I2CEAASTG: createTemplateMemoryRecords: generating memory records.')
	if templateTbl == nil or templateTbl.MemoryRecords == nil then return end
	local addressesList = getAddressList()
	local mrTbl = templateTbl.MemoryRecords
	local createdMemoryRecordsTbl = { }
	local memoryRecord = nil
	for i = 1, #mrTbl do
		memoryRecord = I2CEAutoAssemblerScriptTemplates.createTemplateMR(mrTbl[i], interpTbl)
		createdMemoryRecordsTbl[i] = memoryRecord
	end
	return createdMemoryRecordsTbl
end



--------
--------
--------
-------- Setup and Load:
--------
function I2CEAutoAssemblerScriptTemplates.createTelplateMenuItem(menu, tbl)
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
			Logger.debugf('I2CEAASTG: createTelplateMenuItem: Template Section Menu Item Created: "%s".', 
							sectionMenuItem.Name)
		end
		for i = 1, #tbl do
			I2CEAutoAssemblerScriptTemplates.createTelplateMenuItem(sectionMenuItem, tbl[i])
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
			Logger.debugf('I2CEAASTG: createTelplateMenuItem: Template Menu Item Clicked: "%s".', menuItem.Name)
			I2CEAutoAssemblerScriptTemplates.generate(menuItem, tbl)
		end
		local menuItem = createMenuItem(menu)
		menuItem.Name = name
		menuItem.OnClick = mi_click
		menuItem.Caption = tbl.DisplayString
		menu.add(menuItem)
		if menuItem then
			Logger.debugf('I2CEAASTG: createTelplateMenuItem: Template Menu Item Created: "%s".', menuItem.Name)
		end
		return menuItem
	end
end


function I2CEAutoAssemblerScriptTemplates.createMenuItems(menu)
	if I2CEAutoAssemblerScriptTemplates.Templates == nil then return end
	if menu == nil then return end
	if I2CEAASTG_ADD_MAIN_SEPERATOR or (I2CEAASTG_ADD_MAIN_SEPERATOR == nil and AddMainSeperator) then
		local mi = createMenuItem(menu)
		mi.Caption = '-'
		menu.add(mi)
	end
	for i = 1, #I2CEAutoAssemblerScriptTemplates.Templates do
		if I2CEAutoAssemblerScriptTemplates.Templates[i] ~= nil then
			local menuItem = I2CEAutoAssemblerScriptTemplates.createTelplateMenuItem(menu, 
									I2CEAutoAssemblerScriptTemplates.Templates[i])
		end
	end
end



function I2CEAutoAssemblerScriptTemplates.loadTemplateDir(path, tbl)
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
					local le = tempTbl.LineEnd or I2CEAASTG_LINE_END or default_LineEnd or '\n'
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


function I2CEAutoAssemblerScriptTemplates.loadTemplatesDirectory(path, tbl)
	if type(path) ~= 'string' then return end
	if tbl == nil then
		tbl = I2CEAutoAssemblerScriptTemplates.Templates
	end
	if isDirectory(path) then
		I2CEAutoAssemblerScriptTemplates.loadTemplateDir(path, tbl)
		for i, j in pairs(getDirectoryList(path)) do
			local dirPath, dirName = j:match([==[(.-)([^\/]-%.?([^%.\/]*))$]==])
			local secTbl = {
				DisplayString = dirName:gsub('_', ' '), 
			}
			I2CEAutoAssemblerScriptTemplates.loadTemplateDir(dirPath, secTbl)
			table.insert(tbl, secTbl)
		end

	end
	Logger.debug('I2CEAASTG: loadTemplatesDirectory: loading templates directory.')
	I2CEAutoAssemblerScriptTemplates.loadTemplateDir(dirPath, tbl)
end


function I2CEAutoAssemblerScriptTemplates.formCreateNotify(form)
	if form.ClassName == 'TfrmAutoInject' then
		Logger.debugf('I2CEAASTG: formCreateNotify: "%s" form created, creating timer for menu creation.', form.ClassName)
		local ticks = 0
		local intervals = MENU_CREATION_TIMER_INTERVALS or 500 ---- Set timer a little higher to keep menu items in same spot.
		local timer = createTimer(form)
		timer.Interval = intervals
		local function formCreateNotifyTimer_tick(timer)
			ticks = ticks + 1
			if form == nil or form.Menu == nil then return end
			timer.destroy()
			Logger.debugf('I2CEAASTG: formCreateNotifyTimer_tick: creating menu items, ' .. 
							'timer KILLED. Interval: %d, Ticks: %d.', intervals, ticks)
			local miTemplate = form.emplate1
			I2CEAutoAssemblerScriptTemplates.createMenuItems(miTemplate)
		end
		timer.OnTimer = formCreateNotifyTimer_tick
	end
end


function I2CEAutoAssemblerScriptTemplates.createMainFormMenu()
	local mainForm = getMainForm()
	if mainForm.Menu == nil then return end
	local menuItems = mainForm.Menu.Items
	local miExtra = nil
	for i = 0, menuItems.Count - 1 do
		if menuItems[i].Name == MAIN_FORM_PARENT_MENU_ITEM_NAME then
			miExtra = menuItems[i]
		end
	end
	if miExtra == nil then
		miExtra = createMenuItem(mainForm)
		miExtra.Name = MAIN_FORM_PARENT_MENU_ITEM_NAME
		miExtra.Caption = MAIN_FORM_PARENT_MENU_ITEM_CAPTION
		menuItems.insert(menuItems.Count - 2, miExtra)
	end
	Logger.debug('I2CEAASTG: createMainFormMenu: creating main form menu items.')
	return I2CEAutoAssemblerScriptTemplates.createMenuItems(miExtra)
end


function I2CEAutoAssemblerScriptTemplates.loadTemplates(templates)
	if templates ~= nil then
		if templates.DisplayString ~= nil then
			templates = { templates }
		end
		for i = 1, #templates do
			table.insert(I2CEAutoAssemblerScriptTemplates.Templates, templates[i])
		end
	end
	Logger.debug('I2CEAASTG: loadTemplates: loading templates.')
	I2CEAutoAssemblerScriptTemplates.loadTemplatesDirectory(I2CEAASTG_TEMPLATES_DIRECTORY or TemplatesDirectory)
	registerFormAddNotification(I2CEAutoAssemblerScriptTemplates.formCreateNotify)
end


local function loadI2CEAutoAssemblerScriptTemplates()
	local function loadTemplatesTimer_tick(timer)
		timer.destroy()
		if (I2CEAASTG_AUTO_LOAD ~= nil and I2CEAASTG_AUTO_LOAD) 
		or (I2CEAASTG_AUTO_LOAD == nil and AutoLoad) then
			I2CEAutoAssemblerScriptTemplates.loadTemplates()
		end
		if CREATE_MAIN_FORM_MENU_ITEMS then
			I2CEAutoAssemblerScriptTemplates.createMainFormMenu()
		end
	end
	---- Use timer to allow other files to load templates and keep menu items in same spot.
	local intervals = 300
	local timer = createTimer(getMainForm())
	timer.Interval = intervals
	timer.OnTimer = loadTemplatesTimer_tick
end

loadI2CEAutoAssemblerScriptTemplates()

Logger.debugf('I2CEAASTG: %s: Loaded.', I2CEAutoAssemblerScriptTemplates.ClassName)
return I2CEAutoAssemblerScriptTemplates