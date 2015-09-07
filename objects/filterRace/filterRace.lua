function isActive()
  return not entity.isInboundNodeConnected(0) or entity.getInboundNodeLevel(0) and #pipeUtil.getOutputIds()>0
end 

function canReceiveItem(itemDescriptor)
  if isActive() then
    local inRootConfig = root.itemConfig(itemDescriptor.name)

    for _,item in pairs(world.containerItems(entity.id())) do
      local filterRootConfig = root.itemConfig(item.name)
      if filterRootConfig.race and inRootConfig.race and (inRootConfig.race == filterRootConfig.race) then 
        --entity.say("yes:"..itemDescriptor.name.."("..filterRootConfig.race..")")
        return true
      end 
    end
  end   

  return false
end

function canReceiveLiquid(liquidId, liquidLevel)
  local itemDescriptor = pipeUtil.liquidToItemDescriptor(liquidId, liquidLevel)
  return canReceiveItem(itemDescriptor)
end

function receiveItem(itemDesc)
  return pipeUtil.sendItem(itemDesc)
end

function receiveLiquid(liquidId, liquidLevel)
  return pipeUtil.sendLiquid(liquidId, liquidLevel)
end