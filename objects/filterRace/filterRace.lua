species = {"generic", "human", "glitch", "hylotl", "apex", "avian", "floran", "novakid"}

function init(args)
  if not virtual then
    activate()
  end
end

-- Change Animation
function applySpeciesId()
  if storage.speciesId==nil then storage.speciesId = 1 
  elseif storage.speciesId > #species then storage.speciesId = 1 end  
    entity.setAnimationState("raceState", species[storage.speciesId])
end

function nextSpeciesId()
  if storage.speciesId==nil then storage.speciesId = 0 end
  storage.speciesId = storage.speciesId+1
  applySpeciesId()
end 

function activate()
--  world.logInfo("activating!")
  entity.setInteractive(true)
  applySpeciesId()
end

function onInteraction(args)
--  world.logInfo("interaction")
  nextSpeciesId()
--  entity.say(species[storage.speciesId])
end

function isActive()
  return not entity.isInboundNodeConnected(0) or entity.getInboundNodeLevel(0) and #pipeUtil.getOutputIds()>0
end 

function canReceiveItem(itemDescriptor)
  if isActive() then
    local race = species[storage.speciesId];
    local inRootConfig = root.itemConfig(itemDescriptor.name)
    --world.logInfo(table.show(inRootConfig, "inRootConfig"))

    local itemRace = nil
    if inRootConfig.config.race ~= nil then
      itemRace = inRootConfig.config.race
    else 
      for _,v in pairs(species) do
        if string.find(itemDescriptor.name, v) or string.find(inRootConfig.directory, v) then 
          itemRace = v 
          break
        end  
      end  

      if itemRace == nil then itemRace="generic" end
    end  

    return itemRace==race
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