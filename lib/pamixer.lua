local gears = require('gears')

-- general
local pamixer = {}

local function request(args)
  local file = io.popen('pamixer '..args)
  local contents = file:read('a')
  file:close()
  return contents:sub(1, -2)
end


-- signals
local signals = {
  volume = {},
  mute = {},
}

function pamixer.connect_signal(event, callback)
  table.insert(signals[event], callback)
end

function pamixer.disconnect_signal(event, callback)
  local key = gears.table.hasitem(signals[event], callback)
  if (key) then table.remove(signals[event], key) end
end

function pamixer.emit_signal(event, ...)
  for _, cb in ipairs(signals[event]) do
    cb(...)
  end
end


-- volume
function pamixer.get()
  return tonumber(request('--get-volume'))
end

function pamixer.set(volume)
  local before = pamixer.get()
  request('--set-volume '..tostring(volume))
  local after = pamixer.get()
  if (after ~= before) then pamixer.emit_signal('volume', after, before) end
  return after
end

function pamixer.inc(increment)
  local before = pamixer.get()
  request('-i '..tostring(increment))
  local after = pamixer.get()
  if (after ~= before) then pamixer.emit_signal('volume', after, before) end
  return after
end

function pamixer.dec(decrement)
  local before = pamixer.get()
  request('-d '..tostring(decrement))
  local after = pamixer.get()
  if (after ~= before) then pamixer.emit_signal('volume', after, before) end
  return after
end


-- mute
function pamixer.muted()
  return request('--get-mute') == 'true'
end

function pamixer.mute()
  local before = pamixer.muted()
  request('-m')
  local after = pamixer.muted()
  if (after ~= before) then pamixer.emit_signal('mute', after) end
  return after
end

function pamixer.unmute()
  local before = pamixer.muted()
  request('-u')
  local after = pamixer.muted()
  if (after ~= before) then pamixer.emit_signal('mute', after) end
  return after
end


return pamixer

