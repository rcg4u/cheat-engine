--Initialization-----------------------------------------------------------------------------------

local DNOPBreakpoint = createFormFromFile(getCheatEngineDir()..[[\autorun\forms\DNOPBreakpoint.frm]])

local mf = getMainForm().Menu.Items
local miExtra

for i=0,mf.Count-1 do
	if mf[i].Name == 'miExtra' then miExtra = mf[i] end
end
if miExtra == nil then
	miExtra = createMenuItem(mf)
	miExtra.Name = 'miExtra'
	miExtra.Caption = 'Extra'
	mf.insert(mf.Count-2,miExtra)
end

local miDDL = createMenuItem(miExtra)
miDDL.Caption = 'DNOP Breakpoint List'
miDDL.onClick = DNOPBreakpoint.show
miExtra.add(miDDL)

--Variables----------------------------------------------------------------------------------------

local DNOPTable = {}

--Functions----------------------------------------------------------------------------------------


--Backend function for DisassemblerView
function toggleDNOP(memoryViewForm)
	local minAddr = math.min(memoryViewForm.DisassemblerView.SelectedAddress,memoryViewForm.DisassemblerView.SelectedAddress2)
	local maxAddr = math.max(memoryViewForm.DisassemblerView.SelectedAddress,memoryViewForm.DisassemblerView.SelectedAddress2)
	if DNOPTable[minAddr] ~= nil then
		deleteDNOP(memoryViewForm)
		return
	end
	
	debug_removeBreakpoint(minAddr)
	debug_setBreakpoint(minAddr)
	
	--Returns if breakpoint was not set, mainly for the corner case of debugging CE's process which isn't allowed
	local breakpointTable = debug_getBreakpointList()
	if breakpointTable == nil  or breakpointTable[#breakpointTable] ~= minAddr then return end
	
	if (minAddr == maxAddr) then maxAddr = minAddr+getInstructionSize(minAddr) end
	DNOPTable[minAddr] = maxAddr
	
	local newItem = DNOPBreakpoint.BreakpointList.Items.add()
	newItem.Caption = string.format('0x%X',minAddr)
	newItem.SubItems.add(string.format('0x%X',maxAddr))
end

--Backend function for DisassemblerView
function deleteDNOP(memoryViewForm)
	local minAddr = math.min(memoryViewForm.DisassemblerView.SelectedAddress,memoryViewForm.DisassemblerView.SelectedAddress2)
	if DNOPTable[minAddr] ~= nil then
		debug_removeBreakpoint(minAddr)
		
		DNOPTable[minAddr] = nil
		
		for i=0,DNOPBreakpoint.BreakpointList.Items.Count-1 do
			if DNOPBreakpoint.BreakpointList.Items[i].Caption == string.format('0x%X',minAddr) then
				DNOPBreakpoint.BreakpointList.Items[i].delete()
				return
			end
		end
	end
end

--Backend function for GUI form
function addDNOP(minAddr,maxAddr)
	debug_removeBreakpoint(minAddr)
	debug_setBreakpoint(minAddr)
	
	if DNOPTable[minAddr] ~= nil then
		DNOPTable[minAddr] = maxAddr
		
		for i=0,DNOPBreakpoint.BreakpointList.Items.Count-1 do
			if DNOPBreakpoint.BreakpointList.Items[i].Caption == string.format('0x%X',minAddr) then
				DNOPBreakpoint.BreakpointList.Items[i].SubItems[0] = string.format('0x%X',maxAddr)
				return
			end
		end
	end
	
	DNOPTable[minAddr] = maxAddr
	
	local newItem = DNOPBreakpoint.BreakpointList.Items.add()
	newItem.Caption = string.format('0x%X',minAddr)
	newItem.SubItems.add(string.format('0x%X',maxAddr))
end

--Backend function for GUI form
function deleteDNOP2(minAddr)
	if DNOPTable[minAddr] ~= nil then
		debug_removeBreakpoint(minAddr)
		
		DNOPTable[minAddr] = nil
		
		for i=0,DNOPBreakpoint.BreakpointList.Items.Count-1 do
			if DNOPBreakpoint.BreakpointList.Items[i].Caption == string.format('0x%X',minAddr) then
				DNOPBreakpoint.BreakpointList.Items[i].delete()
				return
			end
		end
	end
end

function debugger_onBreakpoint()
	local bitMode = targetIs64Bit()
	if DNOPTable[minAddr] ~= nil then
		if bitMode then
			if i == RIP then
				RIP = j
			end
		else
			if i == EIP then
				EIP = j
			end
		end
		debug_continueFromBreakpoint(co_run)
	end
end

function AddItemMenuInMemoryViewForm(memoryViewForm, nameItemMenu, shortcut, functionItemClick)
	local dv = memoryViewForm.DisassemblerView

	local popupmenu = dv.PopupMenu
	local mi = createMenuItem(popupmenu)
	mi.Caption = nameItemMenu
	
	mi.onClick =
	function ()
		functionItemClick(memoryViewForm)
	end
	mi.Shortcut = shortcut

	popupmenu.Items.add(mi)
end

function AddItemMenuSeparatorInMemoryViewForm(memoryViewForm)
	local dv = memoryViewForm.DisassemblerView
	
	local popupmenu = dv.PopupMenu
	local mi = createMenuItem(popupmenu)
	mi.Caption = '-'
	popupmenu.Items.add(mi)
end

function addPopUpMenuEntry(memoryViewForm)
	if memoryViewForm.ClassName~="TMemoryBrowser" then
		return
	else
		local timer=createTimer()
		timer.Interval=100
		timer.OnTimer = function (t)
			t.destroy()
			AddItemMenuSeparatorInMemoryViewForm(memoryViewForm)
			AddItemMenuInMemoryViewForm(memoryViewForm, 'Set/Unset DNOP Breakpoint', nil, toggleDNOP)
		end
	end
end

--Main---------------------------------------------------------------------------------------------

registerFormAddNotification(addPopUpMenuEntry)
AddItemMenuSeparatorInMemoryViewForm(getMemoryViewForm())
AddItemMenuInMemoryViewForm(getMemoryViewForm(), 'Set/Unset DNOP Breakpoint', nil, toggleDNOP)

--Events-------------------------------------------------------------------------------------------

--Modifies original CE's toggle breakpoint to check if address already has a DNOP breakpoint
--Deletes existing DNOP breakpoint if it finds one
originalFunc = getMemoryViewForm().Setbreakpoint1.onClick
getMemoryViewForm().Setbreakpoint1.onClick =
function()
	synchronize(originalFunc)
	local minAddr = getMemoryViewForm().DisassemblerView.SelectedAddress
	for i=0,DNOPBreakpoint.BreakpointList.Items.Count-1 do
		if DNOPBreakpoint.BreakpointList.Items[i].Caption == string.format('0x%X',minAddr) then
			DNOPBreakpoint.BreakpointList.Items[i].delete()
			return
		end
	end
end

DNOPBreakpoint.addBreakpoint.onClick =
function()
	local minAddr = DNOPBreakpoint.startAddr.Text
	if string.find(minAddr,'0x') == nil then
		minAddr = '0x'..minAddr
	end
	local maxAddr = DNOPBreakpoint.endAddr.Text
	if string.find(maxAddr,'0x') == nil then
		maxAddr = '0x'..maxAddr
	end
	minAddr = tonumber(minAddr)
	maxAddr = tonumber(maxAddr)
	if (minAddr == maxAddr) or (minAddr == nil) or (maxAddr == nil) or (minAddr > maxAddr) then
		messageDialog('Invalid Range!',mtWarning,mbOK)
		return
	end
	addDNOP(minAddr,maxAddr)
end

DNOPBreakpoint.deleteBreakpoint.onClick =
function()
	if DNOPBreakpoint.BreakpointList.Selected ~= nil then
		local minAddr = DNOPBreakpoint.BreakpointList.Selected.Caption
		deleteDNOP2(tonumber(minAddr))
	end
end