function init()
  storage = console.configParameter("scriptStorage")
  --world.logInfo("dump of storage "..dump(storage))
  
  local titleField = TextField(10, 212, 300, 20, "Write something here")
  titleField.text = storage.text or ""
  titleField.backgroundColor = {0, 0, 0, 128}
  titleField.defaultTextColor = {200,200,200}
  titleField.defaultTextHoverColor = {255,255,0}
  titleField.onEnter = function(field)
    field.defaultText = field.text    
    storage.text = field.text
    syncStorage()
  end
  GUI.add(titleField)

  if storage.listItems==nil then storage.listItems = {} end

   -- Create a list of 20 items
  local list = List(10, 0, 300, 200, 16, TextField)
  list.borderSize = 1
  list.itemPadding = 1
  list.borderColor = {10, 10, 10}
  list.backgroundColor = {0, 0, 0, 128}
  for i=1,20,1 do
    local item = list:emplaceItem()
    --world.logInfo("storage.listItems[".."i".."]"..dump(storage.listItems[i]))
    item.text = (storage.listItems[""..i] or "")
    item.borderColor = {25, 25, 25}
    item.defaultTextColor = {200,200,200}
    item.defaultTextHoverColor = {255,255,0}
    item.backgroundColor = {0, 0, 0}
    item.onEnter = function(field)
    		--world.logInfo("setting list item "..i.." to "..field.text)
    		field.defaultText = field.text    
    		storage.listItems[i] = field.text
    		syncStorage()
  		end
		end

	GUI.add(list)
end

function syncStorage()
  world.sendEntityMessage(console.sourceEntity(), "onConsoleStorageRecieve", storage)
end

function update(dt)
  GUI.step(dt)
end

function canvasClickEvent(position, button, pressed)
  GUI.clickEvent(position, button, pressed)
end

function canvasKeyEvent(key, isKeyDown)
  GUI.keyEvent(key, isKeyDown)
end