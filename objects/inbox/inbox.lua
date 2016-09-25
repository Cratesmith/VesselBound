function isActive()
  return not object.isInputNodeConnected(0) or object.getInputNodeLevel(0)
end 

function canReceiveItem(itemDescriptor)
  return isActive() and world.containerItemsCanFit(entity.id(), itemDescriptor)>0
end

function canReceiveLiquid(liquidId, liquidLevel)
  return isActive()
end

function receiveLiquid(liquidId, liquidLevel, pathIds)
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

function receiveItem(itemDescriptor, pathIds)
  return world.containerAddItems(entity.id(), itemDescriptor)
end

function send()
  local remaining = {}
  for _,item in pairs(world.containerItems(entity.id())) do
    remaining[#remaining+1] = pipeUtil.sendItem(item, entity.id())
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