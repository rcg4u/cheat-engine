-- initial declarations
local fl = getMainForm().Foundlist3
local input = "currentValue ~= previousValue"
local miRemove
for i=0, fl.PopupMenu.Items.Count-1 do
  if fl.PopupMenu.Items[i].Name == "Removeselectedaddresses1" then
    miRemove = fl.PopupMenu.Items[i]
    break
  end
end
assert(miRemove,"Remove addresses using filter failed; could not find Removeselectedaddresses1 menu item")

-- create menu item
local mi = createMenuItem(fl.PopupMenu)
mi.Caption = "Remove addresses using filter"
mi.OnClick = function()
  --get the filter
  input = inputQuery(mi.Caption, "Type Lua code resulting in a boolean value. Function declared as:\nfunction (address, currentValue, previousValue) : boolean", input)
  if not input then return end

  local filter = assert(loadstring("local address, currentValue, previousValue = ...; return " .. input))

  -- select the items to remove
  for i=0, fl.Items.Count-1 do
    fl.Items[i].Selected = filter(fl.Items[i].Caption, fl.Items[i].SubItems[0], fl.Items[i].SubItems[1]) == true
  end

  -- execute the "Remove selected addresses" menu item
  miRemove.DoClick()
end

-- add new menu item just after the "remove selected" menu item
fl.PopupMenu.Items.insert(miRemove.MenuIndex+1, mi)