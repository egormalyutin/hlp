# Helper libraries for LÖVE

(all examples are written on MoonScript)
**Includes:** 

## asset
Async asset loader.
You have structure like this:
```
fixtures
	font.ttf
	shader.glsl
	images
		computers
			1.jpg
			2.jpg
		nature
			1.jpg
			2.jpg
main.moon
main.lua
```

main.moon:
```moonscript
asset = require 'hlp.asset'

dir = asset.Dir
	root: 'examples/fixtures'

love.window.setMode 541, 430

assets = dir.assets

love.update = ->
	dir\update!

love.draw = ->
	if dir.loaded
		-- set loaded shader
		love.graphics.setShader assets.shader

		-- draw image
		love.graphics.draw assets.images.computers[2], 20, 20, 0, 0.14, 0.14

		-- reset shader
		love.graphics.setShader!

		-- set font
		love.graphics.setFont assets.font 30
		love.graphics.print 'SUPPORTS IMAGES, SHADERS,\nVIDEOS AND AUDIOS', 20, 350
```

## locale
Simple localization library.
Can get system locale (wow!)

main.moon:
```moonscript
locale = require 'locale'

lc = locale.new 'en', 'ru'

-- you can set fallback
-- lc.fallback = 'ru'

-- get system locale
lc.current = locale.get!

-- more locales can be loaded later
-- lc\load 'some_locale'

-- export data from locale
data = lc.values

time = 0
font = love.graphics.newFont 'examples/fixtures/font.ttf', 50

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
```

ru.moon:
```moonscript
return {
	language: 'ru'
	values:
		hello: 'Привет!'
}
```

en.moon:
```moonscript
return {
	language: 'en'
	values:
		hello: 'Hello!'
}
```

I'm working on documentation for another utilities.
