-- inspired by os-locale: https://github.com/sindresorhus/os-locale

----------------------------------------------

-- get Windows localization codes
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

codes = load 'localeCodes'

----------------------------------------------

-- execute command and get string result:
-- exec('printf executed') => 'executed'
exec = (command) ->
	handle = assert io.popen command
	result = handle\read '*all'
	handle\close!
	return result

-- split string: 
-- split('a.b.c', '.') => {'a', 'b', 'c'}
split = (input, separator) ->
	if separator == nil
		separator = "%s"

	t = {}
	i = 1

	for str in string.gmatch(input, "([^" .. separator .. "]+)")
		t[i] = str
		i += 1

	return t

----------------------------------------------

-- remove encoding and another things from locale
-- shortLocale("ru_RU.UTF-8") => "ru"
shortLocale = (loc) ->
	loc = loc\gsub('_.+$', '')
	return loc

----------------------------------------------

getters =
	-- get short Linux locale
	linux: (x) ->
		x = exec('locale')

		-- A=1
		-- B=2
		-- C=3
		splitted = split x, '\n'

		env = {}

		-- parse locale
		for _, d in pairs splitted
			-- A=1 => {'A', '1'}
			d = split d, '='

			g = ""

			-- try to parse variable
			pcall ->
				-- A="1" => A=1
				g = d[2]\gsub '"', '' 

				-- env['A'] = '1'
				env[d[1]] = g

		loc = env.LC_ALL or env.LC_MESSAGES or env.LANG or env.LANGUAGE
		return shortLocale loc

	-- get short Android locale
	android: ->
		return shortLocale exec 'getprop persist.sys.language'

	-- get short Windows locale
	windows: ->
		wmic = exec 'wmic get os locale'
		codeString = wmic\gsub 'Locale', ''
		code = tonumber codeString, 16
		loc  = codes[code]
		return shortLocale loc

	-- get short macos locale
	osx: ->
		return shortLocale exec 'defaults read -g AppleLocal'

	ios: ->
		return shortLocale exec 'defaults read -g AppleLocal'

----------------------------------------------

local cache

-- get locale
-- getLocale() => "en"
-- getLocale() => "ru"
-- getLocale() => "fallback"
getLocale = (fallback) ->
	-- use cache	
	if cache
		return cache

	-- get platform
	local platform
	if love and love.system and love.system.getOS
		platform = love.system.getOS!
	else
		error 'Locale detection currently works only in LÖVE!'

	----------------

	-- pick locale getter for platform
	switch platform
		when "Linux"
			cache = getters.linux!

		when "Android"
			cache = getters.android!

		when "OS X"
			cache = getters.osx!

		when "Windows"
			cache = getters.windows!

		when "iOS"
			cache = getters.ios!

		-- others
		else
			cache = fallback

	return cache

----------------------------------------------

-- export
return getLocale
