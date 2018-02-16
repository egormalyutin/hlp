finder = require 'finder'

srv = finder.Server {
	port: 8080
	handshake: '93203'
}
cl  = finder.Client {
	port: 8080
	handshakePort: 8081
	handshake: '93203'
}

print srv.handshake
print cl.handshake

love.update = ->
	srv\update!
	cl\update!
