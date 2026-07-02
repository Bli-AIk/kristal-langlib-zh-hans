local PM, super = Class(PartyMember)

local function locChapter(default, key)
    local chapter_key = key .. "_chapter_" .. tostring(Game.chapter)
    if Game.hasStr and Game:hasStr(chapter_key) then
        return Game:loc(default, chapter_key)
    end
    return Game:loc(default, key)
end

function PM:getName()   return Game:loc(self.name,                  "chara_"..self.id.."_name") end
function PM:getTitle()  return Game:loc("LV[var:lv] [var:title]",   "chara_getTitle", {lv = self:getLevel(), title = locChapter(self.title, "chara_"..self.id.."_title")}) end

function PM:getXActName() return Game:loc(self.xact_name, "chara_"..self.id.."_xactName") end

return PM
