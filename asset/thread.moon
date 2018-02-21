path, format, CHANNEL_NAME, current = ...

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
channel = love.thread.getChannel CHANNEL_NAME

data = loaders[format].thread path

channel\push data
