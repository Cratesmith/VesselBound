function isActive()
  return not entity.isInboundNodeConnected(0) or entity.getInboundNodeLevel(0) and #pipeUtil.getOutboundIds()>0
end 

function canReceiveItem(itemDescriptor)
  return true
end

function canReceiveLiquid(liquidId, liquidLevel)
  return true
end

function receiveItem(itemDescriptor, pathIds)
  return pipeUtil.sendItem(itemDescriptor, entity.id(), pathIds)
end

function receiveLiquid(liquidId, liquidLevel, pathIds)
  return pipeUtil.sendLiquid(liquidId, liquidLevel, entity.id(), pathIds)
end