local LightInventory, super = HookSystem.hookScript(LightInventory)

function LightInventory:tryGiveItem(item, ignore_dark)
    if type(item) == "string" then
        item = Registry.createItem(item)
    end
    if ignore_dark or item.light then
        return super.tryGiveItem(self, item, ignore_dark)
    else
        local dark_inv = self:getDarkInventory()
        local result = dark_inv:addItem(item)
        if result then
            return true, Game:loc("* ([color:yellow][var:itemName][color:reset] was added to your [color:yellow]BALL OF JUNK[color:reset].)", "inventory_tryGiveDarkTrue", {itemName = item:getName()})
        else
            return false, Game:loc("* (Your [color:yellow]BALL OF JUNK[color:reset] is too big to take [color:yellow][var:itemName][color:reset].)", "inventory_tryGiveDarkFalse", {itemName = item:getName()})
        end
    end
end

return LightInventory