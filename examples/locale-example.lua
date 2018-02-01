local locale = require('locale')
local lc = locale.new('examples.locale-example-en', 'examples.locale-example-ru')
lc.current = locale.get()
local data = lc.values
local time = 0
local font = love.graphics.newFont('examples/fixtures/font.ttf', 50)
love.update = function(dt)
  time = time + dt
  if time >= 1 then
    time = 0
    if lc.current == 'en' then
      lc.current = 'ru'
    else
      lc.current = 'en'
    end
  end
end
love.draw = function()
  love.graphics.setFont(font)
  return love.graphics.print(data.hello, 100, 100)
end
