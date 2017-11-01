--Local Functions Declaration
local copyInfo
local popupInfo
local moduleInfo
local getModuleByAddress
local getMonoMethodByAddress
local AddItemMenuInMemoryViewForm
local AddItemMenuSeparatorInMemoryViewForm
local addPopUpMenuEntry
local escHideForm
local centerForm

local dllname="MonoDataCollector"
if targetIs64Bit() then
  dllname=dllname.."64.dll"    
else
  dllname=dllname.."32.dll"
end

local moduleInfoForm = createForm(false)
moduleInfoForm.setSize(226,238)
moduleInfoForm.Name = 'fmModInfo'
moduleInfoForm.Caption = 'Information'
moduleInfoForm.BorderIcons = '[biSystemMenu,biMinimize]'

local labelModuleName = createLabel(moduleInfoForm)
labelModuleName.setPosition(5,5)
labelModuleName.Caption = 'Module:'

local labelBaseAddress = createLabel(moduleInfoForm)
labelBaseAddress.setPosition(5,47)
labelBaseAddress.Caption = 'Base Address:'

local labelEndAddress = createLabel(moduleInfoForm)
labelEndAddress.setPosition(5,89)
labelEndAddress.Caption = 'End Address:'

local labelSize = createLabel(moduleInfoForm)
labelSize.setPosition(5,131)
labelSize.Caption = 'Size:'

local labelSizeUnit = createLabel(moduleInfoForm)
labelSizeUnit.setPosition(192,155)
labelSizeUnit.Caption = 'bytes'

local moduleName = createEdit(moduleInfoForm)
moduleName.setSize(216,25)
moduleName.setPosition(5,22)
moduleName.Name = 'moduleName'
moduleName.ReadOnly = true

local baseAddress = createEdit(moduleInfoForm)
baseAddress.setSize(216,25)
baseAddress.setPosition(5,64)
baseAddress.Name = 'baseAddress'
baseAddress.ReadOnly = true

local endAddress = createEdit(moduleInfoForm)
endAddress.setSize(216,25)
endAddress.setPosition(5,106)
endAddress.Name = 'endAddress'
endAddress.ReadOnly = true

local size = createEdit(moduleInfoForm)
size.setSize(182,25)
size.setPosition(5,148)
size.Name = 'size'
size.ReadOnly = true

local btnCopy = createButton(moduleInfoForm)
btnCopy.Name = 'btnCopy'
btnCopy.Caption = 'Copy Range to Memory Scan'
btnCopy.setSize(216,24)
btnCopy.setPosition (5,180)

local btnOk = createButton(moduleInfoForm)
btnOk.Name = 'btnOk'
btnOk.Caption = 'Close'
btnOk.setSize(216,24)
btnOk.setPosition (5,209)
btnOk.OnClick = moduleInfoForm.hide

function copyInfo()
	local mainForm = nil
	for i=0,getFormCount()-1 do
		if getForm(i).Name == 'MainForm' then
		mainForm = getForm(i)
		break
		end
	end
	if mainForm ~= nil then
		if mainForm.FromAddress.Lines ~= nil then
			mainForm.FromAddress.Lines.Text = baseAddress.Text
			mainForm.ToAddress.Lines.Text = endAddress.Text
		else
			mainForm.FromAddress.Text = baseAddress.Text
			mainForm.ToAddress.Text = endAddress.Text
		end
	end
end

function popupInfo(memoryViewForm,Module)
	moduleName.Text = Module.Name
	baseAddress.Text = string.format('%X',Module.Address)
	endAddress.Text = string.format('%X',Module.EndAddress)
	size.Text = Module.Size
	centerForm(memoryViewForm)
	moduleInfoForm.show()
end

function moduleInfo(memoryViewForm)
	local dv = memoryViewForm.DisassemblerView
	local dv_address1,dv_address2 = dv.SelectedAddress,dv.SelectedAddress2
	if dv_address1 ~= dv_address2 then
		messageDialog("Select only a single line",mtWarning,mbOK)
		return
	elseif inModule(dv_address1) then
		local Module = getModuleByAddress(dv_address1)
		popupInfo(memoryViewForm,Module)
		return
	elseif injectDLL(getCheatEngineDir()..[[\autorun\dlls\]]..dllname) then
    LaunchMonoDataCollector()
		local Module = mono_getJitInfo(dv_address1)
		if Module ~= nil then
			Module = getMonoMethodByAddress(Module)
			popupInfo(memoryViewForm,Module)
			return
		end
	end
	messageDialog("Address is not part of any module",mtWarning,mbOK)
end

function getModuleByAddress(addr)
	local mm = enumModules()
	for i=1,#mm do
		local base,size=mm[i].Address,getModuleSize(mm[i].Name)
		if base~=nil and size~=nil and addr>=base and addr<base+size then
			mm[i].Size = size
			mm[i].EndAddress = size+mm[i].Address
			return mm[i]
		end
	end
end

function getMonoMethodByAddress(result)
	result.class = mono_method_getClass(result.method)
	local mm = {}
	mm.Name = mono_class_getNamespace(result.class)..":"..mono_class_getName(result.class)..":"..mono_method_getName(result.method)
	mm.Address = result.code_start
	mm.Size = result.code_size
	mm.EndAddress = mm.Address+mm.Size
	return mm
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
			AddItemMenuInMemoryViewForm(memoryViewForm, 'Module Information', nil, moduleInfo)
		end
	end
end

function escHideForm(sender, key)
	if key == 27 then moduleInfoForm.hide() end
end

function centerForm(memoryViewForm)
	moduleInfoForm.SetPosition(memoryViewForm.Left+(memoryViewForm.Width-moduleInfoForm.Width)/2,memoryViewForm.Top+(memoryViewForm.Height-moduleInfoForm.Height)/2)
end

btnCopy.OnClick = copyInfo
moduleInfoForm.onClose = moduleInfoForm.hide
moduleInfoForm.onShow = btnOk.SetFocus
moduleInfoForm.moduleName.onKeyDown = escHideForm
moduleInfoForm.baseAddress.onKeyDown = escHideForm
moduleInfoForm.endAddress.onKeyDown = escHideForm
moduleInfoForm.size.onKeyDown = escHideForm
moduleInfoForm.btnCopy.onKeyDown = escHideForm
moduleInfoForm.btnOk.onKeyDown = escHideForm
registerFormAddNotification(addPopUpMenuEntry)
AddItemMenuSeparatorInMemoryViewForm(getMemoryViewForm())
AddItemMenuInMemoryViewForm(getMemoryViewForm(), 'Module Information', nil, moduleInfo)