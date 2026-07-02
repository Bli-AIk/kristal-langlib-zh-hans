local Choicebox, super = Class(Choicebox)

function Choicebox:init(x, y, width, height, battle_box, options)
    super.init(self, x, y, width, height)

    options = options or {}

    self.variables = options["var"] or {}
end

function Choicebox:draw()
    super.super.draw(self)

    love.graphics.setFont(self.font)
    if self.choices[1] then
        local choice = Game:concat(self.choices[1], self.variables)
        Draw.setColor(self.main_colors[1])
        if self.current_choice == 1 then Draw.setColor(self.hover_colors[1]) end
        love.graphics.print(choice, 36, 24)
    end
    if self.choices[2] then
        local choice = Game:concat(self.choices[2], self.variables)
        Draw.setColor(self.main_colors[2])
        if self.current_choice == 2 then Draw.setColor(self.hover_colors[2]) end
        love.graphics.print(choice, 528 - self.font:getWidth(choice), 24)
    end
    if self.choices[3] then
        local choice = Game:concat(self.choices[3], self.variables)
        Draw.setColor(self.main_colors[3])
        if self.current_choice == 3 then Draw.setColor(self.hover_colors[3]) end
        love.graphics.print(choice, 17 + MathUtils.round(self.width / 2) - MathUtils.round(self.font:getWidth(choice) / 2), -8)
    end
    if self.choices[4] then
        local choice = Game:concat(self.choices[4], self.variables)
        Draw.setColor(self.main_colors[4])
        if self.current_choice == 4 then Draw.setColor(self.hover_colors[4]) end
        love.graphics.print(choice, 17 + MathUtils.round(self.width / 2) - MathUtils.round(self.font:getWidth(choice) / 2), 78)
    end

    local choice_2 = Game:concat(self.choices[2] or "", self.variables)
    local choice_3 = Game:concat(self.choices[3] or "", self.variables)
    local choice_4 = Game:concat(self.choices[4] or "", self.variables)

    local soul_positions = {
        --[[ Center: ]] {224, 38},
        --[[ Left:   ]] {4,   34},
        --[[ Right:  ]] {528 - self.font:getWidth(choice_2) - 32, 34},
        --[[ Top:    ]] {17 + MathUtils.round(self.width / 2) - MathUtils.round(self.font:getWidth(choice_3) / 2) - 32, -8 + 6},
        --[[ Bottom: ]] {17 + MathUtils.round(self.width / 2) - MathUtils.round(self.font:getWidth(choice_4) / 2) - 32, 78 + 6}
    }

    local heart_x = soul_positions[self.current_choice + 1][1]
    local heart_y = soul_positions[self.current_choice + 1][2]

    Draw.setColor(Game:getSoulColor())
    Draw.draw(self.heart, heart_x, heart_y, 0, 2, 2)
end

return Choicebox
