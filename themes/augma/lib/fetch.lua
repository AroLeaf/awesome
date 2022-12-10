local awful = require('awful')
local json = require('lunajson')
local promise = require('lib.promise')

local function fetch(url, query)
  local queryargs = ''
  for k,v in pairs(query) do
    queryargs = queryargs .. ' --data-urlencode "' .. k .. '=' .. v .. '"'
  end

  return promise.new(function (res)
    awful.spawn.easy_async('curl --get ' .. queryargs .. ' ' .. url, function (stdout) res(json.decode(stdout)) end)
  end)
end

return fetch
