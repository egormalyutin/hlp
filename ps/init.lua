local current = (...)
local load
load = function(path)
  local succ, loaded = pcall(require, path)
  if not (succ) then
    local LC_PATH = current .. '.' .. path
    succ, loaded = pcall(require, LC_PATH)
    if not (succ) then
      LC_PATH = current:gsub("%.[^%..]+$", "") .. '.' .. path
      succ, loaded = pcall(require, LC_PATH)
      if not (succ) then
        error(loaded)
      end
    end
  end
  return loaded
end
local exec
exec = function(command)
  local handle = assert(io.popen(command))
  local result = handle:read('*all')
  handle:close()
  return result
end
local split
split = function(input, separator)
  if separator == nil then
    separator = "%s"
  end
  local t = { }
  local i = 1
  for str in string.gmatch(input, "([^" .. separator .. "]+)") do
    t[i] = str
    i = i + 1
  end
  return t
end
local join
join = function(delimiter, list)
  local len = #list
  if len == 0 then
    return ""
  end
  local string = list[1]
  local i = 2
  while i <= len do
    string = string .. delimiter .. list[i]
    i = i + 1
  end
  return string
end
local splitLinux
splitLinux = function(input, separator)
  if separator == nil then
    separator = "%s"
  end
  local t = { }
  local i = 1
  local cmd = ""
  for str in string.gmatch(input, "([^" .. separator .. "]+)") do
    if i >= 11 then
      cmd = cmd .. str .. ' '
    else
      t[i] = str
      i = i + 1
    end
  end
  cmd = cmd:sub(1, -2)
  return t, cmd
end
local parse
parse = function(input)
  local strings = split(input, '\n')
  table.remove(strings, 1)
  local list = { }
  for _, str in pairs(strings) do
    local sp, cmd = splitLinux(str, '%s+')
    local item = {
      user = sp[1],
      pid = tonumber(sp[2]),
      cpu = tonumber(sp[3]),
      mem = tonumber(sp[4]),
      vsz = sp[5],
      rss = sp[6],
      tt = sp[7],
      stat = sp[8],
      started = sp[9],
      time = sp[10],
      command = cmd
    }
    table.insert(list, item)
  end
  return list
end
local getProcessesLinux
getProcessesLinux = function()
  local aux = exec('ps aux')
  return parse(aux)
end
local getProcessesWindows
getProcessesWindows = function()
  local csv = load('csv')
  local data = exec('tasklist /v /nh /fo csv')
  local strs = split(data, '\n')
  local str = csv.openstring(data)
  local processes = { }
  for fields in str:lines() do
    local mem = fields[5]:gsub('[^%d]', '')
    local process = {
      imageName = fields[1],
      pid = tonumber(fields[2]),
      sessionName = fields[3],
      sessionNumber = tonumber(fields[4]),
      mem = tonumber(mem) * 1024,
      status = fields[6],
      username = fields[7],
      cpuTime = fields[8],
      windowTitle = fields[9]
    }
    table.insert(processes, process)
  end
  return processes
end
local getProcesses
getProcesses = function()
  local platform
  if love and love.system and love.system.getOS then
    platform = love.system.getOS()
  else
    error('Locale detection currently works only in LÖVE!')
  end
  local r
  local _exp_0 = platform
  if "Linux" == _exp_0 then
    r = getProcessesLinux()
  elseif "Android" == _exp_0 then
    r = getProcessesLinux()
  elseif "OS X" == _exp_0 then
    r = getProcessesLinux()
  elseif "Windows" == _exp_0 then
    r = getProcessesWindows()
  elseif "iOS" == _exp_0 then
    r = getProcessesLinux()
  end
  return r
end
return getProcesses
