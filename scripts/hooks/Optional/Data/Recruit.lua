local Recruit, super = HookSystem.hookScript(Recruit)

function Recruit:getName()        return Game:loc(self.name,        "recruit_"..self.id.."_name")        end
function Recruit:getDescription() return Game:loc(self.description, "recruit_"..self.id.."_description") end
function Recruit:getElement()     return Game:loc(self.element,     "recruit_"..self.id.."_element")     end
function Recruit:getLike()        return Game:loc(self.like,        "recruit_"..self.id.."_like")        end
function Recruit:getDislike()     return Game:loc(self.dislike,     "recruit_"..self.id.."_dislike")     end

return Recruit