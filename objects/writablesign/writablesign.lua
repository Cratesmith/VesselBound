function init(virtual)
  if not virtual then
    storage.consoleStorage = storage.consoleStorage or {}
    entity.setInteractive(true)

    message.setHandler("onConsoleStorageRecieve", function(_, _, consoleStorage)
      world.logInfo("updating storage:"..(consoleStorage.text or "nil"))
      storage.consoleStorage = consoleStorage
    end)

  end
end

function onInteraction(args)
  entity.say(storage.consoleStorage.text or "nil")
  local interactionConfig = entity.configParameter("interactionConfig")
  interactionConfig.scriptStorage = storage.consoleStorage
  return {"ScriptConsole", interactionConfig}
end
