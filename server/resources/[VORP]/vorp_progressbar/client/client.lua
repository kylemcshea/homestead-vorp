-- Queue all progress tasks to prevent infinite loops and overlap
local queue = {}
local function _internalStart(message, miliseconds, cb, theme, color, width)
    if theme == nil then
        theme = "linear"
    end

    if color == nil then
        color = 'rgb(124, 45, 45)'
    end
    
    if width == nil then
        width = '20vw'
    end

    table.insert(queue, {
        message = message,
        callback = cb
    })

    SetNuiFocus(true, false)
    SendNUIMessage({
        type = 'vp-open',
        message = message,
        mili = miliseconds,
        theme = theme,
        color = color,
        width = width
    })
end


exports('initiate', function()
    local self = {}
    self.start = _internalStart
    return self
end)

-- Support `progressBar` resources `startUI` Export.
AddEventHandler('__cfx_export_progressBars_startUI', function(callback)
    callback(function (time, text)
        _internalStart(text, time)
    end)
end)

RegisterNUICallback('ProgressFinished', function(args, nuicb)
    SetNuiFocus(false, false)

    if queue[1].callback then
        queue[1].callback() 
    end

    table.remove(queue, 1) -- Remove prog from queue 
    
    nuicb('ok')
end)