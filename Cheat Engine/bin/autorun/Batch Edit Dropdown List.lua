--Initialization-----------------------------------------------------------------------------------
local al = getAddressList()
--Functions----------------------------------------------------------------------------------------
--Local Functions Declaration
local hookDropdownSettingsForm
local setDDL
local newTimer

function hookDropdownSettingsForm(form)
  if form.ClassName == "TFrmMemoryRecordDropdownSettings" then
    --Timer to allow for form components to finish loading
    newTimer(newBtnOkFunc,form)
  end
end

function newBtnOkFunc(timer,form)
  --Returns if form not fully loaded
  if form.btnOk == nil then return end
  local origFunc = form.btnOk.OnClick
  form.btnOk.OnClick =
  function()
    --Check for valid selected records
    if al.SelCount ~= 0 then
      local selectedRec = al.getSelectedRecord()
      --Apply dropdown list to all selected records
      for i,j in pairs(al.getSelectedRecords()) do
        if j ~= selectedRec then
          setDDL(j,form)
        end
      end
    end
    --Calls original function
    synchronize(origFunc)
  end
  timer.destroy()
end

function setDDL(record,dropdownForm)
  record.DropDownList.Text = dropdownForm.memoDropdownItems.Lines.Text
  record.DropDownReadOnly = dropdownForm.cbDisallowUserInput.Checked
  record.DropDownDescriptionOnly = dropdownForm.cbOnlyShowDescription.Checked
  record.DisplayAsDropDownListItem = dropdownForm.cbDisplayAsDropdownItem.Checked
end

function newTimer(inFunc,form)
  local timer = createTimer()
  timer.Interval = 100
  timer.OnTimer = function(timer)
                    inFunc(timer,form)
                  end
end
--Events-------------------------------------------------------------------------------------------
registerFormAddNotification(hookDropdownSettingsForm)