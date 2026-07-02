local DarkStorageMenu, super = HookSystem.hookScript(DarkStorageMenu)

function DarkStorageMenu:updateDescription()
    local item = self:getSelectedItem(self.list)
    local new_text = Game:loc("---", "no_item_storage")
    if item then
        new_text = item:getDescription()
    end
    if self.description.text ~= new_text then
        self.description:setText(new_text)
    end
end

function DarkStorageMenu:drawStorage(list)
    local text_x = self.text_x[list]
    local text_y = self.text_y[list]

    local name_text_x = text_x - 94
    local name_text_y = text_y - 6

    local page_text_x = name_text_x
    local page_text_y = name_text_y + 70

    local storage = self:getStorage(list)

    love.graphics.setFont(self.font)

    Draw.setColor(self.list == list and PALETTE["world_light_gray"] or PALETTE["world_dark_gray"])
    love.graphics.print(storage.id == "items" and Game:loc("POCKET", "pocket_sotrage") or storage.name, name_text_x, name_text_y)

    local max_pages = self:getMaxPages(list)
    if max_pages > 1 then
        love.graphics.print(Game:loc("Page", "page_storage"), page_text_x, page_text_y)
        love.graphics.print(self.selected_page[list].."/"..max_pages, page_text_x, page_text_y + 20)
    end

    for i = 1, 2 do
        for j = 1, 6 do
            local page_offset = (self.selected_page[list] - 1) * 12
            local item_index = page_offset + i + (j - 1) * 2
            local x = self.text_x[list] + (i - 1) * 220
            local y = self.text_y[list] + (j - 1) * 20
            local storage = Game.inventory:getStorage(self.storages[list])
            local item = Game.inventory:getItem(storage, item_index)
            if storage.max < item_index then
                Draw.setColor(PALETTE["world_dark_gray"])
            elseif self.list ~= list and list ~= 1 then
                Draw.setColor(PALETTE["world_gray"])
            elseif self.selected_x[list] == i and self.selected_y[list] == j then
                Draw.setColor(PALETTE["world_text_selected"])
            else
                Draw.setColor(PALETTE["world_text"])
            end
            if item then
                love.graphics.print(item:getName(), x, y)
            else
                love.graphics.print(Game:loc("---", "no_item_storage"), x, y)
            end
        end
    end

    Draw.setColor(1, 1, 1, 1)
    if self.list == list and max_pages > 1 then
        local left_arrow_x, left_arrow_y = 32, self.arrow_y[list]
        local right_arrow_x, right_arrow_y = 592, self.arrow_y[list]
        local offset = MathUtils.round(math.sin(Kristal.getTime() * 5)) * 2
        Draw.draw(self.arrow_left, left_arrow_x - offset, left_arrow_y, 0, 2, 2)
        Draw.draw(self.arrow_right, right_arrow_x + offset, right_arrow_y, 0, 2, 2)
    end
end

return DarkStorageMenu