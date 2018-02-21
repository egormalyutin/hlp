socket = require 'socket'

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

EventEmitter = load 'event'

PORT  = 4550

CHECK = (a) -> 
	a .. ":handshake_checked"

HANDSHAKE = 'c197fca4-14d0-421a-9d16-88b9c5b7c7bb'

isIn = (arr, item) ->
	for _, a in ipairs arr
		if item.host == a.host and item.port == a.port
			return true
	return false

indexOf = (arr, item) ->
	for num, a in ipairs arr
		if item.host == a.host and item.port == a.port
			return num
	return false



class Server extends EventEmitter
	new: (settings = {}) =>
		super!
		-- settings
		@host      = settings.host      or "*"
		@port      = settings.port      or PORT
		@timeout   = settings.timeout   or 0.1
		@handshake = settings.handshake or HANDSHAKE
		@check     = settings.check     or CHECK
		@closedTimeout = settings.closedTimeout or settings.closed_timeout or settings.ct or 5

		@_checked = @.check(@handshake)
		@_closed_handshake = @_checked .. ':closed'

		if type(@check) == "string"
			oldCheck = @check
			@check = (a) -> a .. oldCheck

		-- udp
		@udp, err = socket.udp!
		error err if err
		@udp\setsockname @host, @port
		@udp\settimeout @timeout

		@_results = {}

	update: =>
		-- check messages
		message, host, port = @udp\receivefrom!


		-- message is handshake? send it back to sender!
		if message == @handshake
			obj = {:host, :port, timeout: 0}
			@udp\sendto @_checked, host, port

			index = indexOf @_results, obj

			if index
				@_results[index].timeout = 0
			else
				table.insert @_results, obj
				@emit 'connect', host

		elseif message == @_closed_handshake
			for num, r in ipairs @_results
				if (r.host == host) and (r.port == port)
					table.remove r, num

		for num, result in ipairs @_results
			result.timeout += 1
			if result.timeout > @closedTimeout
				@emit 'disconnect', result.host 
				table.remove @_results, num

	close: =>
		for num, res in ipairs @_results
			@udp\sendto @_closed_handshake, res.host, res.port

		@udp\close!







class Client extends EventEmitter
	new: (settings = {}) =>
		super!

		-- settings
		@host          = settings.host          or "*"
		@port          = settings.port          or PORT
		@handshakePort = settings.handshakePort or settings.handshake_port or @port + 1
		@timeout       = settings.timeout       or 0.1
		@handshake     = settings.handshake     or HANDSHAKE
		@check         = settings.check         or CHECK
		@closedTimeout = settings.closedTimeout or settings.closed_timeout or settings.ct or 5

		if type(@check) == "string"
			oldCheck = @check
			@check = (a) -> a .. oldCheck

		-- udp
		@udp, err = socket.udp!
		error err if err
		@udp\setsockname @host, @handshakePort
		@udp\setoption 'broadcast', true
		@udp\settimeout @timeout

		@_checked = @.check(@handshake)
		@_closed_handshake = @_checked .. ':closed'

		@_results = {}

	update: =>
		-- check messages
		message, host, port, err = @udp\receivefrom!

		-- if message is handshake, receive it
		if message == @_checked
			obj = {:host, :port, timeout: 0}
			index = indexOf @_results, obj
			if index
				@_results[index].timeout = 0

			else
				table.insert @_results, obj
				@emit 'connect', host

		elseif message == @_closed_handshake
			for num, r in ipairs @_results
				if (r.host == host) and (r.port == port)
					table.remove r, num

		for num, result in ipairs @_results
			result.timeout += 1
			if result.timeout > @closedTimeout
				@emit 'disconnect', result.host 
				table.remove @_results, num

		-- throw error
		error err if err

		-- send handshake to world
		@udp\sendto @handshake, "255.255.255.255", @port

	close: =>
		for num, res in ipairs @_results
			@udp\sendto @_closed_handshake, res.host, res.port	

		@udp\close!

{
	:Server
	:Client
}
