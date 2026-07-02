local DarkEquipMenu, super = HookSystem.hookScript(DarkEquipMenu)

function DarkEquipMenu:drawStats()
    local party = self.party:getSelected()
    Draw.setColor(1, 1, 1, 1)
    Draw.draw(self.stat_icons["attack"], -8, 124, 0, 2, 2)
    Draw.draw(self.stat_icons["defense"], -8, 151, 0, 2, 2)
    Draw.draw(self.stat_icons["magic"], -8, 178, 0, 2, 2)
    love.graphics.print(Game:loc("Attack:", "attack_stat"), 18, 118)
    love.graphics.print(Game:loc("Defense:", "defense_stat"), 18, 145)
    love.graphics.print(Game:loc("Magic:", "magic_stat"), 18, 172)
    local stats, compare = self:getStatsPreview()
    self:drawStatPreview("attack", 148, 118, stats, compare, self:getCurrentItemType() == "weapons")
    self:drawStatPreview("defense", 148, 145, stats, compare, false)
    self:drawStatPreview("magic", 148, 172, stats, compare, false)
    local abilities, ability_comp = self:getAbilityPreview()
    for i = 1, 3 do
        self:drawAbilityPreview(i, -8, 178 + (27 * i), abilities, ability_comp)
    end
end

function DarkEquipMenu:drawAbilityPreview(index, x, y, abilities, compare)
    local name = abilities[index] and abilities[index].name or nil
    local comp_name = compare[index] and compare[index].name or nil
    if abilities[index] and abilities[index].icon then
        local yoff = self.state == "ITEMS" and -6 or 2
        local texture = Assets.getTexture(abilities[index].icon)
        if texture then
            Draw.setColor(abilities[index].color)
            Draw.draw(texture, x, y + yoff, 0, 2, 2)
        end
    end
    if name ~= comp_name then
        if name ~= nil then
            Draw.setColor(1, 1, 0)
        else
            Draw.setColor(1, 0, 0)
        end
    else
        if (name and self.state ~= "ITEMS") or (self.state == "ITEMS" and self.selected_slot == index and self:canEquipSelected()) then
            Draw.setColor(1, 1, 1)
        else
            Draw.setColor(0.25, 0.25, 0.25)
        end
    end
    love.graphics.print(name or Game:loc("(No ability.)", "no_ability_stat"), x + 26, y - 6)
end

return DarkEquipMenu
