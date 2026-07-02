local DarkMenu, super = HookSystem.hookScript(DarkMenu)

function DarkMenu:addButtons()
    -- ITEM
    self:addButton({
        ["state"]          = "ITEMMENU",
        ["sprite"]         = Assets.getTexture("ui/menu/btn/item"),
        ["hovered_sprite"] = Assets.getTexture("ui/menu/btn/item_h"),
        ["desc_sprite"]    = "ui/menu/desc/item",
        ["callback"]       = function()
            self.box = DarkItemMenu()
            self.box.layer = 1
            self:addChild(self.box)

            self.ui_select:stop()
            self.ui_select:play()
        end
    })

    -- EQUIP
    self:addButton({
        ["state"]          = "EQUIPMENU",
        ["sprite"]         = Assets.getTexture("ui/menu/btn/equip"),
        ["hovered_sprite"] = Assets.getTexture("ui/menu/btn/equip_h"),
        ["desc_sprite"]    = "ui/menu/desc/equip",
        ["callback"]       = function()
            self.box = DarkEquipMenu()
            self.box.layer = 1
            self:addChild(self.box)

            self.ui_select:stop()
            self.ui_select:play()
        end
    })

    -- POWER
    self:addButton({
        ["state"]          = "POWERMENU",
        ["sprite"]         = Assets.getTexture("ui/menu/btn/power"),
        ["hovered_sprite"] = Assets.getTexture("ui/menu/btn/power_h"),
        ["desc_sprite"]    = "ui/menu/desc/power",
        ["callback"]       = function()
            self.box = DarkPowerMenu()
            self.box.layer = 1
            self:addChild(self.box)

            self.ui_select:stop()
            self.ui_select:play()
        end
    })

    -- CONFIG
    self:addButton({
        ["state"]          = "CONFIGMENU",
        ["sprite"]         = Assets.getTexture("ui/menu/btn/config"),
        ["hovered_sprite"] = Assets.getTexture("ui/menu/btn/config_h"),
        ["desc_sprite"]    = "ui/menu/desc/config",
        ["callback"]       = function()
            self.box = DarkConfigMenu()
            self.box.layer = -1
            self:addChild(self.box)

            self.ui_select:stop()
            self.ui_select:play()
        end
    })
end

function DarkMenu:draw()
    Draw.setColor(PALETTE["world_fill"])
    love.graphics.rectangle("fill", 0, 0, 640, 80)

    Draw.setColor(1, 1, 1, 1)
    if self.buttons[self.selected_submenu].desc_sprite then
        local desc_sprite = Assets.getTexture(self.buttons[self.selected_submenu].desc_sprite)
        Draw.draw(desc_sprite, 20, 24, 0, 2, 2)
    end

    for i = 1, #self.buttons do
        self:drawButton(i, 120 + ((i - 1) * self:getButtonSpacing()), 20)
    end
    Draw.setColor(1, 1, 1)

    love.graphics.setFont(self.font)
    love.graphics.print(Game:getConfig("darkCurrencyShort") .. " " .. Game.money, 520, 20)

    super.super.draw(self)
end

return DarkMenu