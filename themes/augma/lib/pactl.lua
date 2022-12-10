local awful = require('awful')
local gears = require('gears')
local json = require('lunajson')
local event_emitter = require('lib/eventemitter')
local promise = require('lib/promise')

local pactl = event_emitter({
  sinks = {},
  sink_inputs = {},
  sources = {},
  source_outputs = {},
})


function pactl.construct_command(command, instance, ...)
  local cmd = gears.string.split(command, '-')
  local args = table.concat(table.pack(...), ' ')
  return string.format(
    "%s-%s-%s %s %s",
    cmd[1],
    instance.type:gsub('_', '-'),
    cmd[2],
    instance.index,
    args
  )
end


function pactl.request(command)
  return promise.new(function (resolve)
    awful.spawn.easy_async('pactl -f json '..command, function (stdout)
      if #stdout > 0 then resolve(json.decode(stdout)) end
    end)
  end)
end


function pactl.new(type, data)
  local instance = event_emitter(data)

  instance.type = type

  function instance:set_volume(volume)
    local command = pactl.construct_command('set-volume', instance, tostring(volume))
    return pactl.request(command)
  end

  function instance:set_mute(muted)
    if (muted == true) then muted = '1'
    elseif (muted == false) then muted = '0'
    else muted = tostring(muted) end

    local command = pactl.construct_command('set-mute', instance, muted)
    return pactl.request(command)
  end

  function instance:set_balance(balance, rel)
    balance = math.min(math.max(balance + (rel and instance.balance or 0), -1), 1)

    local left = instance.volume['front-left'].value
    local right = instance.volume['front-right'].value

    local max = math.max(left, right)

    local function round(val) return math.floor(val + 0.5) end
    local function relative(val, to)
      local res = val - to
      return res < 0
        and tostring(res)
        or '+'..tostring(res)
    end

    left = relative(balance >= 0 and round(max * (1-balance)) or max, left)
    right = relative(balance < 0 and round(max * (1+balance)) or max, right)

    local command = pactl.construct_command('set-volume', instance, left, right)
    return pactl.request(command)
  end

  return instance
end


function pactl.list(type, short)
  local command = short
    and 'list '..type:gsub('_', '-')..' short'
    or 'list '..type:gsub('_', '-')
  return pactl.request(command)
end


function pactl.get_idx_by_id(table, id)
  return gears.table.find_first_key(table, function (_, item) return item.index == id end)
end

function pactl.get_by_id(table, id)
  return table[pactl.get_idx_by_id(table, id)]
end


function pactl.add(type, id)
  pactl.list(type..'s').next(function (list)
    local instance = pactl.new(type, pactl.get_by_id(list, id))
    table.insert(pactl[type..'s'], instance)
    pactl:emit_signal('new', instance)
  end)
end


function pactl.update(type, id)
  pactl.list(type..'s').next(function (list)
    local data = pactl.get_by_id(list, id)
    local instance = pactl.get_by_id(pactl[type..'s'], id)
    gears.table.crush(instance, data)
    pactl:emit_signal('update', instance)
    instance:emit_signal('update', instance)
  end)
end


function pactl.remove(type, id)
  local index = pactl.get_idx_by_id(pactl[type..'s'], id)
  if (index) then
    local instance = pactl[type..'s'][index]
    table.remove(pactl[type..'s'], index)
    pactl:emit_signal('remove', instance)
  end
end


function pactl.set_default_sink_volume(volume)
  pactl.request('set-sink-volume @DEFAULT_SINK@ ' .. tostring(volume))
end

function pactl.set_default_sink_mute(muted)
  if type(muted) == 'boolean'
    then muted = muted and '1' or '0'
    else muted = tostring(muted)
  end
  pactl.request('set-sink-mute @DEFAULT_SINK@ ' .. muted)
end


function pactl.init()
  local function handle_event(line)
    local event, type, id = line:match("Event '(.*)' on (%S*) #(%d+)");
    type = type:gsub('-', '_')
    id = tonumber(id)

    if (gears.table.hasitem({   'sink', 'sink_input', 'source', 'source_output' }, type)) then
      local switch = {
        new    = function () pactl.add    (type, id) end,
        update = function () pactl.update (type, id) end,
        remove = function () pactl.remove (type, id) end,
      }
      if switch[event] then switch[event]() end
    end
  end

  local function on_load()
    local pid = awful.spawn.with_line_callback('pactl subscribe', { stdout = handle_event })

    awesome.connect_signal('exit', function ()
      awful.spawn('kill '..pid)
    end)

    pactl:emit_signal('ready')
  end

  pactl.list('').next(function (data)
    for _, type in ipairs({ 'sinks', 'sink_inputs', 'sources', 'source_outputs' }) do
      for _, item in ipairs(data[type]) do
        table.insert(pactl[type], pactl.new(type:sub(1, -2), item))
      end
    end

    on_load()
  end)
end


return pactl

