local gamedata = {
    loaded = {},
}

-- Track which files have been changed.
local changed = {}

-- Web doesn't support threads, so we have to use the main thread.
local isWeb = love.system.getOS() == "Web"

local threadCode = [[
    local file, data = ...
    love.filesystem.write(file, data)
]]

-- Loads the saved file
function gamedata.load(file)
    local id = file or 'data'

    -- Load from the save file if it exists.
    if love.filesystem.getInfo(id) then
        local content = love.filesystem.read(id)
        gamedata.loaded[id] = lume.deserialize(content or '{}')
    else
        gamedata.loaded[id] = {}
    end
end

-- Saves the file to the disk. Called once if something is changed during the update cycle.
function gamedata.save(file)
    local id = file or 'data'

    if gamedata.loaded[id] and changed[id] then
        changed[id] = nil

        local content = lume.serialize(gamedata.loaded[id])

        -- Web doesn't support threads.
        -- This results in a slight delay, so it's recommended to only save while not in-game.
        if isWeb then
            love.filesystem.write(id, content)
        else
            -- Save in a separate thread to avoid lag.
            love.thread.newThread(threadCode):start(id, content)
        end
        
    end
end


-- Gets some data.
function gamedata.get(data, file)
    local id = file or 'data'
    
    if not gamedata.loaded[id] then
        gamedata.load(id)
    end

    return gamedata.loaded[id][data]
end


-- Sets some data.
-- Note: the save file is updated automatically (in update function) when the data is changed.
function gamedata.set(data, value, file)
    local id = file or 'data'
    
    if not gamedata.loaded[id] then
        gamedata.load(id)
    end

    if gamedata.loaded[id][data] ~= value then
        gamedata.loaded[id][data] = value
        changed[id] = true
    end
    
end


-- Checks if some data exists.
function gamedata.has(data, file)
    local id = file or 'data'
    
    if not gamedata.loaded[id] then
        gamedata.load(id)
    end

    return (gamedata.loaded[id][data] ~= nil)
end

-- Resets the save data table.
function gamedata.clear(file)
    local id = file or 'data'
    
    if not gamedata.loaded[id] then
        gamedata.load(id)
    end

    gamedata.loaded[id] = {}
    changed[id] = true
end

-- Get the save data table.
function gamedata.getAll(file)
    local id = file or 'data'
    
    if not gamedata.loaded[id] then
        gamedata.load(id)
    end

    return gamedata.loaded[id]
end

-- Replaces the saved data table with another table.
function gamedata.setAll(t, file)
    local id = file or 'data'
    
    if not gamedata.loaded[id] then
        gamedata.load(id)
    end

    gamedata.loaded[id] = t
    changed[id] = true
end


-- Saves all changed files. Should be called at the end of the update cycle.
function gamedata.update()
    for key, _ in pairs(changed) do
        gamedata.save(key)
    end
end

return gamedata