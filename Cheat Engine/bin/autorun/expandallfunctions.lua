function monoform_miExpandAllClick(sender)
  if messageDialog("Are you sure you wish to expand the whole tree? This can take a while and Cheat Engine may look like it has crashed (It has not)", mtConfirmation, mbYes, mbNo)==mrYes then
    monoForm.TV.beginUpdate()
    --monoForm.autoExpanding=true --special feature where a base object can contain extra lua variables
    --monoForm.TV.fullExpand()
    local tv = monoForm.TV
    local level = 0
    local index = 0
    if tv.Selected ~= nil then
      index = tv.Selected.AbsoluteIndex + 2
      level = tv.Selected.Level
      tv.Selected.Expand(false)
    end
    while index < tv.Items.Count do
      local node = tv.Items[index]
      if node.Level <= level then
        break
      end
      if node.HasChildren and node.Level <= 3 then
        node.Expand(false)
      end
      index = index + 1
    end
    --monoForm.autoExpanding=false
    monoForm.TV.endUpdate()
  end
end