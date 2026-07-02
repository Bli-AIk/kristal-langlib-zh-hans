local NPC, super = HookSystem.hookScript(NPC)

function NPC:init(x, y, shape, properties)
    properties = properties or {}
    
    super.init(self, x, y, shape, properties)

    self.text_id = TiledUtils.parsePropertyMultiList("id", properties)
end

function NPC:onInteract(player, dir)
    if self.talk_sprite then
        self:setSprite(self.talk_sprite)
    end
    if self.turn then
        self:facePlayer()
    end
    self.interact_count = self.interact_count + 1

    if self.script then
        Registry.getEventScript(self.script)(self, player, dir)
    end
    if self.set_flag then
        Game:setFlag(self.set_flag, (self.set_value == nil and true) or self.set_value)
    end
    if self.cutscene then
        self.world:startCutscene(self.cutscene, self, player, dir):after(function()
            self:onTextEnd()
        end)
        return true
    elseif #self.text > 0 then
        self.world:startCutscene(function(cutscene)
            cutscene:setSpeaker(self, self.talk)
            local id = self.text_id or {}
            local text = self.text
            local text_index = MathUtils.clamp(self.interact_count, 1, #text)
            if type(text[text_index]) == "table" then
                id = id[text_index] or text[text_index]
                text = text[text_index]
            end
            for index, line in ipairs(text) do
                local id_line = type(id) == "table" and id[index] or nil
                cutscene:text(Game:loc(line, id_line))
            end
        end):after(function()
            self:onTextEnd()
        end)
        return true
    end

end

return NPC
