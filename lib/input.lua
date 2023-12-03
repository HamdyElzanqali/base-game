--[[
    ROADMAP:
        [+] Mouse
        [+] Keyboard
        [+] Gamepad
        [+] Actions

        [*] Touch
        
    IDEAS:
        [ ] Sequences/combos
        [ ] Save/Load schemes
]]

local input = {
    mouse = {
        x = 0,
        y = 0,
        dx = 0,
        dy = 0,
        down = {},
        pressed = {},
        released = {},
        wheelX = 0,
        wheelY = 0,
    },
    keyboard = {
        down = {},
        pressed = {},
        released = {},
        textInput = "",

        lastDown = nil,
        lastPressed = nil,
        lastReleased = nil,
    },
    gamepads = {
        ids = {},
        added = {},
        removed = {},
        joysticks = {},
        defaultDeadzone = 0.15,
    },
    actions = {},
}

-- resets the state, should be last in the update loop
function input:update(dt)
    -- Keyboard
    for key, _ in pairs(self.keyboard.pressed) do
        self.keyboard.pressed[key] = nil
    end

    for key, _ in pairs(self.keyboard.released) do
        self.keyboard.released[key] = nil
    end

    self.keyboard.textInput = ""

    self.keyboard.lastPressed = nil
    self.keyboard.lastReleased = nil


    -- Mouse
    for button, _ in pairs(self.mouse.pressed) do
        self.mouse.pressed[button] = nil
    end

    for button, _ in pairs(self.mouse.released) do
        self.mouse.released[button] = nil
    end

    self.mouse.dx = 0
    self.mouse.dy = 0
    self.mouse.wheelX = 0
    self.mouse.wheelY = 0

    self.mouse.lastPressed = nil
    self.mouse.lastReleased = nil

    -- Gamepad
    for i = 1, #self.gamepads.ids, 1 do
        local gamepad = self.gamepads[self.gamepads.ids[i]]
        
        -- make sure the gamepad is still connected
        if not gamepad then
            break
        end

        for button, _ in pairs(gamepad.pressed) do
            gamepad.pressed[button] = nil
        end

        for button, _ in pairs(gamepad.released) do
            gamepad.released[button] = nil
        end

        gamepad.lastPressed = nil
        gamepad.lastReleased = nil
        gamepad.lastAxis = nil
        gamepad.lastAxisValue = nil
    end

    for i = 1, #self.gamepads.added, 1 do
        self.gamepads.added[i] = nil
    end

    for i = 1, #self.gamepads.removed, 1 do
        self.gamepads.removed[i] = nil
    end

end

------------ Input ------------

local function checkInput(state, ...)
    for i = 1, select("#", ...), 1 do
        local button = select(i, ...)
        if state[button] then
            return true
        end
    end
end

------------ KEYBOARD ------------

-- check if a key is down
function input:keyDown(...)
    return checkInput(self.keyboard.down, ...)
end

-- check if a key was pressed
function input:keyPressed(...)
    return checkInput(self.keyboard.pressed, ...)
end

-- check if a key was released
function input:keyReleased(...)
    return checkInput(self.keyboard.released, ...)
end

-- get the text input
function input:textInput()
    return self.keyboard.textInput
end

-- check if any key is down
function input:keyAny()
    for key, _ in pairs(self.keyboard.down) do
        return true
    end

    return false
end

-- check if any key was pressed
function input:keyAnyPressed()
    if self.keyboard.lastPressed then
        return true
    end

    return false
end

-- check if any key was released
function input:keyAnyReleased()
    if self.keyboard.lastReleased then
        return true
    end

    return false
end

-- return the last key down
function input:keyLastDown()
    return self.keyboard.lastDown
end

-- return the last key pressed
function input:keyLastPressed()
    return self.keyboard.lastPressed
end

-- return the last key released
function input:keyLastReleased()
    return self.keyboard.lastReleased
end




------------ MOUSE ------------

-- check if a mouse button is down
function input:mouseDown(...)
    return checkInput(self.mouse.down, ...)
end

-- check if a mouse button was pressed
function input:mousePressed(...)
    return checkInput(self.mouse.pressed, ...)
end

-- check if a mouse button was released
function input:mouseReleased(...)
    return checkInput(self.mouse.released, ...)
end

-- get the mouse position
function input:mousePosition()
    return self.mouse.x, self.mouse.y
end

-- get the mouse movement
function input:mouseMovement()
    return self.mouse.dx, self.mouse.dy
end

-- check if mouse has moved
function input:mouseMoved(threshold)
    return math.abs(self.mouse.dx) > (threshold or 0) or math.abs(self.mouse.dy) > (threshold or 0)
end

-- get the mouse wheel movement
function input:mouseWheel()
    return self.mouse.wheelX, self.mouse.wheelY
end

-- get the mouse wheel y movement
function input:mouseWheelY()
    return self.mouse.wheelY
end

-- get the mouse wheel x movement
function input:mouseWheelX()
    return self.mouse.wheelX
end

-- check if the mouse wheel moved up
function input:mouseWheelUp(threshold)
    return self.mouse.wheelY > (threshold or 0)
end

-- check if the mouse wheel moved down
function input:mouseWheelDown(threshold)
    return self.mouse.wheelY < (threshold or 0)
end

-- check if the mouse wheel moved left
function input:mouseWheelLeft(threshold)
    return self.mouse.wheelX < (threshold or 0)
end

-- check if the mouse wheel moved right
function input:mouseWheelRight(threshold)
    return self.mouse.wheelX > (threshold or 0)
end

-- check if any mouse button is down
function input:mouseAny()
    for button, _ in pairs(self.mouse.down) do
        return true
    end

    if self.mouse.wheelX ~= 0 or self.mouse.wheelY ~= 0 then
        return true
    end

    return false
end

-- check if any mouse button was pressed
function input:mouseAnyPressed()
    if self.mouse.lastPressed then
        return true
    end

    if self.mouse.wheelX ~= 0 or self.mouse.wheelY ~= 0 then
        return true
    end

    return false
end

-- check if any mouse button was released
function input:mouseAnyReleased()
    if self.mouse.lastReleased then
        return true
    end

    return false
end

-- return the last mouse button down
function input:mouseLastDown()
    return self.mouse.lastDown
end

-- return the last mouse button pressed
function input:mouseLastPressed()
    return self.mouse.lastPressed
end

-- return the last mouse button released
function input:mouseLastReleased()
    return self.mouse.lastReleased
end


------------ GAMEPAD ------------
local function checkGamepadInput(id, state, ...)
    if input.gamepads[id] == nil then
        if id > 0 then
            -- gamepad is not connected
            return nil
        end

        -- check all gamepads
        for i = 1, #input.gamepads.ids, 1 do
            if checkGamepadInput(input.gamepads.ids[i], state, ...) then
                return true
            end
        end

        return nil
    end

    for i = 1, select("#", ...), 1 do
        local button = select(i, ...)
        if input.gamepads[id][state][button] then
            return true
        end
    end

    return false
end

-- check if a gamepad button is down
function input:gamepadDown(id, ...)
    return checkGamepadInput(id, "down", ...)
end

-- check if a gamepad button was pressed
function input:gamepadPressed(id, ...)
    return checkGamepadInput(id, "pressed", ...)
end

-- check if a gamepad button was released
function input:gamepadReleased(id, ...)
    return checkGamepadInput(id, "released", ...)
end

-- get the gamepad axis value
function input:gamepadAxis(id, ...)
    if self.gamepads[id] == nil then
        if id > 0 then
            -- gamepad is not connected
            return nil
        end
        
        -- check all gamepads
        for i = 1, #self.gamepads.ids, 1 do
            local result = input:gamepadAxis(self.gamepads.ids[i], ...)
            if result ~= 0 then
                return result
            end
        end

        return nil
    end

    local result = 0
    for i = 1, select("#", ...), 1 do
        local axis = select(i, ...)
        result = result + (self.gamepads[id].axis[axis] or 0)
    end

    -- clamp the result
    if result > 1 then
        return 1
    elseif result < -1 then
        return -1
    elseif math.abs(result) < (self.gamepads[id].deadzone or self.gamepads.defaultDeadzone) then
        return 0
    end

    return result

end

function input:gamepadAxisRaw(id, ...)
    local axis = input:gamepadAxis(id, ...)

    if axis > 0 then
        return 1
    elseif axis < 0 then
        return -1
    end

    return 0
end

-- check if any gamepad button is down
function input:gamepadAny(id)
    if self.gamepads[id] == nil then
        if id > 0 then
            -- gamepad is not connected
            return nil
        end

        -- check all gamepads
        for i = 1, #self.gamepads.ids, 1 do
            if input:gamepadAny(self.gamepads.ids[i]) then
                return true
            end
        end
    end

    for button, _ in pairs(self.gamepads[id].down) do
        return true
    end

    return false
end

-- check if any gamepad button was pressed
function input:gamepadAnyPressed(id)
    if self.gamepads[id] == nil then
        if id > 0 then
            -- gamepad is not connected
            return nil
        end

        -- check all gamepads
        for i = 1, #self.gamepads.ids, 1 do
            if input:gamepadAnyPressed(self.gamepads.ids[i]) then
                return true
            end
        end

        return nil
    end

    if self.gamepads[id].lastPressed then
        return true
    end

    return false
end

-- check if any gamepad button was released
function input:gamepadAnyReleased(id)
    if self.gamepads[id] == nil then
        if id > 0 then
            -- gamepad is not connected
            return nil
        end

        -- check all gamepads
        for i = 1, #self.gamepads.ids, 1 do
            if input:gamepadAnyReleased(self.gamepads.ids[i]) then
                return true
            end
        end

        return nil
    end

    if self.gamepads[id].lastReleased then
        return true
    end

    return false
end

-- return the last gamepad button down
function input:gamepadLastDown(id)
    if self.gamepads[id] == nil then
        if id > 0 then
            -- gamepad is not connected
            return nil
        end

        -- check all gamepads
        for i = 1, #self.gamepads.ids, 1 do
            if input:gamepadLastDown(self.gamepads.ids[i]) then
                return true
            end
        end

        return nil
    end

    return self.gamepads[id].lastDown
end

-- return the last gamepad button pressed
function input:gamepadLastPressed(id)
    if self.gamepads[id] == nil then
        if id > 0 then
            -- gamepad is not connected
            return nil
        end

        -- check all gamepads
        for i = 1, #self.gamepads.ids, 1 do
            if input:gamepadLastPressed(self.gamepads.ids[i]) then
                return true
            end
        end

        return nil
    end

    return self.gamepads[id].lastPressed
end

-- return the last gamepad button released
function input:gamepadLastReleased(id)
    if self.gamepads[id] == nil then
        if id > 0 then
            -- gamepad is not connected
            return nil
        end

        -- check all gamepads
        for i = 1, #self.gamepads.ids, 1 do
            if input:gamepadLastReleased(self.gamepads.ids[i]) then
                return true
            end
        end

        return nil
    end

    return self.gamepads[id].lastReleased
end

-- return the last gamepad axis
function input:gamepadLastAxis(id)
    if self.gamepads[id] == nil then
        if id > 0 then
            -- gamepad is not connected
            return nil, nil
        end

        -- check all gamepads
        for i = 1, #self.gamepads.ids, 1 do
            local result, value = input:gamepadLastAxis(self.gamepads.ids[i])
            if result then
                return result, value
            end
        end

        return nil, nil
    end

    return self.gamepads[id].lastAxis, self.gamepads[id].lastAxisValue
end

-- set the deadzone of either a specific gamepad or all gamepads
function input:setGamepadDeadzone(deadzone, id)
    if id then
        self.gamepads[id].deadzone = deadzone
    else
        self.gamepads.defaultDeadzone = deadzone
    end
end

-- get the deadzone of either a specific gamepad or the default
function input:getGamepadDeadzone(id)
    if id then
        return self.gamepads[id].deadzone or self.gamepads.defaultDeadzone
    else
        return self.gamepads.defaultDeadzone
    end
end

-- returns a table of the ids of the connected gamepads
function input:gamepadsConnected()
    return self.gamepads.ids
end

-- vibrate a gamepad
function input:gamepadVibrate(id, leftPower, rightPower, duration)
    if self.gamepads[id] == nil then
        if id > 0 then
            -- gamepad is not connected
            return nil
        end

        -- check all gamepads
        for i = 1, #self.gamepads.ids, 1 do
            if input:gamepadVibrate(self.gamepads.ids[i], leftPower, rightPower, duration) then
                return true
            end
        end

        return nil
    end

    return self.gamepads.joysticks[id]:setVibration(leftPower, rightPower, duration)
end

------------ ACTIONS ------------

local function bind(action, name, ...)
    local target = action.bound[name]
    if target then
        local count = #target
        for i = 1, select("#", ...), 1 do
            local arg = select(i, ...)
            target[count + i] = arg
        end
    else
        action.bound[name] = {...}
    end
end

local function unbind(action, name, ...)
    local target = action.bound[name]
    if target then
        for i = 1, select("#", ...), 1 do
            local arg = select(i, ...)
            for j = 1, #target, 1 do
                if target[j] == arg then
                    table.remove(target, j)
                    break
                end
            end
        end

        if #target == 0 then
            action.bound[name] = nil
        end
    end
end

local function bindAxis(action, axis, ...)
    local target = action.axisBound[axis]
    if target then
        local count = #target
        for i = 1, select("#", ...), 1 do
            local arg = select(i, ...)
            target[count + i] = arg
        end
    else
        action.axisBound[axis] = {...}
    end
end

local function unbindAxis(action, axis, ...)
    local target = action.axisBound[axis]
    if target then
        for i = 1, select("#", ...), 1 do
            local arg = select(i, ...)
            for j = 1, #target, 1 do
                if target[j] == arg then
                    table.remove(target, j)
                    break
                end
            end
        end

        if #target == 0 then
            action.axisBound[axis] = nil
        end
    end
end

-- keyboard
local function bindKeyDown(action, ...)
    bind(action, "keyDown", ...)
    return action
end

local function bindKeyPressed(action, ...)
    bind(action, "keyPressed", ...)
    return action
end

local function bindKeyReleased(action, ...)
    bind(action, "keyReleased", ...)
    return action
end


local function unbindKeyDown(action, ...)
    unbind(action, "keyDown", ...)
    return action
end

local function unbindKeyPressed(action, ...)
    unbind(action, "keyPressed", ...)
    return action
end

local function unbindKeyReleased(action, ...)
    unbind(action, "keyReleased", ...)
    return action
end

--mouse
local function bindMouseDown(action, ...)
    bind(action, "mouseDown", ...)
    return action
end

local function bindMousePressed(action, ...)
    bind(action, "mousePressed", ...)
    return action
end

local function bindMouseReleased(action, ...)
    bind(action, "mouseReleased", ...)
    return action
end

local function bindMouseWheelUp(action, ...)
    bind(action, "mouseWheelUp", ...)
    return action
end

local function bindMouseWheelDown(action, ...)
    bind(action, "mouseWheelDown", ...)
    return action
end

local function bindMouseWheelLeft(action, ...)
    bind(action, "mouseWheelLeft", ...)
    return action
end

local function bindMouseWheelRight(action, ...)
    bind(action, "mouseWheelRight", ...)
    return action
end

local function bindMouseWheelX(action, threshold)
    action.mouseWheelX = threshold or 0
    return action
end

local function bindMouseWheelY(action, threshold)
    action.mouseWheelY = threshold or 0
    return action
end


local function unbindMouseDown(action, ...)
    unbind(action, "mouseDown", ...)
    return action
end

local function unbindMousePressed(action, ...)
    unbind(action, "mousePressed", ...)
    return action
end

local function unbindMouseReleased(action, ...)
    unbind(action, "mouseReleased", ...)
    return action
end

local function unbindMouseWheelUp(action, ...)
    unbind(action, "mouseWheelUp", ...)
    return action
end

local function unbindMouseWheelDown(action, ...)
    unbind(action, "mouseWheelDown", ...)
    return action
end

local function unbindMouseWheelLeft(action, ...)
    unbind(action, "mouseWheelLeft", ...)
    return action
end

local function unbindMouseWheelRight(action, ...)
    unbind(action, "mouseWheelRight", ...)
    return action
end

local function unbindMouseWheelX(action, ...)
    action.mouseWheelX = nil
    return action
end

local function unbindMouseWheelY(action, ...)
    action.mouseWheelY = nil
    return action
end

-- gamepad
local function bindGamepadDown(action, ...)
    bind(action, "gamepadDown", ...)
    return action
end

local function bindGamepadPressed(action, ...)
    bind(action, "gamepadPressed", ...)
    return action
end

local function bindGamepadReleased(action, ...)
    bind(action, "gamepadReleased", ...)
    return action
end

local function bindGamepadAxis(action, ...)
    bindAxis(action, "gamepadAxis", ...)
    return action
end

local function unbindGamepadDown(action, ...)
    unbind(action, "gamepadDown", ...)
    return action
end

local function unbindGamepadPressed(action, ...)
    unbind(action, "gamepadPressed", ...)
    return action
end

local function unbindGamepadReleased(action, ...)
    unbind(action, "gamepadReleased", ...)
    return action
end

local function unbindGamepadAxis(action, ...)
    unbindAxis(action, "gamepadAxis", ...)
    return action
end

local function unbindAll(action)
    action.bound = {}
    action.axisBound = {}
end

local function checkAxis(action, gamepad)
    local result = 0

    if gamepad then
        for name, _ in pairs(action.axisBound) do
            result = result + (input[name](input, gamepad, select(2, unpack(action.axisBound[name]))) or 0)
        end    
    else
        for name, _ in pairs(action.axisBound) do
            result = result + (input[name](input, unpack(action.axisBound[name])) or 0)
        end
    end

    if action.mouseWheelX then
        result = result + input:mouseWheelX()
    end

    if action.mouseWheelY then
        result = result + input:mouseWheelY()
    end

    if action.positiveAction and action.positiveAction:check(gamepad) then
        result = result + 1
    end

    if action.negativeAction and action.negativeAction:check(gamepad) then
        result = result - 1
    end


    if result > 1 then
        return 1
    elseif result < -1 then
        return -1
    end

    return result
end

local function checkAxisRaw(action, gamepad)
    local axis = checkAxis(action, gamepad)
    if axis > 0 then
        return 1
    elseif axis < 0 then
        return -1
    end

    return 0
end

local _pressed = {
    keyDown = "keyPressed",
    keyReleased = "keyPressed",
    mouseDown = "mousePressed",
    mouseReleased = "mousePressed",
    gamepadDown = "gamepadPressed",
    gamepadReleased = "gamepadPressed",
}

local _released = {
    keyDown = "keyReleased",
    keyPressed = "keyReleased",
    mouseDown = "mouseReleased",
    mousePressed = "mouseReleased",
    gamepadDown = "gamepadReleased",
    gamepadPressed = "gamepadReleased",
}

local _down = {
    keyPressed = "keyDown",
    keyReleased = "keyDown",
    mousePressed = "mouseDown",
    mouseReleased = "mouseDown",
    gamepadPressed = "gamepadDown",
    gamepadReleased = "gamepadDown",
}

local function _replace(name, variant)
    local len = #variant

    if len == 4 then
        name = _down[name] or name
    elseif len == 7 then
        name = _pressed[name] or name
    elseif len == 8 then
        name = _released[name] or name
    end

    return name
end

local function check(action, gamepad, variant)
    if gamepad then
        for name, _ in pairs(action.bound) do
            local target = action.bound[name]
            
            if variant then
                name = _replace(name, variant)
            end

            if target then
                if string.sub(name, 1, 7) == "gamepad" then
                    if input[name](input, gamepad, select(2, unpack(target))) then
                        return true
                    end
                else
                    if input[name](input, unpack(target)) then
                        return true
                    end
                end
            end
        end
    else
        for name, _ in pairs(action.bound) do
            local target = action.bound[name]

            if variant then
                name = _replace(name, variant)
            end

            if target then
                if input[name](input, unpack(target)) then
                    return true
                end
            end
        end
    end

    if checkAxis(action, gamepad) ~= 0 then
        return true
    end

    if (action.positiveAction and action.positiveAction:check(gamepad)) or (action.negativeAction and action.negativeAction:check(gamepad)) then
        return true
    end

    return false
end

local action

local function positive(_action)
    if _action.parent then
        _action.parent.positiveAction = action()
        return _action.parent.positiveAction
    end
    _action.positiveAction = action()
    _action.positiveAction.parent = _action
    return _action.positiveAction
end

local function negative(_action)
    if _action.parent then
        _action.parent.negativeAction = action()
        return _action.parent.negativeAction
    end
    _action.negativeAction = action()
    _action.negativeAction.parent = _action
    return _action.negativeAction
end

action = function()
    return {
        bound = {},
        axisBound = {},

        positive = positive,
        negative = negative,

        bindKeyDown = bindKeyDown,
        bindKeyPressed = bindKeyPressed,
        bindKeyReleased = bindKeyReleased,

        unbindKeyDown = unbindKeyDown,
        unbindKeyPressed = unbindKeyPressed,
        unbindKeyReleased = unbindKeyReleased,

        bindMouseDown = bindMouseDown,
        bindMousePressed = bindMousePressed,
        bindMouseReleased = bindMouseReleased,
        bindMouseWheelUp = bindMouseWheelUp,
        bindMouseWheelDown = bindMouseWheelDown,
        bindMouseWheelLeft = bindMouseWheelLeft,
        bindMouseWheelRight = bindMouseWheelRight,

        unbindMouseDown = unbindMouseDown,
        unbindMousePressed = unbindMousePressed,
        unbindMouseReleased = unbindMouseReleased,
        unbindMouseWheelUp = unbindMouseWheelUp,
        unbindMouseWheelDown = unbindMouseWheelDown,
        unbindMouseWheelLeft = unbindMouseWheelLeft,
        unbindMouseWheelRight = unbindMouseWheelRight,
        
        bindMouseWheelX = bindMouseWheelX,
        bindMouseWheelY = bindMouseWheelY,

        unbindMouseWheelX = unbindMouseWheelX,
        unbindMouseWheelY = unbindMouseWheelY,

        bindGamepadDown = bindGamepadDown,
        bindGamepadPressed = bindGamepadPressed,
        bindGamepadReleased = bindGamepadReleased,
        bindGamepadAxis = bindGamepadAxis,

        unbindGamepadDown = unbindGamepadDown,
        unbindGamepadPressed = unbindGamepadPressed,
        unbindGamepadReleased = unbindGamepadReleased,
        unbindGamepadAxis = unbindGamepadAxis,

        unbindAll = unbindAll,

        check = check,
        checkAxis = checkAxis,
        checkAxisRaw = checkAxisRaw,
    }
end



function input:action(name)
    if not self.actions[name] then
        self.actions[name] = action()
    end

    return self.actions[name]
end


------------ GENERAL ------------
function input:any()
    return self:mouseAny() or self:keyAny() or self:gamepadAny()
end

function input:anyPressed()
    return self:mouseAnyPressed() or self:keyAnyPressed() or self:gamepadAnyPressed()
end

function input:anyReleased()
    return self:mouseAnyReleased() or self:keyAnyReleased() or self:gamepadAnyReleased()
end

function input:get(action, gamepad)
    if self.actions[action] then
        return self.actions[action]:check(gamepad)
    end
end

function input:getPressed(action, gamepad)
    if self.actions[action] then
        return self.actions[action]:check(gamepad, "pressed")
    end
end


function input:getReleased(action, gamepad)
    if self.actions[action] then
        return self.actions[action]:check(gamepad, "released")
    end
end

function input:getDown(action, gamepad)
    if self.actions[action] then
        return self.actions[action]:check(gamepad, "down")
    end
end
function input:getAxis(action, gamepad)
    if self.actions[action] then
        return self.actions[action]:checkAxis(gamepad)
    end
end

function input:getAxisRaw(action, gamepad)
    if self.actions[action] then
        return self.actions[action]:checkAxisRaw(gamepad)
    end
end


function input:vibrate(duration)
    love.system.vibrate(duration)
end

------------ LOVE CALLBACKS------------

-- Keyboard
function input:keypressed(key)
    self.keyboard.pressed[key] = true
    self.keyboard.down[key] = true

    self.keyboard.lastPressed = key
    self.keyboard.lastDown = key
end

function input:keyreleased(key)
    self.keyboard.released[key] = true
    self.keyboard.down[key] = nil

    self.keyboard.lastReleased = key
    self.keyboard.lastDown = nil
end

function input:textinput(text)
    self.keyboard.textInput = text
end

-- Mouse
function input:mousepressed(x, y, button)
    self.mouse.pressed[button] = true
    self.mouse.down[button] = true

    self.mouse.lastPressed = button
    self.mouse.lastDown = button
end

function input:mousereleased(x, y, button)
    self.mouse.released[button] = true
    self.mouse.down[button] = nil

    self.mouse.lastReleased = button
    self.mouse.lastDown = nil
end

function input:mousemoved(x, y, dx, dy)
    self.mouse.x = x
    self.mouse.y = y
    self.mouse.dx = dx
    self.mouse.dy = dy
end

function input:wheelmoved(x, y)
    self.mouse.wheelX = x
    self.mouse.wheelY = y
end

-- Gamepad
function input:gamepadpressed(joystick, button)
    self.gamepads[joystick:getID()].pressed[button] = true
    self.gamepads[joystick:getID()].down[button] = true

    self.gamepads[joystick:getID()].lastPressed = button
    self.gamepads[joystick:getID()].lastDown = button
end

function input:gamepadreleased(joystick, button)
    self.gamepads[joystick:getID()].released[button] = true
    self.gamepads[joystick:getID()].down[button] = nil

    self.gamepads[joystick:getID()].lastReleased = button
    self.gamepads[joystick:getID()].lastDown = nil
end

function input:gamepadaxis(joystick, axis, value)
    self.gamepads[joystick:getID()].axis[axis] = value

    self.gamepads[joystick:getID()].lastAxis = axis
    self.gamepads[joystick:getID()].lastAxisValue = value
end

function input:joystickadded(joystick)
    local id = joystick:getID()
    self.gamepads[id] = {
        down = {},
        pressed = {},
        released = {},
        axis = {},

        lastDown = nil,
        lastPressed = nil,
        lastReleased = nil,
        lastAxis = nil,
        lastAxisValue = nil,
    }

    table.insert(self.gamepads.ids, id)
    table.insert(self.gamepads.added, id)

    self.gamepads.joysticks[id] = joystick

    self:onGamepadAdded(id)
end

function input:joystickremoved(joystick)
    local id = joystick:getID()
    self.gamepads[id] = nil

    for i = 1, #self.gamepads.ids, 1 do
        if self.gamepads.ids[i] == id then
            table.remove(self.gamepads.ids, i)
            break
        end
    end

    table.insert(self.gamepads.removed, id)

    self.gamepads.joysticks[id] = nil

    self:onGamepadRemoved(id)
end

-- set all love keyboard callbacks
function input:setupKeyboard()
    function love.keypressed(key)
        input:keypressed(key)
    end

    function love.keyreleased(key)
        input:keyreleased(key)
    end

    function love.textinput(text)
        input:textinput(text)
    end
end

-- set all love mouse callbacks
function input:setupMouse()
    function love.mousepressed(x, y, button)
        input:mousepressed(x, y, button)
    end

    function love.mousereleased(x, y, button)
        input:mousereleased(x, y, button)
    end

    function love.mousemoved(x, y, dx, dy)
        input:mousemoved(x, y, dx, dy)
    end

    function love.wheelmoved(x, y)
        input:wheelmoved(x, y)
    end
end

function input:setupGamepad()
    function love.gamepadpressed(joystick, button)
        input:gamepadpressed(joystick, button)
    end

    function love.gamepadreleased(joystick, button)
        input:gamepadreleased(joystick, button)
    end

    function love.gamepadaxis(joystick, axis, value)
        input:gamepadaxis(joystick, axis, value)
    end

    function love.joystickadded(joystick)
        input:joystickadded(joystick)
    end

    function love.joystickremoved(joystick)
        input:joystickremoved(joystick)
    end
end

-- set all love input callbacks
function input:setup()
    self:setupKeyboard()
    self:setupMouse()
    self:setupGamepad()
end


------------ CALLBACKS ------------

function input:onGamepadAdded(id)
    
end

function input:onGamepadRemoved(id)
    
end

return input