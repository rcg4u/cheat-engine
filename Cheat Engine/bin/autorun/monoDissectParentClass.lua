
local debugSkip = false

function myMonoGuess(s,addr)

  local classes,lastParent = {},s.Name:match('@%s*([%a_][%w_]*)%s*$')
  if nil==lastParent or monoform_escapename==nil or nil==readInteger"mono_domain_get" or LaunchMonoDataCollector()==0 then -- request parent class???
    return nil  -- no change for some input/enviroment error
  else
    local caddr,cname=mono_object_getClass(addr)
    if 0~=caddr then
      caddr = mono_class_getParent(caddr)--1st parent
      while caddr~=0 do
        classes[1+#classes]=caddr
        cname = mono_class_getFullName(caddr)
--        print('-->'..tostring(cname))
        if cname~=nil and cname:find(lastParent,1,true) then
          break -- stop at specified lastParent
        end
        caddr = mono_class_getParent(caddr)
      end
    end
  end

  if #classes==0 then return nil end -- no parents
--  print(#classes)
  s.beginUpdate()
  for j=1,#classes do
    local klass = classes[j]

    local fields=mono_class_enumFields(klass)
--    local str -- string struct
--    local childstructs = {}
    for i=1, #fields do -- for instance fields, ie. no static
--      hasStatic = hasStatic or fields[i].isStatic

      if not fields[i].isStatic and not fields[i].isConst then
        local e=s.addElement()
        local ft = fields[i].monotype
        local fieldname = monoform_escapename(fields[i].name)
        if fieldname~=nil then
          e.Name=fieldname
        end
        e.Offset=fields[i].offset
        e.Vartype=monoTypeToVarType(ft)

        if ft==MONO_TYPE_STRING then

          if mono_StringStruct==nil then

            mono_StringStruct = createStructure("String")

            mono_StringStruct.beginUpdate()
            local ce=mono_StringStruct.addElement()
            ce.Name="Length"
            if targetIs64Bit() then ce.Offset=0x10 else ce.Offset=0x8 end

            ce.Vartype=vtDword
            ce=mono_StringStruct.addElement()
            ce.Name="Value"
            if targetIs64Bit() then ce.Offset=0x14 else ce.Offset=0xC end
            ce.Vartype=vtUnicodeString
            ce.Bytesize=128
            mono_StringStruct.endUpdate()
            mono_StringStruct.addToGlobalStructureList()
          end -- stringStruct
          e.setChildStruct(mono_StringStruct)
        end -- MONO_TYPE_STRING
      end-- instance field
    end -- for field
  end -- for classes
  s.endUpdate()
  return nil
end

if myMonoGuessID then
  unregisterStructureDissectOverride(myMonoGuessID)
  myMonoGuessID = nil
end
if not debugSkip then
  myMonoGuessID = registerStructureDissectOverride(myMonoGuess)
end
