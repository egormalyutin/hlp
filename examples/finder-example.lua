local finder = require('finder')
local srv = finder.Server({
  port = 8080,
  handshake = '93203'
})
local cl = finder.Client({
  port = 8080,
  handshake = '93203'
})
srv:listen(function(address)
  return print(address .. " connected to server!")
end)
cl:listen(function(address)
  return print("Found server " .. address .. "!")
end)
love.update = function()
  srv:update()
  return cl:update()
end
