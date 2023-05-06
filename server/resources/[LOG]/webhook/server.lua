
local VorpCore = {}

TriggerEvent("getCore", function(core)
    VorpCore = core
end)
--exports('send_to_splunk', function(data, source_type)
function send_to_splunk(data, source_type)
    local endpointUrl = "http://splunk-link:8088/services/collector/event"
    local authToken = "YOUR-HEC-TOKEN"
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
end
exports('send_to_splunk', send_to_splunk)
-- RegisterCommand("testing_splunk", function(src, args)
--   local message = args[1]
--    print(src .. " " .. json.encode(args))
--   local data = {message = message}
--   TriggerEvent("mailbox:broadcastMessage", src, "message")
-- end)

RegisterServerEvent("mailbox:broadcastMessage")
AddEventHandler('mailbox:broadcastMessage', function(data)
   data = json.encode(data)
   print(data)
   local sourceCharacter = VorpCore.getUser(source).getUsedCharacter
   local steamIdentifier =  VorpCore.getUser(source).getIdentifier()
   local what_were_sending = {data = data,
  char = sourceCharacter.firstname .. " " .. sourceCharacter.lastname,
  steamId = steamIdentifier}
   send_to_splunk(what_were_sending, "mailbox Broadcast")
end)


