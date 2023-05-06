--send_to_splunk = function(data, source_type)
exports('send_to_splunk', function(data, source_type)
--send_to_splunk = function(data, source_type)
    local endpointUrl = "http://192.155.90.34:8088/services/collector/event"
    local authToken = "ccd15f54-6701-41e0-80df-4e5622f14fd8"
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
  local endpointUrl = "http://192.155.90.34:8088/services/collector/event"
  local authToken = "ccd15f54-6701-41e0-80df-4e5622f14fd8"
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
