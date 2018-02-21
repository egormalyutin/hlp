asset = require 'asset'

assets = {}

love.update = ->
	assets =
		font:   asset.font 'examples/asset/fixtures/font.ttf', 50
		shader: asset 'examples/asset/fixtures/shader.glsl'
		image:  asset 'examples/asset/fixtures/image.jpg'

love.draw = ->
	if assets.font
		love.graphics.setFont assets.font
		love.graphics.print 'SUPPORTS'
