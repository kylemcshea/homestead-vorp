
--- @param source integer
--- @param job string
--- @param jobgrade integer
function validateJob(job, jobgrade)
    local jobsData = LoadResourceFile(GetCurrentResourceName(), "shared/jobs.json")
    jobsData = json.decode(jobsData)
    jobgrade = tostring(jobgrade)
    
    return jobsData.Jobs[job] and jobsData.Jobs[job][jobgrade]
end

--- @param cb function
--- @param job string
--- @param jobgrade integer
function validate_job_cb(job,jobgrade,cb)
    local jobsData = LoadResourceFile(GetCurrentResourceName(), "shared/jobs.json")
    jobsData = json.decode(jobsData)
    jobgrade = tostring(jobgrade)
    cb(jobsData.Jobs[job] and jobsData.Jobs[job][jobgrade])
end

exports('validateJob', validateJob)
exports('validate_job_cb', validate_job_cb)