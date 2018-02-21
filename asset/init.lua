local THREAD_FILE_NAME = (...):gsub("%.", "/") .. "/thread.lua"
local current = (...)
local load
load = function(path)
  local succ, loaded = pcall(require, path)
  if not (succ) then
    local LC_PATH = current .. '.' .. path
    succ, loaded = pcall(require, LC_PATH)
    if not (succ) then
      LC_PATH = current:gsub("%.[^%..]+$", "") .. '.' .. path
      succ, loaded = pcall(require, LC_PATH)
      if not (succ) then
        error(loaded)
      end
    end
  end
  return loaded
end
local loaders = load('loaders')
local getExt
getExt = function(name)
  return name:match("[^.]+$")
end
local channelNum = 0
local cache = { }
local new
new = function(path)
  local CHANNEL_NAME = "load-channel-" .. channelNum
  channelNum = channelNum + 1
  local thread = love.thread.newThread(THREAD_FILE_NAME)
  local channel = love.thread.getChannel(CHANNEL_NAME)
  local ext = getExt(path)
  thread:start(path, ext, CHANNEL_NAME, current)
  local loader = loaders[ext]
  assert(loader, 'Not found loader for format "' .. ext .. '"!')
  local data
  return function()
    if not (data) then
      local err = thread:getError()
      if err then
        error(err)
      end
      data = channel:pop()
      if data then
        data = loader.master(data)
      else
        return false
      end
    end
    return data
  end
end
local asset
asset = function(path)
  if cache[path] then
    return cache[path]()
  else
    cache[path] = new(path)
    return cache[path]()
  end
end
local fonts = { }
local sep = love.timer.getTime() * 2
local font
font = function(path, size)
  local name = path .. sep .. size
  if (fonts[name] == nil) or (fonts[name] == false) then
    fonts[name] = asset(path)
    return false
  elseif type(fonts[name]) == 'function' then
    fonts[name] = fonts[name](size)
  end
  return fonts[name]
end
local obj = {
  asset = asset,
  font = font
}
local mt = setmetatable(obj, {
  __call = function(self, ...)
    return asset(...)
  end
})
return mt
