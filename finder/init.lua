local socket = require('socket')
local current = (...)
local load
load = function(path)
  local succ, loaded = pcall(require, path)
  if not (succ) then
    local LC_PATH = current .. '.' .. path
    succ, loaded = pcall(require, LC_PATH)
    if not (succ) then
      LC_PATH = current:gsub("%.[^%..]+$", "") .. '.' .. path
      succ, loaded = pcall(require, LC_PATH)
      if not (succ) then
        error(loaded)
      end
    end
  end
  return loaded
end
local EventEmitter = load('event')
local PORT = 4550
local CHECK
CHECK = function(a)
  return a .. ":handshake_checked"
end
local HANDSHAKE = 'c197fca4-14d0-421a-9d16-88b9c5b7c7bb'
local isIn
isIn = function(arr, item)
  for _, a in ipairs(arr) do
    if item.host == a.host and item.port == a.port then
      return true
    end
  end
  return false
end
local indexOf
indexOf = function(arr, item)
  for num, a in ipairs(arr) do
    if item.host == a.host and item.port == a.port then
      return num
    end
  end
  return false
end
local Server
do
  local _class_0
  local _parent_0 = EventEmitter
  local _base_0 = {
    update = function(self)
      local message, host, port = self.udp:receivefrom()
      if message == self.handshake then
        local obj = {
          host = host,
          port = port,
          timeout = 0
        }
        self.udp:sendto(self._checked, host, port)
        local index = indexOf(self._results, obj)
        if index then
          self._results[index].timeout = 0
        else
          table.insert(self._results, obj)
          self:emit('connect', host)
        end
      elseif message == self._closed_handshake then
        for num, r in ipairs(self._results) do
          if (r.host == host) and (r.port == port) then
            table.remove(r, num)
          end
        end
      end
      for num, result in ipairs(self._results) do
        result.timeout = result.timeout + 1
        if result.timeout > self.closedTimeout then
          self:emit('disconnect', result.host)
          table.remove(self._results, num)
        end
      end
    end,
    close = function(self)
      for num, res in ipairs(self._results) do
        self.udp:sendto(self._closed_handshake, res.host, res.port)
      end
      return self.udp:close()
    end
  }
  _base_0.__index = _base_0
  setmetatable(_base_0, _parent_0.__base)
  _class_0 = setmetatable({
    __init = function(self, settings)
      if settings == nil then
        settings = { }
      end
      _class_0.__parent.__init(self)
      self.host = settings.host or "*"
      self.port = settings.port or PORT
      self.timeout = settings.timeout or 0.1
      self.handshake = settings.handshake or HANDSHAKE
      self.check = settings.check or CHECK
      self.closedTimeout = settings.closedTimeout or settings.closed_timeout or settings.ct or 5
      self._checked = self.check(self.handshake)
      self._closed_handshake = self._checked .. ':closed'
      if type(self.check) == "string" then
        local oldCheck = self.check
        self.check = function(a)
          return a .. oldCheck
        end
      end
      local err
      self.udp, err = socket.udp()
      if err then
        error(err)
      end
      self.udp:setsockname(self.host, self.port)
      self.udp:settimeout(self.timeout)
      self._results = { }
    end,
    __base = _base_0,
    __name = "Server",
    __parent = _parent_0
  }, {
    __index = function(cls, name)
      local val = rawget(_base_0, name)
      if val == nil then
        local parent = rawget(cls, "__parent")
        if parent then
          return parent[name]
        end
      else
        return val
      end
    end,
    __call = function(cls, ...)
      local _self_0 = setmetatable({}, _base_0)
      cls.__init(_self_0, ...)
      return _self_0
    end
  })
  _base_0.__class = _class_0
  if _parent_0.__inherited then
    _parent_0.__inherited(_parent_0, _class_0)
  end
  Server = _class_0
end
local Client
do
  local _class_0
  local _parent_0 = EventEmitter
  local _base_0 = {
    update = function(self)
      local message, host, port, err = self.udp:receivefrom()
      if message == self._checked then
        local obj = {
          host = host,
          port = port,
          timeout = 0
        }
        local index = indexOf(self._results, obj)
        if index then
          self._results[index].timeout = 0
        else
          table.insert(self._results, obj)
          self:emit('connect', host)
        end
      elseif message == self._closed_handshake then
        for num, r in ipairs(self._results) do
          if (r.host == host) and (r.port == port) then
            table.remove(r, num)
          end
        end
      end
      for num, result in ipairs(self._results) do
        result.timeout = result.timeout + 1
        if result.timeout > self.closedTimeout then
          self:emit('disconnect', result.host)
          table.remove(self._results, num)
        end
      end
      if err then
        error(err)
      end
      return self.udp:sendto(self.handshake, "255.255.255.255", self.port)
    end,
    close = function(self)
      for num, res in ipairs(self._results) do
        self.udp:sendto(self._closed_handshake, res.host, res.port)
      end
      return self.udp:close()
    end
  }
  _base_0.__index = _base_0
  setmetatable(_base_0, _parent_0.__base)
  _class_0 = setmetatable({
    __init = function(self, settings)
      if settings == nil then
        settings = { }
      end
      _class_0.__parent.__init(self)
      self.host = settings.host or "*"
      self.port = settings.port or PORT
      self.handshakePort = settings.handshakePort or settings.handshake_port or self.port + 1
      self.timeout = settings.timeout or 0.1
      self.handshake = settings.handshake or HANDSHAKE
      self.check = settings.check or CHECK
      self.closedTimeout = settings.closedTimeout or settings.closed_timeout or settings.ct or 5
      if type(self.check) == "string" then
        local oldCheck = self.check
        self.check = function(a)
          return a .. oldCheck
        end
      end
      local err
      self.udp, err = socket.udp()
      if err then
        error(err)
      end
      self.udp:setsockname(self.host, self.handshakePort)
      self.udp:setoption('broadcast', true)
      self.udp:settimeout(self.timeout)
      self._checked = self.check(self.handshake)
      self._closed_handshake = self._checked .. ':closed'
      self._results = { }
    end,
    __base = _base_0,
    __name = "Client",
    __parent = _parent_0
  }, {
    __index = function(cls, name)
      local val = rawget(_base_0, name)
      if val == nil then
        local parent = rawget(cls, "__parent")
        if parent then
          return parent[name]
        end
      else
        return val
      end
    end,
    __call = function(cls, ...)
      local _self_0 = setmetatable({}, _base_0)
      cls.__init(_self_0, ...)
      return _self_0
    end
  })
  _base_0.__class = _class_0
  if _parent_0.__inherited then
    _parent_0.__inherited(_parent_0, _class_0)
  end
  Client = _class_0
end
return {
  Server = Server,
  Client = Client
}
