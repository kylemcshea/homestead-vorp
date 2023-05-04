local IS_DEV_MODE = true

RegisterServerEvent('dream_lib:devPrint', function(...)
    if (not IS_DEV_MODE) then return end
    print(...)
end)

local function devPrint(...)
    if (not IS_DEV_MODE) then return end
    print(...)
end

export("devPrint", devPrint)