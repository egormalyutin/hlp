local finder = require('finder')

love.window.close()

print('1 - server, other - client')

if tonumber(io.read(1)) == 1 then
  print('server')

  -- see 45 and 113 lines of Finder source for default values
  local srv = finder.Server({
    port = 8080,
    handshake = '93203'
  })

  srv:on('connect', function(address)
    return print(address .. " connected to server!")
  end)

  srv:on('disconnect', function(address)
    return print(address .. " disconnected from server!")
  end)

  love.update = function(dt)
    return srv:update()
  end

else

  print('client')

  local cl = finder.Client({
    port = 8080,
    handshake = '93203'
  })

  cl:on('connect', function(address)
    return print("Found server " .. address .. "!")
  end)

  cl:on('disconnect', function(address)
    return print(address .. " disconnected!")
  end)

  love.update = function(dt)
    return cl:update()
  end
end
