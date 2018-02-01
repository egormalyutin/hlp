local asset = require('asset')
local dir = asset.Dir({
  root = 'examples/fixtures'
})
love.window.setMode(541, 430)
local assets = dir.assets
love.update = function()
  return dir:update()
end
love.draw = function()
  if dir.loaded then
    love.graphics.setShader(assets.shader)
    love.graphics.draw(assets.images.computers[2], 20, 20, 0, 0.14, 0.14)
    love.graphics.setShader()
    love.graphics.setFont(assets.font(30))
    return love.graphics.print('SUPPORTS IMAGES, SHADERS,\nVIDEOS AND AUDIOS', 20, 350)
  end
end
