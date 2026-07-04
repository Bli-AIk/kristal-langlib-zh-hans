local Actor, super = HookSystem.hookScript(Actor)

function Actor:getName() return Game:locName("actor", self.id, self.name or self.id) end

return Actor
