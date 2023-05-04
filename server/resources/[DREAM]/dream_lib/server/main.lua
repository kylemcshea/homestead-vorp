local VorpCore = {}

TriggerEvent("getCore", function(core)
    VorpCore = core
end)

local ON_DUTY_TABLE = {} -- { [job: string] = amount: number }

---@param job: string
---@return void
function addPlayerToJobTable(job, source)
    if (not source or not job) then return end
    
    if (not ON_DUTY_TABLE[job]) then
        ON_DUTY_TABLE[job] = { tostring(source) }
        devPrint('added new job to table: ' .. job)
        return
    end
    
    -- checks ON_DUTY_TABLE[job] if source is already in there.
    for key, value in pairs(ON_DUTY_TABLE[job]) do
        if (value == tostring(source)) then
            devPrint('player is already in table')
            return
        end
    end

    devPrint('adding player to table: ' .. tostring(source) .. ' ' .. tostring(job))

    return table.insert(ON_DUTY_TABLE[job], tostring(source))
end

---@param job: string
---@param source: string
---@return void
function removePlayerFromJobTable(job, source)
    if (not source or not job) then return end
    if (not ON_DUTY_TABLE[job]) then return end

    local removedPlayer = false

    for key, value in pairs(ON_DUTY_TABLE[job]) do
        if (value == tostring(source)) then
            table.remove(ON_DUTY_TABLE[job], key)
            removedPlayer = true
            devPrint('removed player from table: ' .. tostring(source) .. ' ' .. tostring(job))
            break
        end
    end

    devPrint('did we remove player? ' .. tostring(removedPlayer))
end

function handlePlayerJobChange(source, newJob, oldJob)
    -- remove old job from table
    removePlayerFromJobTable(oldJob, source)
    -- add new job to table
    addPlayerToJobTable(newJob, source)
end

---@param job: string
---@return number
function getOnDutyCount(job)
    return #ON_DUTY_TABLE[job] or 0
end

---@param job: string
---@return table: string[]
function getOnDutyPlayers(job)
    return ON_DUTY_TABLE[job] or {}
end

RegisterServerEvent('dream_lib:addPlayerToJobTable', function(source, job)
    if (not job or job == '') then
        job = VorpCore.getUser(source).getUsedCharacter.job
    end

    devPrint('adding player to table: ' .. tostring(source) .. ' ' .. tostring(job))

    addPlayerToJobTable(job, source)
end)

RegisterServerEvent('dream_lib:removePlayerFromJobTable', function(source, job)
    if (not job or job == '') then
        job = VorpCore.getUser(source).getUsedCharacter.job
    end

    devPrint('adding player to table: ' .. tostring(source) .. ' ' .. tostring(job))

    removePlayerFromJobTable(job, source)
end)

RegisterServerEvent('dream_lib:playerJobChange', function(source, newJob, oldJob)
    local str_source = tostring(source)
    handlePlayerJobChange(str_source, newJob, oldJob)
end)

VorpCore.addRpcCallback("dream_lib:Callback:getOnDutyCount", function(source, cb, job)
    cb(getOnDutyCount(job))
end)

VorpCore.addRpcCallback("dream_lib:Callback:getOnDutyPlayers", function(source, cb, job)
    cb(getOnDutyPlayers(job))
end)

if (IS_DEV_MODE) then
    RegisterCommand('job_table', function()
        devPrint('job table: ' .. json.encode(ON_DUTY_TABLE))
    end)
end