local VorpCore = {}

TriggerEvent("getCore", function(core)
    VorpCore = core
end)

local ON_DUTY_TABLE = {} -- { [job: string] = amount: number }

---@param job: string
---@return void
function addPlayerToJobTable(job, source)
    if (not source or not job) then return end

    local _source = tostring(source)

    if (not ON_DUTY_TABLE[job]) then
        ON_DUTY_TABLE[job] = { _source }
        devPrint('added new job to table: ' .. job)
        return
    end

    for key, value in pairs(ON_DUTY_TABLE[job]) do
        if (value == _source) then
            devPrint('player is already in table')
            return
        end
    end

    devPrint('adding player to table: ' .. _source .. ' ' .. _source)

    return table.insert(ON_DUTY_TABLE[job], _source)
end

---@param job: string
---@param source: string
---@return void
function removePlayerFromJobTable(job, source)
    if (not source or not job) then return end
    if (not ON_DUTY_TABLE[job]) then return end

    local _source = tostring(source)

    local removedPlayer = false

    for key, value in pairs(ON_DUTY_TABLE[job]) do
        if (value == _source) then
            table.remove(ON_DUTY_TABLE[job], key)
            removedPlayer = true
            devPrint('removed player from table: ' .. _source .. ' ' .. tostring(job))
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

---@param job: { string[] | string }
---@return number
function getOnDutyCount(job)
    if (not job) then return 0 end
    -- converts string to table if job is a string
    if (type(job) == 'string') then job = { job } end

    -- iterates through table and adds up all the values
    local player_count = 0

    for _key, value in pairs(job) do
        player_count = player_count + #ON_DUTY_TABLE[value] or 0
    end

    return player_count
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

--- @param source: string
--- @param job: { string | string[] }
VorpCore.addRpcCallback("dream_lib:Callback:getOnDutyCount", function(source, cb, job)
    -- converts string to table if job is a string
    if (type(job) == 'string') then job = { job } end

    cb(getOnDutyCount(job))
end)

VorpCore.addRpcCallback("dream_lib:Callback:getOnDutyPlayers", function(source, cb, job)
    cb(getOnDutyPlayers(job))
end)

if (IS_DEV_MODE) then
    RegisterCommand('job_table', function()
        devPrint('job table: ' .. json.encode(ON_DUTY_TABLE))
    end)

    RegisterCommand('test_add', function()
        addPlayerToJobTable('police', 2)
        addPlayerToJobTable('police', '2')
        addPlayerToJobTable('ambulance', '1')
        addPlayerToJobTable('ambulance', 1)
        addPlayerToJobTable('lawman', '4')
    end)

    RegisterCommand('test_remove', function()
        removePlayerFromJobTable('police', 2)
        removePlayerFromJobTable('ambulance', '1')
    end)

    RegisterCommand('test_police', function()
        print(getOnDutyCount('police'))
    end)

    RegisterCommand('test_ambulance', function()
        print(json.encode(getOnDutyPlayers('police')))
    end)
end