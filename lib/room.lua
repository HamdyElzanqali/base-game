local room = {
    path = "",
    current = "",
}

local instances = {}

local queue = {}
local queueSize = 0
local queueAction = {}
local queueLayer = {}

local layers = {}
local layerCount = 0
local layerSize = {}

local queueFunction = {}

local loadRoom = nil

-- create a layer if it doesn't exist
local function createLayer(layer)
    if instances[layer] == nil then
        instances[layer] = {}
        layerCount = layerCount + 1
        layers[layerCount] = layer
        layerSize[layer] = 0
        table.sort(layers)
    end
end

-- remove a layer if exists
local function removeLayer(layer)
    if instances[layer] ~= nil then
        instances[layer] = nil
        layerCount = layerCount - 1
        layerSize[layer] = nil

        for i = 1, layerCount, 1 do
            if layers[i] == layer then
                table.remove(layers, i)
                break
            end
        end
    end
end

-- add an object to the room
local function addObject(obj)
    -- create the layer if it doesn't exist
    createLayer(obj.layer)

    -- add the object to the layer
    layerSize[obj.layer] = layerSize[obj.layer] + 1
    instances[obj.layer][layerSize[obj.layer]] = obj
    obj._instanceId = layerSize[obj.layer]
end

-- remove an object from the room
local function removeObject(obj)
    if instances[obj.layer] ~= nil then
        -- replace the object with the last object in the layer
        local size = layerSize[obj.layer]
        instances[obj.layer][obj._instanceId] = instances[obj.layer][size]
        instances[obj.layer][obj._instanceId]._instanceId = obj._instanceId
        instances[obj.layer][size] = nil

        layerSize[obj.layer] = layerSize[obj.layer] - 1

        -- remove the layer if it's empty
        if size == 1 then
            removeLayer(obj.layer)
        end

        return true
    end

    return false
end

-- perform queued actions on the start of the frame
local function runQueue()
    -- we use a while loop because the queue can be modified while running
    -- e.g. an object that creates another object in the start event
    local i = 0
    while i < queueSize do
        i = i + 1

        queueFunction[queueAction[i]](queue[i], queueLayer[i])
        
        -- reset the queue
        queue[i] = nil
        queueAction[i] = nil
        queueLayer[i] = nil
    end

    queueSize = 0
end

-- add object to the room
queueFunction[1] = function (obj)
    -- add the object
    addObject(obj)

    -- call the start function
    if obj.args then
        obj:start(unpack(obj.args))
    else
        obj:start()
    end
end

-- remove object from the room
queueFunction[2] = function (obj)
    if removeObject(obj) then
        -- call the remove function if removed
        obj:remove()
    end
end

-- set the layer of the object
queueFunction[3] = function (obj, layer)
    -- remove the object from the old layer
    removeObject(obj)
    
    -- add the object to the new layer
    obj.layer = layer

    -- add the object to the new layer
    addObject(obj)
end


-- queue adding the object to the room
function room._queueAdd(obj)
    queueSize = queueSize + 1
    queue[queueSize] = obj
    queueAction[queueSize] = 1
end

-- queue removing the object from the room
function room._queueRemove(obj)
    queueSize = queueSize + 1
    queue[queueSize] = obj
    queueAction[queueSize] = 2
end

-- queue setting the layer of the object
function room._queueLayer(obj, layer)
    queueSize = queueSize + 1
    queue[queueSize] = obj
    queueAction[queueSize] = 3
    queueLayer[queueSize] = layer
end

-- clear the room
function room:clear(all)
    if all then
        -- remove all objects from the room
        for i = 1, layerCount, 1 do
            for j = 1, layerSize[layers[i]], 1 do
                instances[layers[i]][j]:destroy()
            end
        end
    else
        -- remove all non-persistent objects from the room
        for i = 1, layerCount, 1 do
            for j = 1, layerSize[layers[i]], 1 do
                if not instances[layers[i]][j].persistent then
                    instances[layers[i]][j]:destroy()
                end
            end
        end
    end
end

-- reload the current room
function room:reload()
    self:load(self.current)
end

-- load a room
function room:load(room)
    self.current = room

    local path = self.path .. room .. ".lua"

    -- load the room from file
    loadRoom = love.filesystem.load(path)

    if not loadRoom then
        error('"' .. room .. '" at [' .. path .. "] does not exist.")
    end
end

-- set the path to the rooms
function room:setPath(path)
    self.path = path .. "/"
end

-- update the room
function room:update(dt)
    -- run the queue
    runQueue()

    -- load the target room
    if loadRoom then
        local target = loadRoom
        loadRoom = nil

        -- clear the room
        self:clear(false)

        -- create the room
        target()
        
        -- run the queue to add the objects to the room
        runQueue()

        -- manually collect garbage
        collectgarbage()
    end

    -- update all objects in the room
    for i = 1, layerCount, 1 do
        for j = 1, layerSize[layers[i]], 1 do
            instances[layers[i]][j]:update(dt)
        end
    end
end

-- draw the room
function room:draw()
    -- draw all objects in the room
    for i = 1, layerCount, 1 do
        for j = 1, layerSize[layers[i]], 1 do
            instances[layers[i]][j]:draw()
        end
    end
end


return room