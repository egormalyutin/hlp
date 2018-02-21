local locale = require('locale')

local lc = locale.new('examples.locale.en', 'examples.locale.ru')

-- get system locale, wow!
lc.current = locale.get()

-- more locales can be loaded later
-- lc:load('examples.locale-example-*')

-- export data from locale
local data = lc.values

local time = 0

local font = love.graphics.newFont('examples/asset/fixtures/font.ttf', 50)


love.update = function(dt)
  -- switch locales every second
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
