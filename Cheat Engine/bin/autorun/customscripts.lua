
local mycustomscripts = {
  ["scripts"] = {}
}

function mycustomscripts.ProcessDirectory(dirname)
  local f = getFileList(dirname)
  local dirs = getDirectoryList(dirname)

  local k
  local v
  
  local scripts = {}
  
  for k,v in ipairs(dirs) do
    local r = mycustomscripts.ProcessDirectory(v)
    local c = 0
    local i,s
    for i,s in pairs(r) do
      c = c + 1
    end
    if c > 0 then
       local f = string.match(v,".*\\(.*)")
       scripts[f] = r
    end
  end
  
  for k,v in ipairs(f) do
    local filename = v
    local f = string.match(v,".*\\(.*)")
    local file, ext = string.match(f,"(.*)[.](.*)")
    if ext:lower() == "cea" then
      local myf = io.open(filename, "rb")
      if myf ~= nil then
        local content = myf:read("*all")
        scripts[file] = content
        myf:close()
      end
    end
  end
  return scripts
end

function mycustomscripts.Run()
  --getLuaEngine():Show()
  mycustomscripts.scripts = mycustomscripts.ProcessDirectory(getCheatEngineDir().."\\templates")
  registerFormAddNotification(mycustomscripts.Bind)
end

function mycustomscripts.AddSubMenu(form, pmi, scripts, path)
  local k,v
  local names = {}
  for k in pairs(scripts) do
    table.insert(names, k)
  end
  table.sort(names)
  for k,v in pairs(names) do
    local mi = createMenuItem(pmi)
    mi.Caption = v
    pmi:Add(mi)
    if type(scripts[v]) == "string" then
      mi.OnClick = function(mi)
        mycustomscripts.OnClick(form, mi)
      end
    else
      local p = k
      if path ~= nil then
        p = path .. "\\" .. k
      end
      mycustomscripts.AddSubMenu(form, mi, scripts[v], p)
    end
  end
end

function mycustomscripts.Bind(form)
  if form.Caption == nil then
    -- Weird form that is half created with no Caption possible
    return
  end
  if form.Caption == "" then
    -- Form is not full initialized
    local t = createTimer()
    t.Interval = 100
    t.Enabled = true
    t.OnTimer = function(t)
      t:Destroy()
      mycustomscripts.Bind(form)
    end
  else
    if form.Name:lower():sub(0,13) == "frmautoinject" and form.Menu ~= nil then
      local i
      for i=0,form.Menu.Items.Count-1 do
        if form.Menu.Items[i].Name == "emplate1" or form.Menu.Items[i].Name == "template1" then -- emplate1 ?????
          local j
          local found = false
          for j=0,form.Menu.Items[i].Count - 1 do
            if form.Menu.Items[i][j].Caption == "Custom" then
              found = true
            end
          end
          if not found then
            local citem = createMenuItem(form.Menu.Items[i])
            citem.Caption = "Custom"
            form.Menu.Items[i]:Insert(0, citem);
            mycustomscripts.AddSubMenu(form, citem, mycustomscripts.scripts);
          end
        end
      end
    end
  end
end

function mycustomscripts.OnClick(form, mi)
  local menuitem = mi
  local names = {}
  repeat
    table.insert(names, 1, menuitem.Caption)
    menuitem = menuitem.Parent
  until menuitem == nil or menuitem.Caption == "Custom"
  
  local i,v
  local scripts = mycustomscripts.scripts
  for i,v in ipairs(names) do
    if type(scripts) ~= "table" or scripts[v] == nil then
      scripts = nil
      break
    end
    scripts = scripts[v]
  end
  if type(scripts) == "string" and mi.Caption ~= nil and form.assemblescreen ~= nil then
    form.assemblescreen.Lines.Text = scripts
  end
end

mycustomscripts.Run()
