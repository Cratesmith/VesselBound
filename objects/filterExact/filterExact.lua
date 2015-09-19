function isActive()
  return not entity.isInboundNodeConnected(0) or entity.getInboundNodeLevel(0) and #pipeUtil.getOutputIds()>0
end 

function canReceiveItem(itemDescriptor)
  if isActive() then
    for _,item in pairs(world.containerItems(entity.id())) do
      if(itemDescriptor.name == item.name) then 
        --entity.say("yes:"..itemDescriptor.name)
        return not itemDescriptor.parameters or not itemDescriptor.parameters.generated
      end 
    end
  end   

  --entity.say("no:"..itemDescriptor.name)
  return false
end

function canReceiveLiquid(liquidId, liquidLevel)
  local itemDescriptor = pipeUtil.liquidToItemDescriptor(liquidId, liquidLevel)
  return canReceiveItem(itemDescriptor)
end

function receiveItem(itemDescriptor, pathIds)
  return pipeUtil.sendItem(itemDescriptor, entity.id(), pathIds)
end

function receiveLiquid(liquidId, liquidLevel, pathIds)
  return pipeUtil.sendLiquid(liquidId, liquidLevel, entity.id(), pathIds)
end