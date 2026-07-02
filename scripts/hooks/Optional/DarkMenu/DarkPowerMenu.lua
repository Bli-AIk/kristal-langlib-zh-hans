local DarkPowerMenu, super = HookSystem.hookScript(DarkPowerMenu)

function DarkPowerMenu:drawStats()
    local party = self.party:getSelected()
    Draw.setColor(1, 1, 1, 1)
    Draw.draw(self.stat_icons[ "attack"], -8, 124, 0, 2, 2)
    Draw.draw(self.stat_icons["defense"], -8, 149, 0, 2, 2)
    Draw.draw(self.stat_icons[  "magic"], -8, 174, 0, 2, 2)
    love.graphics.print(  Game:loc("Attack:", "attack_stat"), 18, 118)
    love.graphics.print(Game:loc("Defense:", "defense_stat"), 18, 143)
    love.graphics.print(    Game:loc("Magic:", "magic_stat"), 18, 168)
    local stats = party:getStats()
    love.graphics.print(stats[ "attack"], 148, 118)
    love.graphics.print(stats["defense"], 148, 143)
    love.graphics.print(stats[  "magic"], 148, 168)
    for i = 1, 3 do
        local x, y = 18, 168 + (i * 25)
        love.graphics.setFont(self.font)
        Draw.setColor(PALETTE["world_text"])
        love.graphics.push()
        if not party:drawPowerStat(i, x, y, self) then
            Draw.setColor(PALETTE["world_dark_gray"])
            love.graphics.print(Game:loc("???", "no_power_stat"), x, y)
        end
        love.graphics.pop()
    end
end

return DarkPowerMenu