local file = {
  thread = function(path)
    local fs = love.filesystem or require('love.filesystem')
    return fs.newFileData(path)
  end,
  master = function(f)
    return f
  end
}
local image = {
  thread = function(img)
    image = love.image or require('love.image')
    return image.newImageData(img)
  end,
  master = function(img)
    local graphics = love.graphics or require('love.graphics')
    return graphics.newImage(img)
  end
}
local font = {
  thread = file.thread,
  master = function(fnt)
    local graphics = love.graphics or require('love.graphics')
    return function(size)
      return graphics.newFont(fnt, size)
    end
  end
}
local audio = {
  thread = function(sound)
    love.sound = love.sound or require('love.sound')
    audio = love.audio or require('love.audio')
    return audio.newSource(sound)
  end,
  master = function(sound)
    return sound
  end
}
local video = {
  thread = function(path)
    local fs = love.filesystem or require('love.filesystem')
    return fs.newFile(path)
  end,
  master = function(video)
    local graphics = love.graphics or require('love.graphics')
    return graphics.newVideo(video)
  end
}
local shader = {
  thread = file.thread,
  master = function(fl)
    local graphics = love.graphics or require('love.graphics')
    return graphics.newShader(fl:getString())
  end
}
return {
  txt = file,
  png = image,
  jpg = image,
  jpeg = image,
  dds = image,
  ttf = font,
  otf = font,
  woff = font,
  mp3 = audio,
  ogg = audio,
  wav = audio,
  glsl = shader,
  ogv = video
}
