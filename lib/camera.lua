local camera = {
    position = vector(0, 0),
    scale    = vector(1, 1),
    rotation = 0,
    pivot    = vector(0, 0),
    offset   = vector(0, 0),

    windowSize  = vector(love.graphics.getDimensions()),
    windowPivotPoint = vector(0, 0),

    baseSize = vector(0, 0),
    baseScale   = 1,
    baseOffset  = vector(0, 0),
    integerScaling = true,

    borders  = false,
    borderColor = {0, 0, 0, 1},
    borderOffset = vector(0, 0),

    canvas = nil,
    canvasSize = vector(0, 0),
    useCanvas = false,
    canvasPivotPoint = vector(0, 0)
}

camera.baseSize = nil

local shake = {
    value       = vector(0, 0),
    intensity   = vector(0, 0),
    timer       = 0,
    time        = 0,
    rate        = 0,
    rateTimer   = 0,
}

local canvasOffset = vector(0, 0)

local function drawBorders(self)
    love.graphics.setColor(self.borderColor)

    love.graphics.rectangle("fill", 0, 0, self.borderOffset.x, self.windowSize.y)
    love.graphics.rectangle("fill", self.windowSize.x - self.borderOffset.x, 0, self.borderOffset.x, self.windowSize.y)
    love.graphics.rectangle("fill", 0, 0, self.windowSize.x, self.borderOffset.y)
    love.graphics.rectangle("fill", 0, self.windowSize.y - self.borderOffset.y,self.windowSize.x, self.borderOffset.y)
end

-- enable the camera
function camera:set()
    if self.useCanvas then
        love.graphics.setCanvas(self.canvas)
        love.graphics.clear()

        love.graphics.push()
        love.graphics.translate(self.canvasPivotPoint.x, self.canvasPivotPoint.y)
        love.graphics.scale(self.scale.x, self.scale.y)
        love.graphics.translate(-self.position.x - self.offset.x + shake.value.x + 1, -self.position.y - self.offset.y + shake.value.y + 1)
    else
        love.graphics.push()
        love.graphics.translate(self.windowPivotPoint.x, self.windowPivotPoint.y)
        love.graphics.scale(self.scale.x * self.baseScale, self.scale.y * self.baseScale)
        love.graphics.translate(-self.position.x - self.offset.x + shake.value.x, -self.position.y - self.offset.y + shake.value.y)
    end

    love.graphics.rotate(-self.rotation)

end

-- disable the camera
function camera:unset()
    love.graphics.pop()

    if self.useCanvas then
        -- reset canvas
        love.graphics.setCanvas()

        -- draw canvas
        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.draw(self.canvas, canvasOffset.x, canvasOffset.y, 0, self.baseScale, self.baseScale)
    end

    -- draw borders
    if self.borders and self.baseSize then
        drawBorders(self)
    end
end

-- sets the pivot/origin of the camera in range of [0, 1], [0, 1]
function camera:setPivot(x, y)
    self.pivot.x = x
    self.pivot.y = y

    self.windowPivotPoint.x = math.floor(self.pivot.x * self.windowSize.x)
    self.windowPivotPoint.y = math.floor(self.pivot.y * self.windowSize.y)

    self.canvasPivotPoint.x = math.floor(self.canvasSize.x * self.pivot.x)
    self.canvasPivotPoint.y = math.floor(self.canvasSize.y * self.pivot.y)
end

-- sets the offset of the camera
function camera:setOffset(x, y)
    self.offset.x = x
    self.offset.y = y
end

function camera:setCanvas(active)
    self.useCanvas = active
end

-- removes camera bounds
function camera:resetBounds()
    self.bounds = nil
end

-- sets the borders
function camera:setBorders(active, color)
    self.borders = active
    self.borderColor = color or self.borderColor
end

-- sets the base scale
function camera:setBaseSize(width, height, integerScaling)
    if not width then
        self.baseSize = nil
        return
    end

    self.baseSize = vector(width, height or width)

    if integerScaling ~= nil then
        self.integerScaling = integerScaling
    end

    self:applyBaseScale()
end

-- calculate the correct scale based on the base size
function camera:applyBaseScale()
    local x = self.windowSize.x / self.baseSize.x
    local y = self.windowSize.y / self.baseSize.y

    local smallest = math.min(x, y)

    
    if self.integerScaling then
        smallest = math.floor(smallest)
    end
    
    if smallest <= 0 then
        smallest = 1
    end
    
    self.baseScale = smallest
    
    self.borderOffset.x = (self.windowSize.x - self.baseSize.x * smallest) / 2
    self.borderOffset.y = (self.windowSize.y - self.baseSize.y * smallest) / 2
    
    self.baseOffset.x = (self.windowSize.x / smallest - self.baseSize.x) / 2
    self.baseOffset.y = (self.windowSize.y / smallest - self.baseSize.y) / 2

    self.canvasSize.x = self.windowSize.x / smallest
    self.canvasSize.y = self.windowSize.y / smallest

    canvasOffset.x = math.floor(self.borderOffset.x % smallest) - self.baseScale
    canvasOffset.y = math.floor(self.borderOffset.y % smallest) - self.baseScale

    self.canvas = love.graphics.newCanvas(math.ceil(self.canvasSize.x) + 1, math.ceil(self.canvasSize.y) + 1)

    self.canvasPivotPoint.x = math.floor(self.canvasSize.x * self.pivot.x)
    self.canvasPivotPoint.y = math.floor(self.canvasSize.y * self.pivot.y)
end

-- shakes the camera
function camera:shake(duration, rate, intensityX, intensityY)
    duration = duration or 0.5
    shake.time = (duration > 0 and duration or 1)
    shake.timer = duration

    shake.rate = rate or 0.01
    
    shake.intensity.x = intensityX or 5
    shake.intensity.y = intensityY or 5
end

-- force stop the shake
function camera:resetShake()
    shake.timer = 0
end

-- convert screen to world coordinates
function camera:toWorld(x, y)
    local worldX = (self.position.x + self.offset.x - self.canvasSize.x * self.pivot.x) + self.canvasSize.x * (x / self.windowSize.x)
    local worldY = (self.position.y + self.offset.y - self.canvasSize.y * self.pivot.y) + self.canvasSize.y * (y / self.windowSize.y)
    return worldX, worldY
end

-- convert world to screen coordinates
function camera:toScreen(x, y)
    local screenX = (x - self.position.x - self.offset.x + self.canvasSize.x * self.pivot.x) / self.canvasSize.x * self.windowSize.x
    local screenY = (y - self.position.y - self.offset.y + self.canvasSize.y * self.pivot.y) / self.canvasSize.y * self.windowSize.y
    return screenX, screenY
end

-- update the camera to shake and limit to bounds
function camera:update(dt)
    -- Shake the camera
    if shake.timer > 0 then
        shake.timer = shake.timer - dt

        if shake.rateTimer > 0 then
            shake.rateTimer = shake.rateTimer - dt
        else
            shake.rateTimer = shake.rate
            local amount = shake.timer / shake.time
            shake.value.x = love.math.random(-shake.intensity.x, shake.intensity.x) * amount
            shake.value.y = love.math.random(-shake.intensity.y, shake.intensity.y) * amount
        end
    else
        shake.value.x = 0
        shake.value.y = 0
    end
end

-- used in love.resize event
function camera:windowResize(w, h)
    self.windowSize.x = w
    self.windowSize.y = h

    self.windowPivotPoint.x = math.floor(self.pivot.x * self.windowSize.x)
    self.windowPivotPoint.y = math.floor(self.pivot.y * self.windowSize.y)

    if self.baseSize then
        self:applyBaseScale()
    end
end

return camera