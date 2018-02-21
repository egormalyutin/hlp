local indexOf
indexOf = function(a, b)
  for num, item in ipairs(a) do
    if item == b then
      return num
    end
  end
  return -1
end
local EventEmitter
do
  local _class_0
  local _base_0 = {
    _event_touch = function(self, event)
      if not (self._events[event]) then
        self._events[event] = { }
      end
      if not (self._once_events[event]) then
        self._once_events[event] = { }
      end
    end,
    on = function(self, event, handler)
      self:_event_touch(event)
      local handlers = self._events[event]
      if handler then
        table.insert(handlers, handler)
      end
      return self
    end,
    once = function(self, event, handler)
      self:_event_touch(event)
      local handlers = self._events[event]
      local once = self._once_events[event]
      if handler then
        table.insert(handlers, handler)
        table.insert(once, handler)
      end
      return self
    end,
    emit = function(self, event, ...)
      self:_event_touch(event)
      local handlers = self._events[event]
      local once = self._once_events[event]
      for num, handler in ipairs(handlers) do
        handler(...)
        local index = indexOf(once, handler)
        if index ~= -1 then
          table.remove(once, index)
          table.remove(handlers, num)
        end
      end
      return self
    end,
    off = function(self, event, handler)
      if not (event) then
        for name, _ in self._events do
          self._events[name] = { }
        end
        for name, _ in self._once_events do
          self._once_events[name] = { }
        end
      end
      self:_event_touch(event)
      local handlers = self._events[event]
      local once = self._once_events[event]
      if not (handler) then
        self._events[event] = { }
      else
        for num in ipairs(handlers) do
          if handler == handlers[num] then
            table.remove(handlers, num)
          end
          if handler == once[num] then
            table.remove(once, num)
          end
        end
      end
      return self
    end,
    listeners = function(self, event)
      assert(event, "Event is nil!")
      self:_event_touch(event)
      return self._events[event]
    end
  }
  _base_0.__index = _base_0
  _class_0 = setmetatable({
    __init = function(self)
      self._events = { }
      self._once_events = { }
    end,
    __base = _base_0,
    __name = "EventEmitter"
  }, {
    __index = _base_0,
    __call = function(cls, ...)
      local _self_0 = setmetatable({}, _base_0)
      cls.__init(_self_0, ...)
      return _self_0
    end
  })
  _base_0.__class = _class_0
  EventEmitter = _class_0
end
return EventEmitter
