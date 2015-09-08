function init(args)
  if not virtual then
    self.prevContainer = storage.containerId
  end
end

function isActive()
  return not entity.isInboundNodeConnected(0) or entity.getInboundNodeLevel(0)
end 

function canReceiveItem(itemDescriptor)
  return isActive() and storage.containerId and world.containerItemsCanFit(storage.containerId, itemDescriptor)>0
end

function canReceiveLiquid(liquidId, liquidLevel)
  return isActive() and storage.containerId
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
  return world.containerAddItems(storage.containerId, itemDesc)
end

function send()
  local remaining = {}
  for _,item in pairs(world.containerItems(storage.containerId)) do
    remaining[#remaining+1] = pipeUtil.sendItem(item)
    world.containerConsume(storage.containerId, item)
  end

  for _,item in ipairs(remaining) do
    world.containerAddItems(storage.containerId, item)
  end
end

function findContainer()
  storage.containerId = nil

  local objectIds = world.objectQuery(entity.position(), 50, { order = "nearest" })
  for _, objectId in ipairs(objectIds) do
    if world.containerSize(objectId) then
      storage.containerId = objectId
      break
    end
  end 
end


function checkSayStorageChange( ... )
  if storage.containerId ~= self.prevContainer then
    if storage.containerId == nil then
      self.sayText = "disconnected!"
    else 
      self.sayText = "connted to:"..world.entityName(storage.containerId)
    end
  end

  self.prevContainer = storage.containerId
end


function update(dt)
  if self.sayText ~= nil then
    entity.say(self.sayText)
    self.sayText = nil
  end

  if not storage.containerId or not world.entityExists(storage.containerId) then
    findContainer() 
  end

  checkSayStorageChange()  
  
  if isActive() then
    if storage.containerId and #pipeUtil.getOutputIds() > 0 then      
      send()
    end
  end
end