local DarkItemMenu, super = HookSystem.hookScript(DarkItemMenu)

function DarkItemMenu:draw()
    love.graphics.setFont(self.font)

    local headers = {Game:loc("USE", "use_item"), Game:loc("TOSS", "toss_item"), Game:loc("KEY", "key_item")}

    for i,name in ipairs(headers) do
        if self.state == "MENU" then
            Draw.setColor(PALETTE["world_header"])
        elseif self.item_header_selected == i then
            Draw.setColor(PALETTE["world_header_selected"])
        else
            Draw.setColor(PALETTE["world_gray"])
        end
        local x = 88 + ((i - 1) * 120)
        love.graphics.print(name, x, -2)
    end

    local heart_x = 20
    local heart_y = 20

    if self.state == "MENU" then
        heart_x = 88 + ((self.item_header_selected - 1) * 120) - 25
        heart_y = 8
    elseif self.state == "SELECT" then
        heart_x = 28 + (self.item_selected_x - 1) * 210
        heart_y = 50 + (self.item_selected_y - 1) * 30
    end
    if self.state ~= "USE" then
        Draw.setColor(Game:getSoulColor())
        Draw.draw(self.heart_sprite, heart_x, heart_y)
    end

    local item_x = 0
    local item_y = 0
    local inventory = self:getCurrentStorage()

    for _, item in ipairs(inventory) do
        -- Draw the item shadow
        Draw.setColor(PALETTE["world_text_shadow"])
        local name = item:getWorldMenuName()
        love.graphics.print(name, 54 + (item_x * 210) + 2, 40 + (item_y * 30) + 2)

        if self.state == "MENU" then
            Draw.setColor(PALETTE["world_gray"])
        else
            if item.usable_in == "world" or item.usable_in == "all" then
                Draw.setColor(PALETTE["world_text"])
            else
                Draw.setColor(PALETTE["world_text_unusable"])
            end
        end
        love.graphics.print(name, 54 + (item_x * 210), 40 + (item_y * 30))
        item_x = item_x + 1
        if item_x >= 2 then
            item_x = 0
            item_y = item_y + 1
        end
    end

    for _, item in ipairs(inventory) do
        Draw.setColor(1,1,1)
        item:onMenuDraw(self.parent)
    end

    super.super.draw(self)
end

return DarkItemMenu