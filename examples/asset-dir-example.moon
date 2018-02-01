asset = require 'asset'

dir = asset.Dir
	root: 'examples/fixtures'

-- set window width and height
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
