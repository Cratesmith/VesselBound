function isActive()
  return not entity.isInboundNodeConnected(0) or entity.getInboundNodeLevel(0) and #pipeUtil.getOutboundIds()>0
end 

function canReceiveItem(itemDescriptor)
  return true
end

function canReceiveLiquid(liquidId, liquidLevel)
  return true
end

function receiveItem(itemDesc)
  return pipeUtil.sendItem(itemDesc)
end

function receiveLiquid(liquidId, liquidLevel)
  return pipeUtil.sendLiquid(liquidId, liquidLevel)
end