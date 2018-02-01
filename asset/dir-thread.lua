local path, CHANNEL, ignored = ...
local channel = love.thread.getChannel(CHANNEL)
local isDir = love.filesystem.isDirectory
local isIgnored
isIgnored = function(a)
  for _index_0 = 1, #ignored do
    local pattern = ignored[_index_0]
    if a:match(pattern) ~= nil then
      return true
    end
  end
  return false
end
local scan
scan = function(path)
  local worker
  worker = function(dir, result, root)
    local files = love.filesystem.getDirectoryItems(dir)
    for name, file in ipairs(files) do
      local filePath = dir .. '/' .. file
      if not (isIgnored(filePath)) then
        if isDir(filePath) then
          result[file] = { }
          worker(filePath, result[file], root)
        else
          result[file] = filePath
        end
      end
    end
  end
  local r = { }
  worker(path, r, path)
  return r
end
local toLoad = { }
local tbl = scan(path)
return channel:push(tbl)
