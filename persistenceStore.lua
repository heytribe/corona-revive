local json = require("json")

local base = system.CachesDirectory
local revive_file = "revive_data.json"

---------------------------------------------------------------------------------

local persistenceStore = {}

persistenceStore.allRevives = function()

    log('persistenceStore - allRevives')

    local path = system.pathForFile(revive_file, base)
    local contents = ""
    local savedRevives = {}
    local file = io.open(path, "r")

    if file then
        -- read all contents of file into a string
        local contents = file:read( "*a" )
        savedRevives = json.decode(contents)
        io.close( file )
    end

    return savedRevives
end

persistenceStore.didRevive = function(gameId, disabledTime)

    log('persistenceStore - didRevive for ' .. gameId)

    local savedRevives = {}
    local tmpSavedRevives = persistenceStore.allRevives()
    if tmpSavedRevives then
        savedRevives = tmpSavedRevives
    end
    local now = os.time()
    savedRevives[gameId] = now + disabledTime

    local path = system.pathForFile(revive_file, base)
    local file = io.open(path, "w")
    if file then
        local contents = json.encode(savedRevives)
        log('persistenceStore - didRevive - FILE FOUND - will save - ' .. contents .. ' with now = ' .. now)
        file:write(contents)
        io.close(file)
    end

end

persistenceStore.canRevive = function(gameId)

    log('persistenceStore - canRevive for ' .. gameId)
    local savedRevives = persistenceStore.allRevives()
    local savedRevive = savedRevives[gameId]

    if savedRevive and os.time() < savedRevive then
        log('persistenceStore - canRevive for ' .. gameId .. ' with savedRevive = ' .. savedRevive .. " - VS now = " .. os.time())
        return false
    end

    return true
end

return persistenceStore