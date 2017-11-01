--Initialization-----------------------------------------------------------------------------------
local mvf = getMemoryViewForm()
--Functions----------------------------------------------------------------------------------------
--Local Functions Declaration
local addPopup
local exportSelection

function exportSelection(mvf)
  local saveDialog = createSaveDialog(mvf)
  saveDialog.Options = saveDialog.Options..[[ofOverwritePrompt]]
  if not saveDialog.Execute() then return end
  local selectedBytes = readBytes(mvf.HexadecimalView.SelectionStart, mvf.HexadecimalView.SelectionStop - mvf.HexadecimalView.SelectionStart + 1, true)
	local memStream = createMemoryStream()
  memStream.write(selectedBytes)
  memStream.saveToFile(saveDialog.FileName)
end

function addPopup(mvf)
	local timer=createTimer()
	timer.Interval=100
	timer.OnTimer = function (t)
		t.destroy()
		if mvf.ClassName=="TMemoryBrowser" then
			local miExportSel = createMenuItem(mvf)
			miExportSel.Name = "miExportSel"
			miExportSel.Caption = "Export Selection"
			miExportSel.onClick =
			function()
				exportSelection(mvf)
			end
			mvf.HexadecimalView.PopupMenu.Items.add(miExportSel)
      --Enable/Disable menu item on popup
      local oldPopupFunc = mvf.HexadecimalView.PopupMenu.OnPopup
      mvf.HexadecimalView.PopupMenu.OnPopup =
      function()
        synchronize(oldPopupFunc)
        if mvf.HexadecimalView.HasSelection then
          miExportSel.Enabled = true
        else
          miExportSel.Enabled = false
        end
      end
		end
	end
end
--Main---------------------------------------------------------------------------------------------
registerFormAddNotification(addPopup)
addPopup(mvf)