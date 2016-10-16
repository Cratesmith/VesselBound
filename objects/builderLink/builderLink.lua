require "/scripts/vec2.lua"
require "/scripts/util.lua"
require "/scripts/pipeUtil.lua"
require "/scripts/itemUtil.lua"

function init(args)
  object.setInteractive(true)
  if not virtual then
    self.prevBuilder = self.builderId
  end

end

function isActive()
  return not object.isInputNodeConnected(0) or object.getInputNodeLevel(0)
end 

function canReceiveItem(itemDescriptor)
  --return isActive() and self.builderId and world.containerItemsCanFit(self.builderId, itemDescriptor)>0
  return false
end

function canReceiveLiquid(liquidId, liquidLevel)
  --return isActive() and self.builderId
  return false
end

function receiveLiquid(liquidId, liquidLevel, pathIds)
  --local itemDesc = pipeUtil.liquidToItemDescriptor(liquidId,liquidLevel)
  --if not itemDesc then 
  --  return liquidLevel
  --end 
--
  --local remainingItem = receiveItem(itemDesc)
  --if remainingItem then
  --  return remainingItem.count + (liquidLevel-math.floor(liquidLevel))
  --else 
  --  return (liquidLevel-math.floor(liquidLevel))
  --end
end

function receiveItem(itemDescriptor, pathIds)
  --return world.containerAddItems(self.builderId, itemDescriptor)
end

function send()
  --local remaining = {}
  --for _,item in pairs(world.containerItems(self.builderId)) do
  --  remaining[#remaining+1] = pipeUtil.sendItem(item, entity.id())
  --  world.containerConsume(self.builderId, item)
  --end
--
  --for _,item in ipairs(remaining) do
  --  world.containerAddItems(self.builderId, item)
  --end
end

--function onInteraction(args)
  --testBuildAllRecipes()
--end

-- returns a table of itemName,recipeTable pairs that this builder can make
function getItemRecipes()
  if self.builderId == nil then return {} end 
  local builderStage = world.callScriptedEntity(self.builderId, "currentStageData")
  local interactData = nil;
  if(builderStage~=nil) then 
    interactData = builderStage.interactData;
  else 
    interactData = world.getObjectParameter(self.builderId, "interactData")
  end  

  if(interactData==nil) then return {} end 
    
  local filters = interactData.filter;
  local filterSet = {}
  for _, filter in ipairs(filters) do
    filterSet[filter] = true;
  end 

  --object.say(table.show(filterSet))
  --sb.logInfo(table.show(interactData))
--  object.say(table.show(interactData))

  local playerConfig = root.assetJson("/player.config")
  if(playerConfig == nil) then return {} end

  --sb.logInfo(table.show(playerConfig))
  local blueprints = playerConfig.defaultBlueprints.tier1;
  if(blueprints == nil) then return {} end
  --sb.logInfo(table.show(blueprints))

  local matchedRecipes = {}
  for _, itemName in ipairs(blueprints) do
    local recipes = root.recipesForItem(itemName.item)
    --sb.logInfo(table.show(recipes))
    for _, recipe in ipairs(recipes) do
      if(filterSet[recipe.groups[1]]) then        
        matchedRecipes[itemName.item] = recipe
      end
    end
  end  

  return matchedRecipes
end

function testBuildAllRecipes()
  local matchedRecipes = getItemRecipes()

  --sb.logInfo(table.show(matchedRecipes))
  for itemName, recipe in pairs(matchedRecipes) do
    --sb.logInfo(itemName)
    world.spawnItem(itemName, entity.position(), 1)
  end
  --object.say(table.show(playerConfig))
end

function testBuildFromContainer()
  local matchedRecipes = getItemRecipes()
  for itemName, recipe in pairs(matchedRecipes) do
    local requiredInputs = {}
    sb.logInfo(table.show(recipe))
    for _, inputItem in ipairs(recipe.input) do
      requiredInputs[inputItem.name] = inputItem.count
    end    

    for _,itemDescriptor in pairs(world.containerItems(entity.id())) do
      local requiredCount = requiredInputs[itemDescriptor.name]
      if requiredCount and requiredCount > 0 then      
        local usedItems = math.min(requiredCount, itemDescriptor.count)
        requiredCount = requiredCount - usedItems
        if requiredCount == 0 then 
          requiredInputs[itemDescriptor.name]=nil
        else 
          requiredInputs[itemDescriptor.name]=requiredCount 
        end
      end
    end

    -- build and use items if no requirements remain
    --object.say(table.show(requiredInputs))
    if next(requiredInputs) == nil then
      for _, inputItem in ipairs(recipe.input) do
        world.containerConsume(entity.id(), inputItem)
      end    
      world.spawnItem(itemName, entity.position(), 1)
    end
  end
end

function findBuilder()
  self.builderId = nil  
  local objectIds = world.objectQuery(entity.position(), 50, { order = "nearest" })
  for _, objectId in ipairs(objectIds) do
    local objName = world.entityName(objectId)
    local itemDescriptor = {name=objName, count=1}
    local category = itemUtil.getCategory(itemDescriptor);
    if category == "crafting" then
      self.builderId = objectId
      break
    end
  end 
end


function checkSayStorageChange( ... )
  if self.builderId ~= self.prevBuilder then
    if self.builderId == nil then
      self.sayText = "disconnected!"
    else 
      self.sayText = "connted to:"..world.entityName(self.builderId)
    end
  end

  self.prevBuilder = self.builderId
end


function update(dt)
  testBuildFromContainer()
  if self.sayText ~= nil then
    object.say(self.sayText)
    self.sayText = nil
  end

  if not self.builderId or not world.entityExists(self.builderId) then
    findBuilder() 
  end

  checkSayStorageChange()  
  
  if isActive() then
    if self.builderId and #pipeUtil.getOutputIds() > 0 then      
      send()
    end
  end
end