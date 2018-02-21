--- EventEmitter implementation.
-- @classmod hlp.event

indexOf = (a, b) ->
	for num, item in ipairs a
		if item == b
			return num
	return -1

class EventEmitter
	--- Create a new EventEmitter.
	new: =>
		@_events = {}
		@_once_events   = {}

	_event_touch: (event) =>
		-- simple events
		unless @_events[event]
			@_events[event] = {}

		-- once events
		unless @_once_events[event]
			@_once_events[event] = {}

	--- Add new listener.
	-- @param event Name of event.
	-- @param handler Handler of event.
	on: (event, handler) =>
		@_event_touch event

		-- alias
		handlers = @_events[event]

		if handler
			-- add handler to all event handlers
			table.insert handlers, handler

		-- chaining
		return @

	--- Add new listener, that will be called only once.
	-- @param event Name of event.
	-- @param handler Handler of event.	
	once: (event, handler) =>
		@_event_touch event

		-- aliases
		handlers = @_events[event]
		once     = @_once_events[event]

		if handler
			-- add event to "handlers" and "once" tables
			table.insert handlers, handler
			table.insert once, handler

		-- chaining
		return @

	--- Call handlers, that subscribes to event.
	-- @param event Name of event.
	-- @param ... Arguments, that will be passed to handlers.
	emit: (event, ...) =>
		@_event_touch event

		-- aliases
		handlers = @_events[event]
		once     = @_once_events[event]

		for num, handler in ipairs handlers
			-- call handler with arguments
			handler ...
			-- get index of event handler in "once" table
			index = indexOf once, handler
			-- if it exists
			if index ~= -1
				-- remove event
				table.remove once, index
				table.remove handlers, num

		-- chaining
		return @

	--- Remove handlers from EventEmitter.
	-- @param event Name of event. If it's nil, all handlers will be removed from EventEmitter.
	-- @param handler Handler function. If it's nil and `event` isn't nil, all handlers for event `event` will be removed from EventEmitter. If it's nil and `event` is nil, all handlers will be removed from EventEmitter.
	off: (event, handler) =>

		unless event
			for name, _ in @_events
				@_events[name] = {}

			for name, _ in @_once_events
				@_once_events[name] = {}


		@_event_touch event

		-- aliases
		handlers = @_events[event]
		once     = @_once_events[event]

		-- remove all handlers for choosen event
		unless handler
			@_events[event] = {}

		-- remove one handler for choosen event
		else

			for num in ipairs handlers

				-- remove handler from "handlers" table
				if handler == handlers[num]
					table.remove handlers, num

				-- remove handler from "once" table
				if handler == once[num]
					table.remove once, num

		-- chaining
		return @

	--- Get listeners of event.
	-- @param event Name of event.
	listeners: (event) =>
		assert event, "Event is nil!"
		@_event_touch event
		return @_events[event]

return EventEmitter
