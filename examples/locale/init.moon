locale = require 'locale'

lc = locale.new 'examples.locale.en', 'examples.locale.ru'

-- get system locale, wow!
lc.current = locale.get!

-- more locales can be loaded later
-- lc\load 'examples.locale-example-*'

-- export data from locale
data = lc.values

time = 0
font = love.graphics.newFont 'examples/asset/fixtures/font.ttf', 50

love.update = (dt) ->
	-- switch locales every second
	time += dt
	if time >= 1
		time = 0
		if lc.current == 'en'
			lc.current = 'ru'
		else
			lc.current = 'en'



love.draw = ->
	love.graphics.setFont font
	love.graphics.print data.hello, 100, 100
