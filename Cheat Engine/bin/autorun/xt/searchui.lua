
--
function mixedCmp(a,b)
  if type(a)==type(b) then return a< b end
  return a=='number'
end

function ceupd(o,p,...)-- handy function to update ce userdata/guiclass
  if type(p)~='table' then return o end
  for k,v in pairs(p) do
    if type(v)=='table' then
      if k:lower()=='whxy' then -- size/pos shorthand
        if v[1]~=nil or v[2]~=nil then o.AutoSize=false end
        if v[1]~=nil then o.Width=v[1] end
        if v[2]~=nil then o.Height=v[2] end
        if v[3]~=nil then o.Left=v[3] end
        if v[4]~=nil then o.Top=v[4] end
      elseif k:lower()=='xywh' then -- pos/size shorthand
        if v[3]~=nil or v[4]~=nil then o.AutoSize=false end
        if v[1]~=nil then o.Left=v[1] end
        if v[2]~=nil then o.Top=v[2] end
        if v[3]~=nil then o.Width=v[3] end
        if v[4]~=nil then o.Height=v[4] end
      else
        local peek = o[k]
        o[k]=ceupd(peek,v)
      end
    else
      o[k]=v
    end
  end
  if select('#',...)==0 then return o end
  return ceupd(o,...)
end

function CEDestroy(o)-- seems not work as expected...
  return function()
    if type(o)=='userdata' and type(o.ClassName)=='string' and type(o.Destroy)=='function' then
      if o.ClassName:match('^%a%a%a') then o.Destroy() end
    end
  end
end

function getUid(k)
  local key='global'
  _G.UID = type(_G.UID)~='table' and {} or _G.UID
  UID = _G.UID
  if type(k)=='string' then key = k end
  UID[key]=type(UID[key])~='number' and 0 or UID[key]+1
  return UID[key]
end

function callLater(d,f,...)
  if type(f)=='function' then
    local a,uid = {n=select('#',...),...},getUid('callLater')
    TimerAlive=type(TimerAlive)~='table' and {} or TimerAlive
    TimerAlive[uid]=true
    local cb = function(sender)
      sender.Destroy()
      if TimerAlive[uid]==true then
        TimerAlive[uid]=nil
        f(unpack(a,1,a.n))
      end
    end
    local t = ceupd(createTimer(),{ Interval = d, OnTimer = cb})
    return function()TimerAlive[uid]=nil end -- abort function
  end
end

function GUI(namecls,props,childs,parent,rootForm)
  local c = type(namecls)
  if c=='table' then return GUI(unpack(namecls)) -- input is a table, unpack it
  elseif c=='string' then -- create new ui class by name-class specification
    local name,cls = namecls:match('^([^|/: ]+)[|/: ](.-)$')
    if cls==nil or cls:len()==0 then cls,name = namecls,nil end
    c = _G['create'..assert(cls)]
    assert(type(c)=='function',"check function(?) create"..tostring(cls))
    c = cls == 'Form' and c(false) or assert(parent) and c(parent)
    if c and cls == 'Form' then rootForm = c end
    if name~=nil then c.Name = name end
  elseif c=='userdata' then -- asssum it is existed ui class , else error...
    c = namecls
  end
  if type(props)=='table' then ceupd(c,props) end
  if type(childs)=='table' then
    for _,d in ipairs(childs) do
      local dt = type(d[1])
      if dt=='string' or dt=='userdata' then
        GUI(d[1],d[2] or {},d[3] or {},c,rootForm)
      end
    end
  end
  return c
end

function soundex(s)
  if type(s)~='string' or not s:match('^%a') then return nil end
  local c,r={"bfpv","cgjkqsxz", "dt", "l", "mn", "r"},{s:sub(1,1):upper()}
  local index=function(a)for i=1,#c do if c[i]:match(a) then return ""..i end end end
  for a in s:sub(2):gmatch('%a') do
    local ix=index(a:lower())
    if ix~=nil and ix~=r[#r] then r[1+#r]=ix end
  end
  r[1+#r]='0000'
  return table.concat(r):sub(1,4)
end

function sortedkey(t)
  local r={}
  if type(t)=='table' then
    for k,_ in pairs(t) do r[1+#r]=k end
    table.sort(r,mixedCmp)
  end
  return r
end

function memo1(f)
  _memo=type(_memo)~='table' and {} or _memo
  _memo[f]=_memo[f] or setmetatable({},{__mode='kv'})
  return function(a)
    if _memo[f][a]==nil then _memo[f][a] = {f(a)} end
    return unpack(_memo[f][a])
  end
end

function removeValues(t,value) for k,v in pairs(t) do if v==value then t[k]=nil end end end
function removeKey(t,key) t[k]=nil end
function transferTable(t,newtable)for k,v in pairs(newtable) do t[k]=v end return t end
function emptyTableAndSet(t,newtable)
  for k,_ in pairs(t) do t[k]=nil end
  if type(newtable)=='table' then transferTable(t,newtable) end
  return t
end

function _collectSubKey(key)
  local sndx,xact = {},{}
  local function add(w)sndx[soundex(w)]=true xact[w:lower()]=true return ' ' end
  key = key:gsub('%u%l*',add)
  key = key:gsub('%a+',add)
  return sortedkey(sndx),sortedkey(xact)
end

getSubKey = memo1(_collectSubKey)

function getRootForm(c)
  local parent,p = c,c
  while p~=nil do parent = p  p = p.Parent end
  return parent
end

function searchui(tbl,fn,f)
  local host = {tbl=tbl,sdict={},xdict={},keys={},rkeys={}}
  host=setmetatable({},{__index=host})
  local Uid = "searchui_"..getUid() -- uid for _this_ instance
  --[[
  function host:getKeyTable()
    print('getKeyTable :',type(self),type(host.getKeyTable))
    if type(self.tbl)=='string' then return _G[self.tbl] end -- named global table
    return self.tbl -- expect error if tbl reference a non table
  end
  --]]
  function host:updateTables(key,value)
--    print('updateTables :',type(self),key,type(value))
    local TBL = self.tbl
    if type(key)=='string' then
      local rk = self.rkeys[key]
      if value == nil then 
        if tbl[key]~=nil and rk~=nil then -- delete key
          local sndk,xack = getSubKey(key)
          for i=1,#sndk do removeValues(self.sdict[sndk[i]],rk) end
          for i=1,#xack do removeValues(self.xdict[xack[i]],rk) end
          self.keys[rk]=nil
          self.rkeys[key]=nil
          TBL[key]=nil
        end
      elseif TBL[key]==nil then -- add new key with value
        local newid = getUid(Uid)
        local sndk,xack = getSubKey(key)
        for i=1,#sndk do 
          local sk = sndk[i]
          if self.sdict[sk]==nil then self.sdict[sk]={[newid]=true} 
          else self.sdict[sk][newid]=true end
        end
        for i=1,#xack do
          local xk = xack[i]
          if self.xdict[xk]==nil then self.xdict[xk]={[newid]=true} 
          else self.xdict[xk][newid] = true end
        end 
        self.keys[newid] = key
        self.rkeys[key] = newid        
        TBL[key] = value
      else  -- just update value, no change to sdict xdict keys
        if TBL[key] ~= value then
          TBL[key] = value
        end
      end
    end
  end
  
  function host:setupUi()
  
    for k,v in pairs(self.tbl) do self:updateTables(k,v) end
  
	  local b,ww,colora,colorb=5,0,0xeee8e8,0xaaaa99
	  if type(f)~='userdata' then
	    f = GUI('searchFrm/Form',{Caption='Search',whxy={600,300},Position='poOwnerFormCenter',
	        ShowInTaskBar='stAlways',BorderStyle='bsSizeable'},{})
	    ww = 300
	  end
	  
	  self.ui = f
	  
	  local bw = ww==0 and 0 or b
	  GUI(f,{Constraints={MinWidth=300,MinHeight=200}},{
	    ww==0 and {} or {'pr/Panel',{Caption='',Alignment=2,xywh={f.Width-ww-b,b,ww,f.Height-2*b}}},
	    {'tx/Edit',{Text='--enter--',xywh={b,b,f.Width-ww-2*b-bw,26}}},
	    {'lx/ListBox',{Caption='',Alignment=2,xywh={b,60+3*b,f.Width-ww-2*b-bw,f.Height-4*b-60}}},
	    {'cb/ComboBox',{Text='',xywh={b,30+2*b,f.Width-ww-2*b-bw,30},ReadOnly=false}},
	  })
	
	  local maxDrops,abort=24
	  f.cb.DropDownCount = 12
	  local process= function()
	    local s,collect,common=f.tx.Text,{},{}
--	    local sndk,xack = getSubKey(s)
	    
		  local sndk,xack = {},{}
		--  local function add(w)sndx[soundex(w)]=true xact[w:lower()]=true return ' ' end
		  s = s:gsub('%u%l*',function(w)sndk[soundex(w)]=true return ' ' end)
		  s = s:gsub('%a+',function(w)xack[w:lower()]=true return ' ' end)
      sndk = sortedkey(sndk)
      xack = sortedkey(xack)
	    for i=1,#sndk do
	      local sk,dict = sndk[i],self.sdict[sndk[i]]
	      if sk~=nil and dict~=nil then
	        collect[1+#collect]={}
	        for k,v in pairs(dict) do
	          collect[#collect][k]=true
	          common[k]=true
	        end
	      end
	    end
	    for i=1,#xack do
	      local xk,dict = xack[i],self.xdict[xack[i]]
	      if xk~=nil and dict~=nil then
	        collect[1+#collect]={}
	        for k,v in pairs(dict) do
	          collect[#collect][k]=true
	          common[k]=true
	        end
	      end
	    end

	    local search = {}
	    for k,_ in pairs(common) do
	      local inall = true
	      for i=1,#collect do if collect[i][k]~=true then inall=false break end end
	      if inall==true then search[1+#search]=self.keys[k] end --common[k]=nil end
	    end
	    table.sort(search)
	    f.lx.Items.Text=table.concat(search,'\n')
	    local rf = getRootForm(f)
	    if rf.Caption then
	      local counts = " < "..#search..' of '..#self.keys.." >"
	      local prefix,subfix = rf.Caption:match('^(.-)%s*(%b<>)%s*$')
	      if subfix==nil then prefix = rf.Caption end
 	      rf.Caption = prefix..counts
  	  end
	  end
	
	  f.tx.OnChange=function(sender,key)
	    if abort~=nil then abort() end
	    abort=callLater(1000,process)
	    return key
	  end
	
	  f.lx.OnSelectionChange=function(sender,user)

	    local tx,sx,ix = f.cb.Items.Text,f.lx.Items[f.lx.ItemIndex],0
	    local tt = {}
	    tx:gsub('[^\n\r]+',function(a)
	      tt[1+#tt]=a
	      if a==sx then ix = #tt end
	      return ''
	    end)
	    if ix<=0 or ix==#tt then
	      while #tt>=maxDrops do table.remove(tt) end
	      f.cb.Items.Text = sx..'\n'..table.concat(tt,'\n')
	    else
	      table.remove(tt,ix)
	      f.cb.Items.Text = sx..'\n'..table.concat(tt,'\n')
	    end
	    f.cb.ItemIndex=0
	
	    if type(fn)=='function' then fn(sx,tbl[sx],self) end
	    return user
	  end
	  f.cb.OnChange = function(sender)
	    local ix = f.cb.ItemIndex
	    if ix>=0 and type(fn)=='function' then
	      local sx = f.cb.Items[ix]
	      fn(sx,tbl[sx],self)
	    end
	  end
	  f.OnResize=function(sender)
	    local w,h,o = sender.Width,sender.Height,sender
	    local dv = 0
	    if ww~=0 then
	      dv = math.floor((w - 600)/3)
	      ceupd(o.pr,{xywh={w-ww-dv*2-b,b,ww+dv*2,h-2*b}})
	    end
	    local lw = w-ww-dv*2-2*b-bw
	    ceupd(o.tx,{xywh={b,b,lw,23}})
	    ceupd(o.cb,{xywh={b,h-30-3*b,lw,30}})
	    ceupd(o.lx,{xywh={b,30+2*b,lw,h-4*b-60}})
	  end
	  if type(f.show)=='function' then 
	    f.OnClose=function(sender) return caFree end
	    f.show() 
	  end
  end  -- setup ui
  
  host:setupUi()
  
  return host--setmetatable(host,{__index=host})
end
