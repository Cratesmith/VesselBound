function isActive()
  return not entity.isInboundNodeConnected(0) or entity.getInboundNodeLevel(0)
end 

function canReceiveItem(itemDescriptor)
  return isActive() and self.containerId and world.containerItemsCanFit(self.containerId, itemDescriptor)>0
end

function canReceiveLiquid(liquidId, liquidLevel)
  return isActive() and self.containerId
end

function receiveLiquid(liquidId, liquidLevel)
  local itemDesc = pipeUtil.liquidToItemDescriptor(liquidId,liquidLevel)
  if not itemDesc then 
    return liquidLevel
  end 

  local remainingItem = receiveItem(itemDesc)
  if remainingItem then
    return remainingItem.count + (liquidLevel-math.floor(liquidLevel))
  else 
    return (liquidLevel-math.floor(liquidLevel))
  end
end

function receiveItem(itemDesc)
  return world.containerAddItems(self.containerId, itemDesc)
end

function send()
  local remaining = {}
  for _,item in pairs(world.containerItems(self.containerId)) do
    remaining[#remaining+1] = pipeUtil.sendItem(item)
    world.containerConsume(self.containerId, item)
  end

  for _,item in ipairs(remaining) do
    world.containerAddItems(self.containerId, item)
  end
end

function findContainer()
  local objectIds = world.objectQuery(entity.position(), 50, { order = "nearest" })
  for _, objectId in ipairs(objectIds) do
    if world.containerSize(objectId) then
      if self.containerId ~= objectId then
        self.containerId = objectId
        entity.say("connted to:"..world.entityName(objectId))
      end 
      return
    end
  end 

  self.containerId = nil
end

function update(dt)
  if not self.containerId or not world.entityExists(self.containerId) then
    findContainer() 
  end
  
  if isActive() then
    if self.containerId and #pipeUtil.getOutputIds() > 0 then      
      send()
    end
  end
end