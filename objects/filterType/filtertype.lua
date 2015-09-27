types = {
  { group= "generic",   options={"generic", "coin", "celestialitem"} }, 
  { group= "material",  options={"material"} }, 
  { group= "tool",      options={"miningtool", 
                              "flashlight", 
                              "wiretool", 
                              "beamminingtool", 
                              "tillingtool", 
                              "paintingbeamtool", 
                              "harvestingtool",
                              "instrument",
                              "grapplinghook",
                              "thrownitem"}},
  { group= "weapon",    options={"gun", "sword", "shield"} },
  { group= "armor",     options={"headarmor", "chestarmor", "legsarmor", "backarmor"} }, 
  { group= "consumable",options={"consumable"} },
  { group= "books",     options={"blueprint", "codex"} },
}

function init(args)
  if not virtual then
    activate()
  end
end

-- Change Animation
function applyTypeId()
  if storage.typeId==nil then storage.typeId = 1 
  elseif storage.typeId > #types then storage.typeId = 1 end  
  entity.setAnimationState("typeState", types[storage.typeId].group)
end

function nextTypeId()
  if storage.typeId==nil then storage.typeId = 0 end
  storage.typeId = storage.typeId+1
  applyTypeId()
end 

function activate()
--  world.logInfo("activating!")
  entity.setInteractive(true)
  applyTypeId()
end

function onInteraction(args)
--  world.logInfo("interaction")
  nextTypeId()
--  entity.say(types[storage.typeId])
end

function isActive()
  return not entity.isInboundNodeConnected(0) or entity.getInboundNodeLevel(0) and #pipeUtil.getOutputIds()>0
end 

function getType(itemDescriptor)
  local itemType = root.itemType(itemDescriptor.name)

  for _,group in pairs(types) do
    for _,v in pairs(group.options) do 
      if v==itemType then 
        return group.group
      end
    end
  end

  return "generic"
end

function canReceiveItem(itemDescriptor)
  if isActive() then
    local currentType = types[storage.typeId].group;
    local itemType = getType(itemDescriptor)
    return itemType==currentType
  end   

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