function init(args)
  if not virtual then
    self.drainPos = entity.position()
  end
end

function isActive()
  return not object.isInputNodeConnected(0) or object.getInputNodeLevel(0)
end 

function canReceiveItem(itemDescriptor)
  return isActive()
end

function canReceiveLiquid(liquidId, liquidLevel)
  return isActive()
end

function receiveLiquid(liquidId, liquidLevel, pathIds)
  world.spawnLiquid(entity.position(), liquidId, liquidLevel)
  return nil
end

function receiveItem(itemDescriptor, pathIds)
  local liquidId, liquidLevel = pipeUtil.itemToLiquidIdAndLevel(itemDescriptor)
  if liquidId and liquidLevel then
    world.spawnLiquid(self.drainPos, liquidId, liquidLevel)
  else
    world.spawnItem(itemDescriptor.name, self.drainPos, itemDescriptor.count, itemDescriptor.parameters)
  end 

  return nil
end 

-- Removes objects at current position
function drainItems()
  local itemsIds = world.itemDropQuery(self.drainPos, 3)
  for _, itemId in pairs(itemsIds) do

    local fakeItemDescriptor = {name=world.entityName(itemId), count=1, parameters={}}
    if pipeUtil.canSendItem(fakeItemDescriptor) then

      local itemPos = world.entityPosition(itemId)
      local takenItem = world.takeItemDrop(itemId, entity.id())
      if takenItem then
        local remainingItem = pipeUtil.sendItem(takenItem, entity.id())
        if remainingItem then
          world.spawnItem(remainingItem.name, itemPos, remainingItem.count, remainingItem.parameters)
        end
      end

    end
  end
end

-- Removes Liquids at current position
function drainLiquids()
  local liquidAt = world.liquidAt(self.drainPos)
  if liquidAt then
    local liquidId = liquidAt[1]
    local liquidLevel = liquidAt[2]

    world.destroyLiquid(self.drainPos)  
    local remaining = pipeUtil.sendLiquid(liquidId, liquidLevel, entity.id())
    if remaining then
      world.spawnLiquid(entity.position(), liquidId, remaining)
    end
  end
end

function update(dt)
  if isActive() and #pipeUtil.getOutputIds() > 0 then
    drainLiquids()
    drainItems()
  end
end