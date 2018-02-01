-- consts
LOADER_CHANNEL_PREFIX = "loader-channel-"
THREAD_FILE_NAME      =  (...)\gsub("%.[^%..]+$", "")\gsub("%.", "/") .. "/thread.lua"

----------------------------------------------

current = (...)

load = (path) ->
	local LC_PATH
	succ, loaded = pcall require, LC_PATH
	unless succ
		LC_PATH = current .. '.' .. path
		succ, loaded = pcall require, LC_PATH
		unless succ
			LC_PATH =  current\gsub("%.[^%..]+$", "") .. '.' .. path
			succ, loaded = pcall require, LC_PATH
			unless succ
				error loaded

	return loaded, LC_PATH

loaders, LOADERS_PATH = load 'loaders'

----------------------------------------------

-- find thread script
local threadFile
if love.filesystem
	threadFile = love.filesystem.read THREAD_FILE_NAME
else
	threadFile = THREAD_FILE_NAME

----------------------------------------------

-- helpers
getExt = (path) ->
	return path\match "[^.]+$"

----------------------------------------------

i = 0

----------------------------------------------

class AssetPool
	new: =>
		-- get channel name
		@_CHANNEL_NAME = LOADER_CHANNEL_PREFIX .. i
		i += 1

		-- init
		@_channel = love.thread.getChannel @_CHANNEL_NAME
		@_threads = {}
		@_updates = {}
		@_tid = 1

	load: (path, obj, key, cb = ->) =>
		-- get extname
		ext = getExt path

		-- find loader
		local loader
		if loaders[ext]
			loader = loaders[ext]
		else
			error 'Not found loader for format "' .. ext .. '"!'

		-- init new thread
		thread = love.thread.newThread THREAD_FILE_NAME
		table.insert @_threads, thread

		-- start
		thread\start path, ext, @_tid, @_CHANNEL_NAME, LOADERS_PATH

		sf = @
		ret =
			loaded: false
			resource: nil
			data:     nil

		update = (data) ->
			-- send data
			if data and data.success
				rs = loader.master data.resource
				ret.loaded   = true
				ret.resource = rs
				ret.data     = rs
				if obj ~= nil
					obj[key] = rs

			else if data and data.error
				error data.error

			cb data

		table.insert @_updates, update

		@_tid += 1
		return ret

	update: =>
		for thread in *@_threads
			err = thread\getError!
			error err if err

		while true
			data = @_channel\pop!
			break unless data

			if @_updates[data.id]
				@_updates[data.id] data

	wait: =>


return AssetPool
