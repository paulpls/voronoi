--
--  Voronoi polygon generator
--  ----------------------------------------------------------------------------
--  Generates voronoi polygons from a series of random points.
--
--  Author:  paulpls
--  License: GLP 3.0
--



--
--  Parameters
--
local w,h = love.graphics.getDimensions()
local n = 32    --  Number of points to generate
local a = 1.0   --  Transparency, 0.0 -> 1.0
local d = 0.1   --  Animation delay, seconds


--
--  Dependencies
--
require "class"
local Grid = require "grid"



love.load = function ()
    --
    --  Load and randomize the grid
    --
    grid = Grid:new(w, h, n, a, d)
    grid:randomize()
end



love.update = function (dt)
    --
    --  Update and animate the grid
    --
    grid:update(dt)
end



love.draw = function ()
    --
    --  Draw points and colors
    --
    grid:draw()
end



love.keypressed = function (key)
    --
    --  Detect keyboard input
    --
    if key == "escape" or key == "q" then
        --  Quit
        love.event.quit()
    elseif key == "r" then
        --  Refresh and randomize
        grid:refresh()
        grid:randomize()
    elseif key == "space" then
        --  Toggle animaton
        grid.animate = not grid.animate
    end
end



love.mousepressed = function (x, y, button, isTouch, presses)
    --
    --  Add points where clicked
    --
    if grid:validate(x,y) then grid:plot(x,y) end
end



love.quit = function (msg)
    --
    --  Bye, Felicia
    --
    print("\nDone")
end



