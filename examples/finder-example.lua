local finder = require('finder')
local srv = finder.Server({
  port = 8080,
  handshake = '93203'
})
local cl = finder.Client({
  port = 8080,
  handshakePort = 8081,
  handshake = '93203'
})
print(srv.handshake)
print(cl.handshake)
love.update = function()
  srv:update()
  return cl:update()
end
