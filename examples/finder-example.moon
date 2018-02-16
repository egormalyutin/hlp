finder = require 'finder'

srv = finder.Server {
	port: 8080
	handshake: '93203'
}
cl  = finder.Client {
	port: 8080
	handshake: '93203'
}

srv\listen (address) ->
	print address .. " connected to server!"

cl\listen (address) ->
	print "Found server " .. address .. "!"

love.update = ->
	srv\update!
	cl\update!
