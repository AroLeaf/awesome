local gears = require('gears')
local json = require('lib/lunajson')
local fs = require('lib/fs')

local function readJSON(path)
  local data = fs.read(path)
  return #data ~= 0 and json.decode(data) or {}
end

local function writeJSON(path, config)
  fs.write(path, json.encode(config))
end


return function (path, defaults)
  local config = gears.table.join(
    defaults,
    readJSON(path)
  )
  
  config.save = function (data)
    local filtered = {}
    for k,v in pairs(data) do
      if (k ~= 'save' and config[k] ~= nil) then filtered[k] = v end
    end
    writeJSON(path, filtered)
  end
  return config
end

