local LOADER_CHANNEL_PREFIX = "loader-channel-"
local THREAD_FILE_NAME = (...):gsub("%.[^%..]+$", ""):gsub("%.", "/") .. "/thread.lua"
local current = (...)
local load
load = function(path)
  local LC_PATH
  local succ, loaded = pcall(require, LC_PATH)
  if not (succ) then
    LC_PATH = current .. '.' .. path
    succ, loaded = pcall(require, LC_PATH)
    if not (succ) then
      LC_PATH = current:gsub("%.[^%..]+$", "") .. '.' .. path
      succ, loaded = pcall(require, LC_PATH)
      if not (succ) then
        error(loaded)
      end
    end
  end
  return loaded, LC_PATH
end
local loaders, LOADERS_PATH = load('loaders')
local threadFile
if love.filesystem then
  threadFile = love.filesystem.read(THREAD_FILE_NAME)
else
  threadFile = THREAD_FILE_NAME
end
local getExt
getExt = function(path)
  return path:match("[^.]+$")
end
local i = 0
local AssetPool
do
  local _class_0
  local _base_0 = {
    load = function(self, path, obj, key, cb)
      if cb == nil then
        cb = function() end
      end
      local ext = getExt(path)
      local loader
      if loaders[ext] then
        loader = loaders[ext]
      else
        error('Not found loader for format "' .. ext .. '"!')
      end
      local thread = love.thread.newThread(THREAD_FILE_NAME)
      table.insert(self._threads, thread)
      thread:start(path, ext, self._tid, self._CHANNEL_NAME, LOADERS_PATH)
      local sf = self
      local ret = {
        loaded = false,
        resource = nil,
        data = nil
      }
      local update
      update = function(data)
        if data and data.success then
          local rs = loader.master(data.resource)
          ret.loaded = true
          ret.resource = rs
          ret.data = rs
          if obj ~= nil then
            obj[key] = rs
          end
        else
          if data and data.error then
            error(data.error)
          end
        end
        return cb(data)
      end
      table.insert(self._updates, update)
      self._tid = self._tid + 1
      return ret
    end,
    update = function(self)
      local _list_0 = self._threads
      for _index_0 = 1, #_list_0 do
        local thread = _list_0[_index_0]
        local err = thread:getError()
        if err then
          error(err)
        end
      end
      while true do
        local data = self._channel:pop()
        if not (data) then
          break
        end
        if self._updates[data.id] then
          self._updates[data.id](data)
        end
      end
    end,
    wait = function(self) end
  }
  _base_0.__index = _base_0
  _class_0 = setmetatable({
    __init = function(self)
      self._CHANNEL_NAME = LOADER_CHANNEL_PREFIX .. i
      i = i + 1
      self._channel = love.thread.getChannel(self._CHANNEL_NAME)
      self._threads = { }
      self._updates = { }
      self._tid = 1
    end,
    __base = _base_0,
    __name = "AssetPool"
  }, {
    __index = _base_0,
    __call = function(cls, ...)
      local _self_0 = setmetatable({}, _base_0)
      cls.__init(_self_0, ...)
      return _self_0
    end
  })
  _base_0.__class = _class_0
  AssetPool = _class_0
end
return AssetPool
