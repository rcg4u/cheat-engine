--Initialization-----------------------------------------------------------------------------------
local mf = getMainForm()
local al = getAddressList()
--Functions----------------------------------------------------------------------------------------
--Local Functions Declaration
local miHideChildrenClick
local miBindActivationClick
local miBindDeactivationClick
local miRecursiveSetValueClick
local miAllowCollapseClick
local miManualExpandCollapseClick
local optionWrapper

function miHideChildrenClick(mr)
	if mr.Options:match("moHideChildren") == nil then
		mr.Options = mr.Options.."moHideChildren"
	else
		mr.Options = mr.Options:gsub("moHideChildren","")
	end
end
function miBindActivationClick(mr)
	if mr.Options:match("moActivateChildrenAsWell") == nil then
		mr.Options = mr.Options.."moActivateChildrenAsWell"
	else
		mr.Options = mr.Options:gsub("moActivateChildrenAsWell","")
	end
end
function miBindDeactivationClick(mr)
	if mr.Options:match("moDeactivateChildrenAsWell") == nil then
		mr.Options = mr.Options.."moDeactivateChildrenAsWell"
	else
		mr.Options = mr.Options:gsub("moDeactivateChildrenAsWell","")
	end
end
function miRecursiveSetValueClick(mr)
	if mr.Options:match("moRecursiveSetValue") == nil then
		mr.Options = mr.Options.."moRecursiveSetValue"
	else
		mr.Options = mr.Options:gsub("moRecursiveSetValue","")
	end
end
function miAllowCollapseClick(mr)
	if mr.Options:match("moAllowManualCollapseAndExpand") == nil then
		mr.Options = mr.Options.."moAllowManualCollapseAndExpand"
	else
		mr.Options = mr.Options:gsub("moAllowManualCollapseAndExpand","")
	end
end
function miManualExpandCollapseClick(mr)
	if mr.Options:match("moManualExpandCollapse") == nil then
		mr.Options = mr.Options.."moManualExpandCollapse"
	else
		mr.Options = mr.Options:gsub("moManualExpandCollapse","")
	end
end
function optionWrapper(sender)
	local sr = al.getSelectedRecords()
	for i in pairs(sr) do
		if al[i-1].Count > 0 then
			if sender.Name == "miHideChildren" then miHideChildrenClick(al[i-1])
			elseif sender.Name == "miBindActivation" then miBindActivationClick(al[i-1])
			elseif sender.Name == "miBindDeactivation" then miBindDeactivationClick(al[i-1]) 
			elseif sender.Name == "miRecursiveSetValue" then miRecursiveSetValueClick(al[i-1])
			elseif sender.Name == "miAllowCollapse" then miAllowCollapseClick(al[i-1])
			elseif sender.Name == "miManualExpandCollapse" then miManualExpandCollapseClick(al[i-1])
			end
		end
	end
end
--Events-------------------------------------------------------------------------------------------
mf.miHideChildren.onClick = optionWrapper
mf.miBindActivation.onClick = optionWrapper
mf.miBindDeactivation.onClick = optionWrapper
mf.miRecursiveSetValue.onClick = optionWrapper
mf.miAllowCollapse.onClick = optionWrapper
mf.miManualExpandCollapse.onClick = optionWrapper