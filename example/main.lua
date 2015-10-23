-- This program is free software: you can redistribute it and/or modify
-- it under the terms of the GNU General Public License as published by
-- the Free Software Foundation, either version 3 of the License, or
-- any later version.
   
-- This program is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU General Public License for more details.
   
-- You should have received a copy of the GNU General Public License
-- along with this program. If not, see http://www.gnu.org/licenses/.

-----------------------------------------------------------------------

-- Nova pinball engine example
-- Written by Wesley "keyboard monkey" Werner 2015
-- https://github.com/wesleywerner/

-- The pinball table editor was used to create the table layout.
-- The table file is nothing more than a lua table serialized
-- with the binser utility. You are free to deconstruct the table format, or
-- look at the editor code.

-- This example shows the bare minimum to get a pinball game up and running.

local pinball = require ("nova-pinball-engine")

function love.load()
    love.graphics.setBackgroundColor(0, 0, 0)
    -- Load the table layout into the pinball engine
    local binser = require("binser")
    local mydata, size = love.filesystem.read("nova.pinball", nil)
    local tableDefinition = binser.deserialize(mydata)
    pinball:loadTable(tableDefinition)
    pinball:newBall()
end

function love.update (dt)
    -- Update the pinball simulation
    pinball:update(dt)
end

function love.keypressed (key, isrepeat)
    if (key == "escape") then
        love.event.quit()
    elseif (key == " ") then
        pinball:newBall()
    end
end

function love.draw ( )
    pinball:draw()
end

function love.resize (w, h)
    -- Recalculate positions and draw scale
    pinball:resize(w, h)
end

function pinball.drawWall (points)
    love.graphics.setLineWidth(6)
    love.graphics.setColor(92, 201, 201)
    love.graphics.line(points)
end

function pinball.drawBumper (tag, x, y, r)
    love.graphics.setLineWidth(2)
    love.graphics.setColor(42, 161, 152)
    love.graphics.circle("fill", x, y, r * 0.8)
    love.graphics.setColor(108, 113, 196)
    love.graphics.circle("line", x, y, r)
end

function pinball.drawKicker (tag, points)
    love.graphics.setLineWidth(1)
    love.graphics.setColor(108, 196, 113)
    love.graphics.polygon("fill", points)
end

function pinball.drawTrigger (tag, points)
    love.graphics.setLineWidth(1)
    love.graphics.setColor(32, 32, 32)
    love.graphics.polygon("fill", points)
end

function pinball.drawFlipper (orientation, position, angle, origin, points)
    -- orientation is "left" or "right"
    -- position {x,y}
    -- angle is in radians
    -- origin {x,y} is offset from the physics body center
    -- points {} are polygon vertices

    love.graphics.setColor(108, 113, 196)
    love.graphics.polygon("fill", points)
    love.graphics.setLineWidth(4)
    love.graphics.setColor(68, 73, 156)
    love.graphics.polygon("line", points)
end

function pinball.drawBall (x, y, radius)
    love.graphics.setLineWidth(4)
    love.graphics.setColor(238, 232, 213)
    love.graphics.circle("fill", x, y, radius)
    love.graphics.setColor(147, 161, 161)
    love.graphics.circle("line", x, y, radius)
end

-- Called when a ball has drained out of play.
function pinball.ballDrained (ballsInPlay)
    if (ballsInPlay == 0) then
        pinball:newBall()
    end
end

function pinball.tagContact (tag, id)
    print("tag hit:", tag, "id:", id)

    -- Demonstrates locking the ball in place for a short period
    -- before ejecting it back into play.
    if (tag == "hole") then
        local x, y = pinball:getObjectXY("hole")
        local secondsDelay = 1
        local releaseXVelocity = 500
        local releaseYVelocity = 500
        pinball:lockBall(id, x, y, secondsDelay, releaseXVelocity, releaseYVelocity)
    end
end

-- When a ball is locked with pinball:lockBall()
function pinball.ballLocked(id)
end

-- When a locked ball delay expired and is released into play
function pinball.ballUnlocked(id)
end
