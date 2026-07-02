local langLibZh = {}

local DEFAULT_LANGUAGE = "en"
local FALLBACK_LANGUAGE = "en"

local function getConfig(key, merge, deep_merge)
    if Kristal and Kristal.getLibConfig then
        local ok, value = pcall(Kristal.getLibConfig, "langLibZh", key, merge, deep_merge)
        if ok and value ~= nil then
            return value
        end
    end
end

local function tableCopy(tbl)
    local out = {}
    for k, v in pairs(tbl or {}) do
        out[k] = v
    end
    return out
end

local function listContains(list, value)
    for _, item in ipairs(list or {}) do
        if item == value then
            return true
        end
    end
    return false
end

local function normalizeLanguageId(lang)
    lang = tostring(lang or DEFAULT_LANGUAGE)
    lang = lang:gsub("-", "_")
    return lang
end

local function getLanguageList()
    local configured = getConfig("languages")
    local result = {}

    if type(configured) == "table" then
        for _, lang in ipairs(configured) do
            table.insert(result, normalizeLanguageId(lang))
        end
    end

    if #result == 0 then
        result = { "en", "zh_hans" }
    end

    if not listContains(result, FALLBACK_LANGUAGE) then
        table.insert(result, 1, FALLBACK_LANGUAGE)
    end

    return result
end

local function getLanguageName(lang)
    local names = getConfig("languageNames", true, true) or {}
    return names[lang] or names[normalizeLanguageId(lang)] or lang
end

local function ensureLanguageGlobals()
    Game.langAvailable = getLanguageList()
    -- Keep the original library's misspelled field as an alias for existing hooks/mod code.
    Game.langAvalable = Game.langAvailable

    Game.lang = normalizeLanguageId(Game.lang or getConfig("defaultLanguage") or DEFAULT_LANGUAGE)
    if not listContains(Game.langAvailable, Game.lang) then
        Game.lang = Game.langAvailable[1] or DEFAULT_LANGUAGE
    end

    Game.langSelected = Game.langSelected or 1
    for index, lang in ipairs(Game.langAvailable) do
        if lang == Game.lang then
            Game.langSelected = index
            break
        end
    end
end

local function readJsonIfExists(path)
    if love.filesystem.getInfo(path) then
        local raw = love.filesystem.read(path)
        if raw and raw ~= "" then
            return JSON.decode(raw)
        end
    end
    return nil
end

local function langFileCandidates(base_path, lang)
    return {
        base_path .. "/lang/" .. lang .. ".json",
        base_path .. "/lang/lang_" .. lang .. ".json",
        base_path .. "/lang/" .. lang:gsub("_", "-") .. ".json",
        base_path .. "/lang/lang_" .. lang:gsub("_", "-") .. ".json",
    }
end

local function loadLangTable(lang)
    local merged = {}
    local bases = {}

    if langLibZh.info and langLibZh.info.path then
        table.insert(bases, langLibZh.info.path)
    end
    if Mod and Mod.info and Mod.info.path then
        table.insert(bases, Mod.info.path)
    end

    for _, base in ipairs(bases) do
        for _, path in ipairs(langFileCandidates(base, lang)) do
            local data = readJsonIfExists(path)
            if type(data) == "table" then
                for key, value in pairs(data) do
                    merged[key] = value
                end
                break
            end
        end
    end

    return merged
end

local function localizeTextValue(value, id, var)
    if type(value) == "table" then
        local out = {}
        for key, item in pairs(value) do
            local child_id = nil
            if type(id) == "table" then
                child_id = id[key]
            elseif type(id) == "string" then
                child_id = id .. "." .. tostring(key)
            end
            out[key] = localizeTextValue(item, child_id, var)
        end
        return out
    end

    return Game:loc(value, id, var)
end

local function refreshLocalizedAssets()
    if not Game or not Game.stage then
        return
    end

    for _, sprite in pairs(Game.stage:getObjects(Sprite)) do
        if sprite.texture_path then
            local texture = Assets.getTexture(sprite.texture_path)
            if texture then
                sprite.texture = texture
            end
        end
    end

    if Game.world and Game.world.menu then
        if Game.world.menu.font then
            Game.world.menu.font = Assets.getFont("main")
        end
        if Game.world.menu.box and Game.world.menu.box.font then
            Game.world.menu.box.font = Assets.getFont("main")
        end
    end
end

local function applyItemLocalizationPatch(item)
    if not item or item.__langlib_zh_localized then
        return item
    end

    item.__langlib_zh_localized = true

    if item.id == "glowshard" then
        local original_get_battle_text = item.getBattleText
        function item:getBattleText(user, target)
            if Game.battle and Game.battle.encounter and Game.battle.encounter.onGlowshardUse then
                return original_get_battle_text(self, user, target)
            end
            return {
                Game:loc("* [var:charaName] used the [var:useName]!", "item_glowshard_battleText", {
                    charaName = user.chara:getName(),
                    useName = self:getUseName()
                }),
                Game:loc("* But nothing happened...", "item_glowshard_battleNothing")
            }
        end
    elseif item.id == "cell_phone" then
        function item:onWorldUse()
            Game.world:startCutscene(function(cutscene)
                Assets.playSound("phone", 0.7)
                cutscene:text(Game:loc("* (You tried to call on the Cell\nPhone.)", "item_cell_phone_call_try"), nil, nil, {advance = false})
                cutscene:wait(40/30)

                local was_playing = Game.world.music:isPlaying()
                if was_playing then
                    Game.world.music:pause()
                end

                Assets.playSound("smile")
                cutscene:wait(200/30)

                if was_playing then
                    Game.world.music:resume()
                end

                if Game.chapter == 1 then
                    cutscene:text(Game:loc("* But it doesn't seem to be working.", "item_cell_phone_call_not_working"))
                else
                    cutscene:text(Game:loc("* It's nothing but garbage noise.", "item_cell_phone_call_garbage_noise"))
                end
            end)
        end
    elseif item.id == "shadowcrystal" then
        function item:getDescription()
            local desc = Game:loc(self.description, "item_shadowcrystal_description")
            if self:getCollected() > 0 then
                desc = desc .. "\n" .. Game:loc("You have collected [var:count].", "item_shadowcrystal_collected", {
                    count = self:getCollected()
                })
            end
            return desc
        end

        function item:onWorldUse()
            if Kristal.callEvent(KRISTAL_EVENT.onShadowCrystal, self, false) then
                return
            elseif not self:getFlag("used_none") then
                self:setFlag("used_none", true)

                Game.world:showText({
                    Game:loc("* You held the crystal up to your\neye.", "item_shadowcrystal_use_1"),
                    Game:loc("* ...[wait:5] but nothing happened.", "item_shadowcrystal_use_2")
                })
            else
                Game.world:showText(Game:loc("* It doesn't seem very useful.", "item_shadowcrystal_use_again"))
            end
        end
    end

    return item
end

local function applySpellLocalizationPatch(spell)
    if not spell or spell.__langlib_zh_localized then
        return spell
    end

    spell.__langlib_zh_localized = true

    if spell.id == "rude_buster" then
        function spell:getCastMessage(user, target)
            return Game:loc("* [var:userName] used [var:castName]!", "spell_rude_buster_castMessage", {
                userName = user.chara:getName(),
                castName = self:getCastName()
            })
        end
    elseif spell.id == "pacify" then
        function spell:getCastMessage(user, target)
            local message = Game:loc("* [var:userName] cast [var:castName]!", "spell_castMessage", {
                userName = user.chara:getName(),
                castName = self:getCastName()
            })
            if target.tired then
                return message
            elseif target.mercy < 100 then
                return message .. "\n[wait:0.25s]" .. Game:loc("* But the enemy wasn't [color:blue]TIRED[color:reset]...", "spell_pacify_not_tired_enemy")
            else
                return message .. "\n[wait:0.25s]" .. Game:loc("* But the foe wasn't [color:blue]TIRED[color:reset]... try\n[color:yellow]SPARING[color:reset]!", "spell_pacify_not_tired_foe_spare")
            end
        end
    end

    return spell
end

function langLibZh:init()
    ensureLanguageGlobals()
end

function langLibZh:postInit()
    ensureLanguageGlobals()
    Game:loadLang(Game.lang)

    Game.hasXtraConfig = (Utils.getAnyCase(Mod.libs, "xtractrl") and true) or false

    HookSystem.hook(Assets, "getFont", function(orig, path, size)
        local lang_path = "lang/" .. (Game.lang or FALLBACK_LANGUAGE) .. "/" .. path
        return orig(lang_path, size) or orig(path, size)
    end)

    HookSystem.hook(Assets, "getTexture", function(orig, path)
        local lang_path = "lang/" .. (Game.lang or FALLBACK_LANGUAGE) .. "/" .. path
        return orig(lang_path) or orig(path)
    end)

    HookSystem.hook(Assets, "getTextureData", function(orig, path)
        local lang_path = "lang/" .. (Game.lang or FALLBACK_LANGUAGE) .. "/" .. path
        return orig(lang_path) or orig(path)
    end)

    HookSystem.hook(Assets, "getFrames", function(orig, path)
        local lang_path = "lang/" .. (Game.lang or FALLBACK_LANGUAGE) .. "/" .. path
        return orig(lang_path) or orig(path)
    end)

    HookSystem.hook(Assets, "getFrameIds", function(orig, path)
        local lang_path = "lang/" .. (Game.lang or FALLBACK_LANGUAGE) .. "/" .. path
        return orig(lang_path) or orig(path)
    end)

    HookSystem.hook(Assets, "getSound", function(orig, sound)
        local lang_path = "lang/" .. (Game.lang or FALLBACK_LANGUAGE) .. "/" .. sound
        return orig(lang_path) or orig(sound)
    end)

    HookSystem.hook(Assets, "newSound", function(orig, sound)
        local lang_path = "lang/" .. (Game.lang or FALLBACK_LANGUAGE) .. "/" .. sound
        if Assets.sounds and Assets.sounds[lang_path] then
            return orig(lang_path)
        end
        return orig(sound)
    end)

    HookSystem.hook(Assets, "startSound", function(orig, sound)
        local lang_path = "lang/" .. (Game.lang or FALLBACK_LANGUAGE) .. "/" .. sound
        if Assets.sounds and Assets.sounds[lang_path] then
            return orig(lang_path)
        end
        return orig(sound)
    end)

    HookSystem.hook(Assets, "stopSound", function(orig, sound, actually_stop)
        local lang_path = "lang/" .. (Game.lang or FALLBACK_LANGUAGE) .. "/" .. sound
        return orig(lang_path, actually_stop) or orig(sound, actually_stop)
    end)

    HookSystem.hook(Assets, "playSound", function(orig, sound, volume, pitch)
        local lang_path = "lang/" .. (Game.lang or FALLBACK_LANGUAGE) .. "/" .. sound
        if Assets.sounds and Assets.sounds[lang_path] then
            return orig(lang_path, volume, pitch)
        end
        return orig(sound, volume, pitch)
    end)

    HookSystem.hook(Assets, "stopAndPlaySound", function(orig, sound, volume, pitch, actually_stop)
        local lang_path = "lang/" .. (Game.lang or FALLBACK_LANGUAGE) .. "/" .. sound
        if Assets.sounds and Assets.sounds[lang_path] then
            return orig(lang_path, volume, pitch, actually_stop)
        end
        return orig(sound, volume, pitch, actually_stop)
    end)

    HookSystem.hook(Assets, "getMusicPath", function(orig, music)
        local lang_path = "lang/" .. (Game.lang or FALLBACK_LANGUAGE) .. "/" .. music
        return orig(lang_path) or orig(music)
    end)

    HookSystem.hook(Assets, "getVideoPath", function(orig, video)
        local lang_path = "lang/" .. (Game.lang or FALLBACK_LANGUAGE) .. "/" .. video
        return orig(lang_path) or orig(video)
    end)

    HookSystem.hook(Assets, "newVideo", function(orig, video, load_audio)
        local lang_path = "lang/" .. (Game.lang or FALLBACK_LANGUAGE) .. "/" .. video
        if Assets.data and Assets.data.videos and Assets.data.videos[lang_path] then
            return orig(lang_path, load_audio)
        end
        return orig(video, load_audio)
    end)

    HookSystem.hook(StringUtils, "upper", function(_, str)
        local map = getConfig("lowerAndUpper", true, true) or {}
        local result = {}
        for _, codepoint in utf8.codes(tostring(str or "")) do
            local char = utf8.char(codepoint)
            table.insert(result, map[char] or char:upper())
        end
        return table.concat(result)
    end)

    HookSystem.hook(StringUtils, "lower", function(_, str)
        local upper_to_lower = {}
        for lower, upper in pairs(getConfig("lowerAndUpper", true, true) or {}) do
            upper_to_lower[upper] = lower
        end

        local result = {}
        for _, codepoint in utf8.codes(tostring(str or "")) do
            local char = utf8.char(codepoint)
            table.insert(result, upper_to_lower[char] or char:lower())
        end
        return table.concat(result)
    end)

    HookSystem.hook(Text, "init", function(orig, self, text, x, y, w, h, options)
        options = options or {}
        local id = options["id"] or options["loc_id"] or options["loc"]

        if id then
            text = localizeTextValue(text, id, options["var"])
        elseif options["var"] then
            text = Game:concat(text, options["var"])
        end

        return orig(self, text, x, y, w, h, options)
    end)

    HookSystem.hook(WorldCutscene, "text", function(orig, self, text, portrait, actor, options)
        options = options or {}
        local id = options["id"] or options["loc_id"] or options["loc"]
        if id then
            text = localizeTextValue(text, id, options["var"])
        elseif options["var"] then
            text = Game:concat(text, options["var"])
        end
        return orig(self, text, portrait, actor, options)
    end)

    HookSystem.hook(BattleCutscene, "text", function(orig, self, text, portrait, actor, options)
        options = options or {}
        local id = options["id"] or options["loc_id"] or options["loc"]
        if id then
            text = localizeTextValue(text, id, options["var"])
        elseif options["var"] then
            text = Game:concat(text, options["var"])
        end
        return orig(self, text, portrait, actor, options)
    end)

    HookSystem.hook(WorldCutscene, "choicer", function(orig, self, choices, options)
        options = options or {}
        local ids = options["ids"] or options["loc_ids"]
        if ids then
            local localized = {}
            for index, choice in ipairs(choices) do
                localized[index] = Game:loc(choice, ids[index], options["var"])
            end
            choices = localized
        elseif options["var"] then
            choices = Game:concat(choices, options["var"])
        end
        return orig(self, choices, options)
    end)

    HookSystem.hook(BattleCutscene, "choicer", function(orig, self, choices, options)
        options = options or {}
        local ids = options["ids"] or options["loc_ids"]
        if ids then
            local localized = {}
            for index, choice in ipairs(choices) do
                localized[index] = Game:loc(choice, ids[index], options["var"])
            end
            choices = localized
        elseif options["var"] then
            choices = Game:concat(choices, options["var"])
        end
        return orig(self, choices, options)
    end)

    HookSystem.hook(Registry, "createItem", function(orig, id, ...)
        return applyItemLocalizationPatch(orig(id, ...))
    end)

    HookSystem.hook(Registry, "createSpell", function(orig, id, ...)
        return applySpellLocalizationPatch(orig(id, ...))
    end)

    if DarkMenu then
        HookSystem.hook(DarkMenu, "setDescription", function(orig, self, text, visible)
            if type(text) == "string" then
                local item_name = text:match("^Really throw away the\n(.+)%?$")
                if item_name then
                    text = Game:loc("Really throw away the\n[var:itemName]?", "dark_item_toss_confirm", {
                        itemName = item_name
                    })
                end
            end
            return orig(self, text, visible)
        end)
    end

    refreshLocalizedAssets()
end

function langLibZh:load(data)
    ensureLanguageGlobals()

    Game.lang = normalizeLanguageId(data.lang or Game.lang or getConfig("defaultLanguage") or DEFAULT_LANGUAGE)
    Game.langSelected = data.langSelected or Game.langSelected or 1

    Game:loadLang(Game.lang)
    return data
end

function langLibZh:save(data)
    data.lang = Game.lang
    data.langSelected = Game.langSelected
    return data
end

function Game:loadLang(lang)
    ensureLanguageGlobals()

    lang = normalizeLanguageId(lang or Game.lang or DEFAULT_LANGUAGE)

    Game.langBaseStr = loadLangTable(FALLBACK_LANGUAGE)
    Game.langStr = loadLangTable(lang)
    Game.lang = lang

    for index, available in ipairs(Game.langAvailable) do
        if available == lang then
            Game.langSelected = index
            break
        end
    end
end

function Game:setLanguage(lang, refresh_assets)
    ensureLanguageGlobals()

    lang = normalizeLanguageId(lang)
    if not listContains(Game.langAvailable, lang) then
        return false
    end

    Game:loadLang(lang)
    if refresh_assets ~= false then
        refreshLocalizedAssets()
    end
    return true
end

function Game:getLanguage()
    ensureLanguageGlobals()
    return Game.lang
end

function Game:getLanguageName(lang)
    return getLanguageName(normalizeLanguageId(lang or Game.lang))
end

function Game:getLanguages()
    ensureLanguageGlobals()
    return tableCopy(Game.langAvailable)
end

function Game:loc(default, id, var)
    local value = nil

    if id then
        if Game.langStr then
            value = Game.langStr[id]
        end
        if value == nil and Game.langBaseStr then
            value = Game.langBaseStr[id]
        end
    end

    if value == nil then
        value = default
    end
    if value == nil then
        value = "---missing-string:" .. tostring(id or "nil") .. "---"
    end

    if var then
        return Game:concat(value, var)
    end
    return value
end

function Game:locRaw(id)
    if Game.langStr and Game.langStr[id] ~= nil then
        return Game.langStr[id]
    end
    if Game.langBaseStr and Game.langBaseStr[id] ~= nil then
        return Game.langBaseStr[id]
    end
    return nil
end

function Game:hasStr(id)
    return Game:locRaw(id) ~= nil
end

function Game:concat(value, var)
    if type(value) == "table" then
        local out = {}
        for key, item in pairs(value) do
            out[key] = Game:concat(item, var)
        end
        return out
    end

    local str = tostring(value or "")
    if not var then
        return str
    end

    return (str:gsub("%[var:([^%]]+)%]", function(key)
        local replacement = var[key]
        if replacement == nil then
            return ""
        end
        return tostring(replacement)
    end))
end

return langLibZh
