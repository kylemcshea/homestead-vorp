IS_DEV_MODE = true

RegisterServerEvent('dream_lib:devPrint', function(...)
    if (not IS_DEV_MODE) then return end
    print(...)
end)

function devPrint(...)
    if (not IS_DEV_MODE) then return end
    print(...)
end

exports("devPrint", devPrint)