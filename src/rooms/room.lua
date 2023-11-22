love.graphics.setBackgroundColor(0.12, 0.12, 0.12)

local obj = object:extend()

function obj:draw()
    love.graphics.setColor(1, 1, 1)
    love.graphics.printf("Hello, world!", -70, -3, 140, "center")
end

obj()
