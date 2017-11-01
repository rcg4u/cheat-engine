--------------------------------------------------------------------------------
----------------  Cheat Engine LUA_Engine Bak File     -------------------------
--------------------------------------------------------------------------------
---- AutoRun on Start Up

local mScript = getLuaEngine().Component[11]
local CE_D = getCheatEngineDir()
local FileToCheck = CE_D..[[Lua_Bak\Dir_Check.txt]]
local FileToOpen = io.open (FileToCheck)
local CE_Open_Time = (os.date ("%c"))
local Fix = string.gsub (CE_Open_Time, "/", ".")
local Time = string.gsub (Fix, ":", ".")

    if FileToOpen == nil
     then
     -- print('No File Exist')
     local Chr = [[chdir XXX && mkdir Lua_Bak]]
     local DirMake = string.gsub(Chr,"XXX",getCheatEngineDir())
     os.execute(DirMake)
     local f = io.open(FileToCheck,"w")
     f:write("This file is to check if directory exists.")
     f:close()
    end

--------------------------------------------------------------------------------


local function Write_Bak()
    local Bak = CE_D..[[Lua_Bak\]]..Time..".bak"

    local f = io.open(Bak,'w')

        for l=0, mScript.Lines.Count do
         f:write(mScript.Lines[l].."\n")
        end

    f:close()

end --Write_Bak


mScript.OnChange = Write_Bak
