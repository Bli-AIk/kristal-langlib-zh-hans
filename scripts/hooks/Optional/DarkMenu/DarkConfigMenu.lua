local DarkConfigMenu, super = HookSystem.hookScript(DarkConfigMenu)

local function formatLocalizedInput(text, mode)
    if mode == "upper" then
        return StringUtils.upper(text)
    elseif mode == "title" then
        return StringUtils.titleCase(text)
    end
    return text
end

local function localizeInputText(default, id, mode)
    local text = Game:loc(default, id)
    if Game.lang == "en" or not (Game.langStr and Game.langStr[id] ~= nil) then
        return formatLocalizedInput(text, mode)
    end
    return text
end

local function localizeAlias(alias)
    if type(alias) == "table" then
        local parts = {}
        for _, word in ipairs(alias) do
            table.insert(parts, localizeInputText(word, word, "title"))
        end
        return table.concat(parts, "+")
    elseif alias ~= nil then
        return localizeInputText(alias, alias, "title")
    end
end

local function playMenuSound(self, sound)
    local instance = self and self[sound]
    if instance then
        instance:stop()
        instance:play()
    else
        Assets.stopAndPlaySound(sound)
    end
end

function DarkConfigMenu:update()
    if self.state == "MAIN" then
        if Input.pressed("confirm") then
            playMenuSound(self, "ui_select")

            if self.currently_selected == 1 then
                self.state = "VOLUME"
                self.noise_timer = 0
            elseif self.currently_selected == 2 then
                self.state = "CONTROLS"
                self.currently_selected = 1
            elseif self.currently_selected == 3 then
                Kristal.Config["simplifyVFX"] = not Kristal.Config["simplifyVFX"]
            elseif self.currently_selected == 4 then
                Kristal.Config["fullscreen"] = not Kristal.Config["fullscreen"]
                love.window.setFullscreen(Kristal.Config["fullscreen"])
            elseif self.currently_selected == 5 then
                Kristal.Config["autoRun"] = not Kristal.Config["autoRun"]
            elseif self.currently_selected == 6 then
                self.state = "LANGUAGE"
            elseif self.currently_selected == 7 then
                Game:returnToMenu()
            elseif self.currently_selected == 8 then
                Game.world.menu:closeBox()
            end

            return
        end

        if Input.pressed("cancel") then
            playMenuSound(self, "ui_cancel_small")
            Game.world.menu:closeBox()
            return
        end

        local old_selected = self.currently_selected
        if Input.pressed("up") then
            self.currently_selected = self.currently_selected - 1
        end
        if Input.pressed("down") then
            self.currently_selected = self.currently_selected + 1
        end

        self.currently_selected = MathUtils.clamp(self.currently_selected, 1, 8)
        
        if old_selected ~= self.currently_selected then
            playMenuSound(self, "ui_move")
        end
    elseif self.state == "CONTROLS" and Game.hasXtraConfig then
        if not self.rebinding then
            if Input.pressed("cancel") and Kristal.getLibConfig("xtractrl", "cancelToExit") then
                self.reset_flash_timer = 0
                self.state = "MAIN"
                self.currently_selected = 2
                Input.clear("confirm", true)
            end
        end
    elseif self.state == "VOLUME" then
        if Input.pressed("cancel") or Input.pressed("confirm") then
            Kristal.setVolume(MathUtils.round(Kristal.getVolume() * 100) / 100)
            playMenuSound(self, "ui_select")
            self.state = "MAIN"
            return
        end

        self.noise_timer = self.noise_timer + DTMULT
        if Input.down("left") then
            Kristal.setVolume(Kristal.getVolume() - ((2 * DTMULT) / 100))
            if self.noise_timer >= 3 then
                self.noise_timer = self.noise_timer - 3
                Assets.stopAndPlaySound("noise")
            end
        end
        if Input.down("right") then
            Kristal.setVolume(Kristal.getVolume() + ((2 * DTMULT) / 100))
            if self.noise_timer >= 3 then
                self.noise_timer = self.noise_timer - 3
                Assets.stopAndPlaySound("noise")
            end
        end
        if (not Input.down("right")) and (not Input.down("left")) then
            self.noise_timer = 3
        end
    elseif self.state == "LANGUAGE" then
        if Input.pressed("cancel") or Input.pressed("confirm") then
            playMenuSound(self, "ui_select")
            self.state = "MAIN"
            return
        end

        local old_selected = Game.langSelected
        if Input.pressed("left") then
            Game.langSelected = Game.langSelected - 1
        end
        if Input.pressed("right") then
            Game.langSelected = Game.langSelected + 1
        end

        local languages = Game.langAvailable or Game.langAvalable or {"en"}
        Game.langSelected = MathUtils.clamp(Game.langSelected, 1, #languages)
        if old_selected ~= Game.langSelected then           
            Game:setLanguage(languages[Game.langSelected])
            
            playMenuSound(self, "ui_move")
        end
    end

    self.reset_flash_timer = math.max(self.reset_flash_timer - DTMULT, 0)

    super.super.update(self)
end

function DarkConfigMenu:draw()
    if Game.state == "EXIT" then
        super.draw(self)
        return
    end
    love.graphics.setFont(self.font)
    Draw.setColor(PALETTE["world_text"])

    if self.state ~= "CONTROLS" then
        local on, off = Game:loc("ON", "on"), Game:loc("OFF", "off")
        love.graphics.print(Game:loc("CONFIG", "config"), 188, -12)

        if self.state == "VOLUME" then
            Draw.setColor(PALETTE["world_text_selected"])
        end
        love.graphics.print(Game:loc("Master Volume", "master_volume_config"), 88, 30 + (0 * 32))
        Draw.setColor(PALETTE["world_text"])
        love.graphics.print(Game:loc("Controls", "controls_config"), 88, 30 + (1 * 32))
        love.graphics.print(Game:loc("Simplify VFX", "simp_vfx_config"), 88, 30 + (2 * 32))
        love.graphics.print(Game:loc("Fullscreen", "fullscreen_config"), 88, 30 + (3 * 32))
        love.graphics.print(Game:loc("Auto-Run", "auto_run_config"), 88, 30 + (4 * 32))
        if self.state == "LANGUAGE" then
            Draw.setColor(PALETTE["world_text_selected"])
        end
        love.graphics.print(Game:loc("Language", "lang_config"), 88, 30 + (5 * 32))
        Draw.setColor(PALETTE["world_text"])
        love.graphics.print(Game:loc("Return to Title", "back_title_config"), 88, 30 + (6 * 32))
        love.graphics.print(Game:loc("Back", "back_config"), 88, 30 + (7 * 32))

        if self.state == "VOLUME" then
            Draw.setColor(PALETTE["world_text_selected"])
        end
        love.graphics.print(MathUtils.round(Kristal.getVolume() * 100) .. "%", 348, 30 + (0 * 32))
        Draw.setColor(PALETTE["world_text"])
        love.graphics.print(Kristal.Config["simplifyVFX"] and on or off, 348, 30 + (2 * 32))
        love.graphics.print(Kristal.Config["fullscreen"] and on or off, 348, 30 + (3 * 32))
        love.graphics.print(Kristal.Config["autoRun"] and on or off, 348, 30 + (4 * 32))
        if self.state == "LANGUAGE" then
            Draw.setColor(PALETTE["world_text_selected"])
        end
        local text, scale = StringUtils.squishAndTrunc(Game:getLanguageName(), self.font, 120, nil, 0.5)
        love.graphics.print(text, 348, 30 + (5 * 32), 0, scale, 1)
        Draw.setColor(PALETTE["world_text"])

        Draw.setColor(Game:getSoulColor())
        Draw.draw(self.heart_sprite, 63, 40 + ((self.currently_selected - 1) * 32))
        Draw.setColor(1, 1, 1, 1)
        
    else
    -- NOTE: This is forced to true if using a PlayStation in DELTARUNE... Kristal doesn't have a PlayStation port though.
        local dualshock = Input.getControllerType() == "ps4"

        love.graphics.print(Game:loc("Function", "function_config"), 23, -12)
        -- Console accuracy for the Heck of it
        if not Kristal.isConsole() then
            love.graphics.print(Game:loc("Key", "key_config"), 243, -12)
        end
        if Input.hasGamepad() then
            love.graphics.print(Kristal.isConsole() and Game:loc("Button", "button_config") or Game:loc("Gamepad", "gamepad_config"), 353, -12)
        end

        if not Game.hasXtraConfig then
            for index, name in ipairs(Input.order) do
                if index > 7 then
                    break
                end
                Draw.setColor(PALETTE["world_text"])
                if self.currently_selected == index then
                    if self.rebinding then
                        Draw.setColor(PALETTE["world_text_rebind"])
                    else
                        Draw.setColor(PALETTE["world_text_hover"])
                    end
                end

                local input_name = localizeInputText(name:gsub("_", " "), name, "upper")
                if dualshock then
                    love.graphics.print(input_name, 23, -4 + (29 * index))
                else
                    love.graphics.print(input_name, 23, -4 + (28 * index) + 4)
                end

                local shown_bind = self:getBindNumberFromIndex(index)

                if not Kristal.isConsole() then
                    local alias = Input.getBoundKeys(name, false)[1]
                    local alias_text = localizeAlias(alias)
                    if alias_text then
                        love.graphics.print(alias_text, 243, 0 + (28 * index))
                    end
                end

                Draw.setColor(1, 1, 1)

                if Input.hasGamepad() then
                    local alias = Input.getBoundKeys(name, true)[1]
                    if alias then
                        local btn_tex = Input.getButtonTexture(alias)
                        if dualshock then
                            Draw.draw(btn_tex, 353 + 42, -2 + (29 * index), 0, 2, 2, btn_tex:getWidth() / 2, 0)
                        else
                            Draw.draw(btn_tex, 353 + 42 + 16 - 6, -2 + (28 * index) + 11 - 6 + 1, 0, 2, 2,
                                    btn_tex:getWidth() / 2, 0)
                        end
                    end
                end
            end

            Draw.setColor(PALETTE["world_text"])
            if self.currently_selected == 8 then
                Draw.setColor(PALETTE["world_text_hover"])
            end

            if (self.reset_flash_timer > 0) then
                Draw.setColor(ColorUtils.mergeColor(PALETTE["world_text_hover"], PALETTE["world_text_selected"],
                                            ((self.reset_flash_timer / 10) - 0.1)))
            end

            if dualshock then
                love.graphics.print(Game:loc("Reset to default", "reset_default_config"), 23, -4 + (29 * 8))
            else
                love.graphics.print(Game:loc("Reset to default", "reset_default_config"), 23, -4 + (28 * 8) + 4)
            end

            Draw.setColor(PALETTE["world_text"])
            if self.currently_selected == 9 then
                Draw.setColor(PALETTE["world_text_hover"])
            end

            if dualshock then
                love.graphics.print(Game:loc("Finish", "finish_config"), 23, -4 + (29 * 9))
            else
                love.graphics.print(Game:loc("Finish", "finish_config"), 23, -4 + (28 * 9) + 4)
            end

            Draw.setColor(Game:getSoulColor())

            if dualshock then
                Draw.draw(self.heart_sprite, -2, 34 + ((self.currently_selected - 1) * 29))
            else
                Draw.draw(self.heart_sprite, -2, 34 + ((self.currently_selected - 1) * 28) + 2)
            end
        else
            Draw.pushScissor()
            Draw.scissor(15, 30, 440, 200)
            for index, key_info in ipairs(self.keybinds) do
                if ((index > self.offset) and index <= (7 + self.offset)) then
                    Draw.setColor(PALETTE["world_text"])
                    if self.currently_selected == index then
                        if self.rebinding then
                            Draw.setColor(PALETTE["world_text_rebind"])
                        else
                            Draw.setColor(PALETTE["world_text_hover"])
                        end
                    end

                    local input_name = localizeInputText(key_info.name, key_info.keybind, "upper")
                    local text, scale = StringUtils.squishAndTrunc(input_name, self.font, 210, nil, 1)
                    if dualshock then
                        love.graphics.print(text, 23, -4 + (29 * (index - self.offset)), 0, scale, 1)
                    else
                        love.graphics.print(text, 23, -4 + (28 * (index - self.offset)) + 4, 0, scale, 1)
                    end
                    
                    if not Kristal.isConsole() then
                        local alias = Input.getBoundKeys(key_info.keybind, false)[1]
                        local alias_text = localizeAlias(alias)
                        if alias_text then
                            love.graphics.print(alias_text, 243, 0 + (28 * (index - self.offset)))
                        end
                    end

                    Draw.setColor(1, 1, 1)

                    if Input.hasGamepad() then
                        local alias = Input.getBoundKeys(key_info.keybind, true)[1]
                        if alias then
                            local btn_tex = Input.getButtonTexture(alias)
                            if dualshock then
                                Draw.draw(btn_tex, 353 + 42, -2 + (29 * (index - self.offset)), 0, 2, 2, btn_tex:getWidth() / 2, 0)
                            else
                                Draw.draw(btn_tex, 353 + 42 + 16 - 6, -2 + (28 * (index - self.offset)) + 11 - 6 + 1, 0, 2, 2,
                                        btn_tex:getWidth() / 2, 0)
                            end
                        end
                    end
                end
            end
            Draw.popScissor()

            Draw.setColor(PALETTE["world_text"])
            if self.currently_selected == 8 + self.max_offset then
                Draw.setColor(PALETTE["world_text_hover"])
            end

            if (self.reset_flash_timer > 0) then
                Draw.setColor(ColorUtils.mergeColor(PALETTE["world_text_hover"], PALETTE["world_text_selected"],
                                            ((self.reset_flash_timer / 10) - 0.1)))
            end

            if dualshock then
                love.graphics.print(Game:loc("Reset to default", "reset_default_config"), 23, -4 + (29 * 8))
            else
                love.graphics.print(Game:loc("Reset to default", "reset_default_config"), 23, -4 + (28 * 8) + 4)
            end

            Draw.setColor(PALETTE["world_text"])
            if self.currently_selected == 9 + self.max_offset then
                Draw.setColor(PALETTE["world_text_hover"])
            end

            if dualshock then
                love.graphics.print(Game:loc("Finish", "finish_config"), 23, -4 + (29 * 9))
            else
                love.graphics.print(Game:loc("Finish", "finish_config"), 23, -4 + (28 * 9) + 4)
            end

            Draw.setColor(Game:getSoulColor())

            if dualshock then
                Draw.draw(self.heart_sprite, -2, 34 + ((self.currently_selected - 1 - self.offset) * 29))
            else
                Draw.draw(self.heart_sprite, -2, 34 + ((self.currently_selected - 1 - self.offset) * 28) + 2)
            end

            local alpha = 1
            if self.currently_selected >= 8 + self.max_offset then
                alpha = 0.5
            end

            for id = 1, #self.keybinds do
                if self.currently_selected == id then
                    Draw.setColor(1, 1, 1, alpha)
                    love.graphics.rectangle("fill", -3 + 472, -3 + 20 + id * self:getPointSpacing(), 6, 6)
                else
                    Draw.setColor(0.5, 0.5, 0.5, alpha)
                    love.graphics.rectangle("fill", -1.5 + 472, -1.5 + 20 + id * self:getPointSpacing(), 3, 3)
                end
                
            end
        end
    end

    Draw.setColor(1, 1, 1, 1)

    super.super.draw(self)
end

if Game.hasXtraConfig then
    function DarkConfigMenu:init()
        super.init(self)

    --  Setup variables
        self.flat_arrow_sprite = Assets.getTexture("ui/flat_arrow_right")
        
        self.keybinds = {}
        
        self:registerKeybind()

        self.offset = 0
        self.max_offset = #self.keybinds - 7
    end

    function DarkConfigMenu:registerKeybind()
        local alr_used = {}

        for _, keybind in ipairs(Input.order) do
            if not (TableUtils.contains(Kristal.getLibConfig("xtractrl", "bannedKeys"), keybind) or TableUtils.contains(alr_used, keybind)) then
                table.insert(self.keybinds, {keybind = keybind, name = Input.getBindName(keybind) or keybind:gsub("_", " ")})
                table.insert(alr_used, keybind)
            end
        end

        local _ , keys = Mod.info.id, Input.mod_keybinds[Mod.info.id] or {}

        for _, keybind in ipairs(keys) do
            if not (TableUtils.contains(Kristal.getLibConfig("xtractrl", "bannedKeys"), keybind) or TableUtils.contains(alr_used, keybind)) then
                table.insert(self.keybinds, {keybind = keybind, name = Input.getBindName(keybind) or keybind:gsub("_", " ")})
                table.insert(alr_used, keybind)
            end
        end
    end

    function DarkConfigMenu:onKeyPressed(key)
        if self.state == "CONTROLS" then
            if self.rebinding then
                local gamepad = StringUtils.startsWith(key, "gamepad:")
                local key_rebind = self.keybinds[self.currently_selected]["keybind"]

                local worked = key ~= "escape" and
                    Input.setBind(key_rebind, 1, key, gamepad)

                self.rebinding = false

                if worked then
                    playMenuSound(self, "ui_select")

                    if Kristal.getLibConfig("xtractrl", "saveAfterModification") then Input.saveBinds() end
                else
                    playMenuSound(self, "ui_cant_select")
                end

                return
            end
            if Input.pressed("confirm") then
                if self.currently_selected < 8 + self.max_offset then
                    playMenuSound(self, "ui_select")
                    self.rebinding = true
                    return
                end

                if self.currently_selected == 8 + self.max_offset then
                    Assets.playSound("levelup")

                    if Kristal.isConsole() then
                        Input.resetBinds(true)  -- Console, no keyboard, only reset gamepad binds
                    elseif Input.hasGamepad() then
                        Input.resetBinds()      -- PC, keyboard and gamepad, reset all binds
                    else
                        Input.resetBinds(false) -- PC, no gamepad, only reset keyboard binds
                    end
                    Input.saveBinds()
                    self.reset_flash_timer = 10
                end

                if self.currently_selected == 9 + self.max_offset then
                    self.reset_flash_timer = 0
                    self.state = "MAIN"
                    self.currently_selected = 2
                    self.offset = 0
                    playMenuSound(self, "ui_select")
                    Input.clear("confirm", true)
                end
                return
            end

            local old_selected = self.currently_selected
            if Input.pressed("up") then
                self.currently_selected = self.currently_selected - 1
                if self.currently_selected < 1 then
                    self.currently_selected = 1
                end
            end
            if Input.pressed("down") then
                self.currently_selected = self.currently_selected + 1
                if self.currently_selected > self.max_offset + 9 then
                    self.currently_selected = self.max_offset + 9
                end
            end

            if self.currently_selected > 7 + self.offset and self.currently_selected < self.max_offset + 8 then
                self.offset = self.offset + 1
            elseif self.currently_selected <= self.offset then
                self.offset = self.offset - 1
            end

            if Input.pressed("left") then
                self.offset = 0
                self.currently_selected = 1
            end
            if Input.pressed("right") then
                self.offset = self.max_offset
                self.currently_selected = 7 + self.max_offset
            end

            self.currently_selected = MathUtils.clamp(self.currently_selected, 1, self.max_offset + 9)

            if old_selected ~= self.currently_selected then
                playMenuSound(self, "ui_move")
            end
        end
    end

    function DarkConfigMenu:getPointSpacing()
        if #self.keybinds <= 9 then
            return 25
        else
            return 20 * (#self.keybinds/9)
        end
    end
end

return DarkConfigMenu
