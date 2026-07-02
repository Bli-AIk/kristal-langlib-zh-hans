local WorldCutscene, super = Class(WorldCutscene)

function WorldCutscene:text(text, portrait, actor, options)
    options = options or {}

    local id = options["id"] or options["loc_id"] or options["loc"]
    if id then
        text = Game:loc(text, id, options["var"])
    elseif options["var"] then
        text = Game:concat(text, options["var"])
    end

    return super.text(self, text, portrait, actor, options)
end

return WorldCutscene
