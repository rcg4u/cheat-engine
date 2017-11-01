--[[
    Options Class for Cheat Engine 6.4
    requirements: CE6.4
    ------------------------------------------------------------
    (c) 2014 mgr.inz.Player

    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND.
    For God's sake, do not touch anything here :-D
]]--

local function Class(base, init)
  local c = {}

  if not init and type(base) == 'function' then
    init = base
    base = nil

  elseif type(base) == 'table' then
      for k,v in pairs(base) do c[k] = v end
      c._base = base
  end

  c.__index = c

  local mt = {}
  mt.__call =
    function(class_tbl, ...)
      local obj = {}
      setmetatable(obj,c)
      if init then init(obj,...) end
      return obj
    end

  c.init = init
  setmetatable(c, mt)
  return c
end

local function customRepaint(control)
  control.HideSelection = false  -- oddly, it is better than "repaint"
  control.HideSelection = true
end

local function checkingInitData(val,b1,b2,int)
  if val~=nil and int==true then val = math.floor(val) end
  if val==nil               then return 0 end

  if b1 and b2 then
    if b1>b2 then b1,b2=b2,b1 end
    if val<b1 or val>b2  then return b1 end
  elseif b1 and (val<b1) then return b1
  elseif b2 and (val>b2) then return b2
  end

  return val
end

local function getControlTextAsNumber(control,b1,b2,int)
  local number = tonumber(control.Text)
  if number==nil then
    control.Color = 0x9090ff   -- bright Red, not a number
    control.Hint = 'not a number, please correct it'
    control.ShowHint = true
    customRepaint(control)
    return nil
  end

  if int==true then number = math.floor(number); control.Text=number end
  local wrong = false

  if b1 and b2 then
    if b1>b2 then b1,b2=b2,b1 end
    if number < b1 or number > b2 then wrong = true end
  elseif b1 and number < b1 then wrong = true
  elseif b2 and number > b2 then wrong = true
  end

  if wrong then
    control.Color = 0x90ffff   -- bright Yellow, outside range
    control.Hint = 'outside range, please correct it'
    control.ShowHint = true
    customRepaint(control)
    return nil
  end

  control.Color = 0x20000000 -- clDefault
  control.ShowHint = false
  customRepaint(control)
  return number
end

local function setLeftAndTopSib_andSpacing(control, sibling, leftSpacing, topSpacing)
  control.BorderSpacing.Left = leftSpacing or 0
  control.BorderSpacing.Top = topSpacing or 0

  control.AnchorSideLeft.Control = sibling
  control.AnchorSideTop.Control = sibling
end

local function CenterV(control, sibling)
  control.AnchorSideTop.Control = sibling
  control.AnchorSideTop.Side = 'asrCenter'
end

local function CenterH(control, sibling)
  control.AnchorSideLeft.Control = sibling
  control.AnchorSideLeft.Side = 'asrCenter'
end

local function createControls(parentControl, list, editWidth, EditLeftSpacing, RowSpacing, ColSpacing, perColumn)
 local T = {}

 if parentControl==nil then return T end


 parentControl.Visible = false
 parentControl.BorderSpacing.InnerBorder = 5

 editWidth = editWidth or 40
 EditLeftSpacing = EditLeftSpacing or 5
 perColumn = perColumn or math.floor( ((#list) ^ 0.5) * 2)
 RowSpacing = RowSpacing or 10
 ColSpacing = ColSpacing or 10

 local prevLabel,prevEdit,prevColEdit = nil,nil,nil
 local tmp,widestLabel = 0,0

 for i=1,#list do

   -- Value, GreaterThanOr, LessThanOr, Int
   local hint
   local caption = list[i].VarName
   local gto,lto=list[i].GreaterThanOr,list[i].LessThanOr
   local range = ''
   if gto and lto then
     gto,lto = math.min(gto,lto),math.max(gto,lto)
     range = ' ['..gto..','..lto..']'
     hint = 'must be equal to '..gto..' or '..lto..', or between'
   elseif gto then
     range = ' >'..gto
     hint = 'must be equal to '..gto..' or greater'
   elseif lto then
     range = ' <'..lto
     hint = 'must be equal to '..lto..' or less'
   end

   if list[i].Int then hint=hint..', it is an integer value' end



   local edit = createEdit(parentControl)
         edit.Text  = list[i].Value
         edit.Width = editWidth

   local label = createLabel(parentControl)
         label.Caption = caption..range..' :'
         label.Hint = hint
         label.ShowHint = true

   if i==1 then -- only for first label and edit
     label.BorderSpacing.Left = 8
     label.BorderSpacing.Top = 8
     prevColEdit=edit

     -- next to label (BorderSpacing will be set later)
     edit.AnchorSideTop.Side = 'asrCenter'
     setLeftAndTopSib_andSpacing(edit,label)

   elseif (i-1) % perColumn == 0 then -- label and edit in: first row and for every column except first

     -- next to edit from previous column
     label.AnchorSideLeft.Side = 'asrBottom'
     label.AnchorSideTop.Side = 'asrCenter'
     setLeftAndTopSib_andSpacing(label,prevColEdit, ColSpacing)

     -- next to label
     edit.AnchorSideTop.Side = 'asrCenter'
     setLeftAndTopSib_andSpacing(edit,label)

     -- set spacing for edit (in previous column, first row)
     prevColEdit.BorderSpacing.Left = widestLabel + EditLeftSpacing
     widestLabel = 0
     prevColEdit = edit

   else
     -- current label, below previous label
     label.AnchorSideTop.Side = 'asrBottom'
     setLeftAndTopSib_andSpacing(label,prevLabel,0,RowSpacing)

     -- current edit, center horizontally to previous edit, and vertically to label
     CenterH(edit,prevEdit)
     CenterV(edit,label)
   end

   -- find widest label
   tmp=label.Canvas.getTextWidth(label.Caption)
   if widestLabel < tmp then widestLabel = tmp end

   T[#T+1] = edit

   prevLabel = label
   prevEdit = edit
 end

 -- set BorderSpacing for edit in last column, (to be sure it is set)
 prevColEdit.BorderSpacing.Left = widestLabel + EditLeftSpacing

 parentControl.Visible = true
 return T
end

Options = Class(function (self,button,title,trainername)
  self.OptionsButton   = button      -- button object
  self.Title           = title       -- form title
  self.TrainerName     = trainername -- trainername

  self.Variables       = {}          -- table with variables
  self.Form            = nil         -- form
  self.bSaveSettings   = false       -- flag, Do we want to save the settings
  self.ControlList     = {}          -- table, it keeps current Edit controls

  self.OptionsButton.OnClick = function (sender) self:buttonClicked() end
end)

function Options:addVariables(...)
  for i,v in ipairs{...} do

   if v.GreaterThanOr and not tonumber(v.GreaterThanOr) then error('"GreaterThanOr" is not a number') end
   if v.LessThanOr and not tonumber(v.LessThanOr) then error('"LessThanOr" is not a number') end
   if v.Value and not tonumber(v.Value) then error('"Value" is not a number') end

   v.Value = checkingInitData(v.Value, v.GreaterThanOr, v.LessThanOr, v.Int)
   v.DefaultValue = v.Value
   self.Variables[#self.Variables+1] = v
  end
end

function Options:buttonClicked()
  self.OptionsButton.Enabled = false

  self.Form = createForm(false)
  self.Form.Caption        = self.Title
  self.Form.BorderStyle    = 'bsSingle'
  self.Form.Position       = 'poScreenCenter'
  self.Form.ShowInTaskBar  = 'stAlways'
  self.Form.DoubleBuffered = true
  self.Form.AutoSize = true
  self.Form.OnClose = function (sender)
                       self.OptionsButton.Enabled = true
                       sender.hide()
                       return caFree
                      end

  local panel1 = createPanel(self.Form)
        panel1.Align = alClient
        panel1.AutoSize = true
        panel1.OnMouseDown = function (sender) self.Form.dragNow() end -- drag form

  local panel2 = createPanel(self.Form)
        panel2.Align = alBottom
        panel2.ChildSizing.LeftRightSpacing = 6
        panel2.ChildSizing.TopBottomSpacing = 6
        panel2.ChildSizing.HorizontalSpacing  = 6
        panel2.AutoSize = true
        panel2.OnMouseDown = panel1.OnMouseDown


--createControls(container, list, editWidth, EditLeftSpacing, RowSpacing, ColSpacing, perColumn)
  self.ControlList = createControls(panel1, self.Variables, 40, 5, 10, 10)


  local button1 = createButton(panel2)
        button1.Caption = 'Apply'
        button1.Align = alLeft
        button1.AutoSize = true
        button1.Left=0
        button1.Hint = 'Immediately applies new valid values. Some cheats may require re-enabling.'
        button1.ShowHint = true

  local button2 = createButton(panel2)
        button2.Caption = 'Reset Settings'
        button2.Align = alLeft
        button2.AutoSize = true
        button2.Left=1
        button2.Hint = 'Use defualt values'
        button2.ShowHint = true

  local button3 = createCheckBox(panel2)
        button3.Caption = 'Save these settings as default'
        button3.Align = alLeft
        button3.AutoSize = true
        button3.Left=2
        button3.Hint = 'Settings will be saved on program exit'
        button3.ShowHint = true

        button1.OnClick =
          function (sender)
           for i,v in ipairs(self.Variables) do
            local newValue = getControlTextAsNumber(self.ControlList[i], v.GreaterThanOr, v.LessThanOr, v.Int)
            v.Value = newValue or v.Value
           end
          end

        button2.OnClick =
          function (sender)
            for i,v in ipairs(self.Variables) do
              --v.Value = v.DefaultValue
              self.ControlList[i].Text  = v.DefaultValue
              self.ControlList[i].Color = 0x20000000 -- clDefault
              self.ControlList[i].ShowHint = false
              customRepaint(self.ControlList[i])
            end
          end

        button3.OnClick =
          function (sender)
           self.bSaveSettings = sender.Checked
          end


  self.Form.show()
end

function Options:saveSettings()
  if self.bSaveSettings == false then return end
  if #self.Variables==0 then return end

  settings = getSettings(self.TrainerName)
  for _,v in ipairs(self.Variables) do
    settings.Value[v.VarName] = v.Value
  end
  settings.destroy()
end

function Options:loadSettings()
  if #self.Variables==0 then return end

  settings = getSettings(self.TrainerName)
  for _,v in ipairs(self.Variables) do
    local val = settings.Value[v.VarName]
    if val~='' then v.Value = val end
  end
  settings.destroy()
end
