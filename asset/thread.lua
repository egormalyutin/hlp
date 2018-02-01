local path, ext, id, channel, LOADERS_PATH = ...
local loaders = require(LOADERS_PATH)
channel = love.thread.getChannel(channel)
local loader, resource
if loaders[ext] then
  loader = loaders[ext]
  resource = loader.thread(path)
end
if resource then
  return channel:push({
    id = id,
    resource = resource,
    success = true
  })
else
  return channel:push({
    id = id,
    error = 'Failed to load resource ' .. path,
    success = false
  })
end
