local path, format, CHANNEL_NAME, current = ...
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
local channel = love.thread.getChannel(CHANNEL_NAME)
local data = loaders[format].thread(path)
return channel:push(data)
