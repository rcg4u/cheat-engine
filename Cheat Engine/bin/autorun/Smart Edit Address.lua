--Initialization-----------------------------------------------------------------------------------
errorOnLookupFailure(false)
local mf = getMainForm()
local al = getAddressList()

local incPtr = createMenuItem(mf.PopupMenu2.Items[1])
mf.PopupMenu2.Items[1].add(incPtr)
incPtr.Caption = "Smart increment address(es)"

local mousePos = {x,y}
local THeaderSections = {
	BaseAddress,
	Active = {Start,Right},
	Description = {Left,Right},
	Address = {Left,Right},
	Type = {Left,Right},
	Value = {Left,End}
}
--Functions----------------------------------------------------------------------------------------
--Local Functions Declaration
local Address1Click
local TreeviewDblClick
local backupOffsets
local compareOffsets
local copyOffsets
local incrementOffsets
local updatePosition
local inrange
local getTableLen
local doIndexTable
local bubblesort

local originalAddressFunc = mf.PopupMenu2.Items[1].Item[1].onClick
function Address1Click()
	--Backup original offsets
	local sr = al.getSelectedRecord()
	local originalAddress,originalOffsets,originalType = backupOffsets(sr)
	synchronize(originalAddressFunc)
	--Prompt for confirmation before copying offsets to all selected records
	if getTableLen(al.getSelectedRecords()) > 1 then
		if	messageDialog("Apply address/offset of main selection to all selected records?",mtConfirmation,mbYes,mbNo) == mrYes then
			copyOffsets(sr)
		end
	end
end

local originalTreeViewDblClickFunc = al.getComponent(0).OnDblClick
function TreeviewDblClick()
	--Local Variables Declaration
	local sr
	local originalAddress,originalOffsets,originalType
	--Check if address section is double clicked
	local addressSection = false
	updatePosition()
	if inrange(mousePos.x,THeaderSections.Address.Left,THeaderSections.Address.Right) then
		addressSection = true
	end
	--Backup original offsets
	if addressSection then
		sr = al.getSelectedRecord()
    if sr == nil then return end --Error checking when no selected records and double clicked in column area.
		originalAddress,originalOffsets,originalType = backupOffsets(sr)
	end
	synchronize(originalTreeViewDblClickFunc)
	--Check for changes else return
	if addressSection then
		if getTableLen(al.getSelectedRecords()) > 1 then
			if messageDialog("Apply address/offset of main selection to all selected records?",mtConfirmation,mbYes,mbNo) == mrYes then
				copyOffsets(sr)
			end
		end
	end
end

function backupOffsets(sr)
	local originalAddress,originalOffsets = sr.getAddress()
	local originalType = sr.Type
	return originalAddress,originalOffsets,originalType
end

function compareOffsets(originalAddress,originalOffsets,originalType,sr)
	if sr.Address ~= originalAddress then
		return true
	elseif sr.OffsetCount ~= getTableLen(originalOffsets) then
		return true
	end
	for i=0,sr.OffsetCount-1,1 do
		if sr.Offset[i] ~= originalOffsets[i] then
			return true
		end
	end
	return false
end

function copyOffsets(sr)
	--Copies data over to all selected pointer records
	for i in pairs(al.getSelectedRecords()) do
		if (i-1) ~= sr.Index and al[i-1].isGroupHeader ~= true then
			al[i-1].setAddress(sr.getAddress())
			al[i-1].Type = sr.Type
		end
	end
end

function incrementOffsets(originalAddress,originalOffsets,originalType,sr)
	--Symbol address prompt flag
	local promptFlag = 0
	--Backup increment values
	local incAddress,incOffsets = sr.getAddress() 
	incAddress = tonumber(incAddress,16)
	if incAddress == nil then incAddress = 0 end
	local incType = sr.Type
	--Create variables for serially incrementing values
	local curAddress = incAddress
	local curOffsets = {}
	if incOffsets ~= nil then
		for i,j in ipairs(incOffsets) do
			curOffsets[i] = j
		end
	end
	--Get selected records table.
	local selectedRecords = al.getSelectedRecords()
	--Index selected records table.
	local indexTable = doIndexTable(selectedRecords)
	--Sort index table.
	bubblesort(indexTable)
	--Copies data over to all selected pointer records
	for i,j in ipairs(indexTable) do
		if al[j-1].isGroupHeader ~= true then
			--Restore original address and offsets for selected record
			if (j-1) == sr.Index then
				sr.setAddress(originalAddress,originalOffsets)
				sr.Type = originalType
			end
			--Sets new type
			al[j-1].Type = incType
			if incOffsets ~= nil then
				--Sets new offset count
				al[j-1].OffsetCount = getTableLen(incOffsets)
				--Sets new offsets and increments them by specified values
				for k in ipairs(incOffsets) do
					al[j-1].Offset[k-1] = al[j-1].Offset[k-1]+curOffsets[k]
					curOffsets[k] = curOffsets[k]+incOffsets[k]
				end
			end
			--Gets address and offset table
			local tmpAddress,tmpOffset = al[j-1].getAddress()
			--Sets new address and increments it by specified value
			local tmp = tonumber(tmpAddress,16)
			if tmp == nil then tmp = 0 end
			--Check for symbol address
			if getAddress(tmpAddress) ~= tmp then
				local promptReturn
				--mbYes/No == 0, mbYesToAll == 1, mbNoToAll == 2
				if promptFlag == 0 then
					promptReturn = messageDialog("Symbol address detected. Dereference address?",mtConfirmation,mbYes,mbNo,mbNoToAll,mbYesToAll)
				end
				if promptReturn == mrYesToAll then promptFlag = 1
				elseif promptReturn == mrNoToAll then promptFlag = 2 end
				if	promptReturn == mrYes or promptFlag == 1 then
					al[j-1].setAddress(string.format("%X",getAddress(tmpAddress)+curAddress),tmpOffset)
				elseif promptReturn == mrNo or promptFlag == 2 then
					local strAddress
					if curAddress == 0 then strAddress = tmpAddress else strAddress = tmpAddress.."+"..string.format("%X",curAddress) end
					al[j-1].setAddress(strAddress,tmpOffset)
				end
			else
				al[j-1].setAddress(string.format("%X",tmp+curAddress),tmpOffset)
			end
			curAddress = curAddress+incAddress
		end
	end
end

function updatePosition()
	mousePos.x,mousePos.y = getMousePos()
	
	THeaderSections.BaseAddress = userDataToInteger(al.getComponent(1).Sections)
	
	THeaderSections.Active.Start = mf.Left
	THeaderSections.Active.Right = THeaderSections.Active.Start+readIntegerLocal(THeaderSections.BaseAddress+0xAC)
	
	THeaderSections.Description.Left = THeaderSections.Active.Right
	THeaderSections.Description.Right = THeaderSections.Description.Left+readIntegerLocal(THeaderSections.BaseAddress+0x10C)
	
	THeaderSections.Address.Left = THeaderSections.Description.Right
	THeaderSections.Address.Right = THeaderSections.Address.Left+readIntegerLocal(THeaderSections.BaseAddress+0x16C)
	
	THeaderSections.Type.Left = THeaderSections.Address.Right
	THeaderSections.Type.Right = THeaderSections.Type.Left+readIntegerLocal(THeaderSections.BaseAddress+0x1CC)
	
	THeaderSections.Value.Left = THeaderSections.Type.Right
	THeaderSections.Value.End = THeaderSections.Value.Left+THeaderSections.Active.Start+mf.Width
end

function inrange(x,leftLimit,rightLimit)
	if x >= leftLimit and x <= rightLimit then return true end
	return false
end

function getTableLen(table)
	local count = 0
	if table ~= nil then
		for i in pairs(table) do
			count = count+1
		end
	end
	return count
end

function doIndexTable(inTable)
	local iterator = 1
	local outTable = {}
	for i in pairs(inTable) do
		outTable[iterator] = i
		iterator = iterator+1
	end
	return outTable
end

function bubblesort(table)
	local repeatFlag = 1
	while repeatFlag == 1 do
	repeatFlag = 0
		for i=1,#table-1,1 do
			local tmp
			if table[i] > table[i+1] then
				tmp=table[i]
				table[i]=table[i+1]
				table[i+1] = tmp
				repeatFlag = 1
			end
		end
	end
end
--Events-------------------------------------------------------------------------------------------
local originalPopupFunc = mf.PopupMenu2.OnPopup
mf.PopupMenu2.OnPopup =
function()
	synchronize(originalPopupFunc)
	if al.getSelectedRecords() ~= nil then
		if getTableLen(al.getSelectedRecords()) > 1 then
			incPtr.Visible = true
			return
		end
	end
	incPtr.Visible = false
end
mf.PopupMenu2.Items[1].Item[1].onClick = Address1Click
al.getComponent(0).OnDblClick = TreeviewDblClick
incPtr.onClick =
function()
	local sr = al.getSelectedRecord()
	--Backup original offsets
	local originalAddress,originalOffsets,originalType = backupOffsets(sr)
	--Sets offsets and address to 0 by default
	local tmpAddress,tmpOffset = sr.getAddress()
	tmpAddress = 0
	if tmpOffset ~= nil then
		for i in ipairs(tmpOffset) do
			tmpOffset[i] = 0
		end
	end
	sr.setAddress(tmpAddress,tmpOffset)
	synchronize(originalAddressFunc)
	--Check for changes else return
	if	messageDialog("Proceed incrementing with specified values?",mtConfirmation,mbYes,mbNo) == mrYes then
		incrementOffsets(originalAddress,originalOffsets,originalType,sr)
	else
	--Restore original values to selected record
		sr.setAddress(originalAddress,originalOffsets)
		sr.Type = originalType
	end
end