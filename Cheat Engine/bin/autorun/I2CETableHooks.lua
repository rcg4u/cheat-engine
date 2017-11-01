--[====================================================================================================================[

I2 Cheat Engine Table Hooks
    
	Version: 1.0.1

	Author: Matt - TheyCallMeTim13 - MattI2.com


	Install / Setup 1:
		- Put in CE lua folder (it isn't created by default).
		- Import and add hooks.

	Install / Setup 2:
		- Put in CET folder.
		- Import and add hooks.



	Hooks.new:
		I2CETableHooks.Hooks.new(key, enable, ceaFile, autoHook)
			- key		: string - The hooks key in the table.
			- enable	: boolean - Set to true to allow the hook to be enabled or disabled.
			- ceaFile	: string - The CEA file name.
					** Looks for file in 'ceaFiles' directory in the current directory, 
						then if not found looks for a table file and creates a local file for loading.
							- Looking in to how to read from the memory stream returned from table file. 
								So no local file is required, and only for overriding.
			- autoHook	: boolean - Set to true to have enabled or disabled with runAutoHook function


	run:
		Hooks[key].run(enable, force)
			- enable	: boolean - Set to true to enable and false to disable.
			- force		: boolean - Set to true to force enable or disable even if already in that state.

	enable:
		Hooks[key].enable(force)
			- force		: boolean - Set to true to force enable even if already in that state.

	disable:
		Hooks[key].disable(force)
			- force		: boolean - Set to true to force disable even if already in that state.


	Hooks.runAutoHook:
		- Runs all enabled auto hooks.
		Hooks.runAutoHook(enable)
			- enable	: boolean - Set to true to enable and false to disable.

	Hooks.runHooks:
		- Runs all enabled hooks (even auto hooks).
		Hooks.runHooks(enable, force)
			- enable	: boolean - Set to true to enable and false to disable.
			- force		: boolean - Set to true to force enable or disable even if already in that state.



	To Import:
		require 'I2CETableHooks'

	To Add Hooks:
		I2CETableHooks.Hooks.new('PlayerBase', true, 'PlayerBaseHook.CEA', true)
		I2CETableHooks.Hooks.new('HealthDEC', true, 'HealthDECHook.CEA')
		I2CETableHooks.Hooks.new('ManaWrite', true, 'ManaWriteHook.CEA')
		I2CETableHooks.Hooks.new('MovementSpeed', true, 'MovementSpeedHook.CEA')

	To Enable Hooks:
		I2CETableHooks.Hooks.PlayerBase.enable()
		I2CETableHooks.Hooks.HealthDEC.run(true)

	To Disable Hooks:
		I2CETableHooks.Hooks.PlayerBase.disable()
		I2CETableHooks.Hooks.HealthDEC.run(false)



	Settings:
		CEAFilesDirectory			: string - The directory name where cea files will be stored.



	Functions:
		I2CETableHooks.autoAssemble(str, name)
		I2CETableHooks.getAutoAssembleFileSection(ceaFile, enable)
		I2CETableHooks.autoAssembleFile(ceaFile, enable)
		I2CETableHooks.runSetupCeas(setupCEAs, enable)
		I2CETableHooks.init(setupAAStrs, setupCEAs, hooks)


		Hooks:
			I2CETableHooks.Hooks.new(key, enable, ceaFile, autoHook)
			I2CETableHooks.Hooks.runAutoHook(enable)
			I2CETableHooks.Hooks.runHooks(enable, force)


		Hook Objects:
			run(enable, force)
			enable(force)
			disable(force)
			readFile(enable, mode)
			writeFile(enable, cea, mode)
			getSection(enable)



]====================================================================================================================]--





local NAME = 'I2 Cheat Engine Table Hooks'
local CLASS_NAME = 'I2CETableHooks'
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
Logger.debugf('I2CETH: %s: Loaded.', Logger.ClassName)



local default_CEAFilesDirectory = 'ceaFiles'


----
----
---- Class / Base table
----
I2CETableHooks = {
	Name = NAME, 
	ClassName = CLASS_NAME, 
	Version = VERSION, 
	Author = AUTHOR, 
	License = LICENSE, 
	CEAFilesDirectory = default_CEAFilesDirectory, 
}


--------
--------
-------- Helpers
--------
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
--------
-------- Functions
--------
function I2CETableHooks.autoAssemble(str, name)
	if str then
		if name then
			Logger.debugf('I2CETH: autoAssemble: Assembling String: "%s"', name)
		else
			Logger.debug('I2CETH: autoAssemble: Assembling String.')
		end
		Logger.debug('====================================================================================================')
		local logStr = str:gsub('\r\n', '\n'):gsub('\n', '\r\n')
		Logger.debug(logStr)
		Logger.debug('====================================================================================================')
		local assembled = autoAssemble(str)
		if assembled then
			return assembled, str
		end
		return false, 2
	end
	return false, 1
end


function I2CETableHooks.getAutoAssembleFileSectionFromString(fileStr, enable)
	if fileStr == nil then return end
	Logger.debug('I2CETH: getAutoAssembleFileSectionFromString: getting string sections.')
	Logger.debug('====================================================================================================')
	local logStr = fileStr:gsub('\r\n', '\n'):gsub('\n', '\r\n')
	Logger.debug(logStr)
	Logger.debug('====================================================================================================')
	local topStr, enableStr, disableStr = fileStr:match('(.*)%[ENABLE%](.*)%[DISABLE%](.*)')
	enableStr = (topStr or '') .. (enableStr or '')
	disableStr = (topStr or '') .. (disableStr or '')
	Logger.debug('Enable String:')
	Logger.debug('====================================================================================================')
	local logStr = enableStr:gsub('\r\n', '\n'):gsub('\n', '\r\n')
	Logger.debug(logStr)
	Logger.debug('====================================================================================================')
	Logger.debug('Disable String:')
	Logger.debug('====================================================================================================')
	local logStr = disableStr:gsub('\r\n', '\n'):gsub('\n', '\r\n')
	Logger.debug(logStr)
	Logger.debug('====================================================================================================')
	return ((enable and enableStr) or disableStr)
end


function I2CETableHooks.getAutoAssembleFileSection(ceaFile, enable)
	if ceaFile ~= nil then
		Logger.debugf('I2CETH: getAutoAssembleFileSection: Loading CEA file section: %s "%s"', 
						((enable and 'Enable') or 'Disable'), ceaFile)
		local localCEAFilePath = ceaFile
		if I2CETableHooks.CEAFilesDirectory ~= nil or I2CETableHooks.CEAFilesDirectory ~= '' then
			localCEAFilePath = getPath(I2CETableHooks.CEAFilesDirectory, ceaFile)
		end
		local fileStr = nil
		local f, err = io.open(localCEAFilePath, 'r')
		if f and not err then
			fileStr = f:read('*all')
			Logger.debug('I2CETH: getAutoAssembleFileSection: load local file.')
			return I2CETableHooks.getAutoAssembleFileSectionFromString(fileStr, enable)
		else
			local tableFile = findTableFile(ceaFile)
			if tableFile == nil then
				Logger.error(format('I2CETH: getAutoAssembleFileSection: Error opening table file: "%s"', ceaFile), err)
				return nil
			end
			---- START: Not Working
			-- local stringStream = createStringStream()
			-- stringStream.copyFrom(tableFile.Stream, tableFile.Stream.Size)
			-- print(fileStr)
			-- local fileStr = stringStream.DataString
			-- stringStream.Destroy()
			---- END: Not Working
			local stream = tableFile.getData()
			local fileStr = nil
			local bytes = stream.read(stream.Size)
			for i = 1, #bytes do
				if fileStr == nil then
					fileStr = ''
				end
				fileStr = fileStr .. string.char(bytes[i])
			end
			Logger.debug('I2CETH: getAutoAssembleFileSection: load table file.')
			return I2CETableHooks.getAutoAssembleFileSectionFromString(fileStr, enable)
		end
	end
	return nil
end


function I2CETableHooks.autoAssembleFile(ceaFile, enable)
	local ceaSectionStr = I2CETableHooks.getAutoAssembleFileSection(ceaFile, enable)
	if ceaSectionStr then
		Logger.debugf('I2CETH: autoAssembleFile: Assembling File: "%s".', ceaFile)
		Logger.debug('====================================================================================================')
		local logStr = ceaSectionStr:gsub('\r\n', '\n'):gsub('\n', '\r\n')
		Logger.debug(logStr)
		Logger.debug('====================================================================================================')
		local assembled = autoAssemble(ceaSectionStr)
		if assembled then
			return assembled, ceaSectionStr
		end
		return false, 2
	end
	return false, 1
end


function I2CETableHooks.runSetupCeas(setupCEAs, enable)
	if setupCEAs then
		for k, cea in pairs(setupCEAs) do
			if cea then
				local assembled, ceaSectionStr = I2CETableHooks.autoAssembleFile(cea, enable)
				if assembled then
					return assembled, ceaSectionStr
				end
				return false, 2
			end
		end
	end
	return false, 1
end


function I2CETableHooks.init(setupAAStrs, setupCEAs, hooks)
	Logger.debug('I2CETH: Initializing Table.')
	if setupAAStrs then
		for k, aaStr in pairs(setupAAStrs) do
			if aaStr then
				if not I2CETableHooks.autoAssemble(aaStr, k) then
					return false, 1
				end
			end
		end
	end
	if not I2CETableHooks.runSetupCeas(setupCEAs, true) then
		return false, 2
	end
	if hooks then
		Logger.debug('I2CETH: init: Initializing Hooks.')
		if not Hooks.runAutoHook(true) then
			return false, 3
		end
	end
	return true, 0
end




local Hooks = { }


function Hooks.new(key, enable, ceaFile, autoHook)
	Hooks[key] = { Enable = enable, CeaFile = ceaFile, AutoHook = autoHook, IsEnabled = false, }
	Hooks[key].run = function(enable, force)
		local enableStr = 'Enabled'
		if not enable then enableStr = 'Disabled' end
		if Hooks[key].CeaFile and (Hooks[key].Enable or force) then
			local assemled, ceaSectionStr = I2CETableHooks.autoAssembleFile(Hooks[key].CeaFile, enable)
			if assemled then
				Hooks[key].IsEnabled = enable
				Logger.debugf('I2CETH: run: Hook %s: "%s".', enableStr, key)
				return true, 0
			else
				Logger.errorf('I2CETH: run: Hook was NOT %s: "%s" Faild to assemble.', enableStr, key)
				return false, 2
			end
		end
		return false, 1
	end
	Hooks[key].enable = function(force)
		if Hooks[key].IsEnabled and not force then
			Logger.warnf('I2CETH: enable: Hook is already Enabled use "force" if needed, Hook: "%s".', key)
			return false, 1
		end
		local assembled, ceaSectionStr = Hooks[key].run(true, force)
		if assembled then
			return assembled, ceaSectionStr
		end
		return false, 2
	end
	Hooks[key].disable = function(force)
		if not Hooks[key].IsEnabled and not force then
			Logger.warnf('I2CETH: disable: Hook is already Disabled use "force" if needed, Hook: "%s".', key)
			return false, 1
		end
		local assembled, ceaSectionStr = Hooks[key].run(false, force)
		if assembled then
			return assembled, ceaSectionStr
		end
		return false, 2
	end
	Hooks[key].readFile = function(enable, mode)
		if not mode then mode = 'r' end
		local rtn = nil
		if Hooks[key].CeaFile then
			local f, err = io.open(Hooks[key].CeaFile, mode)
			if not err and f then
				rtn = f:read()
				f:close()
			else
				Logger.error(format('I2CETH: readFile: Error opening CEA file: "%s"', Hooks[key].CeaFile), err)
			end
		end
		return rtn
	end
	Hooks[key].writeFile = function(enable, cea, mode)
		if not mode then mode = 'w' end
		local rtn = false
		if Hooks[key].CeaFile then
			local f, err = io.open(Hooks[key].CeaFile, mode)
			if not err and f then
				rtn = f:write(cea)
				f:close()
			else
				Logger.error(format('I2CETH: writeFile: Error opening CEA file: "%s"', Hooks[key].CeaFile), err)
			end
		end
		return rtn
	end
	Hooks[key].getSection = function(enable)
		if Hooks[key].CeaFile then
			return I2CETableHooks.getAutoAssembleFileSection(Hooks[key].CeaFile, enable)
		end
		return false
	end
end


function Hooks.runAutoHook(enable)
	local enableStr = 'Enabled'
	if not enable then enableStr = 'Disabled' end
	for k, v in pairs(Hooks) do
		local ex = { }
		if not ex[k] then
			if Hooks[k] 
			and type(Hooks[k]) ~= 'function'
			and Hooks[k].Enable and Hooks[k].AutoHook then
				Hooks[k].run(enable)
				Logger.warnf('I2CETH: runAutoHook: AutoHoook: %s -> %s : %s', enableStr, k, Hooks[k].CeaFile)
			end
		end
	end
end


function Hooks.runHooks(enable, force)
	local enableStr = 'Enabled'
	if not enable then enableStr = 'Disabled' end
	for k, v in pairs(Hooks) do
		local ex = { }
		if not ex[k] then
			if Hooks[k] 
			and type(Hooks[k]) ~= 'function'
			and (Hooks[k].Enable or force) then
				Hooks[k].run(enable)
				Logger.infof('I2CETH: runHooks: Hook: %s -> %s : %s', enableStr, k, Hooks[k].CeaFile)
			end
		end
	end
end


I2CETableHooks.Hooks = Hooks



Logger.debugf('I2CETH: %s: Loaded.', I2CETableHooks.ClassName)
return I2CETableHooks