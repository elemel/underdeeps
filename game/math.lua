local sqrt = assert(math.sqrt)

local function length2(x, y)
  return sqrt(x * x + y * y)
end

local function distance2(ax, ay, bx, by)
  return length2(bx - ax, by - ay)
end

local function normalize2(x, y)
  local len = length2(x, y)
  return x / len, y / len, len
end

return {
  distance2 = distance2,
  length2 = length2,
  normalize2 = normalize2,
}
