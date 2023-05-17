--
--  Grid prototype
--
local Grid = Class:new()



--
--  Utils for square and square root
--
local sq =   function (n) return math.pow(n, 2) end
local sqrt = function (n) return math.sqrt(n) end



local hsvaColor = function (h, s, v, a)
    --
    --  HSVA color modelling
    --  Based on the example at https://love2d.org/wiki/HSV_color
    --
    h = h / 255
    if s <= 0 then return {v, v, v, a} end
    h = h * 6
    local c = v * s
    local x = c * (1 - math.abs((h % 2) - 1))
    local m = v - c
    local colors = {
        {c, x, 0},
        {x, c, 0},
        {0, c, x},
        {0, x, c},
        {x, 0, x},
        {c, 0, x}
    }
    h = 1 + math.floor(h) % 6
    local r,g,b = unpack(colors[h])
    return {
        r + m,
        g + m,
        b + m,
        a
    }
end



Grid.init = function (self, w, h, n, a, d)
    --
    --  Init
    --
    self.totalPoints = n   --  Number of points to generate
    self.points = {}       --  Table of generated points
    self.color = {}        --  Color information
    self.alpha = a         --  Color transparency, 0.0 -> 1.0
    self.stopped = false   --  True if no more points to plot
    self.r = 1             --  Current radius
    self.animate = true    --  Toggle animation
    self.delay = d         --  Animation delay, seconds
    self.elapsed = 0       --  Animation time elapsed, seconds
    --  Set grid width and height to window dimensions
    self.w, self.h = love.graphics.getDimensions()
    --  Configure RNG
    math.randomseed(os.time())
    math.random()
    math.random()
    math.random()
end



Grid.count = function (self)
    --
    --  Returns the total number of points in the grid
    --
    if self.points == {} then return 0 end
    local n = 0
    for y in pairs(self.points) do
        for x in pairs(self.points[y]) do n = n + 1 end
    end
    return n
end



Grid.refresh = function (self, hard)
    --
    --  Refresh the grid
    --
    if hard then self.points = {} end
    self.color = {}
    self.animate = false
    self.stopped = false
    self.elapsed = 0
    self.r = 1
end



Grid.plot = function (self, x, y)
    --
    --  Plot a point and assign a color to it
    --
    local h = math.floor((self:count()) / self.totalPoints * 255)
    local s = 1
    local v = math.random(50, 100) / 100
    local a = self.alpha
    --  Soft refresh
    self:refresh()
    --  Add point and color information
    if not self.points[y] then self.points[y] = {} end
    self.points[y][x] = hsvaColor(h, s, v, a)
end



Grid.randomize = function (self)
    --
    --  Plot a number of random points in the window
    --
    for _=1, self.totalPoints do
        local x = math.floor(math.random() * self.w)
        local y = math.floor(math.random() * self.h)
        self:plot(x, y)
    end
end



Grid.validate = function (self, x, y)
    --
    --  Point (x,y) is valid if:
    --  *   (x,y) coordinates are within window boundaries
    --  *   Color information is not detected
    --
    local X = (0 < x) and (x <= self.w)
    local Y = (0 < y) and (y <= self.h)
    if X and Y then 
        if self.color[y] then
            return not self.color[y][x]
        else
            return true
        end
    else
        return false
    end
end



Grid.grow = function (self, h, k, r)
    --
    --  Cache the set of points within a circle centered at point (h,k):
    --                     ____________________
    --                    /   2             2
    --      x == h + ‾\  /   r  -  ( y - k )
    --                 \/
    --
    for y=k-r, k+r do
        --  Solve for x
        local x1 = math.ceil(h - sqrt(sq(r) - sq(y-k)))
        local x2 = math.ceil(h + sqrt(sq(r) - sq(y-k)))
        --  Validate results in range and add color info
        for x=x1, x2 do
            if self:validate(x, y) then
                if not self.color[y] then self.color[y] = {} end
                self.color[y][x] = self.points[k][h]
            end
        end
    end 
end



Grid.update = function (self, dt)
    --
    --  Animate and grow the plot
    --
    if self.animate and not self.stopped then
        self.elapsed = self.elapsed + dt
        if self.elapsed > self.delay then
            --  Subtract delay from elapsed time
            self.elapsed = self.elapsed - self.delay
            --  Iterate points and grow the plot
            for y in pairs(self.points) do
                for x in pairs(self.points[y]) do
                    self:grow(x, y, self.r)
                end
            end
            --  Increment radius
            self.r = self.r + 1
            --  Stop growth if maxed out
            local max = math.min(grid.w, grid.h)
            self.stopped = self.r >= max
        end
    end
end



Grid.draw = function (self)
    --
    --  Draw points and color information
    --
    local points = self.points
    local color = self.color
    --  Draw color data
    for y in pairs(self.color) do
        for x in pairs(self.color[y]) do
            love.graphics.setColor(self.color[y][x])
            love.graphics.rectangle("fill", x, y, 1, 1)
        end
    end
    --  Draw points
    for y in pairs(self.points) do
        for x in pairs(self.points[y]) do
            love.graphics.setColor({1,1,1})
            love.graphics.rectangle("fill", x-1, y-1, 3, 3)
            love.graphics.setColor({0,0,0})
            love.graphics.rectangle("line", x-2, y-2, 5, 5)
        end
    end
end



return Grid



