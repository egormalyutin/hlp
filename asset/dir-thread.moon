path, CHANNEL, ignored = ...

channel = love.thread.getChannel CHANNEL


isDir = love.filesystem.isDirectory

isIgnored = (a) ->
	for pattern in *ignored
		if a\match(pattern) ~= nil
			return true
	return false

scan = (path) ->
	worker = (dir, result, root) ->
		files = love.filesystem.getDirectoryItems dir
		for name, file in ipairs files
			filePath = dir .. '/' .. file
			unless isIgnored filePath
				if isDir filePath
					result[file] = {}
					worker filePath, result[file], root
				else
					result[file] = filePath

	r = {}
	worker path, r, path
	return r


toLoad = {}

tbl = scan path

channel\push tbl
