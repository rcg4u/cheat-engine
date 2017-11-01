--[[
    NFOWindow Object for Cheat Engine 6.4
    requirements: CE6.4
    ------------------------------------------------------------
    (c) 2014 mgr.inz.Player

    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND.
    For God's sake, do not touch anything here :-D
]]--

NFOWindow = {}

function NFOWindow:Init(arg)

  self.windowCaption  = arg.windowCaption or 'NFO Window by mgr.inz.Player'
  self.fontSize       = arg.fontSize      or 12
  self.scrollLines    = arg.scrollLines   or 9

  if not arg.nfo then arg.nfo = 'nfo text is mandatory, you forgot it' end
  if not arg.windowMaximumHeight then arg.windowMaximumHeight = 600 end

  arg.nfo = arg.nfo:gsub('\r',' ')

  -- PREPARE nfoTEXT table
  local longestLine = ''
  self.nfoTEXT = {}
  table.insert(self.nfoTEXT, ansiToUtf8(' ') )
  for w in string.gmatch (arg.nfo,"[^\n]+") do
    table.insert(self.nfoTEXT, ansiToUtf8(w) )
    if #longestLine < #w then longestLine = w end
  end
  table.insert(self.nfoTEXT,' ')
  table.insert(self.nfoTEXT,' ')



  -- DETERMINE line width, line height, total height
  local tmpImage = createImage(nil)
        tmpImage.Canvas.Font.Name = 'Terminal'
        tmpImage.Canvas.Font.Size = self.fontSize
        tmpImage.Canvas.Font.CharSet= 255 --'OEM_CHARSET'

  local lineWidth   = tmpImage.Canvas.getTextWidth(longestLine)
  local lineHeight  = tmpImage.Canvas.getTextHeight(longestLine)
  tmpImage.destroy(); tmpImage=nil

  self.lineHeight     = lineHeight
  self.totalHeight    = lineHeight * (#self.nfoTEXT)
  self.scrollDistance = lineHeight * self.scrollLines


  -- DETERMINE window size
  self.CW = lineWidth + 10
  self.CH = self.totalHeight > arg.windowMaximumHeight
            and arg.windowMaximumHeight or self.totalHeight

  if self.CW < 200 then self.CW=200 end

  --assign event to given button
  if arg.button then
    self.Button = arg.button
    self.Button.Enabled = true
    self.Button.OnClick = function () self:ShowWindow() end
  end
end

function NFOWindow:DestroyAndNil()
  if self.Bitmap~=nil then self.Bitmap.destroy(); self.Bitmap=nil end
  if self.Form~=nil   then self.Form.destroy();     self.Form=nil end
end

function NFOWindow:ShowWindow()

  if self.Button then self.Button.Enabled = false end

  --remove previously created objects (if any)
  self:DestroyAndNil()

  -- MAIN WINDOW ATTRIBUTES, CAPTION and EVENTS
  self.Form = createForm(false)
  self.Form.setSize(self.CW, self.CH)
  self.Form.Caption        = self.windowCaption
  self.Form.Borderstyle    = 'bsToolWindow'
  self.Form.Position       = 'poScreenCenter'
  self.Form.ShowInTaskBar  = 'stAlways'
  self.Form.DoubleBuffered = true
  self.Form.OnClose = function ()
                       if self.Button then self.Button.Enabled = true end
                       self:DestroyAndNil()
                      end

  local customColors = {
  0x000000,0x060600,0x0E0C00,0x171300,0x221C00,0x2D2500,0x3A2F00,0x473900,
  0x554500,0x634F00,0x725C00,0x816800,0x907400,0x9E7F00,0xAC8C00,0xB99700,
  0xC6A400,0xD2AE00,0xDDB900,0xE7C400,0xEFCD00,0xF5D600,0xFADD00,0xFEE400,
  0xFFEA00,0xFFEE04,0xFCF109,0xFAF410,0xF6F717,0xF1FA1E,0xEBFC27,0xE3FC30,
  0xDCFC39,0xD3FC43,0xCBFC4E,0xC1FC58,0xB8FC63,0xADFC6E,0xA2FC79,0x97FC84,
  0x8CFC8F,0x81FC9A,0x76FCA4,0x6AFCAF,0x5FFCB9,0x54FCC3,0x4AFCCC,0x3FFCD5,
  0x36FCDD,0x2CFCE5,0x24FCEB,0x1CFCF1,0x15FCF6,0x0EFCFA,0x08FCFC,0x04FCFF,
  0x00FCFF,0x00FCFE,0x00F9FD,0x00F8FB,0x00F7F7,0x00F5F3,0x00F3EE,0x00F1E8,
  0x00EEE0,0x00ECDA,0x00E9D1,0x00E7C9,0x00E5C0,0x00E1B7,0x00DEAE,0x00DBA4,
  0x00D99A,0x00D690,0x03D386,0x05D07B,0x08CD71,0x0BCA66,0x0EC85C,0x12C552,
  0x14C349,0x19C03E,0x1BBE36,0x20BC2D,0x23BB25,0x26B91E,0x2BB716,0x2FB60F,
  0x32B50A,0x36B405,0x3AB401,0x3EB400,0x41B400,0x46B500,0x4BB500,0x50B600,
  0x55B800,0x5AB900,0x5FBA00,0x66BC00,0x6CBE00,0x72C000,0x79C200,0x7FC400,
  0x86C600,0x8BC900,0x92CB00,0x99CD00,0xA0D000,0xA9D300,0xB4D700,0xBDDA00,
  0xC7DD00,0xD0E100,0xD8E300,0xE0E500,0xE8E700,0xEFE900,0xF5EA00,0xFAEA00,
  0xFFEA00,0xFFE900,0xFFE700,0xFFE500,0xFFE200,0xFFDE00,0xFFDA00,0xFFD500,
  0xFFD000,0xFFCB00,0xFFC700,0xFFC200,0xFFC000,0xFFBD00,0xFFBA00,0xFFB700,
  0xFFB400,0xFFB100,0xFFAE00,0xFFAC00,0xFFA900,0xFFA700,0xFFA400,0xFFA200,
  0xFFA000,0xFF9E00,0xFF9C00,0xFF9A00,0xFF9800,0xFF9800,0xFF9600,0xFE9405,
  0xFE940A,0xFF9311,0xFE9318,0xFF9220,0xFF9229,0xFF9232,0xFF923C,0xFF9346,
  0xFF9351,0xFF945C,0xFF9567,0xFF9572,0xFF967D,0xFF9689,0xFF9697,0xFF96A7,
  0xFF96B7,0xFE96C5,0xFD96D4,0xFC96DF,0xF896EB,0xF596F3,0xF196F9,0xEC95FD,
  0xE691FF,0xE18DFE,0xDA8AFB,0xD285F6,0xCA7FEF,0xC07AE6,0xB673DD,0xAB6CD2,
  0xA066C6,0x945EB9,0x8957AC,0x7D4F9E,0x714890,0x654080,0x5A3972,0x4F3263,
  0x442B55,0x382447,0x2E1E3A,0x24172D,0x1B1122,0x130C16,0x0C080E,0x000000}

  -- CREATE NICE RAINBOW
  local rainbowImage = createImage(self.Form)
        rainbowImage.setSize(1,200)
        rainbowImage.Align = alClient
        rainbowImage.Stretch = true
  local drawPixel = rainbowImage.Canvas.setPixel

  for i=1,200 do drawPixel(0,i-1,customColors[i]) end

  -- create bitmap
  self.Bitmap = createBitmap(self.CW, self.totalHeight)
  self.Bitmap.TransparentColor = 0x800080
  self.Bitmap.Transparent      = true
  self.Bitmap.Canvas.Font.Name = 'Terminal'
  self.Bitmap.Canvas.Font.Size = self.fontSize
  self.Bitmap.Canvas.Font.CharSet= 255 --'OEM_CHARSET'
  self.Bitmap.Canvas.Font.Color = 0x800080
  self.Bitmap.Canvas.Brush.Color = 0x000000

  -- draw text
  for i,v in ipairs(self.nfoTEXT) do
    local Y = self.lineHeight*(i-1)
    self.Bitmap.Canvas.textOut(5,Y,v)
  end

  -- CREATE PAINTBOX
  self.PaintBox = createPaintBox(self.Form)
  self.PaintBox.Align = alClient
  self.PaintBox.OnPaint = function () self:PaintState() end
  self.PaintBox.OnMouseDown = function () self.Form.dragNow() end -- drag form
  self.Form.show()

  self.scrollTimer = createTimer(self.Form,false)
  self.scrollTimer.OnTimer  = function () self:scrollOnTimer() end
  self.scrollTimer.Interval = 10

  self.PaintBox.OnMouseWheelDown = function () self:scrollDown() end
  self.PaintBox.OnMouseWheelUp   = function () self:scrollUp()   end

  self.Form.OnKeyDown =
      function (sender, key)
       if     key == 27 then  -- ESC key to exit
         self.Form.OnClose(self.Form)
       elseif key == 33 or key == 38 then -- PGUP and UP
         self:scrollUp()
       elseif key == 34 or key == 40 then -- PGDOWN and DOWN
         self:scrollDown()
       end

       return 0
      end

  self.DestY    = 0
  self.currentY = 0
end

function NFOWindow:PaintState()
  local canvas = self.PaintBox.Canvas
  local r=canvas.getClipRect()

  canvas.drawWithMask(r.Left,  r.Top,    -- dest
                      r.Right, r.Bottom, -- dest
                      self.Bitmap,                       -- source
                      r.Left,  r.Top    - self.currentY, -- source
                      r.Right, r.Bottom - self.currentY) -- source

  local cw = self.CW
  local ch = self.CH
  local th = self.totalHeight
  local  y = self.currentY

  local height = ch*ch/th
  local top    = (ch-height)*(y/(ch-th))

  -- set canvas Pen color
  canvas.Pen.Color = 0xAAAAAA
  canvas.Pen.Width = 5

  canvas.line(cw-5  ,  top           +7,
              cw-5  ,  top+height-1  -7)
end

function NFOWindow:changeDestY(amount)
  local y = self.currentY + amount
        y = math.min(0, math.max(y, self.CH-self.totalHeight) )

  self.DestY = y

  if not self.scrollTimer.Enabled
    then self.scrollTimer.Enabled = true end
end

function NFOWindow:scrollUp()
  local speed = self.scrollTimer.Enabled and 3 or 1
  self:changeDestY(self.scrollDistance*speed)
end

function NFOWindow:scrollDown()
  local speed = self.scrollTimer.Enabled and 3 or 1
  self:changeDestY(-self.scrollDistance*speed)
end

function NFOWindow:scrollOnTimer()
  local step = (self.DestY-self.currentY) * 0.05

  if step*step<0.0001 then
    self.currentY = ( self.DestY == 0 ) and 0 or self.DestY
    self.scrollTimer.Enabled = false
  else
    self.currentY = self.currentY + step
  end

  -- you can remove this IF
  if self.CH~=self.totalHeight then
    self.Form.Caption = self.windowCaption..
                        '   position: '..
                        math.floor(self.currentY / (self.CH-self.totalHeight) * 100 )..'%'
  end

  self.PaintBox.repaint()
end
