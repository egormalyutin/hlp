path, ext, id, channel, LOADERS_PATH = ...

loaders = require LOADERS_PATH

channel = love.thread.getChannel(channel)

local loader, resource

if loaders[ext]
	loader = loaders[ext]
	resource = loader.thread path

if resource
	channel\push 
		:id
		:resource
		success: true
else
	channel\push 
		:id
		error: 'Failed to load resource ' .. path
		success: false
