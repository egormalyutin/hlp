local asset = require('asset')
local assets = {}


love.update = function()
	assets = {
		font = asset.font('examples/asset/fixtures/font.ttf', 26),
		shader = asset('examples/asset/fixtures/shader.glsl'),
		image = asset('examples/asset/fixtures/image.jpg')
	}
end

love.draw = function()
	if assets.font then
		love.graphics.setFont(assets.font)
		love.graphics.print('SUPPORTS FONTS, SHADERS, IMAGES, AUDIOS AND VIDEOS')
	end

	if assets.shader then
		love.graphics.setShader(assets.shader)
	end

	if assets.image then
		love.graphics.draw(assets.image, 0, 55, nil, 0.14, 0.14)
	end

	if assets.shader then
		love.graphics.setShader()
	end
end
