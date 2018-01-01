function Only_IF_64_CE_xcv()

  local ok1=autoAssemble([[
aobscanmodule(aobAceBoxList_High_Add,cheatengine-x86_64.exe,        48 8B 88 00 01 00 00 BA 08 00 00 80 E8)
aobscanmodule(aobCheck_Active_Color_xcv,cheatengine-x86_64.exe,     48 8B 8A 00 01 00 00 BA FF 00 00 00)
aobscanmodule(aobCheck_Active_High_Color_xcv,cheatengine-x86_64.exe,48 8B 8A 00 01 00 00 BA 00 00 00 00)
aobscanmodule(aobBase_Selection_Color_xcv,cheatengine-x86_64.exe,   48 8B 8A 10 01 00 00 BA 0D 00 00 80)
aobscanmodule(aobDouble_Selection_Color_xcv,cheatengine-x86_64.exe, 48 8B 8A 10 01 00 00 BA 02 00 00 80)

label(AceBoxList_High_Add)
label(Check_Active_Color_xcv)
label(Check_Active_High_Color_xcv)
label(Base_Selection_Color_xcv)
label(Double_Selection_Color_xcv)
registersymbol(AceBoxList_High_Add)
registersymbol(Check_Active_Color_xcv)
registersymbol(Check_Active_High_Color_xcv)
registersymbol(Base_Selection_Color_xcv)
registersymbol(Double_Selection_Color_xcv)

aobAceBoxList_High_Add+8:
AceBoxList_High_Add:

aobCheck_Active_Color_xcv+8:
Check_Active_Color_xcv:

aobCheck_Active_High_Color_xcv+8:
Check_Active_High_Color_xcv:

aobBase_Selection_Color_xcv+8:
Base_Selection_Color_xcv:

aobDouble_Selection_Color_xcv+8:
Double_Selection_Color_xcv:
]],true)

  local ok2=autoAssemble([[
aobscanregion(aobAceBoxList_Norm_Add,AceBoxList_High_Add,AceBoxList_High_Add+100,48 8B 88 00 01 00 00 BA 08 00 00 80 E8)

label(AceBoxList_Norm_Add)
registersymbol(AceBoxList_Norm_Add)

aobAceBoxList_Norm_Add+8:
AceBoxList_Norm_Add:
]],true)

  if not (ok1 and ok2) then return end -- signatures not found, exit

  local AL = getAddressList()


  local Windows_Pick_xcv = getMainForm().findComponentByName("ColorDialog1")

  local Form_For_List_Color = createForm(false)
  Form_For_List_Color.Caption = "Address List Companion"
  Form_For_List_Color.Position = poMainFormCenter
  Form_For_List_Color.Height = 289
  Form_For_List_Color.Width = 291
  Form_For_List_Color.BorderIcons = "[biSystemMenu]"
  Form_For_List_Color.OnClose = function()
                                  Grab_Entry_Color_Timer_xcv.Enabled = false
                                  return caHide
                                end

  local Form_For_List_Color_Panel = createPanel(Form_For_List_Color)
  Form_For_List_Color_Panel.Left = 1
  Form_For_List_Color_Panel.Top = 1
  Form_For_List_Color_Panel.Width = Form_For_List_Color.Width -2
  Form_For_List_Color_Panel.Height = Form_For_List_Color.Height -2
  Form_For_List_Color_Panel.BorderStyle = bsSingle
  Form_For_List_Color_Panel.BevelOuter = bvNone
  Form_For_List_Color_Panel.Color = "0x00f9f9f9"

  local Select_Box_Label_xcv0 = createLabel(Form_For_List_Color_Panel)
  Select_Box_Label_xcv0.Left = 230-2
  Select_Box_Label_xcv0.Top = 10+10+2
  Select_Box_Label_xcv0.Caption = "Secondary:"
  Select_Box_Label_xcv0.Font.Size = 7

-----------------------------------------------------

  local Select_Box_Label_xcv1 = createLabel(Form_For_List_Color_Panel)
  Select_Box_Label_xcv1.Left = 13
  Select_Box_Label_xcv1.Top = 32+10
  Select_Box_Label_xcv1.Caption = "Check Box Color :"

  local Select_Box_xcv1_Panel = createPanel(Form_For_List_Color_Panel)
  Select_Box_xcv1_Panel.Left = 222
  Select_Box_xcv1_Panel.Width = 50
  Select_Box_xcv1_Panel.Height = 20
  Select_Box_xcv1_Panel.Top = 26+10
  Select_Box_xcv1_Panel.BevelOuter = bvNone
  Select_Box_xcv1_Panel.Borderstyle = bsSingle
  Select_Box_xcv1_Panel.OnClick = function ()
                                    if not Windows_Pick_xcv.Execute() then return end
                                    writeIntegerLocal('AceBoxList_High_Add',Windows_Pick_xcv.Color)
                                    Select_Box_xcv1_Panel.Color = Windows_Pick_xcv.Color
                                  end

  local Select_Box_xcv2_Panel = createPanel(Form_For_List_Color_Panel)
  Select_Box_xcv2_Panel.Left = 138
  Select_Box_xcv2_Panel.Width = 50
  Select_Box_xcv2_Panel.Height = 20
  Select_Box_xcv2_Panel.Top = 26+10
  Select_Box_xcv2_Panel.BevelOuter = bvNone
  Select_Box_xcv2_Panel.Borderstyle = bsSingle
  Select_Box_xcv2_Panel.OnClick = function ()
                                    if not Windows_Pick_xcv.Execute() then return end
                                    writeIntegerLocal('AceBoxList_Norm_Add',Windows_Pick_xcv.Color)
                                    Select_Box_xcv2_Panel.Color = Windows_Pick_xcv.Color
                                  end

-----------------------------------------------------

  local Select_Box_Label_xcv2 = createLabel(Form_For_List_Color_Panel)
  Select_Box_Label_xcv2.Left = 13
  Select_Box_Label_xcv2.Top = 32+10+32
  Select_Box_Label_xcv2.Caption = "Check Active Color :"

  local Select_Box_xcv3_Panel = createPanel(Form_For_List_Color_Panel)
  Select_Box_xcv3_Panel.Left = 138
  Select_Box_xcv3_Panel.Width = 50
  Select_Box_xcv3_Panel.Height = 20
  Select_Box_xcv3_Panel.Top = 26+10+32
  Select_Box_xcv3_Panel.BevelOuter = bvNone
  Select_Box_xcv3_Panel.Borderstyle = bsSingle
  Select_Box_xcv3_Panel.OnClick = function ()
                                    if not Windows_Pick_xcv.Execute() then return end
                                    writeIntegerLocal('Check_Active_Color_xcv',Windows_Pick_xcv.Color)
                                    Select_Box_xcv3_Panel.Color = Windows_Pick_xcv.Color
                                  end

  local Select_Box_xcv4_Panel = createPanel(Form_For_List_Color_Panel)
  Select_Box_xcv4_Panel.Left = 222
  Select_Box_xcv4_Panel.Width = 50
  Select_Box_xcv4_Panel.Height = 20
  Select_Box_xcv4_Panel.Top = 26+10+32
  Select_Box_xcv4_Panel.BevelOuter = bvNone
  Select_Box_xcv4_Panel.Borderstyle = bsSingle
  Select_Box_xcv4_Panel.OnClick = function ()
                                    if not Windows_Pick_xcv.Execute() then return end
                                    writeIntegerLocal('Check_Active_High_Color_xcv',Windows_Pick_xcv.Color)
                                    Select_Box_xcv4_Panel.Color = Windows_Pick_xcv.Color
                                  end

-----------------------------------------------------

  local Select_Box_Label_xcv3 = createLabel(Form_For_List_Color_Panel)
  Select_Box_Label_xcv3.Left = 13
  Select_Box_Label_xcv3.Top = 32+10+32+32
  Select_Box_Label_xcv3.Caption = "Selection Color :"

  local Select_Box_xcv5_Panel = createPanel(Form_For_List_Color_Panel)
  Select_Box_xcv5_Panel.Left = 138
  Select_Box_xcv5_Panel.Width = 50
  Select_Box_xcv5_Panel.Height = 20
  Select_Box_xcv5_Panel.Top = 26+10+32+32
  Select_Box_xcv5_Panel.BevelOuter = bvNone
  Select_Box_xcv5_Panel.Borderstyle = bsSingle
  Select_Box_xcv5_Panel.OnClick = function ()
                                    if not Windows_Pick_xcv.Execute() then return end
                                    writeIntegerLocal('Base_Selection_Color_xcv',Windows_Pick_xcv.Color)
                                    Select_Box_xcv5_Panel.Color = Windows_Pick_xcv.Color
                                  end

  local Select_Box_xcv6_Panel = createPanel(Form_For_List_Color_Panel)
  Select_Box_xcv6_Panel.Left = 222
  Select_Box_xcv6_Panel.Width = 50
  Select_Box_xcv6_Panel.Height = 20
  Select_Box_xcv6_Panel.Top = 26+10+32+32
  Select_Box_xcv6_Panel.BevelOuter = bvNone
  Select_Box_xcv6_Panel.Borderstyle = bsSingle
  Select_Box_xcv6_Panel.OnClick = function ()
                                    if not Windows_Pick_xcv.Execute() then return end
                                    writeIntegerLocal('Double_Selection_Color_xcv',Windows_Pick_xcv.Color)
                                    Select_Box_xcv6_Panel.Color = Windows_Pick_xcv.Color
                                  end

-----------------------------------------------------

  local Select_Box_Label_xcv4 = createLabel(Form_For_List_Color_Panel)
  Select_Box_Label_xcv4.Left = 13
  Select_Box_Label_xcv4.Top = 32+10+32+32+32
  Select_Box_Label_xcv4.Caption = "Address List :"

  local Select_Box_xcv7_Panel = createPanel(Form_For_List_Color_Panel)
  Select_Box_xcv7_Panel.Left = 138
  Select_Box_xcv7_Panel.Width = 50
  Select_Box_xcv7_Panel.Height = 20
  Select_Box_xcv7_Panel.Top = 26+10+32+32+32
  Select_Box_xcv7_Panel.BevelOuter = bvNone
  Select_Box_xcv7_Panel.Borderstyle = bsSingle
  Select_Box_xcv7_Panel.OnClick = function ()
                                    if not Windows_Pick_xcv.Execute() then return end
                                    AL.Component[0].BackgroundColor = Windows_Pick_xcv.Color
                                    AL.Component[0].Color = Windows_Pick_xcv.Color
                                    Select_Box_xcv7_Panel.Color = Windows_Pick_xcv.Color
                                  end

-----------------------------------------------------

  local function update_panels_colors_XCV()
    Select_Box_xcv1_Panel.Color = readIntegerLocal('AceBoxList_High_Add')
    Select_Box_xcv2_Panel.Color = readIntegerLocal('AceBoxList_Norm_Add')
    Select_Box_xcv3_Panel.Color = readIntegerLocal('Check_Active_Color_xcv')
    Select_Box_xcv4_Panel.Color = readIntegerLocal('Check_Active_High_Color_xcv')
    Select_Box_xcv5_Panel.Color = readIntegerLocal('Base_Selection_Color_xcv')
    Select_Box_xcv6_Panel.Color = readIntegerLocal('Double_Selection_Color_xcv')
    Select_Box_xcv7_Panel.Color = AL.Component[0].Color
  end

-----------------------------------------------------

  local Batch_Swapper_xcv_Label = createLabel(Form_For_List_Color_Panel)
  Batch_Swapper_xcv_Label.Caption = "             Selected Entry Batch Color Swap:                           \n\n\n\n      "
  Batch_Swapper_xcv_Label.Color = "0x00323239"
  Batch_Swapper_xcv_Label.Font.Color = "0x00ffb0b0"
  Batch_Swapper_xcv_Label.Font.Size = 10
  Batch_Swapper_xcv_Label.Top = 26+10+32+32+32+32+32+5

  local Select_Box_xcv8_Panel = createPanel(Form_For_List_Color_Panel)
  Select_Box_xcv8_Panel.Left = 80-20-10
  Select_Box_xcv8_Panel.Width = 50
  Select_Box_xcv8_Panel.Height = 50
  Select_Box_xcv8_Panel.Top = 26+10+32+32+32+48+40+3
  Select_Box_xcv8_Panel.Color = 0x00FF00FF
  Select_Box_xcv8_Panel.BevelOuter = bvNone
  Select_Box_xcv8_Panel.Borderstyle = bsSingle

  local Select_Box_xcv9_Panel = createPanel(Form_For_List_Color_Panel)
  Select_Box_xcv9_Panel.Left = 80-20-10+100+45
  Select_Box_xcv9_Panel.Width = 50
  Select_Box_xcv9_Panel.Height = 50
  Select_Box_xcv9_Panel.Top = 26+10+32+32+32+48+40+3
  Select_Box_xcv9_Panel.Color = "0x80000008"
  Select_Box_xcv9_Panel.BevelOuter = bvNone
  Select_Box_xcv9_Panel.Borderstyle = bsSingle
  Select_Box_xcv9_Panel.OnClick = function ()
                                    if not Windows_Pick_xcv.Execute() then return end

                                    for j=0,AL.Count-1 do
                                     if AL.getMemoryRecord(j).Color == Select_Box_xcv8_Panel.Color
                                     then
                                      AL.getMemoryRecord(j).Color = Windows_Pick_xcv.Color
                                      Select_Box_xcv9_Panel.Color = Windows_Pick_xcv.Color
                                     end
                                    end
                                  end

  Grab_Entry_Color_Timer_xcv = createTimer(Form_For_List_Color_Panel)
  Grab_Entry_Color_Timer_xcv.Interval = 100
  Grab_Entry_Color_Timer_xcv.Enabled = false
  Grab_Entry_Color_Timer_xcv.OnTimer = function ()
                                         if AL.SelectedRecord == nil then
                                           Select_Box_xcv8_Panel.Color = 0x00FF00FF
                                         else
                                           Select_Box_xcv8_Panel.Color = AL.SelectedRecord.Color
                                         end
                                       end

------------------------------------------------------------
------ Pop Up Entries
-----------------------------------------------------------


  local List_Popup_xcv = getMainForm().findComponentByName("PopupMenu2")
  local Entry_Space_xcv = 0
  for x = 1,List_Popup_xcv.Items.Count-1 do
   if List_Popup_xcv.Items[x].Name == "N1" then Entry_Space_xcv = x end
  end

  ----- Separate
  local Sep_xcv = createMenuItem(List_Popup_xcv)  ---- Last Separate
  Sep_xcv.Caption= "-"
  Sep_xcv.Name = "Seperator_xcv"
  List_Popup_xcv.Items.insert(Entry_Space_xcv+1,Sep_xcv) --- uses default Divider



  switch_List_Compact_xcv = true   ---- Full Mode by default
  local Com_xcv = createMenuItem(List_Popup_xcv)  ---- Compact Mode
  Com_xcv.Caption= "Compact Mode"
  Com_xcv.Name = "Compact_Toggle"
  Com_xcv.OnClick = function ()
                      if switch_List_Compact_xcv == true then
                        Com_xcv.Caption= "Full Mode"
                      else
                        Com_xcv.Caption= "Compact Mode"
                      end
                      switch_List_Compact_xcv = not switch_List_Compact_xcv
                      getMainForm().Splitter1.Visible = switch_List_Compact_xcv
                      getMainForm().Panel4.Visible = switch_List_Compact_xcv
                      getMainForm().Panel5.Visible = switch_List_Compact_xcv
                    end

  List_Popup_xcv.Items.insert(Entry_Space_xcv+1,Com_xcv) --- uses default Divider

  local Pick_xcv = createMenuItem(List_Popup_xcv)   --- Set List Colors
  Pick_xcv.Caption= "List Companion"
  Pick_xcv.OnClick = function ()
                       Form_For_List_Color.Show()
                       Grab_Entry_Color_Timer_xcv.Enabled = true
                       update_panels_colors_XCV()
                     end
  Pick_xcv.Name = "Choose_List_Colors"
  List_Popup_xcv.Items.insert(Entry_Space_xcv+1,Pick_xcv) --- uses default Divider


--------------------------------------------------------------------------------------------
---------------  Load Saved Default Colors -------------------------------------------------
--------------------------------------------------------------------------------------------
  local function Load_ACE_XCV_COLORS()
    local file = io.open(getCheatEngineDir().."autorun\\Color_Defaults.ini","r")
    if file~=nil then
      local colorTable = {}
      for line in file:lines() do
        colorTable[1+#colorTable] = line
      end
      writeIntegerLocal('AceBoxList_Norm_Add',colorTable[1])
      writeIntegerLocal('AceBoxList_High_Add',colorTable[2])
      writeIntegerLocal('Base_Selection_Color_xcv',colorTable[3])
      writeIntegerLocal('Double_Selection_Color_xcv',colorTable[4])
      writeIntegerLocal('Check_Active_Color_xcv',colorTable[5])
      writeIntegerLocal('Check_Active_High_Color_xcv',colorTable[6])

      getAddressList().Component[0].Color = colorTable[7]
      getAddressList().Component[0].BackgroundColor = colorTable[7]

      file:close()
      update_panels_colors_XCV()
    end
  end

  local function Save_ACE_XCV_COLORS()
    local file = io.open(getCheatEngineDir().."autorun\\Color_Defaults.ini","w")
    file:write(readIntegerLocal('AceBoxList_Norm_Add')..'\n')
    file:write(readIntegerLocal('AceBoxList_High_Add')..'\n')
    file:write(readIntegerLocal('Base_Selection_Color_xcv')..'\n')
    file:write(readIntegerLocal('Double_Selection_Color_xcv')..'\n')
    file:write(readIntegerLocal('Check_Active_Color_xcv')..'\n')
    file:write(readIntegerLocal('Check_Active_High_Color_xcv')..'\n')
    file:write(getAddressList().Component[0].Color)
    file:close()
  end

  local Save_Xcv_Button = createButton(Form_For_List_Color)
  Save_Xcv_Button.Left = 222 - 55 - 10
  Save_Xcv_Button.Width = 50+5
  Save_Xcv_Button.Height = 20
  Save_Xcv_Button.Top = 175
  Save_Xcv_Button.Caption = "Save"
  Save_Xcv_Button.OnClick = Save_ACE_XCV_COLORS

  local Load_Xcv_Button = createButton(Form_For_List_Color)
  Load_Xcv_Button.Left = 222
  Load_Xcv_Button.Width = 50+5
  Load_Xcv_Button.Height = 20
  Load_Xcv_Button.Top = 170+5
  Load_Xcv_Button.Caption = "Load"
  Load_Xcv_Button.OnClick =  Load_ACE_XCV_COLORS

  local Auto_Load = createCheckBox(Form_For_List_Color)
  Auto_Load.Left = 13
  Auto_Load.Top = 170+5+2
  Auto_Load.Caption = "Auto Load OnStartup"
  Auto_Load.Color = "0x0045ff45"

  local file = io.open(getCheatEngineDir().."autorun\\Color_Defaults_Auto.ini","r")
  if file~=nil then
    for line in file:lines() do
       if line == "true" then
         -- print('Auto Load_Xcv_ Active')
         Auto_Load.Checked = true
         Load_ACE_XCV_COLORS()  --- Load Colors
       end -- if true
    end -- line read
    file:close()
  end

  Auto_Load.OnChange =
    function ()
      local file = io.open(getCheatEngineDir().."autorun\\Color_Defaults_Auto.ini","w")
      file:write(tostring(Auto_Load.Checked))
      file:close()
    end

---------------------------------------------------------------------------------------------------------------------------
----------------   Web Check ----------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------

  local function Web_Check_ADD_List_Companion()
    local grabinternet=getInternet()
    local ADD_Companion_xcv = grabinternet.getURL("https://www.dropbox.com/s/tur8hv61z5af98j/AddressListCompanion_Version.txt?dl=1")
    local ADD_Companion_xcv_Update = grabinternet.getURL("https://www.dropbox.com/s/nz84o9rq90vb2lj/AddressListCompanion_Updates.txt?dl=1")
    grabinternet.destroy()

    if (ADD_Companion_xcv~=nil) and (ADD_Companion_xcv ~= "Version 1.0.2") then
      if messageDialog("New Address List Companion Available :   "..ADD_Companion_xcv..
                       "\n\n"..ADD_Companion_xcv_Update..
                       "\n\nDo you wish to visit the forum Post",mtInformation,mbYes,mbNo) == mrYes then
        shellExecute("http://forum.cheatengine.org/viewtopic.php?p=5683526#5683526")
      end
    end
  end

  --createNativeThread(Web_Check_ADD_List_Companion)
  -- I disabled web check because it is modified AddressListCompanion extension
  -- I do not own above dropbox account

end -- end of "Only_IF_64_CE_xcv" function

if cheatEngineIs64Bit() == true then
  Only_IF_64_CE_xcv()
end

