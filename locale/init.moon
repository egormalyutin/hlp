----------------------------------------------


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

getLocale = load 'getLocale'

----------------------------------------------

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

-- reporter
reporter =
	fileNotFound: (name, stack) ->
		report   = 'Localization file ' .. name .. ' not found!\n'
		splitted = split(stack, '\n')
		separator = '   '
		tabStack = separator .. table.concat(splitted, separator .. '\n')
		report ..= tabStack
		error report

	mustBeATable: ->
		error 'Locale must be a table!'

	noLanguage: ->
		error 'Locale must have a "language" property!'

	failedMount: (name) ->
		error 'Failed to mount locale "' .. name .. '": locale not found!'

	notFoundFallback: ->
		error 'Not found fallback locale!'

----------------------------------------------


clean = (a) ->
	for name in pairs a
		a[name] = nil	

assign = (a, b) ->
	for name, value in pairs b
		a[name] = value

private =
	load: (locale) =>

		if type(locale) != 'table'
			reporter.mustBeATable!

		locale.language or= locale.lang or locale.locale or locale.loc
		locale.values   or= locale.values or locale.storage or locale.main or locale.all or {}

		unless locale.language
			reporter.noLanguage!

		@locales[locale.language] = locale.values

	mount: (locale) =>
		clean @value
		assign @value, @locales[locale]

		clean @values
		assign @values, @locales[locale]

proto =
	load: (...) =>
		arguments = {...}
		for _, argument in pairs arguments

			-- load file
			if type(argument) == 'string'
				succ, result = pcall require, argument

				-- file not found
				unless succ
					reporter.fileNotFound argument, result

				argument = result

			if type(argument) == 'table'
				private.load @, argument

	get: =>
		return getLocale!

Localization = (...) ->

	values =
		current:  nil
		fallback: 'en'
		locales: {}
		value:  {}
		values: {}

	self = setmetatable {}, 
		__index: (t, k) ->
			if proto[k]
				return proto[k]
			elseif values[k]
				return values[k]

		__newindex: (_, k, v) ->
			if k == 'current'
				values.current = v
				if values.locales[values.current]
					private.mount values, values.current
				else if not values.locales[values.fallback]
					reporter.notFoundFallback!
				else
					private.mount values, values.fallback

			else
				values[k] = v


	@load ...

	return @

----------------------------------------------

loc = {
	new: Localization
	get: getLocale
}

return loc
