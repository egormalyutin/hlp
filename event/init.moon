class EventEmitter
	new: =>
		@_events = {}
		@_once   = {}

	-- create event table if it doesn't exist
	_touch: (event) =>
		-- simple events
		unless @_events[event]
			@_events[event] = {}

		-- once events
		unless @_once[event]
			@_once[event] = {}

	-- add new listener
	on: (event, handler) =>
		@_touch event

		-- alias
		handlers = @_events[event]

		if handler
			-- add handler to all event handlers
			table.insert handlers, handler

		-- chaining
		return @

	-- add event, that can be called only once
	once: (event, handler) =>
		@_touch event

		-- aliases
		handlers = @_events[event]
		once     = @_once[event]

		if handler
			-- add event to "handlers" and "once" tables
			table.insert handlers, handler
			table.insert once, handler

		-- chaining
		return @


	-- call handlers, that subscribes to event. "..." is arguments
	emit: (event, ...) =>
		@_touch event

		-- aliases
		handlers = @_events[event]
		once     = @_once[event]

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

	--    event, handlers
	off: (event, handler) =>
		@_touch event

		-- aliases
		handlers = @_events[event]
		once     = @_once[event]

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

	-- get listeners
	listeners: (event) =>
		assert event, "Event is nil!"
		@_touch event
		return @_events[event]

return EventEmitter
