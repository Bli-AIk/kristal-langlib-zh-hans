local Spell, super = HookSystem.hookScript(Spell)

local function locChapter(default, key)
    local chapter_key = key .. "_chapter_" .. tostring(Game.chapter)
    if Game.hasStr and Game:hasStr(chapter_key) then
        return Game:loc(default, chapter_key)
    end
    return Game:loc(default, key)
end

function Spell:getName()        return Game:loc(self.name,                                  "spell_"..self.id.."_name")     end
function Spell:getCastName()    return Game:loc(self.cast_name or StringUtils.upper(self:getName()), "spell_"..self.id.."_castName") end

function Spell:getDescription()         return locChapter(self.description, "spell_"..self.id.."_description") end
function Spell:getBattleDescription()   return locChapter(self.effect,      "spell_"..self.id.."_effect")      end

function Spell:getCastMessage(user, target)
    return Game:loc("* [var:userName] cast [var:castName]!", "spell_castMessage", {userName = user.chara:getName(), castName = self:getCastName()})
end

return Spell
