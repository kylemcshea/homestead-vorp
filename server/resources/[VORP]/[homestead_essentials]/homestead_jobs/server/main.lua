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
    jobgrade = tostring(jobgrade)
    
    cb(jobsData.Jobs[job] and jobsData.Jobs[job][jobgrade])
end)