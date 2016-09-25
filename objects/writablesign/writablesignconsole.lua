function init()
  storage = console.configParameter("scriptStorage")
  
  local titleField = TextField(10, 212, 300, 20, storage.text or "Write something here")
  titleField.defaultTextColor = {200,200,200}
  titleField.defaultTextHoverColor = {255,255,0}
  titleField.onEnter = function(field)
    field.defaultText = field.text    
    storage.text = field.text
    syncStorage()
  end
  GUI.add(titleField)

  
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