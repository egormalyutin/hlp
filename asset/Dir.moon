current = (...)

THREAD_FILE_NAME      =  (...)\gsub("%.[^%..]+$", "")\gsub("%.", "/") .. "/dir-thread.lua"

local threadFile
if love.filesystem
	threadFile = love.filesystem.read THREAD_FILE_NAME
else
	threadFile = THREAD_FILE_NAME

load = (path) ->
	succ, loaded = pcall require, path
	unless succ
		LC_PATH = current .. '.' .. path
		succ, loaded = pcall require, LC_PATH
		unless succ
			LC_PATH =  current\gsub("%.[^%..]+$", "") .. '.' .. path
			succ, loaded = pcall require, LC_PATH
			unless succ
				error loaded

	return loaded

Pool      = load 'Pool'

stub = ->
	obj = {}
	setmetatable obj,
		__index: -> obj
		__call:  ->


-- turn table like
-- n = {a = {b = {c = {d: 1}}}, e: 2}
-- to
-- f = {{key = 'd', value = 1, obj = <c>}, {key = 'e', value = 2, obj = <n>}}
flat = (obj) ->
	worker = (obj, result) ->
		for key, value in pairs obj
			if type(value) == 'table'
				worker value, result
			else
				table.insert result, { :key, :obj, :value }

	r = {}
	worker obj, r
	return r

assign = (a, b) ->
	for name, value in pairs b
		a[name] = value

class Dir
	new: (@_settings) =>
		assert @_settings, 'Settings is nil!'
		assert @_settings.root, 'Rootdir must be specified!'

		@_settings.ignored or= @_settings.ignore

		if type(@_settings.ignored) ~= 'table'
			if @_settings.ignored == nil
				@_settings.ignored = {}
			else
				@_settings.ignored = {@_settings.ignored}


		@_pool = Pool!

		@tree   = {}
		@assets = @tree

		@_onload = {}

		@_phase = 0

		@loaded = false

		@_resources = 0

	_loaded: (data) =>
		@_resources -= 1
		on data for on in *@_onload
		if @_resources <= 0
			@loaded = true

	update: =>
		if @_phase == 2
			@_pool\update!

		else if @_phase == 1
			data = @_channel\pop!
			err  = @_thread\getError!

			error err if err

			if data
				assign @tree, data
				@assets = @tree

				-- flatify tree
				flt = flat @tree

				if #flt <= 0
					@_loaded!

				for obj in *flt
					-- add resoruce
					@_resources += 1

					-- remove extension from name
					key = obj.key\gsub("%.[^%..]+$", "")

					-- set number if name is number
					if tonumber(key) ~= nil
						key = tonumber key

					-- load
					@_pool\load obj.value, obj.obj, key, (data) -> @_loaded data

					-- remove original file
					obj.obj[obj.key] = nil

				@_phase = 2

		else
			@_thread  = love.thread.newThread threadFile
			@_channel = love.thread.getChannel 'asset-dir'
			@_thread\start @_settings.root, 'asset-dir', @_settings.ignored
			@_phase = 1
