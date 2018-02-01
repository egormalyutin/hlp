file = 
	thread: (path) ->
		fs = love.filesystem or require 'love.filesystem'
		return fs.newFileData path

	master: (f) ->
		return f

image = 
	thread: (img) ->
		image = love.image or require('love.image')
		return image.newImageData img

	master: (img) -> 
		graphics = love.graphics or require('love.graphics')
		return graphics.newImage img


font =
	thread: file.thread

	master: (fnt) ->
		graphics = love.graphics or require('love.graphics')
		return (size) -> 
			return graphics.newFont(fnt, size)

audio = 
	thread: (sound) ->
		love.sound or= require 'love.sound'
		audio = love.audio or require 'love.audio'
		return audio.newSource sound

	master: (sound) -> sound

video =
	thread: (path) ->
		fs = love.filesystem or require 'love.filesystem'
		return fs.newFile path

	master: (video) ->
		graphics = love.graphics or require('love.graphics')
		return graphics.newVideo video

shader = 
	thread: file.thread

	master: (fl) ->
		graphics = love.graphics or require('love.graphics')
		return graphics.newShader fl\getString!


return { 
	txt: file

	png:  image
	jpg:  image
	jpeg: image
	dds:  image

	ttf:  font
	otf:  font
	woff: font

	mp3: audio
	ogg: audio
	wav: audio

	glsl: shader

	ogv: video
}

