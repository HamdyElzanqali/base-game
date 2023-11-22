local object = class:extend()

-- default values
object.layer = 0
object.persistent = false

-- Constructor
function object:new(...)
    if ... ~= nil then
        self.args = {...}
    end

    Room._queueAdd(self)
end


-- METHODS

-- remove the object from in the next frame
function object:destroy()
    Room._queueRemove(self)
end

-- set the layer of the object
function object:setLayer(layer)
    Room._queueRemove(self)
end


-- CALLBACKS

-- called when the object is added to the room
function object:start(...)
    
end

-- called once per frame 
function object:update()
    
end

-- called once per draw cycle
function object:draw()
    
end

-- called when the object is removed from the room
function object:remove()

end

return object
