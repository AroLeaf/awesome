local gears = require('gears')

local Promise = {}


function Promise.new(func)
  local promise = {
    _success = {},
    _fail = {},
  }

  local function async_or_not(f, resolve, reject, async, ...)
    if async
      then f(resolve, reject, ...)
      else f(...)
    end
  end

  function promise.next(success, fail, async)
    if (type(fail) ~= 'function') then
      async = fail
      fail = nil
    end

    return Promise.new(function (resolve, reject)
      table.insert(promise._success, function (...)
        async_or_not(success, resolve, reject, async, ...)
      end)

      if fail then table.insert(promise._fail, function (...) async_or_not(fail, resolve, reject, async, ...) end) end
    end)
  end

  function promise.catch(fail, async)
    return Promise.new(function (resolve, reject)
      table.insert(promise._success, function (...)
        resolve(...)
      end)
      table.insert(promise._fail, function (...)
        async_or_not(fail, resolve, reject, async, ...)
      end)
    end)
  end

  local handled = false

  local function resolve(...)
    if handled then return end
    handled = true
    for _, next in ipairs(promise._success) do next(...) end
  end

  local function reject(...)
    if handled then return end
    handled = true
    for _, fail in ipairs(promise._fail) do fail(...) end
  end

  gears.timer.delayed_call(func, resolve, reject)

  return promise
end


function Promise.promisify(func)
  return function (...)
    local args = table.pack(...)
    return Promise.new(function (resolve, reject)
      func(table.unpack(args), function (err, ...)
        if (err) then reject(err) else resolve(...) end
      end)
    end)
  end
end


return Promise

