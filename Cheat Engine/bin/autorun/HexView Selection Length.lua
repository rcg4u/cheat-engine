--Initialization-----------------------------------------------------------------------------------
local mvf = getMemoryViewForm()
--Functions----------------------------------------------------------------------------------------
--Local Functions Declaration
local getSelectLen
local popupSelectLen
local addPopup

function getSelectLen(mvf)
	local len = mvf.HexadecimalView.SelectionStop - mvf.HexadecimalView.SelectionStart
	local displayType = mvf.HexadecimalView.DisplayType
	if displayType == "dtByte" or displayType == "dtByteDec" then
		len = len+1
	elseif displayType == "dtWord" or displayType == "dtWordDec" then
		len = len+2
	elseif displayType == "dtDword" or displayType == "dtDwordDec" or displayType == "dtSingle" then
		len = len+4
	elseif displayType == "dtQword" or displayType == "dtQwordDec" or displayType == "dtDouble" then
		len = len+8
	end
	return len
end

function popupSelectLen(mvf)
	local len = getSelectLen(mvf)
	len = string.format("0x%X",len)
	if inputQuery("Selection Length","Copy selection length to clipboard?",len) then
		writeToClipboard(len)
	end
end

function addPopup(mvf)
	local timer=createTimer()
	timer.Interval=100
	timer.OnTimer = function (t)
		t.destroy()
		if mvf.ClassName=="TMemoryBrowser" then
			local miSelectLen = createMenuItem(mvf)
			miSelectLen.Name = "miSelectLen"
			miSelectLen.Caption = "Selection Length"
			miSelectLen.onClick =
			function()
				popupSelectLen(mvf)
			end
			mvf.HexadecimalView.PopupMenu.Items.insert(2,miSelectLen)
      --Enable/Disable menu item on popup
      local oldPopupFunc = mvf.HexadecimalView.PopupMenu.OnPopup
      mvf.HexadecimalView.PopupMenu.OnPopup =
      function()
        synchronize(oldPopupFunc)
        if mvf.HexadecimalView.HasSelection then
          miSelectLen.Enabled = true
        else
          miSelectLen.Enabled = false
        end
      end
		end
	end
end
--Main---------------------------------------------------------------------------------------------
registerFormAddNotification(addPopup)
addPopup(mvf)