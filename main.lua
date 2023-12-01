-- Load game libraries
require 'lib'

-- Enable the debugger
if arg[2] == "debug" then
    require("lldebugger").start()
end

-- Paths to resources
Resource.pathToImages = "src/sprites/"
Room:setPath("src/rooms")

-- Set the game for pixel art
love.graphics.setDefaultFilter("nearest", "nearest")
love.graphics.setLineStyle("rough")

-- Default camera setup
Camera:setBaseSize(160, 90, true)
Camera:setPivot(0.5, 0.5)
--Camera:setBorders(true)
Camera:setCanvas(true) -- simple pixel effect

local charset = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz1234567890':\"()[] !,-|_+/*\\?.%@><"
Global.fonts = {
    normal = love.graphics.newImageFont('src/fonts/main-font.png', charset)
}

love.graphics.setFont(Global.fonts.normal)

function love.load()
    -- Load the starting room
    Room:load("room")
end

function love.update(dt)
    -- Update room instances
    Room:update(dt)

    -- Update the camera
    Camera:update(dt)

    -- Save user's data if changed
    Gamedata:update()

    -- Reset input state 
    Input:update(dt)
end

-- Draw is called once on draw
function love.draw()
    -- Set the camera
    Camera:set()

    -- Draw the room instances
    Room:draw()

    -- Reset the camera
    Camera:unset()
end

function love.resize(w, h)
    -- Update the camera size and apply the correct scaling
    Camera:windowResize(w, h)
end

-- setup all love input callbacks
Input:setup()