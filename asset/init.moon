--- Asynchronous asset loading.
-- @module hlp.asset

THREAD_FILE_NAME = (...)\gsub("%.", "/") .. "/thread.lua"

current = (...)

load = (path) ->
	succ, loaded = pcall require, path
	unless succ
		LC_PATH = current .. '.' .. path
		succ, loaded = pcall require, LC_PATH
		unless succ
			LC_PATH = current\gsub("%.[^%..]+$", "") .. '.' .. path
			succ, loaded = pcall require, LC_PATH
			unless succ
				error loaded

	return loaded

loaders = load 'loaders'

getExt = (name) ->
	name\match "[^.]+$"


channelNum = 0

cache = {}

new = (path) ->
	CHANNEL_NAME = "load-channel-" .. channelNum
	channelNum += 1
	thread  = love.thread.newThread  THREAD_FILE_NAME
	channel = love.thread.getChannel CHANNEL_NAME

	ext = getExt path 

	thread\start path, ext, CHANNEL_NAME, current
	loader = loaders[ext]

	assert loader, 'Not found loader for format "' .. ext .. '"!'

	local data

	return ->
		unless data
			err = thread\getError!
			error err if err
			data = channel\pop!
			if data
				data = loader.master data
			else
				return false

		return data

--- Asynchronous loader. On first call, it starts new LÖVE Thread (which loads resource and sends it back to mester thread) and returns false. On next calls, if resource isn't loaded, it returns false; else, if resource is loaded, it returns resource (can be FileData, Image, Font, Audio, Video or Shader.)
-- @function asset
-- @string path Path to resource.
-- @return False or loaded resource.
-- @export
asset = (path) ->
	if cache[path]
		return cache[path]()
	else
		cache[path] = new path
		return cache[path]()

fonts = {}
sep = love.timer.getTime! * 2 

--- Load font asynchronously.
-- @function asset.font
-- @string path Path to font.
-- @int size Size of font.
-- @return False or loaded resource, same as `asset`.
font = (path, size) ->
	name = path .. sep .. size
	if (fonts[name] == nil) or (fonts[name] == false)
		fonts[name] = asset path
		return false

	elseif type(fonts[name]) == 'function'
		fonts[name] = fonts[name] size

	return fonts[name]


obj = :asset, :font
mt = setmetatable obj, __call: (...) => asset ...
return mt