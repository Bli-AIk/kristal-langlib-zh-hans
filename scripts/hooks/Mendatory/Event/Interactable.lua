local Interactable, super = HookSystem.hookScript(Interactable)

function Interactable:init(x, y, shape, properties)
    properties = properties or {}
    
    super.init(self, x, y, shape, properties)

    self.text_id = TiledUtils.parsePropertyMultiList("id", properties)
end

function Interactable:onInteract(player, dir)
    self.interact_count = self.interact_count + 1

    if self.script then
        Registry.getEventScript(self.script)(self, player, dir)
    end
    local cutscene
    if self.cutscene then
        cutscene = self.world:startCutscene(self.cutscene, self, player, dir)
    else
        cutscene = self.world:startCutscene(function(c)
            local text = self.text
            local id = self.text_id or {}
            local text_index = MathUtils.clamp(self.interact_count, 1, #text)
            if type(text[text_index]) == "table" then
                id = id[text_index] or text[text_index]
                text = text[text_index]
            end
            for index,line in ipairs(text) do
                local id_line = type(id) == "table" and id[index] or nil
                line = Game:loc(line, id_line)
                c:text(line)
            end
        end)
    end
    cutscene:after(function()
        self:onTextEnd()
    end)

    if self.set_flag then
        Game:setFlag(self.set_flag, (self.set_value == nil and true) or self.set_value)
    end

    self:setFlag("used_once", true)
    if self.once then
        self:remove()
    end

    return true
end

return Interactable
