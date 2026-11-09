local watcher, hook
CreateFrame = function()
  watcher = { shown = true, scripts = {} }
  function watcher:Hide() self.shown = false end
  function watcher:Show() self.shown = true end
  function watcher:SetScript(event, callback) self.scripts[event] = callback end
  return watcher
end
local now, falling, mounted, swimming = 0, false, false, false
GetTime = function() return now end
IsFalling = function() return falling end
IsMounted = function() return mounted end
IsSwimming = function() return swimming end
UnitOnTaxi = function() return false end
UnitIsGhost = function() return false end
JumpOrAscendStart = function() end
hooksecurefunc = function(name, callback)
  assert(name == "JumpOrAscendStart")
  hook = callback
end
local count = 0
local AF = { RecordJump = function() count = count + 1 end }
assert(loadfile("Jump.lua"))("AzerothFitness", AF)
AF.Jump.Start()
hook()
assert(watcher.shown and count == 0)
now, falling = 0.1, true
watcher.scripts.OnUpdate()
assert(count == 1 and not watcher.shown)
hook()
assert(not watcher.shown, "Held/repeated input while airborne must not count again")
now, falling = 1, false
hook()
now = 1.9
watcher.scripts.OnUpdate()
assert(count == 1 and not watcher.shown, "An unconfirmed press must expire")
mounted = true
hook()
assert(not watcher.shown)
mounted, swimming = false, true
hook()
assert(not watcher.shown)
print("PASS: jump confirmation, airborne repeat suppression, timeout and mounted/swimming exclusions")
