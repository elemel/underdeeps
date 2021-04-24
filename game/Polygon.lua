local Class = require("game.Class")

local huge = assert(math.huge)
local insert = assert(table.insert)
local max = assert(math.max)
local min = assert(math.min)

local M = Class.new()

function M:init(vertices)
    self.vertices = {unpack(vertices)}
    assert(#self.vertices % 2 == 0)
    assert(#self.vertices >= 6)
    return self
end

function M:clone()
    return M.new(self.vertices)
end

function M:getBounds()
    local x1 = huge
    local y1 = huge

    local x2 = -huge
    local y2 = -huge

    for i = 1, #self.vertices, 2 do
        local x = self.vertices[i]

        x1 = min(x1, x)
        x2 = max(x2, x)
    end

    for i = 2, #self.vertices, 2 do
        local y = self.vertices[i]

        y1 = min(y1, y)
        y2 = max(y2, y)
    end

    return x1, y1, x2, y2
end

function M:clip(x1, y1, x2, y2)
    local vertices = self.vertices
    self.vertices = {}

    local x3 = vertices[#vertices - 1]
    local y3 = vertices[#vertices]

    for i = 1, #vertices, 2 do
        local x4 = vertices[i]
        local y4 = vertices[i + 1]

        if self:isPointInside(x4, y4, x1, y1, x2, y2) then
            if not self:isPointInside(x3, y3, x1, y1, x2, y2) then
                local x, y = self:intersectLines(x3, y3, x4, y4, x1, y1, x2, y2)

                insert(self.vertices, x)
                insert(self.vertices, y)
            end

            insert(self.vertices, x4)
            insert(self.vertices, y4)
        else
            if self:isPointInside(x3, y3, x1, y1, x2, y2) then
                local x, y = self:intersectLines(x3, y3, x4, y4, x1, y1, x2, y2)

                insert(self.vertices, x)
                insert(self.vertices, y)
            end
        end

        x3 = x4
        y3 = y4
    end
end

function M:isPointInside(x, y, x1, y1, x2, y2)
    return (x - x1) * (y2 - y1) - (y - y1) * (x2 - x1) < 0
end

-- See: https://en.wikipedia.org/wiki/Line%E2%80%93line_intersection
function M:intersectLines(x1, y1, x2, y2, x3, y3, x4, y4)
    local divisor = (x1 - x2) * (y3 - y4) - (y1 - y2) * (x3 - x4)

    local x = (x1 * y2 - y1 * x2) * (x3 - x4) - (x1 - x2) * (x3 * y4 - y3 * x4)
    local y = (x1 * y2 - y1 * x2) * (y3 - y4) - (y1 - y2) * (x3 * y4 - y3 * x4)

    return x / divisor, y / divisor
end

-- See: https://en.wikipedia.org/wiki/Centroid#Centroid_of_a_polygon
function M:getArea()
    local area = 0
    local x1 = self.vertices[#self.vertices - 1]
    local y1 = self.vertices[#self.vertices]

    for i = 1, #self.vertices, 2 do
        local x2 = self.vertices[i]
        local y2 = self.vertices[i + 1]
        area = area + (x1 * y2 - x2 * y1)
        x1 = x2
        y1 = y2
    end

    return 0.5 * area
end

-- See: https://en.wikipedia.org/wiki/Centroid#Centroid_of_a_polygon
function M:getCentroid()
    local centroidX = 0
    local centroidY = 0

    local area = 0

    local x1 = self.vertices[#self.vertices - 1]
    local y1 = self.vertices[#self.vertices]

    for i = 1, #self.vertices, 2 do
        local x2 = self.vertices[i]
        local y2 = self.vertices[i + 1]

        local z = (x1 * y2 - x2 * y1)

        centroidX = centroidX + (x1 + x2) * z
        centroidY = centroidY + (y1 + y2) * z

        area = area + z

        x1 = x2
        y1 = y2
    end

    local scale = 1 / (3 * area)
    return scale * centroidX, scale * centroidY, 0.5 * area
end

function M:containsPoint(x, y)
    local x1 = self.vertices[#self.vertices - 1]
    local y1 = self.vertices[#self.vertices]

    for i = 1, #self.vertices, 2 do
        local x2 = self.vertices[i]
        local y2 = self.vertices[i + 1]

        if cross2(x - x1, y - y1, x2 - x1, y2 - y1) > 0 then
            return false
        end

        x1 = x2
        y1 = y2
    end

    return true
end

return M
