local physics = {
    world = nil,
}

local colliders = {}

local function beginContact(a, b, contact)
    a, b = colliders[a], colliders[b]
	a.beginContact(a, b, contact, false)
    b.beginContact(b, a, contact, true)
end

local function endContact(a, b, contact)
    a, b = colliders[a], colliders[b]
    a.endContact(a, b, contact, false)
    b.endContact(b, a, contact, true)
end

local function preSolve(a, b, contact)
    a, b = colliders[a], colliders[b]
    a.preSolve(a, b, contact, false)
    b.preSolve(b, a, contact, true)
end

local function postSolve(a, b, contact, normalimpulse, tangentimpulse)
    a, b = colliders[a], colliders[b]
    a.postSolve(a, b, contact, normalimpulse, tangentimpulse, false)
    b.postSolve(b, a, contact, normalimpulse, tangentimpulse, true)
end

-- initialize the physics world
function physics:init(gravityX, gravityY, sleep)
    self.world = love.physics.newWorld(gravityX or 0, gravityY or 9.8, (sleep ~= nil) and sleep or true)
    self.world:setCallbacks(beginContact, endContact, preSolve, postSolve)
end

-- update the physics world
function physics:update(dt)
    self.world:update(dt)
end

-- destroy a collider
function physics:destroy(collider)
    if colliders[collider.fixture] then
        collider.fixture:destroy()
        colliders[collider.fixture] = nil
    end
end

local function empty() end


local function getPositionRectangle(collider)
   local w, h = collider.shape:getPoints()
   local x, y = collider.body:getPosition()
   return x + w, y + h
end

local function getPosition(collider)
   return collider.body:getPosition()
end

local function getRadius(collider) return collider.shape:getRadius() end
local function getPoints(collider) return collider.shape:getPoints() end

local function getX(collider)
    local x, y = collider.shape:getPoints()
    return collider.body:getX() + x
end

local function getY(collider) 
    local x, y = collider.shape:getPoints()
    return collider.body:getY() + y
end

local function getDimensions(collider)
    local w, h = collider.shape:getPoints()
    return -w * 2, -h * 2
end

local function getWidth(collider)
    local w, h = collider.shape:getPoints()
    return -w * 2
end

local function getHeight(collider)
    local w, h = collider.shape:getPoints()
    return -h * 2
end

local function getAngle(collider)
    return collider.body:getAngle() % (2 * math.pi)
end

local function setCategory(collider, ...)
    collider.fixture:setCategory(...)
end

local function ignore(collider, ...)
    collider.fixture:setMask(...)
end

local function setSensor(collider, sensor)
    collider.fixture:setSensor(sensor)
end

local function setPositionRectangle(collider, x, y)
    local offX, offY = collider.shape:getPoints()
    collider.body:setPosition(x - offX, y - offY)
end

local function setXRectangle(collider, x)
    local offx = collider.shape:getPoints()
    collider.body:setX(x - offx)
end

local function setYRectangle(collider, y)
    local _, offy = collider.shape:getPoints()
    collider.body:setY(y - offy)
end

local function setPosition(collider, x, y)
    collider.body:setPosition(x, y)
end

local function setX(collider, x)
    collider.body:setX(x)
end

local function setY(collider, y)
    collider.body:setY(y)
end

local function setAngle(collider, angle)
    collider.body:setAngle(angle)
end

local function destroy(collider)
    physics:destroy(collider)
end

local function _oneInMany(category, ...)
    for i = 1, select("#", ...) do
        local current = select(i, ...)
        if category == current then
            return true
        end
    end

    return false
end

local function hasCategory(collider, ...)
    for i = 1, select("#", ...) do
        local category = select(i, ...)
        if _oneInMany(category, collider.fixture:getCategory()) then
            return true
        end
    end

    return false
end


-- create a rectangle in the world
function physics:rectangle(x, y, width, height, type)
    local collider = {}
    collider.body = love.physics.newBody(self.world, x + width/2, y + height/2, type or "static")
    collider.shape = love.physics.newRectangleShape(width, height)
    collider.fixture = love.physics.newFixture(collider.body, collider.shape)

    collider.beginContact = empty
    collider.endContact = empty
    collider.preSolve = empty
    collider.postSolve = empty

    collider.getX = getX
    collider.getY = getY
    collider.getPosition = getPositionRectangle
    collider.getDimensions = getDimensions
    collider.getWidth = getWidth
    collider.getHeight = getHeight
    collider.getAngle = getAngle

    collider.setPosition = setPositionRectangle
    collider.setX = setXRectangle
    collider.setY = setYRectangle
    collider.setAngle = setAngle
    collider.setCategory = setCategory
    collider.ignore = ignore
    collider.setSensor = setSensor

    collider.hasCategory = hasCategory
    collider.destroy = destroy

    colliders[collider.fixture] = collider

    return collider
end

-- create a circle in the world
function physics:circle(x, y, radius, type)
    local collider = {}
    collider.body = love.physics.newBody(self.world, x, y, type or "static")
    collider.shape = love.physics.newCircleShape(radius)
    collider.fixture = love.physics.newFixture(collider.body, collider.shape)

    collider.beginContact = empty
    collider.endContact = empty
    collider.preSolve = empty
    collider.postSolve = empty

    collider.getX = getY
    collider.getY = getY
    collider.getPosition = getPosition
    collider.getRadius = getRadius
    collider.getAngle = getAngle

    collider.setPosition = setPosition
    collider.setX = setX
    collider.setY = setY
    collider.setAngle = setAngle
    collider.setCategory = setCategory
    collider.ignore = ignore
    collider.setSensor = setSensor

    collider.hasCategory = hasCategory
    collider.destroy = destroy

    colliders[collider.fixture] = collider

    return collider
end

-- create a polygon in the world
function physics:polygon(x, y, vertices, type)
    local collider = {}
    collider.body = love.physics.newBody(self.world, x, y, type or "static")
    collider.shape = love.physics.newPolygonShape(vertices)
    collider.fixture = love.physics.newFixture(collider.body, collider.shape)

    collider.begineContact = empty
    collider.endContact = empty
    collider.preSolve = empty
    collider.postSolve = empty

    collider.getX = getX
    collider.getY = getY
    collider.getPosition = getPosition
    collider.getPoints = getPoints
    collider.getAngle = getAngle

    collider.setPosition = setPosition
    collider.setX = setX
    collider.setY = setY
    collider.setAngle = setAngle
    collider.setCategory = setCategory
    collider.ignore = ignore
    collider.setSensor = setSensor

    collider.hasCategory = hasCategory
    collider.destroy = destroy

    colliders[collider.fixture] = collider

    return collider
end

return physics