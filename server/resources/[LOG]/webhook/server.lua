--send_to_splunk = function(data, source_type)
exports('send_to_splunk', function(data, source_type)
--send_to_splunk = function(data, source_type)
    local endpointUrl = "http://splunk-link-here/services/collector/event"
    local authToken = "SPLUNK-HEC-TOKEN-HERE"
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
end)

RegisterCommand('splunktest', function(source, args)
  local endpointUrl = "http://splunk-link-here/services/collector/event"
  local authToken = "SPLUNK-HEC-TOKEN-HERE"
  local index = "main"
  local sourcetype = "redm_log"
  local headers = {
      ["Authorization"] = "Splunk " .. authToken,
      ["Content-Type"] = "application/json",
  
    }
    local body = json.encode({
      index = index,
      sourcetype = sourcetype,
      event = "this is what was sent"
    })
    PerformHttpRequest(endpointUrl, function(statusCode, responseBody, responseHeaders)
      if statusCode ~= 200 then
        print("Failed to send data to Splunk:", responseBody)
      end
    end, "POST", body, headers)
  
end)

AddEventHandler('gameEventTriggered', function(name, args)
  exports.webhook:send_to_splunk('game event ' .. name .. ' (' .. json.encode(args) .. ')', "gameEventTrigger")
end)

AddEventHandler('EVENT_SHOT_FIRED', function(name, args)
  exports.webhook:send_to_splunk('game event ' .. name .. ' (' .. json.encode(args) .. ')', "gameEventTrigger")
end)
