love.graphics.setBackgroundColor(0.12, 0.12, 0.12)

local obj = object:extend()

function obj:start()
    self.text = "Hello, world!"
end

function obj:draw()
    -- shadow
    love.graphics.setColor(0.3, 0.3, 0.3)
    love.graphics.printf(self.text, -70, -2, 140, "center")
    
    -- text
    love.graphics.setColor(1, 1, 1)
    love.graphics.printf(self.text, -69, -3, 140, "center")
end

obj()