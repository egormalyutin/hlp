local current = (...)
local THREAD_FILE_NAME = (...):gsub("%.[^%..]+$", ""):gsub("%.", "/") .. "/dir-thread.lua"
local threadFile
if love.filesystem then
  threadFile = love.filesystem.read(THREAD_FILE_NAME)
else
  threadFile = THREAD_FILE_NAME
end
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
local Pool = load('Pool')
local stub
stub = function()
  local obj = { }
  return setmetatable(obj, {
    __index = function()
      return obj
    end,
    __call = function() end
  })
end
local flat
flat = function(obj)
  local worker
  worker = function(obj, result)
    for key, value in pairs(obj) do
      if type(value) == 'table' then
        worker(value, result)
      else
        table.insert(result, {
          key = key,
          obj = obj,
          value = value
        })
      end
    end
  end
  local r = { }
  worker(obj, r)
  return r
end
local assign
assign = function(a, b)
  for name, value in pairs(b) do
    a[name] = value
  end
end
local Dir
do
  local _class_0
  local _base_0 = {
    _loaded = function(self, data)
      self._resources = self._resources - 1
      local _list_0 = self._onload
      for _index_0 = 1, #_list_0 do
        local on = _list_0[_index_0]
        on(data)
      end
      if self._resources <= 0 then
        self.loaded = true
      end
    end,
    update = function(self)
      if self._phase == 2 then
        return self._pool:update()
      else
        if self._phase == 1 then
          local data = self._channel:pop()
          local err = self._thread:getError()
          if err then
            error(err)
          end
          if data then
            assign(self.tree, data)
            self.assets = self.tree
            local flt = flat(self.tree)
            if #flt <= 0 then
              self:_loaded()
            end
            for _index_0 = 1, #flt do
              local obj = flt[_index_0]
              self._resources = self._resources + 1
              local key = obj.key:gsub("%.[^%..]+$", "")
              if tonumber(key) ~= nil then
                key = tonumber(key)
              end
              self._pool:load(obj.value, obj.obj, key, function(data)
                return self:_loaded(data)
              end)
              obj.obj[obj.key] = nil
            end
            self._phase = 2
          end
        else
          self._thread = love.thread.newThread(threadFile)
          self._channel = love.thread.getChannel('asset-dir')
          self._thread:start(self._settings.root, 'asset-dir', self._settings.ignored)
          self._phase = 1
        end
      end
    end
  }
  _base_0.__index = _base_0
  _class_0 = setmetatable({
    __init = function(self, _settings)
      self._settings = _settings
      assert(self._settings, 'Settings is nil!')
      assert(self._settings.root, 'Rootdir must be specified!')
      self._settings.ignored = self._settings.ignored or self._settings.ignore
      if type(self._settings.ignored) ~= 'table' then
        if self._settings.ignored == nil then
          self._settings.ignored = { }
        else
          self._settings.ignored = {
            self._settings.ignored
          }
        end
      end
      self._pool = Pool()
      self.tree = { }
      self.assets = self.tree
      self._onload = { }
      self._phase = 0
      self.loaded = false
      self._resources = 0
    end,
    __base = _base_0,
    __name = "Dir"
  }, {
    __index = _base_0,
    __call = function(cls, ...)
      local _self_0 = setmetatable({}, _base_0)
      cls.__init(_self_0, ...)
      return _self_0
    end
  })
  _base_0.__class = _class_0
  Dir = _class_0
  return _class_0
end
