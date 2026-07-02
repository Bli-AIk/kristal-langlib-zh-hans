local Actor, super = HookSystem.hookScript(Actor)

function Actor:getName() return Game:loc(self.name or self.id, "actor_"..self.id.."_name") end

return Actor