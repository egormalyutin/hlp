socket = require 'socket'

PORT  = 4550

CHECK = (a) -> 
	a .. ":handshake_checked"

HANDSHAKE = 'c197fca4-14d0-421a-9d16-88b9c5b7c7bb'

isIn = (arr, item) ->
	for _, a in ipairs arr
		if item.host == a.host and item.port == a.port
			return true
	return false

class Server
	new: (settings = {}) =>
		-- settings
		@host      = settings.host      or "*"
		@port      = settings.port      or PORT
		@timeout   = settings.timeout   or 0.1
		@handshake = settings.handshake or HANDSHAKE
		@check     = settings.check     or CHECK

		if type(@check) == "string"
			oldCheck = @check
			@check = (a) -> a .. oldCheck

		-- udp
		@udp, err = socket.udp!
		error err if err
		@udp\setsockname @host, @port
		@udp\settimeout @timeout

		@_results = {}
		@_listeners = {}

	listen: (listener) =>
		table.insert @_listeners, listener

	emit: (...) =>
		for _, listener in ipairs @_listeners
			listener ...

	update: =>
		-- check messages
		message, host, port = @udp\receivefrom!


		-- message is handshake? send it back to sender!
		if message == @handshake
			obj = {:host, :port}
			unless isIn @_results, obj
				table.insert @_results, obj
				@udp\sendto @.check(message), host, port
				@emit host

			-- Why @.check and not @check?
			-- Because @.check compiles to self.check and @check compiles to self:check

	close: =>
		@udp\close!

class Client
	new: (settings = {}) =>

		-- settings
		@host          = settings.host          or "*"
		@port          = settings.port          or PORT
		@handshakePort = settings.handshakePort or settings.handshake_port or @port + 1
		@timeout       = settings.timeout       or 0.1
		@handshake     = settings.handshake     or HANDSHAKE
		@check         = settings.check         or CHECK

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

		@_results = {}

		@_listeners = {}

	listen: (listener) =>
		table.insert @_listeners, listener

	emit: (...) =>
		for _, listener in ipairs @_listeners
			listener ...

	update: =>
		-- check messages
		message, host, port, err = @udp\receivefrom!

		-- if message is handshake, receive it
		if message == @_checked
			obj = {:host, :port}
			unless isIn @_results, obj
				table.insert @_results, obj
				@emit host

		-- throw error
		error err if err

		-- send handshake to world
		@udp\sendto @handshake, "255.255.255.255", @port

	close: =>
		@udp\close!

{
	:Server
	:Client
}
