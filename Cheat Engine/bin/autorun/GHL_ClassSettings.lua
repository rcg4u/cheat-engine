ClassSettings = {}
ClassSettings.__index = ClassSettings
function ClassSettings:New(_fileName, _maskFile)

	local obj = {}
	obj.stringList = createStringlist()
	obj.fileName = _fileName
	obj.maskFile = _maskFile
	
	obj.directoryPath = getCheatEngineDir()..'autorun'
	obj.filePath = obj.directoryPath..'\\'..obj.fileName
	
	-- Есть ли такой ключ
	function obj:HasKey(keyString)
		local stringCount = obj.stringList.Count

		for i=0,stringCount-1 do
			local items = obj:Split(obj.stringList[i])
			if(keyString == items[1]) then
				return true 
			end
		end
	end
	
	-- Получить значение ключа
	function obj:Get(keyString, defaultValue)
		if(obj:HasKey(keyString)) then
			local stringCount = obj.stringList.Count
			for i=0,stringCount-1 do
				local items = obj:Split(obj.stringList[i])
				if(keyString == items[1]) then
					return  items[2]
				end
			end
		end
		return defaultValue
	end
	
	-- Записать ключ
	function obj:Set(keyString, stringOrDigitalValue)
		-- Искать номер строки
		local stringCount = obj.stringList.Count
		for i=0,stringCount-1 do
			local items = obj:Split(obj.stringList[i])
			if(keyString == items[1]) then
				items[2] = stringOrDigitalValue
				obj.stringList.remove(obj.stringList[i])
				break
			end
		end
		
		obj.stringList.add (keyString..' '..stringOrDigitalValue)
	end
	
	function obj:SaveForm(form, key)
		obj:Set(key..'.Width', form.Width)
		obj:Set(key..'.Height', form.Height)
		obj:Set(key..'.Left', form.Left)
		obj:Set(key..'.Top', form.Top)
	end
	
	function obj:LoadForm(form, key)
			form.Width = obj:GetDigital(key..'.Width', form.Width)
			form.Height = obj:GetDigital(key..'.Height', form.Height)
			form.Left = obj:GetDigital(key..'.Left', form.Left)
			form.Top = obj:GetDigital(key..'.Top', form.Top)
	end
	
	-- Возвращает числовой вариант
	function obj:GetDigital(keyString, defaultValue)
		if(obj:HasKey(keyString)) then
			return tonumber(obj:Get(keyString))
		end
		return defaultValue
	end

	-- Сохранить все ключи
	function obj:Save()
		obj.stringList.saveToFile(obj.filePath)
	end

	function obj:FileExist(directoryPath, pathToFile, mask)
		local paths = getFileList(directoryPath, mask, false)
		for i=1,#paths do
			if(paths[i] == pathToFile) then
				return true
			end
		end
		return false
	end
	
	function obj:Split(argString)
		local resultTable = {}
		local maxLen = string.len(argString)
		
		for i=1, maxLen do
			if string.sub (argString, i, i) == ' ' then
				return 
				{
					string.sub (argString, 1, i - 1),  
					string.sub (argString, i + 1, maxLen)
				}
			end
		end
		
	
	-- for i in string.gmatch(argString, "%S+") do
	-- 	table.insert(resultTable, i)
	-- end
		return nil
	end

	
	-- Загрузка ключей в память
	if(obj:FileExist(obj.directoryPath, obj.filePath, obj.maskFile)) then
		obj.stringList.loadFromFile(obj.filePath)
	end	
	setmetatable(obj, obj)
	return obj
end