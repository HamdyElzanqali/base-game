local sprite = object:extend()

function sprite.createGrid(image, width, height, spacing, margin)
    spacing = spacing or 0
    margin = margin or 0

    local img = Resource:image(image)
    local imageWidth, imageHeight = img:getDimensions()

    local grid = {
        width = width,
        height = height,
        spacing = spacing,
        margin = margin,
        image = img
    }
    
    local pos = 1
    for y = margin, imageHeight - 1, height + spacing do
        for x = margin, imageWidth - 1, width + spacing do
            local quad = love.graphics.newQuad(x, y, width, height, imageWidth, imageHeight)
            grid[pos] = quad
            pos = pos + 1
        end
    end

    return grid
end



function sprite.framesFromGrid(grid, ...)
    local frames = {
        quads = true,
        image = grid.image,
        width = grid.width,
        height = grid.height,
        length = select("#", ...)
    }

    for i = 1, frames.length do
        local frame = select(i, ...)
        frames[i] = grid[frame]
    end

    return frames
end

function sprite.framesFromImages(...)
    local frames = {
        images = true,
        length = select("#", ...)
    }

    for i = 1, frames.length do
        local frame = select(i, ...)
        frames[i] = Resource:image(frame)
    end

    return frames
end

function sprite:new()
    self.animations = {}
    self.currentAnimation = nil
    self.frame = 1
    self.timer = 0
end

function sprite:addAnimation(name, frames, frameTime)
    self.animations[name] = {
        frames = frames,
        duration = frameTime or 0,
    }
end

function sprite:setAnimation(name)
    if self.animations[name] then
        self.currentAnimation = self.animations[name]
        self.frame = 1
        self.timer = 0
    end
end

function sprite:update(dt)
    if self.currentAnimation then
        self.timer = self.timer + dt
        if self.timer > self.currentAnimation.duration then
            self.timer = self.timer - self.currentAnimation.duration
            self.frame = self.frame + 1
            if self.frame > self.currentAnimation.frames.length then
                if self.currentAnimation.loop then
                    self:onFinish()
                    self.frame = 1
                else
                    self.frame = self.currentAnimation.frames.length
                end
            end
        end
    end
end

function sprite:draw(x, y, r, sx, sy, ox, oy, kx, ky)
    if self.currentAnimation then
        local frame = self.currentAnimation.frames[self.frame]
        if self.currentAnimation.frames.quads then
            love.graphics.draw(self.currentAnimation.frames.image, frame, x, y, r, sx, sy, ox, oy, kx, ky)
        else
            love.graphics.draw(frame, x, y, r, sx, sy, ox, oy, kx, ky)
        end
    end
end

-- CALLBACKS
function sprite:onFinish() end

return sprite