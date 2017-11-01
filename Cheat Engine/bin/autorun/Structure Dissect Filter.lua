--[[--Library Functions----------------------------------------------------------------------------|
---------------------------------------------------------------------------------------------------|
                                                                                                   |
getFocused(structureFrm)                                                                           |
------------------------                                                                           |
Input:  structureFrm - Structure Dissect form object.                                              |
Output: Returns the focused group and column of the structure dissect form.                        |
                                                                                                   |
getSelectedNodes(structureFrm)                                                                     |
------------------------------                                                                     |
Input:  structureFrm - Structure Dissect form object.                                              |
Output: Returns a selectedNodes array with all selected nodes.                                     |
                                                                                                   |
getExpandedNodes(structureFrm)                                                                     |
------------------------------                                                                     |
Input:  structureFrm - Structure Dissect form object.                                              |
Output: Returns a expandedNodes array with all expanded nodes.                                     |
                                                                                                   |
getParentStructureFromNode(node)                                                                   |
--------------------------------                                                                   |
Input:  node - TTreeNode object in Structure Dissect form.                                         |
Output: Returns the parent structure object of the node.                                           |
                                                                                                   |
getElementFromNode(node)                                                                           |
------------------------                                                                           |
Input:  node - TTreeNode object in Structure Dissect form.                                         |
Output: Returns the specified element in the main structure.                                       |
                                                                                                   |
getElementFromNodeIndex(structureFrm,elementIndex)                                                 |
--------------------------------------------------                                                 |
Input:  structureFrm - Structure Dissect form object.                                              |
        elementIndex - Index of specified element in main structure of structure dissect form.     |
Output: Returns the specified element in the main structure.                                       |
                                                                                                   |
doSelectNodes(selectedNodes)                                                                       |
----------------------------                                                                       |
Input:  selectedNodes - Array of selected TTreeNodes in Structure Dissect form.                    |
Output: Selects all nodes in array.                                                                |
                                                                                                   |
doExpandNodes(expandedNodes)                                                                       |
----------------------------                                                                       |
Input:  expandedNodes - Array of expanded TTreeNodes in Structure Dissect form.                    |
Output: Expands all nodes in array.                                                                |
                                                                                                   |
doRemoveNode(nodeToRemove,selectedNodes,expandedNodes,oldElementByteSize)                          |
--------------------------------------                                                             |
Input:  nodeToRemove  - TTreeNode object to be removed from Structure Dissect form's TTreeView.    |
        selectedNodes - Array of selected TTreeNodes in Structure Dissect form.                    |
        expandedNodes - Array of expanded TTreeNodes in Structure Dissect form.                    |
		    oldElementByteSize - Array of old element byte size										                     |
Output: Removes node from selectedNodes and expandedNodes arraya and adjusts elements following it |
        accordingly.                                                                               |
                                                                                                   |
doRemoveElement(structureFrm,elementIndex)                                                         |
----------------------------------------                                                           |
Input:  structureFrm - Structure Dissect form object.                                              |
        elementIndex - Index of specified element in main structure of structure dissect form.     |
Output: Destroys the specified element in the main structure.                                      |
                                                                                                   |
doAddNode(nodeToAdd,selectedNodes,expandedNodes,oldElementByteSize)                                |
-------------------------------------------------------------------								                 |
Input:  nodeToAdd	  - TTreeNode object to be added to Structure Dissect form's TTreeView.   	     |
        selectedNodes - Array of selected TTreeNodes in Structure Dissect form.                    |
        expandedNodes - Array of expanded TTreeNodes in Structure Dissect form.                    |
		    oldElementByteSize - Array of old element byte size										                     |
Output:	Adds node to selectedNodes and expandedNodes arraya and adjusts elements following it      |
        accordingly.                                                                               |
                                                                                                   |
doAddElement(structure,offset,vartype,bytesize)                                                    |
-----------------------------------------------                                                    |
Input:  structure - Structure object element is to be added to.                                    |
        offset    - Offset of element.                                                             |
        vartype   - Variable type of element.                                                      |
        bytesize  - Byte size of element.                                                          |
Output: Adds a new element to the passed structure and sets the properties accordingly.            |
                                                                                                   |
doToggleChecked(sender)                                                                            |
---------------------                                                                              |
Input:  sender - Menu item object used to call this function onClick.                              |
Output: Toggles checked status of menu item.                                                       |
                                                                                                   |
newTimer(inFunc,form)                                                                              |
---------------------                                                                              |
Input:  inFunc - Function to call onTimer.                                                         |
        form   - Optional form object to be passed into inFunc.                                    |
Output: Creates a new timer with interval 100 which performs inFunc onTimer, and returns the timer |
        object.                                                                                    |
                                                                                                   |
---------------------------------------------------------------------------------------------------|
--]]-----------------------------------------------------------------------------------------------|

--Local Functions Declaration
local getFocused
local getSelectedNodes
local getExpandedNodes
local getParentStructureFromNode
local getElementFromNode
local getElementFromNodeIndex
local doSelectNodes
local doExpandNodes
local doRemoveNode
local doRemoveElement
local doAddNode
local doAddElement
local doToggleChecked
local newTimer

function getFocused(structureFrm)
  local focusedGroup,focusedColumn
  for i = 0,structureFrm.groupCount-1,1 do
    for j = 0,structureFrm.Group[i].columnCount-1,1 do
      if structureFrm.Group[i].Column[j].Focused == true then return structureFrm.Group[i],structureFrm.Group[i].Column[j] end
    end
  end
end

function getSelectedNodes(structureFrm)
  local selectedNodes = {}
  local storedIndex = 1
  for i=1,structureFrm.tvStructureView.Items.Count-1 do
    if structureFrm.tvStructureView.Items[i].Selected then
      selectedNodes[storedIndex] = structureFrm.tvStructureView.Items[i]
      storedIndex = storedIndex+1
    end
  end
  return selectedNodes
end

function getExpandedNodes(structureFrm)
  local expandedNodes = {}
  local storedIndex = 1
  for i=1,structureFrm.tvStructureView.Items.Count-1 do
    if structureFrm.tvStructureView.Items[i].Expanded then
      expandedNodes[storedIndex] = structureFrm.tvStructureView.Items[i]
      storedIndex = storedIndex+1
    end
  end
  return expandedNodes
end

function getParentStructureFromNode(node)
  return integerToUserData(node.Parent.Data)
end

function getElementFromNode(node)
  return integerToUserData(node.Parent.Data).Element[node.Index]
end

function getElementFromNodeIndex(structureFrm,elementIndex)
  return structureFrm.mainStruct.Element[elementIndex]
end

function doSelectNodes(selectedNodes)
  for i=1,#selectedNodes do selectedNodes[i].Selected = true end
end

function doExpandNodes(expandedNodes)
  for i=1,#expandedNodes do expandedNodes[i].Expanded = true end
end

function doRemoveNode(nodeToRemove,selectedNodes,expandedNodes,oldElementByteSize)
  local j = 1
  --Remove node from selectedNodes if necessary
  while j <= #selectedNodes do
    if selectedNodes[j] == nodeToRemove then
      table.remove(selectedNodes,j)
      table.remove(oldElementByteSize,j)
    elseif selectedNodes[j].Index > nodeToRemove.Index then
      --Decrement index of nodes coming after the deleted node
      selectedNodes[j] = selectedNodes[j].Parent[selectedNodes[j].Index-1]
      j = j+1
    else j = j+1 end
  end
  --Adjust nodes from expandedNodes if necessary
  j = 1
  while j <= #expandedNodes do
    if expandedNodes[j].Index > nodeToRemove.Index then
      --Decrement index of nodes coming after the deleted node
      expandedNodes[j] = expandedNodes[j].Parent[expandedNodes[j].Index-1]
    end
    j = j+1
  end
end

function doRemoveElement(structureFrm,elementIndex)
  structureFrm.mainStruct.Element[elementIndex].destroy()
end

function doAddNode(nodeToAdd,selectedNodes,expandedNodes,oldElementByteSize)
  local j = 1
  --Add node to selectedNodes
  while j <= #selectedNodes do
    if selectedNodes[j].Index == nodeToAdd.Index-1 then
      table.insert(selectedNodes,j+1,nodeToAdd)
      table.insert(oldElementByteSize,j+1,getElementFromNode(nodeToAdd).Bytesize)
      j = j+2
    elseif selectedNodes[j].Index >= nodeToAdd.Index then
      --Increment index of nodes coming after the deleted node
      selectedNodes[j] = selectedNodes[j].Parent[selectedNodes[j].Index+1]
      j = j+1
    else j = j+1 end
  end
  --Adjust nodes from expandedNodes if necessary
  j = 1
  while j <= #expandedNodes do
    if expandedNodes[j].Index > nodeToAdd.Index then
      --Increment index of nodes coming after the deleted node
      expandedNodes[j] = expandedNodes[j].Parent[expandedNodes[j].Index+1]
      j = j+1
    else j = j+1 end
  end
end

function doAddElement(structure,offset,vartype,bytesize)
  local closestCeilingElement = structure.getElementByOffset(offset)
  if closestCeilingElement ~= nil and closestCeilingElement.Offset == offset then return false end --Returns if element at that offset already exists
  local newElement = structure.addElement()
  newElement.Offset  = offset
  newElement.Vartype = vartype
  if vartype == 6 or vartype == 7 or vartype == 8 then newElement.Bytesize = bytesize end
  return true
end

function doToggleChecked(menuItem)
  if menuItem.Checked then menuItem.Checked = false
  else menuItem.Checked = true end
end

function newTimer(inFunc,form)
  local timer = createTimer()
  timer.Interval = 100
  timer.OnTimer = function(timer)
                    inFunc(timer,form)
                  end
end

--[[--Main Functions-------------------------------------------------------------------------------|
---------------------------------------------------------------------------------------------------|
                                                                                                   |
combineSplit(form)                                                                                 |
------------------                                                                                 |
Input:  structureElementInfoFrm - Structure Info form object.                                      |
Output: Combine overlapping elements or create new ones when changing element properties.          |
                                                                                                   |
removeDuplicate(structureFrm)                                                                      |
-----------------------------                                                                      |
Input:  structureFrm - Structure Dissect form object.                                              |
Output: Removes duplicate elements in the main structure of structure dissect form.                |
                                                                                                   |
duplicateStructure(structureFrm)                                                                   |
--------------------------------                                                                   |
Input:  structureFrm - Structure Dissect form object.                                              |
Output: Duplicate main structure of structure dissect form.                                        |
                                                                                                   |
compareColumns(structureFrm,offset,byteSize)                                                       |
--------------------------------------------                                                       |
Input:  structureFrm - Structure Group object.                                                     |
        byteSize     - Byte size of element.                                                       |
        offset       - Offset of element.                                                          |
Output: Returns 0 if element values are equal for all columns in the structure form, 1 if          |
        vice-versa.                                                                                |
                                                                                                   |
compareGroup(structGroup,offset,byteSize)                                                          |
-----------------------------------------                                                          |
Input:  structGroup - Structure Group object.                                                      |
        byteSize    - Byte size of element.                                                        |
        offset      - Offset of element.                                                           |
Output: Returns 0 if element values are equal for all columns in the group, 1 if vice-versa.       |
                                                                                                   |
filterColumnEqual(structureFrm)                                                                    |
-------------------------------                                                                    |
Input:  structureFrm - Structure Dissect form object.                                              |
Output: Filters out elements that have equal values in the focused group.                          |
                                                                                                   |
filterColumnDifferent(structureFrm)                                                                |
-----------------------------------                                                                |
Input:  structureFrm - Structure Dissect form object.                                              |
Output: Filters out elements that have different values in the focused group.                      |
                                                                                                   |
filterGroupEqual(structureFrm)                                                                     |
------------------------------                                                                     |
Input:  structureFrm - Structure Dissect form object.                                              |
Output: Filters out elements that have equal values in all groups.                                 |
                                                                                                   |
filterGroupDifferent(structureFrm)                                                                 |
----------------------------------                                                                 |
Input:  structureFrm - Structure Dissect form object.                                              |
Output: Filters out elements that have equal values in the focused group but different from other  |
        groups.                                                                                    |
                                                                                                   |
---------------------------------------------------------------------------------------------------|
--]]-----------------------------------------------------------------------------------------------|

--Local Functions Declaration
local combineSplit
local removeDuplicate
local duplicateStructure
local compareColumns
local compareGroup
local filterColumnEqual
local filterColumnDifferent
local filterGroupEqual
local filterGroupDifferent

function combineSplit(form)
  local structureFrm = form.Owner

  --Collapses all pointers
  for i=0,structureFrm.tvStructureView.Items[0].Count-1 do
    if structureFrm.tvStructureView.Items[0][i].Expanded then structureFrm.tvStructureView.Items[0][i].Expanded = false end
  end

  local selectedNodes = getSelectedNodes(structureFrm)
  local expandedNodes = getExpandedNodes(structureFrm)

  --Gets old element byte size
  local oldElementByteSize = {}
  for i=1,#selectedNodes do oldElementByteSize[i] = getElementFromNode(selectedNodes[i]).Bytesize end

  --Gets new element byte size
  local newElementByteSize = nil
  if form.cbType.ItemIndex == 0 then newElementByteSize = 1 --Byte
  elseif form.cbType.ItemIndex == 1 then newElementByteSize = 2 --Word
  elseif form.cbType.ItemIndex == 2 or form.cbType.ItemIndex == 4 then newElementByteSize = 4 --DWord/Float
  elseif form.cbType.ItemIndex == 3 or form.cbType.ItemIndex == 5 then newElementByteSize = 8 --QWord/Double
  elseif form.cbType.ItemIndex == 6 or form.cbType.ItemIndex == 7 or form.cbType.ItemIndex ==  8 then newElementByteSize = tonumber(form.edtByteSize.Text) --String/Unicode String/Array of Byte
  elseif form.cbType.ItemIndex == 9 then --Pointer
    if targetIs64Bit() then newElementByteSize = 4
    else newElementByteSize = 8 end
  end
  if newElementByteSize == nil then newElementByteSize = 1 end --For invalid numbers entered into edtByteSize field
  local newVarType = form.cbType.ItemIndex
  if newVarType == 9 then newVarType = 12 end --Pointer type defined in defines.lua

  --Update variable type of selected nodes now, to allow for comparison when determining if merge/split is required
  for i=1,#selectedNodes do
    local selectedElement = getElementFromNode(selectedNodes[i])
    selectedElement.Vartype = newVarType
    if selectedElement.Vartype == 6 or selectedElement.Vartype == 7 or selectedElement.Vartype == 8 then --String/Unicode String/Array of Byte
      selectedElement.Bytesize = newElementByteSize
    end
  end

  local i = 1
  while i <= #selectedNodes do
    local selectedElement = getElementFromNode(selectedNodes[i])
    --If new variable type is larger in size than older variable type, then delete any overlapping elements after the current one.
    if newElementByteSize > oldElementByteSize[i] then
      while true do
        if selectedNodes[i].Index+1 > selectedNodes[i].Parent.Count-1 then break end
        local nextNode = selectedNodes[i].Parent[selectedNodes[i].Index+1]
        local nextElement = getElementFromNode(nextNode)
        if nextElement.Offset < (selectedElement.Offset+newElementByteSize) then
          doRemoveNode(nextNode,selectedNodes,expandedNodes,oldElementByteSize)
          nextElement.destroy()
          doExpandNodes(expandedNodes) --Re-expand nodes if necessary after modifying structure.
        else break end
      end
    --If new variable type is smaller in size than older variable type, then create new elements with the new variable type up to address(Offset+Old Byte Size).
    elseif newElementByteSize < oldElementByteSize[i] then
      local splitCount = math.floor(oldElementByteSize[i]/newElementByteSize)-1
      for j=1,splitCount do
        if doAddElement(selectedElement.Owner,selectedElement.Offset+(j*newElementByteSize),newVarType,newElementByteSize) then
          doAddNode(selectedNodes[i].Parent[selectedNodes[i].Index+j],selectedNodes,expandedNodes,oldElementByteSize)
          doExpandNodes(expandedNodes) --Re-expand nodes if necessary after modifying structure.
        end
      end
    end
    i = i+1
  end

  doSelectNodes(selectedNodes) --Reselect original element after deletion
end

function removeDuplicate(structureFrm)
  if structureFrm.mainStruct == nil then return end --When there is no structure defined
  local elementCount = structureFrm.mainStruct.Count
  local i = 0
  while i < elementCount-1 do
    local curOffset = getElementFromNodeIndex(structureFrm,i).Offset
    local nxtOffset = getElementFromNodeIndex(structureFrm,i+1).Offset
    while curOffset == nxtOffset do
      doRemoveElement(structureFrm,i+1)
      --Refresh element count after deletion
      elementCount = structureFrm.mainStruct.Count
      --Refresh next element offset after deletion if not at end of element array
      if i < elementCount-1 then nxtOffset = getElementFromNodeIndex(structureFrm,i+1).Offset
      else break end
    end
    i = i+1
  end
end

function duplicateStructure(structureFrm)
  local srcStructure = structureFrm.mainStruct
  local dstStructure = createStructure(srcStructure.Name)
  for i = 0,srcStructure.Count-1,1 do
    local newElement = dstStructure.addElement()
    newElement.Offset = srcStructure.Element[i].Offset
    newElement.Name = srcStructure.Element[i].Name
    newElement.Vartype = srcStructure.Element[i].Vartype
    if srcStructure.Element[i].ChildStruct ~= nil then
      newElement.ChildStruct = srcStructure.Element[i].ChildStruct
      newElement.ChildStructStart = srcStructure.Element[i].ChildStructStart
    end
    newElement.Bytesize = srcStructure.Element[i].Bytesize
  end
  dstStructure.addToGlobalStructureList()
end

function compareColumns(structureFrm,offset,byteSize)
  for i = 0,(structureFrm.columnCount-1)-1,1 do
    local curColumnAddress = structureFrm.Column[i].Address+offset
    local nxtColumnAddress = structureFrm.Column[i+1].Address+offset
    local curValue = readBytes(curColumnAddress,byteSize,true)
    local nxtValue = readBytes(nxtColumnAddress,byteSize,true)
    for j = 1,byteSize,1 do
      if curValue[j] ~= nxtValue[j] then return 1 end
    end
  end
  return 0
end

function compareGroup(structGroup,offset,byteSize)
  for i = 0,(structGroup.columnCount-1)-1,1 do
    local curColumnAddress = structGroup.Column[i].Address+offset
    local nxtColumnAddress = structGroup.Column[i+1].Address+offset
    local curValue = readBytes(curColumnAddress,byteSize,true)
    local nxtValue = readBytes(nxtColumnAddress,byteSize,true)
    for j = 1,byteSize,1 do
      if curValue[j] ~= nxtValue[j] then return 1 end
    end
  end
  return 0
end

function filterColumnEqual(structureFrm)
  local focusedGroup,focusedColumn = getFocused(structureFrm)
  local elementCount = structureFrm.mainStruct.Count
  local i = 0
  while i < elementCount do
    local offset = structureFrm.mainStruct.Element[i].Offset
    local byteSize = structureFrm.mainStruct.Element[i].Bytesize
    local removeFlag = true
    --Continue comparing other groups only if focused group has equal element values.
    if compareGroup(focusedGroup,offset,byteSize) == 0 then
      --Disable remove flag if there is focused group is the only group and all its element values are equal
      if structureFrm.groupCount == 1 then
        removeFlag = false
      else
      --Continues checking other groups if focused group is not the only group.
        for j = 0,structureFrm.groupCount-1,1 do
          --Skips focused group
          --Disable remove flag if there are other groups with different element values.
          if structureFrm.Group[j] ~= focusedGroup and compareGroup(structureFrm.Group[j],offset,byteSize) == 1 then
            removeFlag = false
            break
          end
        end
      end
    end
    if removeFlag then
      doRemoveElement(structureFrm,i)
      --Refresh element count after deletion. Iterator remains the same.
      elementCount = structureFrm.mainStruct.Count
    else
      --Increment iterator to next element if no deletion performed.
      i = i+1
    end
  end
end

function filterColumnDifferent(structureFrm)
  local focusedGroup,focusedColumn = getFocused(structureFrm)
  local elementCount = structureFrm.mainStruct.Count
  local i = 0
  while i < elementCount do
    local offset = structureFrm.mainStruct.Element[i].Offset
    local byteSize = structureFrm.mainStruct.Element[i].Bytesize
    --Removes element if focused group has equal element values.
    if compareGroup(focusedGroup,offset,byteSize) == 0 then
      doRemoveElement(structureFrm,i)
      --Refresh element count after deletion. Iterator remains the same.
      elementCount = structureFrm.mainStruct.Count
    else
      --Increment iterator to next element if no deletion performed.
      i = i+1
    end
  end
end

function filterGroupEqual(structureFrm)
  local elementCount = structureFrm.mainStruct.Count
  local i = 0
  while i < elementCount do
    local offset = structureFrm.mainStruct.Element[i].Offset
    local byteSize = structureFrm.mainStruct.Element[i].Bytesize
    --Removes element if not all columns have equal element values.
    if compareColumns(structureFrm,offset,byteSize) == 1 then
      doRemoveElement(structureFrm,i)
      --Refresh element count after deletion. Iterator remains the same.
      elementCount = structureFrm.mainStruct.Count
    else
      --Increment iterator to next element if no deletion performed.
      i = i+1
    end
  end
end

function filterGroupDifferent(structureFrm)
  local elementCount = structureFrm.mainStruct.Count
  local i = 0
  while i < elementCount do
    local offset = structureFrm.mainStruct.Element[i].Offset
    local byteSize = structureFrm.mainStruct.Element[i].Bytesize
    local removeFlag = false
    --Continue comparing groups only if not all columns have equal element values.
    if compareColumns(structureFrm,offset,byteSize) == 1 then
      for j = 0,structureFrm.groupCount-1,1 do
        --Sets remove flag to true if one group has different element values.
        if compareGroup(structureFrm.Group[j],offset,byteSize) == 1 then
          removeFlag = true
          break
        end
      end
    --Sets remove flag to true if all columns have the same element value.
    else
      removeFlag = true
    end
    if removeFlag then
      doRemoveElement(structureFrm,i)
      --Refresh element count after deletion. Iterator remains the same.
      elementCount = structureFrm.mainStruct.Count
    else
      --Increment iterator to next element if no deletion performed.
      i = i+1
    end
  end
end

--[[--Hooking Functions----------------------------------------------------------------------------|
---------------------------------------------------------------------------------------------------|
                                                                                                   |
hookStructureInfoForm()                                                                            |
-----------------------                                                                            |
Input:  Void                                                                                       |
Output: Creates a timer which finds the newly opened Structure Info form, then weave the           |
        combineSplit function into the OK button.                                                  |
                                                                                                   |
addMenuItem(form)                                                                                  |
-----------------                                                                                  |
Input:  form - Form object passed by registerFormAddNotification(function).                        |
Output: Adds menu items to form's popup menu if it is structure dissect form.                      |
                                                                                                   |
---------------------------------------------------------------------------------------------------|
--]]-----------------------------------------------------------------------------------------------|

--Local Functions Declaration
local hookStructureInfoForm
local addMenuItem

function hookStructureInfoForm(timer,form)
  --Get new Structure Info form
  local structInfoFrm = nil
  for i = 0,getFormCount(i)-1 do
    if getForm(i).ClassName == "TfrmStructures2ElementInfo" then
      structInfoFrm = getForm(i)
      break
    end
  end
  if structInfoFrm == nil then return end --Returns if Structure Info form was not found

  --Check if buttons are created yet, if not skip & return
  if structInfoFrm.Button1 ~= nil then
    local origOkFunc = structInfoFrm.Button1.onClick
    timer.destroy()
    structInfoFrm.Button1.onClick = function()
                                      combineSplit(structInfoFrm)
                                      synchronize(origOkFunc)
                                    end
  end
end

function addMenuItem(timer,form)
  local structuresMenuItem = form.Menu.Items[3]
  local popupMenu = form.pmStructureView
  if popupMenu ~= nil and structuresMenuItem ~= nil then
    timer.destroy()
    --Add new menu items into popup menu
    local miSeparator             = createMenuItem(form)
    local miCombineSplit          = createMenuItem(form)
    local miRemoveDuplicate       = createMenuItem(form)
    local miFilterColumnEqual     = createMenuItem(form)
    local miFilterColumnDifferent = createMenuItem(form)
    local miFilterGroupEqual      = createMenuItem(form)
    local miFilterGroupDifferent  = createMenuItem(form)

    miSeparator.Name             = 'miSeparator'
    miCombineSplit.Name          = 'miCombineSplit'
    miRemoveDuplicate.Name       = 'miRemoveDuplicate'
    miFilterColumnEqual.Name     = 'miFilterColumnEqual'
    miFilterColumnDifferent.Name = 'miFilterColumnDifferent'
    miFilterGroupEqual.Name      = 'miFilterGroupEqual'
    miFilterGroupDifferent.Name  = 'miFilterGroupDifferent'

    miSeparator.Caption             = '-'
    miCombineSplit.Caption          = 'Combine/Split overlapping element(s)'
    miRemoveDuplicate.Caption       = 'Remove duplicate element(s)'
    miFilterColumnEqual.Caption     = 'Filter out equal element(s)'
    miFilterColumnDifferent.Caption = 'Filter out different element(s)'
    miFilterGroupEqual.Caption      = 'Filter out group equal element(s)'
    miFilterGroupDifferent.Caption  = 'Filter out group different element(s)'

    miCombineSplit.OnClick          = function(sender) doToggleChecked(sender)     end
    miRemoveDuplicate.OnClick       = function()       removeDuplicate(form)       end
    miFilterColumnEqual.OnClick     = function()       filterColumnEqual(form)     end
    miFilterColumnDifferent.OnClick = function()       filterColumnDifferent(form) end
    miFilterGroupEqual.OnClick      = function()       filterGroupEqual(form)      end
    miFilterGroupDifferent.OnClick  = function()       filterGroupDifferent(form)  end

    popupMenu.Items.add(miSeparator)
    popupMenu.Items.add(miCombineSplit)
    popupMenu.Items.add(miRemoveDuplicate)
    popupMenu.Items.add(miFilterColumnEqual)
    popupMenu.Items.add(miFilterColumnDifferent)
    popupMenu.Items.add(miFilterGroupEqual)
    popupMenu.Items.add(miFilterGroupDifferent)

    local oldFunc = popupMenu.OnPopup
    popupMenu.OnPopup = function()
                          synchronize(oldFunc)
                          miFilterColumnEqual.Visible     = form.miChangeValue.Visible
                          miFilterColumnDifferent.Visible = form.miChangeValue.Visible
                          miFilterGroupEqual.Visible      = form.miChangeValue.Visible
                          miFilterGroupDifferent.Visible  = form.miChangeValue.Visible
                        end

    --Add new menu items into main menu
    local miDuplicateStructure = createMenuItem(structuresMenuItem)
    miDuplicateStructure.Caption = 'Duplicate structure'
    miDuplicateStructure.OnClick = function()
                                     if form.mainStruct ~= nil then
                                       duplicateStructure(form)
                                     end
                                   end
    structuresMenuItem.insert(1,miDuplicateStructure)

    --Hook into "Change Element" function
    local origChangeElementFunc  = form.miChangeElement.onClick
    form.miChangeElement.onClick = function()
                                     if form.miCombineSplit.Checked then --Skips if Combine/Split function is disabled
                                       --Sets first selected node as main selection
                                       for i=0,form.tvStructureView.Items[0].Count-1 do
                                         if form.tvStructureView.Items[0][i].Selected then
                                           form.tvStructureView.setSelected(form.tvStructureView.Items[0][i])
                                           break
                                         end
                                       end
                                       newTimer(hookStructureInfoForm,form)
                                     end
                                     synchronize(origChangeElementFunc)
                                   end
  end
end

registerFormAddNotification(
function(form)
  if form.ClassName == "TfrmStructures2" then
    local timer = newTimer(addMenuItem,form)
  end
end
)