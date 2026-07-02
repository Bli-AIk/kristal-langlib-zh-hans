local TensionItem, super = HookSystem.hookScript(TensionItem)

function TensionItem:onWorldUse(target)
    Game.world:showText({
        Game:loc("* (You felt tense.)", "tensionItem_worldUse1"),
        Game:loc("* (... try using it in battle.)", "tensionItem_worldUse2")
    })
    return false
end

return TensionItem