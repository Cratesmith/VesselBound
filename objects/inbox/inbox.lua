function isActive()
  return not entity.isInboundNodeConnected(0) or entity.getInboundNodeLevel(0)
end 

function canReceiveItem(itemDescriptor)
  return isActive() and world.containerItemsCanFit(entity.id(), itemDescriptor)>0
end

function canReceiveLiquid(liquidId, liquidLevel)
  return isActive()
end

function receiveLiquid(liquidId, liquidLevel)
  local itemDesc = pipeUtil.liquidToItemDescriptor(liquidId,liquidLevel)
  if not itemDesc then 
    return liquidLevel
  end 

  local remainingItem = world.containerAddItems(entity.id(), itemDesc)
  if remainingItem then
    return remainingItem.count + (liquidLevel-math.floor(liquidLevel))
  else 
    return (liquidLevel-math.floor(liquidLevel))
  end
end

function receiveItem(itemDesc)
  return world.containerAddItems(entity.id(), itemDesc)
end

function send()
  local remaining = {}
  for _,item in pairs(world.containerItems(entity.id())) do
    remaining[#remaining+1] = pipeUtil.sendItem(item)
    world.containerConsume(entity.id(), item)
  end

  for _,item in ipairs(remaining) do
    world.containerAddItems(entity.id(), item)
  end
end

function update(dt)
  if isActive() and #pipeUtil.getOutputIds() > 0 then       
    send()
  end
end