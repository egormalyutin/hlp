
current = (...)

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

--------------------------------

exec = (command) ->
	handle = assert io.popen command
	result = handle\read '*all'
	handle\close!
	return result

split = (input, separator) ->
	if separator == nil
		separator = "%s"

	t = {}
	i = 1

	for str in string.gmatch(input, "([^" .. separator .. "]+)")
		t[i] = str
		i += 1

	return t

join = (delimiter, list) ->
	len = #list
	if len == 0 then
		return "" 
	string = list[1]
	i = 2
	while i <= len
		string = string .. delimiter .. list[i] 
		i += 1
	return string



------------------------------
-- LINUX

splitLinux = (input, separator) ->
	if separator == nil
		separator = "%s"

	t = {}
	i = 1

	cmd = ""

	for str in string.gmatch(input, "([^" .. separator .. "]+)")
		if i >= 11
			cmd = cmd .. str .. ' '
		else
			t[i] = str
			i += 1

	cmd = cmd\sub(1, -2)

	return t, cmd

parse = (input) ->
	strings = split(input, '\n')
	table.remove strings, 1
	list = {}

	for _, str in pairs strings
		sp, cmd = splitLinux(str, '%s+')


		item =
			user:    sp[1]
			pid:     tonumber sp[2]
			cpu:     tonumber sp[3]
			mem:     tonumber sp[4]
			vsz:     sp[5]
			rss:     sp[6]
			tt:      sp[7]
			stat:    sp[8]
			started: sp[9]
			time:    sp[10]
			command: cmd

		table.insert list, item

	return list

getProcessesLinux = ->
	aux = exec 'ps aux'
	return parse aux

----------------------------------
-- WINDOWS


getProcessesWindows = () ->
	csv = load 'csv'

	data = exec 'tasklist /v /nh /fo csv'

	strs = split data, '\n'	

	str = csv.openstring(data)
	processes = {}

	for fields in str\lines!
		mem = fields[5]\gsub('[^%d]', '')
		process = 
			imageName:     fields[1]
			pid:           tonumber fields[2]
			sessionName:   fields[3]
			sessionNumber: tonumber fields[4]
			mem:           tonumber(mem) * 1024
			status:        fields[6]
			username:      fields[7]
			cpuTime:       fields[8]
			windowTitle:   fields[9]
		table.insert processes, process
	return processes

getProcesses = ->

	-- get platform
	local platform
	if love and love.system and love.system.getOS
		platform = love.system.getOS!
	else
		error 'Locale detection currently works only in LÖVE!'

	----------------

	local r

	-- pick locale getter for platform
	switch platform
		when "Linux"
			r = getProcessesLinux!

		when "Android"
			r = getProcessesLinux!

		when "OS X"
			r = getProcessesLinux!

		when "Windows"
			r = getProcessesWindows!

		when "iOS"
			r = getProcessesLinux!

	return r 

return getProcesses
