local Item, super = HookSystem.hookScript(Item)

function Item:onCheck()
    if type(self:getCheck()) == "table" then
        local text
        for i, check in ipairs(self:getCheck()) do
            if i > 1 then
                if text == nil then
                    text = {}
                end
                table.insert(text, check)
            end
        end
        Game.world:showText({{Game:loc("* \"[var:name]\" - [var:check]",    "item_check", {name = self:getName(), check = (self:getCheck()[1] or "")})}, text})
    else
        Game.world:showText(Game:loc("* \"[var:name]\" - [var:check]",      "item_check", {name = self:getName(), check = self:getCheck()}))
    end
end

function Item:onToss()
    if Game:isLight() then
        if self.type == "weapon" and not Game:getConfig("canTossLightWeapons") then
            Game.world:showText(Game:loc("* (Recently, seems like weapons can't be thrown away so easily.)", "item_tossWeapon"))
            return false
        end

        local choice = love.math.random(30)
        if choice == 1 then
            Game.world:showText(Game:loc("* You bid a quiet farewell to the [var:name].",                           (Game:hasStr("item_"..self.id.."_toss1") and "item_"..self.id.."_toss1" or "item_toss1"),   {name = self:getName()}))
        elseif choice == 2 then
            Game.world:showText(Game:loc("* You put the [var:name] on the ground and gave it a little pat.",        (Game:hasStr("item_"..self.id.."_toss2") and "item_"..self.id.."_toss2" or "item_toss2"),   {name = self:getName()}))
        elseif choice == 3 then
            Game.world:showText(Game:loc("* You threw the [var:name] on the ground like the piece of trash it is.", (Game:hasStr("item_"..self.id.."_toss3") and "item_"..self.id.."_toss3" or "item_toss3"),   {name = self:getName()}))
        elseif choice == 4 then
            Game.world:showText(Game:loc("* You abandoned the [var:name].",                                         (Game:hasStr("item_"..self.id.."_toss4") and "item_"..self.id.."_toss4" or "item_toss4"),   {name = self:getName()}))
        else
            Game.world:showText(Game:loc("* The [var:name] was thrown away.",                                       (Game:hasStr("item_"..self.id.."_toss5") and "item_"..self.id.."_toss5" or "item_toss5"),   {name = self:getName()}))
        end
    end
    return true
end

function Item:getName()     return Game:loc(self.name, "item_"..self.id.."_name") end
function Item:getUseName()  return Game:loc(self.use_name or StringUtils.upper(self:getName()), "item_"..self.id.."_useName") end

local function locChapter(default, key)
    local chapter_key = key .. "_chapter_" .. tostring(Game.chapter)
    if Game.hasStr and Game:hasStr(chapter_key) then
        return Game:loc(default, chapter_key)
    end
    return Game:loc(default, key)
end

function Item:getDescription() return locChapter(self.description, "item_"..self.id.."_description") end
function Item:getBattleDescription() return locChapter(self.effect, "item_"..self.id.."_effect") end
function Item:getCheck() return Game:loc(self.check, "item_"..self.id.."_check") end

function Item:getShopDescription()
    return Game:loc("[var:typeName]\n[var:shopName]", "item_"..self.id.."_shopDesc", {typeName = self:getTypeName(), shopName = Game:loc(self.shop, "item_"..self.id.."_shopName")})
end

function Item:getBattleText(user, target)
    return Game:loc("* [var:charaName] used the [var:useName]!", (Game:hasStr("item_"..self.id.."_battleText") and "item_"..self.id.."_battleText" or "item_battleText"), {charaName = user.chara:getName(), useName = self:getUseName()})
end

function Item:getReaction(user_id, reactor_id)
    local reactions = self:getReactions()
    if reactions[user_id] then
        if type(reactions[user_id]) == "string" then
            if reactor_id == user_id then
                return Game:loc(reactions[user_id], "item_"..self.id.."_"..user_id.."Reaction") -- item_darkburger_krisReaction
            else
                return nil
            end
        else
            return Game:loc(reactions[user_id][reactor_id], "item_"..self.id.."_"..user_id.."/"..reactor_id.."Reaction") -- item_darkburger_kris/ralseiReaction
        end
    end
end

function Item:getTypeName()
    if self.type == "item" then
        return Game:loc("ITEM", "itemType_item")
    elseif self.type == "key" then
        return Game:loc("KEYITEM", "itemType_key")
    elseif self.type == "weapon" then
        return Game:loc("WEAPON", "itemType_weapon")
    elseif self.type == "armor" then
        return Game:loc("ARMOR", "itemType_armor")
    end
    return Game:loc("UNKNOWN", "itemType_unknown")
end

return Item
