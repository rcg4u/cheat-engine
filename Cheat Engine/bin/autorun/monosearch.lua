--
require '../autorun/xt/searchui'

local state,nmod,maxmod = {},0,2

MonoClassSearch = {}
PendingNodes = {}
PendingDelay = 0
ProcessCount = 0
MonoSearchHost=nil

function addKeyNode(th)

    if #PendingNodes>0 and PendingDelay<=0 then
      local processed = 0
      for j=#PendingNodes,1,-1 do
        processed = processed + 1
        if processed > 50 then callLater(250,addKeyNode) return end

        local node,klass,fqname = unpack(PendingNodes[j])
        table.remove(PendingNodes)
--        ProcessCount = ProcessCount + 1

--        if ProcessCount % 100 == 99 then print(ProcessCount) end


      end
    end
    PendingDelay = PendingDelay==nil and 10 or PendingDelay>0 and PendingDelay-1 or 0
    callLater(100,addKeyNode)
end
--callLater(100,addKeyNode)

--createNativeThread(addKeyNode)

function modFunc()
  if nmod >= maxmod then return end
  if state['AddClass']==nil and type(monoform_EnumClasses)=='function' then
    state['AddClass']=monoform_EnumClasses
    nmod=nmod+1

    monoform_EnumClasses = function(node)

      local n = state['AddClass'](node) -- call original function

      if type(MonoSearchHost)~='table' or type(MonoSearchHost.ui)~='userdata' then return end

        --local desc,n=string.format("%x : %s", klass, fqname)
      local re = '^%s*(%x+)%s*:%s*(.-)%s*$'
      local _,img1 = node.Text:match(re)
      for i=0,node.Count-1 do-- if node[i].Text==desc then n=node[i] break end end
        local n = node[i]
        local klass,fqname = n.Text:match('^%s*(.-)%s*:%s*(.-)%s*$')
        if n~=nil and fqname ~=nil then
          local function add_node(name)
	          if MonoClassSearch[name]~=nil then -- dulplicated key
	            local _,img2 = MonoClassSearch[name].Parent.Text:match(re)
	            if img1~=nil and img2~=nil and img1~=img2 then
	              local n1 = img1.."::"..name
	              local n2 = img2.."::"..name
	              MonoSearchHost:updateTables(n1,n)
	              MonoSearchHost:updateTables(n2,MonoClassSearch[name])
	              MonoSearchHost:updateTables(name,nil)
	            end
	          else -- new key
	            MonoSearchHost:updateTables(name,n)
	          end
	        end
          klass = n.Data
          local ms,fs = mono_class_enumMethods(klass),mono_class_enumFields(klass)
          for i=1,#ms do add_node(fqname.."::"..ms[i].name) end
          for i=1,#fs do add_node(fqname..":."..fs[i].name) end	        
        end
      end
--      return n
--      table.insert(PendingNodes,{node,klass,fqname})
--      PendingDelay = 10
    end
  end

  if state['monodissect']==nil and type(mono_dissect)=='function' then
    state['monodissect']=mono_dissect
    nmod=nmod+1

    mono_dissect = function()
      emptyTableAndSet(MonoClassSearch)-- clear table without assign a new table reference
      emptyTableAndSet(PendingNodes)-- clear table without assign a new table reference

      state['monodissect']() -- call original function

      local modform
      modform = function()
        if type(monoForm)=='userdata' and type(monoForm.TV)=='userdata' then
          if type(monoForm.search)=='userdata' then return end -- end mod

          GUI(monoForm,{AutoSize=false,Constraints={MinWidth=360,MinHeight=300}},{
            {'search/Panel',{AutoSize=false}}
          })
          monoForm.TV.AutoSize=false
--          monoForm.TV.AnchorSideBottom.Control = monoForm.search
--          monoForm.TV.AnchorSideBottom.Side='asrBottom'
            monoForm.TV.Anchors ='[]'
            monoForm.TV.Align ='alNone'
          MonoSearchHost = searchui(MonoClassSearch,function(k,v,p)
            if type(v)=='userdata' then -- v should be a node
--              if v.Expanded then v.Collapse(false) else v.expand(false)end
              v.makeVisible()   -- make it visible (scroll to this node?)
              v.Selected=true
            end
          end,monoForm.search)

--          monoForm.Color=0xeeee88
          monoForm.OnResize=function(sender)
            local w,h,o,b = sender.Width, sender.Height, sender,0
            local sh = sender.search.Height
            local dv = math.floor((h - 300-3*b)/3)
            ceupd(o.TV,{xywh={b,b,w-2*b,100+2*dv}})
            ceupd(o.search,{xywh={b,100+2*dv-2*b,w-2*b,200+dv}})
          end
          monoForm.OnResize(monoForm)
        end
        callLater(250,modform)
      end -- modform

      callLater(250,modform)
    end -- mono_dissect
  end

  callLater(1000,modFunc)
end

callLater(1000,modFunc)
callLater(120000,function()nmod=999 end)--abort on timeout 2min
