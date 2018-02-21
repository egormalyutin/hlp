finder = require 'finder'
love.window.close!

print '1 - server, other - client'

if tonumber(io.read(1)) == 1
	print 'server'

	-- see 45 and 113 lines of Finder source for default values
	srv = finder.Server {
		port: 8080	
		handshake: '93203'
	}

	srv\on 'connect', (address) ->
		print address .. " connected to server!"

	srv\on 'disconnect', (address) ->
		print address .. " disconnected from server!"

	love.update = (dt) ->
		srv\update!

else
	print 'client'
	cl  = finder.Client {
		port: 8080
		handshake: '93203'
	}

	cl\on 'connect', (address) ->
		print "Found server " .. address .. "!"

	cl\on 'disconnect', (address) ->
		print address .. " disconnected!"
	

	love.update = (dt) ->
		cl\update!
