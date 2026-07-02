local Inventory, super = HookSystem.hookScript(Inventory)

function Inventory:tryGiveItem(item, ignore_convert)
    if type(item) == "string" then
        item = Registry.createItem(item)
    end
    local result = self:addItem(item, ignore_convert)
    if result then
        local destination = self:getStorage(self.stored_items[result].storage)
        return true, Game:loc("* ([color:yellow][var:itemName][color:reset] was added to your [color:yellow][var:destinationName][color:reset].)", "inventory_giveItemTrue", {itemName = item:getName(),destinationName = destination.name})
    else
        local destination = self:getDefaultStorage(item)
        return false, Game:loc("* (You have too many [color:yellow][var:destinationName][color:reset] to take [color:yellow][var:itemName][color:reset].)", "inventory_giveItemFalse", {destinationName = destination.name, itemName = item:getName()})
    end
end

return Inventory