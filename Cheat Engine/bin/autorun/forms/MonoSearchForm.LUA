LaunchMonoDataCollector()

local counter = 0

local addedItems = {}

local deleteChildren = function(TV, index, node)
  --while node.HasChildren do TV.items.Delete(node.GetLastChild) end
  --print('Treeview:', tostring(TV))
  --print('index:', tostring(index))
  --print('node:', tostring(node))
  for k,v in pairs(node) do
    print("k:",tostring(k),", v:",tostring(v))
  end
end

function nameMatches(search, name)
  return string.find(string.lower(name), string.lower(search)) ~= nil
end

function monoSearchForm_buttonSearch_onClick(sender)
  -- search text: print(monoSearchForm.editText.Text)
  local form = monoSearchForm
  local TV = form.TV

  -- first we clear the tree, except for the base nodes Classes, Fields and Methods
  for i=0,2 do TV.items[i].deleteChildren() end

  local searchText = form.editText.Text

  --[[ replaced with above (hopefully works
  while i < TV.items.Count do
    if TV.items[i].HasChildren then
      local node = TV.items[i+1]
      addedNodes[node] = nil
      node.delete()
      --TV.items[i+1].delete()
    else
      i = i + 1
    end
  end --]]

  local nodeClasses = TV.Items[0]
  local nodeFields = TV.Items[1]
  local nodeMethods = TV.Items[2]

  local domains = mono_enumDomains()
  local assemblies = mono_enumAssemblies()
  local i,j
  for i=1,#assemblies do
    local image = mono_getImageFromAssembly(assemblies[i]);
    local imageName = mono_image_get_name(image);
    local ass = { name = imageName, image = image, id = assemblies[i] }
    if not shouldIgnore(ass.name) then
      ass.classes = mono_image_enumClasses(ass.image)
      table.sort(ass.classes, function(a,b) return a.classname < b.classname end)
      for j=1,#ass.classes do
        local class = ass.classes[j]
        local item = nil

        -- check class itself
        if form.checkClasses.Checked and nameMatches(searchText, class.classname) then
          item = { isClass = true, assembly = ass, class = class }
          table.insert(addedItems, item)
          item.index = #addedItems
          local newNode = nodeClasses.add(class.classname)
          newNode.Data = item.index
          item.node = newNode
        end

        -- fields
        if form.checkFields.Checked then
           local fields = mono_class_enumFields(class.class)
           for j=1,#fields do
             local field = fields[j]
             if nameMatches(searchText,field.name) then
               item = { isField = true, assembly = ass, class = class, field = field }
               table.insert(addedItems, item)
               item.index = #addedItems
               local newNode = nodeFields.add(string.format("%s  (%s)", field.name, class.classname))
               newNode.Data = item.index
               item.node = newNode
             end
           end
        end
      end
    end
  end
end


function monoSearchForm_TV_onDblClick(sender)
  local TV = monoSearchForm.TV
  local selected = TV.Selected
  if selected == nil then return end
  local item = addedItems[selected.Data]

  if not item then return end

  local strings = createStringlist()
  local memo = monoSearchForm.memoText
  --strings.add("You double-clicked "..selected.Text.."!")
  --strings.add(string.format("Data is: %d", selected.Data))
  --strings.add("line 1")
  --strings.add("line 2")
  --strings.add("line 3")
  memo.Lines = strings
--  if selected == nil then
--    memo.Lines = ""
--  end
end


function getSelectedItem()
  local TV = monoSearchForm.TV
  local selected = TV.Selected
  if selected == nil then return nil end
  local item = addedItems[selected.Data]
  return item
end

function monoSearchForm_StructureDef(sender)
  local item = getSelectedItem()
  if not item then return end
  if not item.class then return end
  local class = item.class
  local fields = mono_class_enumFields(class.class)
  if not fields then return end
  if #fields < 1 then return end
  table.sort(fields, function(a, b) return a.offset < b.offset end)

  local strings = createStringlist()
  local memo = monoSearchForm.memoText
  strings.add("// you can use this and it will define the structure when enabling")
  strings.add(string.format("GETMONOSTRUCT(%s)", class.classname))
  strings.add("")
  strings.add("{")
  strings.add("  // sample usage:")
  local sample = fields[#fields - 1]
  strings.add(string.format("  // resolves to mov eax,[edi+%04x]", sample.offset))
  strings.add(string.format("  mov eax,[edi+%s]", sample.name))
  strings.add(string.format("  mov eax,[edi+%s.%s]", class.classname, sample.name))
  strings.add("")

  strings.add("// or you can include the structure as we detect it now:")
  strings.add(string.format("STRUCT %s", class.classname))

  -- loop through fields.  if we are at the right offset, create a label
  -- if not, enter resb with the number of bytes to skip
  local offset = 0
  for i=1,#fields do
    local field = fields[i]
    local newOffset = offset
    if (field.offset > offset) then
      -- field is ahead of where we are, reserve some bytes and set where we are to where the field is
      strings.add(string.format("  %-21s resb %-3d", "", field.offset - offset))
      offset = field.offset
    end
    local size = 4 -- default only used on last item
    if i < #fields then
      size = fields[i+1].offset - offset
      -- print(string.format("size %d from offset %d to %d", size, offset, fields[i+1].offset))
    end

    strings.add(string.format("  %-21s resb %-3d    // offset %04x", field.name..":", size, field.offset))
    offset = offset + size
  end

  strings.add("ENDS")
  strings.add("")
  strings.add("}")

  memo.Lines = strings
end


local ignore = {}
ignore["System"] = true
ignore["mscorlib"] = true
ignore["Boo.Lang"] = true
ignore["Mono"] = true

function shouldIgnore(name)
  if name == nil then return true end
  local len = string.len(name)
  for k,v in pairs(ignore) do
    --print(string.format("k,v = '%s','%s'", k, tostring(v)))
    if string.len(k) <= len then
      if string.sub(name,1,string.len(k)) == k then
        return true
      end
    end
  end
  return false
end

function popupblaclick()
  print("POPUP CLICKED!")
end

monoSearchForm = createFormFromFile("..\\MonoSearch.FRM")
monoSearchForm = FormMonoSearch
local pmenu = createPopupMenu(monoSearchForm)
local pmenu_items = menu_getItems(pmenu)

local mi = createMenuItem(pmenu)
menuItem_setCaption(mi, 'Structure')
--menuItem_onClick(mi, popup_Structure)
menuItem_onClick(mi, monoSearchForm_StructureDef)
menuItem_add(pmenu_items, mi)

mi = createMenuItem(pmenu)
menuItem_setCaption(mi, 'Methods')
menuItem_onClick(mi, popup_Methods)
menuItem_add(pmenu_items, mi)

mi = createMenuItem(pmenu)
menuItem_setCaption(mi, 'AA Code')
menuItem_onClick(mi, popup_AA)
menuItem_add(pmenu_items, mi)

mi = createMenuItem(pmenu)
menuItem_setCaption(mi, 'Defines')
menuItem_onClick(mi, popup_AA)
menuItem_add(pmenu_items, mi)

monoSearchForm.TV.PopupMenu = pmenu
monoSearchForm.show()

-- for testing, automatically do search for "Weapon" (works with Distant Star: Revenant Fleet)
monoSearchForm.editText.Text = "Weapon"
monoSearchForm_buttonSearch_onClick(nil)




--[[
function string.starts(String,Start)
   if string.len(String) < string.len(Start) then
     return false
   end
   return string.sub(String,1,string.len(Start))==Start
end

--print('starts:', tostring(1==1))





local domains = mono_enumDomains()
print(string.format("Found %d domains", #domains))
local assemblies = mono_enumAssemblies()
print(string.format("Found %d assemblies", #assemblies))
local i
local myAssemblies = {}
for i=1,#assemblies do
  local image = mono_getImageFromAssembly(assemblies[i]);
  local imageName = mono_image_get_name(image);
  local ass = { name = imageName, image = image, id = assemblies[i] }
  -- ignore 'Mono.' or 'System.' (or 'mscorlib') assemblies
  print(string.format("ass.name: '%s'", ass.name))
  if shouldIgnore(ass.name) then
    print(string.format("Ignoring system assembly '%s'", ass.name))
  else
    -- print(string.format("Assembly %d: 0x%x - '%s'", i, ass.id, ass.name))
    print(string.format("Adding assembly '%s'", ass.name))
    ass.classes = mono_image_enumClasses(ass.image)
    for j=1,#ass.classes do
      local class = ass.classes[j]
      class.id = class.class
      --class.assembly = ass
      print(string.format("Getting fields for 0x%x: %s", class.class, class.classname))
      class.fields = mono_class_enumFields(class.id)
      class.methods = mono_class_enumMethods(class.id)
    end
    table.insert(myAssemblies, ass)
  end
end

for i=1,#myAssemblies do
  local ass = myAssemblies[i]
  for j=1,#ass.classes do
    if j < 20 then
      local class = ass.classes[j]
      print(string.format("  class[%d]: 0x%x is '%s' in namespace '%s'", j, class.class, class.classname, class.namespace))
    end
  end
end

print('DONE!')
--]]


