if luasymbols then
  unregisterSymbolLookupCallback(luasymbols)
  luasymbols=nil
end
luasymbols=registerSymbolLookupCallback(function(str)
  return tonumber(_G[str])
end, slFailure)
