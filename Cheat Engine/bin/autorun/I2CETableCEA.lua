--[====================================================================================================================[

I2 Cheat Engine CEA File Assembler

	Version: 1.0.1

	Author: Matt - TheyCallMeTim13 - MattI2.com


	Features:
		- A Lua module for assembling CEA files be it, table files or local files, in a Cheat Engine table.
			Note: Local files will override the table files, this is meant for updating scripts.
		- Really the only function meant to be used is autoAssembleFile(ceaFile, targetSelf, disable)


	Settings:
		CEAFilesDirectory			: The directory to check for local files.
										Can be set to nil to look in current folder.
										i.e.: 'ceaFiles'


	Install / Setup Method:
		This is a Lua module so place it in the Cheat Engine 'lua' folder or in the same directory as the cheat table
		then just import (require) the module to use


	Examples:
		require 'I2CETableCEA'
		I2CETableCEA.autoAssembleFile('CoordHook.CEA', false, false) -- Enable
		I2CETableCEA.autoAssembleFile('CoordHook.CEA', false, true) -- Disable
		I2CETableCEA.autoAssembleFile('CoordHook.CEA', true, false) -- Enable and assemble in Cheat Engine's memory


	Note:
		The "Table Require" template in my "pluginI2CELuaScriptTemplateGenerator.lua" plug-in will also allow for 
			Lua modules to be added as table files then imported, but local files will override the table files.

			Table Require Code:
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
						local f, err = io.open(localTableLuaFilePath .. '.lua')
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
				CETrequire('I2CETableCEA')
				-- I2CETableCEA.autoAssembleFile('CoordHook.CEA', false, false)



]====================================================================================================================]--



local default_CEAFilesDirectory = 'ceaFiles'





local NAME = 'I2 Cheat Engine Table CEA'
local CLASS_NAME = 'I2CETableCEA'
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
Logger.debugf('I2CETC: %s: Loaded.', Logger.ClassName)



I2CETableCEA = {
	Name = NAME, 
	ClassName = CLASS_NAME, 
	Version = VERSION, 
	Author = AUTHOR, 
	License = LICENSE, 
	CEAFilesDirectory = default_CEAFilesDirectory, 
}
I2CETableCEA.TableFileInfoSets = {}

function I2CETableCEA.getPath( ... )
	local pathseparator = package.config:sub(1,1)
	local elements = { ... }
	return table.concat(elements, pathseparator)
end

function I2CETableCEA.exists(path)
	if type(path) ~= 'string' then return end
	return os.rename(path, path) and true or false
end

function I2CETableCEA.isFile(path)
	if type(path) ~= 'string' then return end
	if not exists(path) then return false end
	local f = io.open(path)
	if f then
		f:close()
		return true
	end
	return false
end

function I2CETableCEA.isDirectory(path)
	return (exists(path) and not isFile(path))
end


function I2CETableCEA.getFileStr(ceaFile)
	if ceaFile ~= nil then
		Logger.debugf('I2CETC: getFileStr: Loading CEA fil: "%s"', ceaFile)
		local localCEAFilePath = ceaFile
		if I2CETableCEA.CEAFilesDirectory ~= nil or I2CETableCEA.CEAFilesDirectory ~= '' then
			localCEAFilePath = I2CETableCEA.getPath(I2CETableCEA.CEAFilesDirectory, ceaFile)
		end
		local fileStr = nil
		local f, err = io.open(localCEAFilePath, 'r')
		if f and not err then
			fileStr = f:read('*all')
			Logger.debug('I2CETC: getFileStr: load local file.')
			return fileStr
		else
			local tableFile = findTableFile(ceaFile)
			if tableFile == nil then
				Logger.error(format('I2CETC: getFileStr: Error opening table file: "%s"', ceaFile), err)
				error(format('I2CETC: getFileStr: Error opening table file: "%s"', ceaFile))
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
			Logger.debug('I2CETC: getFileStr: load table file.')
			return fileStr
		end
	end
	return nil
end

function I2CETableCEA.autoAssembleFile(ceaFile, targetSelf, disable)
	local fileStr = I2CETableCEA.getFileStr(ceaFile)
	if fileStr then
		Logger.debugf('I2CETC: autoAssembleFile: Assembling File: "%s".', ceaFile)
		local assembled = nil
		local disableInfo = I2CETableCEA.TableFileInfoSets[ceaFile]
		local checkOk, errMsg = autoAssembleCheck(fileStr, not disable)
		if not checkOk then
			if errMsg == nil or errMsg == '' then
				errMsg = 'No Error Message!'
			end
			Logger.error(format('I2CETC: autoAssembleFile: Syntx error in file: "%s"\r\n%s', ceaFile, errMsg))
			error(format('I2CETC: autoAssembleFile: Syntx error in file: "%s"\r\n%s', ceaFile, errMsg))
		end
		assembled, disableInfo = autoAssemble(fileStr, targetSelf, disableInfo)
		if assembled then
			if disable then
				disableInfo = nil
			end
			I2CETableCEA.TableFileInfoSets[ceaFile] = disableInfo
			return assembled, disableInfo
		else
			Logger.error(format('I2CETC: autoAssembleFile: Error assembling file: "%s"', ceaFile))
			error(format('I2CETC: autoAssembleFile: Error assembling file: "%s"', ceaFile))
		end
		return false
	end
	return false
end
Logger.debugf('I2CETC: %s: Loaded.', I2CETableCEA.ClassName)
return I2CETableCEA