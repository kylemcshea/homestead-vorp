
local VorpCore = {}

TriggerEvent("getCore", function(core)
    VorpCore = core
end)

function send_to_splunk(data, source_type)
    local endpointUrl = "YOUR SPLUNK LINK HERE"
    local authToken = "YOUR SPLUNK TOKEN HERE"
    local index = "main"
    local sourcetype = source_type
    local headers = {
        ["Authorization"] = "Splunk " .. authToken,
        ["Content-Type"] = "application/json",
    
      }
      local body = json.encode({
        index = index,
        sourcetype = sourcetype,
        event = data
      })
      PerformHttpRequest(endpointUrl, function(statusCode, responseBody, responseHeaders)
        if statusCode ~= 200 then
          print("Failed to send data to Splunk:", responseBody)
        end
      end, "POST", body, headers)
end -- ends send_to_splunk



function send_to_discord(data, channel)
  local channel = channel
  local discord = ""
  if channel == "mailbox Broadcast"   then
      --enter discord link next line for that channel
      discord = "YOUR-FIRST-DISCORD-WEBHOOK-HERE" 
  elseif channel == "chat" then
      --enter discord link next line for that channel
      discord = "YOUR-SECOND-DISCORD-WEBHOOK-HERE" 
  elseif channel == "bank" then
      --enter discord link next line for that channel
 elseif channel == "inventory" then
      --enter discord link next line for that channel
  end
  local headers = {
    ["Content-Type"] = "application/json"
  }
  local decoded_data = json.decode(data.data)
  local message = decoded_data.message
  local discord_body = json.encode({
    username = data.char,
    content = message,        
  })

  PerformHttpRequest(discord, function(statusCode, responseText, headers)
    if statusCode ~= 204 then
      print("Failed to send message to Discord webhook:", responseText)
    end
  end, "POST", discord_body, headers)
end -- end of send to discord



exports('send_to_splunk', send_to_splunk)
exports('send_to_discord', send_to_discord)

-- RegisterCommand("testing_splunk", function(src, args)
--   local message = args[1]
--    print(src .. " " .. json.encode(args))
--   local data = {message = message}
--   TriggerEvent("mailbox:broadcastMessage", src, "message")
-- end)


RegisterServerEvent("mailbox:broadcastMessage")
AddEventHandler('mailbox:broadcastMessage', function(data)
   data = json.encode(data)
   --print(data)
   local sourceCharacter = VorpCore.getUser(source).getUsedCharacter
   local steamIdentifier =  VorpCore.getUser(source).getIdentifier()
   local what_were_sending = {data = data,
  char = sourceCharacter.firstname .. " " .. sourceCharacter.lastname,
  steamId = steamIdentifier}
   send_to_splunk(what_were_sending, "mailbox Broadcast")
   send_to_discord(what_were_sending, "mailbox Broadcast")
end
)

RegisterServerEvent("vorpCoreClient:addItem")
AddEventHandler("vorpCoreClient:addItem", function(_source, item)
  local what_were_sending = {source = _source, item=item}
  send_to_splunk(what_were_sending,"inventory")
end)

AddEventHandler("chatMessage", function(source, author, text)
  local data = json.encode({message = text})
  local sourceCharacter = VorpCore.getUser(source).getUsedCharacter
  local steamIdentifier =  VorpCore.getUser(source).getIdentifier()
  local what_were_sending = { 
    data = data,
    char = sourceCharacter.firstname .. " " .. sourceCharacter.lastname .. "("..author..")",    
  }
  send_to_discord(what_were_sending, "chat")
  local for_splunk ={author = author, char =sourceCharacter.firstname .. " " .. sourceCharacter.lastname, message = text, }
  send_to_splunk(for_splunk, "chat")
end)