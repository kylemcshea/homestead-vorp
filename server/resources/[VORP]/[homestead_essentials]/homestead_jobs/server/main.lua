local VorpCore = {}

TriggerEvent("getCore", function(core)
    VorpCore = core
end)

--- @param source integer
--- @param job string
--- @param jobgrade integer
VorpCore.addRpcCallback("homestead_jobs:validateJob", function(source, callback, job, jobgrade)
    local jobsData = LoadResourceFile(GetCurrentResourceName(), "shared/jobs.json")
    jobsData = json.decode(jobsData)
    local exists = false
    for job, grades in pairs(jobsData.Jobs) do
        if job == job then
            for grade, data in pairs(grades) do
                if grade == jobgrade then
                    exists = true
                end
            end
        end
    end
    cb(exists)
end)

RegisterCommand('writejobsTable', function(source,args)
    local jobs = {

    }
end)