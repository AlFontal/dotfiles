require("hs.ipc") -- lets the `hs` command-line tool talk to Hammerspoon

-- Move the divider between two side-by-side windows.
--   cmd+alt+left  : divider moves left
--   cmd+alt+right : divider moves right
-- Hold the keys to keep moving. The focused window and the window on its other
-- side are resized together, so they always meet and their outer edges stay
-- where they are. If the two don't meet yet (a gap or an overlap), the first
-- press lines them up at whichever inner edge is in the arrow's direction.
-- With no window on the other side, only the focused window is resized.

local STEP = 20   -- pixels per press
local TOL = 20    -- how close two edges must be to count as touching
local MIN_W = 300 -- smallest width either window may get

hs.window.animationDuration = 0

local function near(a, b) return math.abs(a - b) <= TOL end

-- Windows on the same screen that share most of `win`'s height, frontmost first.
local function sideBySide(win)
  local f = win:frame()
  local screenId = win:screen():id()
  local result = {}
  for _, w in ipairs(hs.window.orderedWindows()) do
    if w:id() ~= win:id() and w:isStandard() and w:screen():id() == screenId then
      local g = w:frame()
      local overlap = math.min(f.y + f.h, g.y + g.h) - math.max(f.y, g.y)
      if overlap > 0.5 * f.h then table.insert(result, w) end
    end
  end
  return result
end

-- Window whose edge touches `win`'s left or right edge.
local function findNeighbor(win, side)
  local f = win:frame()
  local edge = (side == "right") and (f.x + f.w) or f.x
  for _, w in ipairs(sideBySide(win)) do
    local g = w:frame()
    if near((side == "right") and g.x or (g.x + g.w), edge) then return w end
  end
end

-- Window that reaches the opposite screen edge on `side`, touching or not.
local function findPartner(win, side)
  local s = win:screen():frame()
  for _, w in ipairs(sideBySide(win)) do
    local g = w:frame()
    if side == "right" and near(g.x + g.w, s.x + s.w) and g.x > s.x + TOL then return w end
    if side == "left" and near(g.x, s.x) and g.x + g.w < s.x + s.w - TOL then return w end
  end
end

local function setLeftWindow(w, d)  -- keep its left edge, put its right edge at d
  local g = w:frame(); g.w = d - g.x; w:setFrame(g)
  local a = w:frame(); return a.x + a.w
end

local function setRightWindow(w, d) -- keep its right edge, put its left edge at d
  local g = w:frame(); local r = g.x + g.w; g.x = d; g.w = r - d; w:setFrame(g)
  return w:frame().x
end

local function moveDivider(dx)
  local win = hs.window.focusedWindow()
  if not win then return end
  local f, s = win:frame(), win:screen():frame()
  local atLeft = near(f.x, s.x)
  local atRight = near(f.x + f.w, s.x + s.w)

  local leftWin, rightWin
  if atLeft and atRight then
    return -- full width, nothing to split
  elseif atLeft then
    leftWin, rightWin = win, findNeighbor(win, "right") or findPartner(win, "right")
  elseif atRight then
    leftWin, rightWin = findNeighbor(win, "left") or findPartner(win, "left"), win
  else
    local r = findNeighbor(win, "right")
    if r then leftWin, rightWin = win, r
    else
      local l = findNeighbor(win, "left")
      if not l then return end
      leftWin, rightWin = l, win
    end
  end

  -- Inner edges: e1 = right edge of the left window, e2 = left edge of the right one.
  local lf = leftWin and leftWin:frame()
  local rf = rightWin and rightWin:frame()
  local e1 = lf and (lf.x + lf.w)
  local e2 = rf and rf.x

  local d
  if e1 and e2 and not near(e1, e2) then
    d = (dx < 0) and math.min(e1, e2) or math.max(e1, e2) -- line them up first
  else
    d = (e1 or e2) + dx
  end
  local lo = (lf and lf.x or s.x) + MIN_W
  local hi = (rf and (rf.x + rf.w) or (s.x + s.w)) - MIN_W
  d = math.max(lo, math.min(hi, d))

  -- Resize the shrinking window first; some apps refuse a size or round it
  -- (terminals snap to character cells), so the other window follows where
  -- the first one ended up.
  if leftWin and d < e1 then
    d = setLeftWindow(leftWin, d)
    if rightWin then setRightWindow(rightWin, d) end
  elseif rightWin and d > e2 then
    d = setRightWindow(rightWin, d)
    if leftWin then setLeftWindow(leftWin, d) end
  else
    if leftWin and d ~= e1 then d = setLeftWindow(leftWin, d) end
    if rightWin and d ~= e2 then setRightWindow(rightWin, d) end
  end
end

local mods = { "cmd", "alt" }
local function left() moveDivider(-STEP) end
local function right() moveDivider(STEP) end
hs.hotkey.bind(mods, "left", left, nil, left)
hs.hotkey.bind(mods, "right", right, nil, right)

-- Focus the window to the left / right of the focused one.
--   ctrl+alt+left / ctrl+alt+right
local function focusDir(method)
  return function()
    local win = hs.window.focusedWindow()
    if win then win[method](win, nil, true, true) end
  end
end
hs.hotkey.bind({ "ctrl", "alt" }, "left", focusDir("focusWindowWest"))
hs.hotkey.bind({ "ctrl", "alt" }, "right", focusDir("focusWindowEast"))

hs.alert.show("Hammerspoon config loaded")
