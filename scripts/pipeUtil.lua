pipeUtil = {
  liquidIds = {
    "liquidwater", 
    "liquidlava", 
    "liquidpoison",
    "liquidalienjuice",
    "liquidoil",
    "liquidhealing",
    "liquidmilk",
    "liquidlava",
    "liquidcoffee",
    "liquidwater",
    "liquidfuel",
    "swampwater",
    "liquidoil"
  }
}

function pipeUtil.itemToLiquidIdAndLevel(itemDescriptor)
  for i,v in ipairs(pipeUtil.liquidIds) do
    if itemDescriptor.name==v then
      return i,itemDescriptor.count
    end 
  end

  return nil
end

function pipeUtil.liquidToItemDescriptor(liquidId, liquidLevel)
  if liquidId > 0 and liquidId <= #pipeUtil.liquidIds and liquidLevel >= 1 then
    return {name=pipeUtil.liquidIds[liquidId], count=liquidLevel, parameters={} }
  end
  
  return nil
end

function pipeUtil.canSendItem(itemDescriptor)
  local outputIds = pipeUtil.getOutputIds()
  local remainingItems = itemDescriptor
  for _, outputId in ipairs(outputIds) do 
    if world.callScriptedEntity(outputId, "canReceiveItem", remainingItems) then
      return true
    end
  end

  return false
end

function pipeUtil.sendItem(itemDescriptor)
  local outputIds = pipeUtil.getOutputIds()
  local remainingItems = itemDescriptor
  for _, outputId in ipairs(outputIds) do 
    if world.callScriptedEntity(outputId, "canReceiveItem", remainingItems) then
      remainingItems = world.callScriptedEntity(outputId, "receiveItem", remainingItems)
      if not remainingItems then
        break
      end 
    end 
  end

  return remainingItems
end

function pipeUtil.sendLiquid(liquidType, liquidLevel)
  local outputIds = pipeUtil.getOutputIds()
  local remainingLiquid = liquidLevel
  for _, outputId in ipairs(outputIds) do 
    if world.callScriptedEntity(outputId, "canReceiveLiquid", liquidType, remainingLiquid) then
      remainingLiquid = world.callScriptedEntity(outputId, "receiveLiquid", liquidType, remainingLiquid )
      if remainingLiquid == 0 then
        break
      end 
    end
  end

  return remainingLiquid  
end

local function spairs(t, order)
    -- collect the keys
    local keys = {}
    for k in pairs(t) do keys[#keys+1] = k end

    -- if order function given, sort by it by passing the table and keys a, b,
    -- otherwise just sort the keys 
    if order then
        table.sort(keys, function(a,b) return order(t[a], t[b]) end)
    else
        table.sort(keys)
    end

    -- return the iterator function
    local i = 0
    return function()
        i = i + 1
        if keys[i] then
            return keys[i], t[keys[i]]
        end
    end
end


-- Returns all output ids as an array
function pipeUtil.getOutputIds()
  local outboundIds = entity.getOutboundNodeIds(0)
  local temp = {}
  for id, tableData in pairs(outboundIds) do 
    table.insert(temp, {id=id, dist=vec2.mag(entity.distanceToEntity(id))}) 
  end

  local outputIds = {}
  for _, id in spairs(temp, function(a,b) 
      return b.dist < a.dist 
    end) do 
    table.insert(outputIds, id.id) 
  end

  return outputIds
end