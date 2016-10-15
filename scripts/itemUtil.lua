itemUtil = {}

function itemUtil.getCategory(itemDescriptor)
  if itemDescriptor.parameters and itemDescriptor.parameters.itemName == "generatedgun" then
    return itemDescriptor.parameters.weaponType
  end

  local inRootConfig = pipeUtil.itemConfig(itemDescriptor)
  if inRootConfig then
    return inRootConfig.config.category  
  end 
  
  return nil
end