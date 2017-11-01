local files = { "MonoUtility.LUA", "MonoSearch.LUA" }
for i,fileName in ipairs(files) do
  local tableFile = findTableFile(fileName)
  if tableFile then tableFile.saveToFile(fileName)
end

dofile("MonoSearch.LUA") -- has require("MonoUtility.LUA") in it 