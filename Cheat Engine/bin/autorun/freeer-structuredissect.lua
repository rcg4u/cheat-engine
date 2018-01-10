if getCEVersion() <= 6.7 then
  -- use hacky version pre support, diff function so checks aren't redone for every column when nothing can change
  local structureColumnShadowOffset = cheatEngineIs64Bit() and 0x18 or 0xC
  function getStructureColumnAddress(structureColumn)
    local columnShadowAddress = readPointerLocal(userDataToInteger(structureColumn)+structureColumnShadowOffset)
    return columnShadowAddress ~= 0 and columnShadowAddress or structureColumn.Address
  end
else
  function getStructureColumnAddress(structureColumn)
      return structureColumn.SavedState ~ 0 and structureColumn.SavedState or structureColumn.Address
  end
end


function compareColumns(structureFrm,offset,byteSize)
  for i = 0,(structureFrm.columnCount-1)-1,1 do
    local curColumnAddress = getStructureColumnAddress(structureFrm.Column[i]) + offset
    local nxtColumnAddress = getStructureColumnAddress(structureFrm.Column[i+1]) + offset
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
    local curColumnAddress = getStructureColumnAddress(structGroup.Column[i]) + offset
    local nxtColumnAddress = getStructureColumnAddress(structGroup.Column[i+1]) + offset
    local curValue = readBytes(curColumnAddress,byteSize,true)
    local nxtValue = readBytes(nxtColumnAddress,byteSize,true)
    for j = 1,byteSize,1 do
      if curValue[j] ~= nxtValue[j] then return 1 end
    end
  end
  return 0
end