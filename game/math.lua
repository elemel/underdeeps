local pi = assert(math.pi)
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

local function mix(x, y, t)
  return (1 - t) * x + t * y
end

local function mix2(ax, ay, bx, by, tx, ty)
  ty = ty or tx
  return mix(ax, bx, tx), mix(ay, by, ty)
end

local function mix3(ax, ay, az, bx, by, bz, tx, ty, tz)
  ty = ty or tx
  tz = tz or tx

  return mix(ax, bx, tx), mix(ay, by, ty), mix(az, bz, tz)
end

local function normalizeAngle(a)
  return (a + pi) % (2 * pi) - pi
end

local function mixAngles(a, b, t)
  return a + normalizeAngle(b - a) * t
end

return {
  distance2 = distance2,
  length2 = length2,
  mix = mix,
  mix2 = mix2,
  mix3 = mix3,
  mixAngles = mixAngles,
  normalize2 = normalize2,
  normalizeAngle = normalizeAngle,
}
