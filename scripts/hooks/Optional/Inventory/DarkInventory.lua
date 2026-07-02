local DarkInventory, super = HookSystem.hookScript(DarkInventory)

function DarkInventory:tryGiveItem(item, ignore_light)
    if type(item) == "string" then
        item = Registry.createItem(item)
    end
    if ignore_light or not item.light then
        return super.tryGiveItem(self, item, ignore_light)
    else
        local light_inv = self:getLightInventory()
        local result = light_inv:addItem(item)
        if result then
            return true, Game:loc("* ([color:yellow][var:itemName][color:reset] was added to your [color:yellow]LIGHT ITEMs[color:reset].)", "inventory_tryGiveLightTrue", {itemName = item:getName()})
        else
            return false, Game:loc("* (You have too many [color:yellow]LIGHT ITEMs[color:reset] to take [color:yellow][var:itemName][color:reset].)", "inventory_tryGiveLightFalse", {itemName = item:getName()})
        end
    end
end

return DarkInventory