local gears = require('gears')

return function (patch)
  local signals = {}

  local event_emitter = patch or {}

  function event_emitter:connect_signal(signal, callback)
    if (not signals[signal])
      then signals[signal] = { callback }
      else table.insert(signals[signal], callback)
    end
  end

  function event_emitter:disconnect_signal(signal, callback)
    if (signals[signal]) then
      local index = gears.table.has_item(signals[signal], callback);
      if (index) then table.remove(signals[signal], index) end
    end
  end

  function event_emitter:emit_signal(signal, ...)
    if (signals[signal]) then
      for _, callback in ipairs(signals[signal]) do
        callback(...)
      end
    end
  end

  return event_emitter
end

