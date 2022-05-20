local gears = require('gears')
local fs = require('elegant.fs')

local function load(path)
  local data = fs.read(path)
  local out = {}
  for _, line in ipairs(gears.string.split(data, '\n')) do
    if (#line > 0) then
      local key, value = line:match('^(%S+)%s+(.+)$')
      if (value:match('^-?%d*.?%d+$')) then value = tonumber(value) end
      out[key] = value
    end
  end
  return out
end

local function save(path, config)
  local out = ''
  for key, value in pairs(config) do 
    out = out .. string.format("%s %s\n", key, tostring(value))
  end
  fs.write(path, out)
end


return function (path, defaults)
  local config = gears.table.join(
    defaults,
    load(path)
  )
  
  config.save = function (data)
    local filtered = {}
    for k,v in pairs(data) do
      if (k ~= 'save' and config[k] ~= nil) then filtered[k] = v end
    end
    save(path, filtered)
  end
  return config
end

