local fetch = require('lib/fetch')

local base = 'https://api.openweathermap.org/'

return function (key)
  local openweathermap = { key = key }

  function openweathermap:geo(location)
    return fetch(base .. 'geo/1.0/direct', {
      q = location,
      limit = 1,
      appid = key,
    }).next(function (res, _, data) res(data[1]) end, true)
  end

  function openweathermap:now(loc)
    return fetch(base .. 'data/2.5/weather', {
      lon = loc.lon,
      lat = loc.lat,
      appid = key,
      units = 'metric',
    })
  end

  return openweathermap
end

