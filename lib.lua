local langLibZh = {}

local DEFAULT_LANGUAGE = "en"
local FALLBACK_LANGUAGE = "en"
local AUTO_LANGUAGE = "auto"
local CJK_FIXED_TEXT_SPACING = 2
local CJK_DIALOGUE_TEXT_SPACING = 4
local CJK_DIALOGUE_Y_OFFSET = -1
local CJK_TYPEWRITER_SPEED_MULTIPLIER = 1 --0.85

local STATIC_TEXT_IDS = {
    ["Save"] = "save_menu_save",
    ["Return"] = "save_menu_return",
    ["Storage"] = "save_menu_storage",
    ["STORAGE"] = "storage_storage",
    ["Recruits"] = "save_menu_recruits",
    ["File Saved"] = "save_menu_file_saved",
    ["File saved."] = "save_menu_file_saved_period",
    ["New File"] = "save_menu_new_file",
    ["Return to Title"] = "save_menu_return_to_title",
    ["Really return to title?"] = "save_menu_really_return_to_title",
    ["Yes"] = "yes",
    ["No"] = "no",
    ["YES"] = "yes",
    ["NO"] = "no",
    ["CONTINUE"] = "gameover_continue",
    ["GIVE UP"] = "gameover_give_up",
    ["[speed:0.5][spacing:8][voice:none]IT APPEARS YOU\nHAVE REACHED[wait:30]\n\n   AN END."] = "gameover_end",
    ["[speed:0.5][spacing:8][voice:none]WILL YOU TRY AGAIN?"] = "gameover_try_again",
    ["[speed:0.5][spacing:8][voice:none]WILL YOU PERSIST?"] = "gameover_persist",
    ["[noskip][speed:0.5][spacing:8][voice:none] THEN, THE FUTURE\n IS IN YOUR HANDS."] = "gameover_future",
    ["[noskip][speed:0.5][spacing:8][voice:none] THEN THE WORLD[wait:30] \n WAS COVERED[wait:30] \n IN DARKNESS."] = "gameover_darkness",
    ["Useless\nanalysis"] = "act_check_useless_analysis",
    ['Whether the "Check" act in battle says "Useless analysis" or not'] = "mod_config_check_act_description_description",
}

local GAMEOVER_PARTY_TEXT_IDS = {
    ["  Come on,[wait:5]\n  that all you got!?"] = "gameover_susie_challenge",
    ["  Kris,[wait:5]\n  get up...!"] = "gameover_susie_get_up",
    ["  This is not\n  your fate...!"] = "gameover_ralsei_fate",
    ["  Please,[wait:5]\n  don't give up!"] = "gameover_ralsei_dont_give_up",
}

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
    lang = lang:lower()
    lang = lang:gsub("-", "_")
    lang = lang:gsub("%..*$", "")
    lang = lang:gsub("@.*$", "")
    return lang
end

local function addLanguageCandidate(candidates, seen, lang)
    lang = normalizeLanguageId(lang)
    if lang ~= "" and not seen[lang] then
        table.insert(candidates, lang)
        seen[lang] = true
    end
end

local function getLocaleCandidates(locale)
    local candidates = {}
    local seen = {}
    local normalized = normalizeLanguageId(locale)

    addLanguageCandidate(candidates, seen, normalized)

    local base = normalized:match("^([a-z]+)")
    if base == "zh" then
        if normalized:find("hant") or normalized:find("_tw") or normalized:find("_hk") or normalized:find("_mo") then
            addLanguageCandidate(candidates, seen, "zh_hant")
        else
            addLanguageCandidate(candidates, seen, "zh_hans")
        end
    end

    if base then
        addLanguageCandidate(candidates, seen, base)
    end

    return candidates
end

local function matchAvailableLanguage(lang, available)
    local normalized = normalizeLanguageId(lang)

    for _, candidate in ipairs(getLocaleCandidates(normalized)) do
        if listContains(available, candidate) then
            return candidate
        end
    end

    local base = normalized:match("^([a-z]+)")
    if base then
        for _, available_lang in ipairs(available or {}) do
            if available_lang:match("^" .. base .. "_") then
                return available_lang
            end
        end
    end

    return nil
end

local function addLocale(locales, value)
    if type(value) == "string" then
        for locale in value:gmatch("[^:]+") do
            if locale ~= "" and locale ~= "C" and locale ~= "POSIX" then
                table.insert(locales, locale)
            end
        end
    elseif type(value) == "table" then
        for _, locale in ipairs(value) do
            addLocale(locales, locale)
        end
    end
end

local function getSystemLocales()
    local locales = {}

    if love and love.system then
        if type(love.system.getPreferredLocales) == "function" then
            local ok, value = pcall(love.system.getPreferredLocales)
            if ok then
                addLocale(locales, value)
            end
        end

        if type(love.system.getLocale) == "function" then
            local ok, value = pcall(love.system.getLocale)
            if ok then
                addLocale(locales, value)
            end
        end
    end

    if os and type(os.setlocale) == "function" then
        local ok, value = pcall(os.setlocale, nil, "ctype")
        if ok then
            addLocale(locales, value)
        end
    end

    if os and type(os.getenv) == "function" then
        for _, name in ipairs({ "LANGUAGE", "LC_ALL", "LC_MESSAGES", "LANG" }) do
            local ok, value = pcall(os.getenv, name)
            if ok then
                addLocale(locales, value)
            end
        end
    end

    return locales
end

local function getSystemLanguage(available)
    for _, locale in ipairs(getSystemLocales()) do
        local lang = matchAvailableLanguage(locale, available)
        if lang then
            return lang
        end
    end

    return nil
end

local function resolveLanguageId(lang, available)
    lang = normalizeLanguageId(lang)

    if lang == AUTO_LANGUAGE then
        return getSystemLanguage(available)
    end

    return matchAvailableLanguage(lang, available)
end

local function getDefaultLanguage(available)
    local configured = getConfig("defaultLanguage") or DEFAULT_LANGUAGE
    return resolveLanguageId(configured, available) or available[1] or DEFAULT_LANGUAGE
end

local function isCjkCodepoint(codepoint)
    return (codepoint >= 0x2E80 and codepoint <= 0x9FFF)
        or (codepoint >= 0xF900 and codepoint <= 0xFAFF)
        or (codepoint >= 0xFE10 and codepoint <= 0xFE1F)
        or (codepoint >= 0xFF00 and codepoint <= 0xFFEF)
        or (codepoint >= 0x20000 and codepoint <= 0x2FA1F)
end

local function hasCjkText(text)
    for _, codepoint in utf8.codes(text) do
        if isCjkCodepoint(codepoint) then
            return true
        end
    end
    return false
end

local function hasMultipleCodepoints(text)
    local count = 0
    for _ in utf8.codes(text) do
        count = count + 1
        if count > 1 then
            return true
        end
    end
    return false
end

local function addCjkTextSpacing(text, spacing_value, offset_y)
    if type(text) ~= "string" then
        return text
    end

    if Game.lang ~= "zh_hans" or not hasCjkText(text) or text:find("%[spacing:") then
        return text
    end

    local out = {}
    if offset_y and not text:find("%[offset:") then
        table.insert(out, "[offset:0," .. tostring(offset_y) .. "]")
    end

    local spacing = false
    local index = 1
    while index <= #text do
        local char = text:sub(index, index)
        if char == "[" then
            local close = text:find("]", index, true)
            if close then
                table.insert(out, text:sub(index, close))
                index = close + 1
            else
                table.insert(out, char)
                index = index + 1
            end
        else
            local codepoint = utf8.codepoint(text, index)
            local next_index = utf8.offset(text, 2, index) or (#text + 1)
            local cjk = isCjkCodepoint(codepoint)

            if cjk and not spacing then
                table.insert(out, "[spacing:" .. tostring(spacing_value) .. "]")
                spacing = true
            elseif not cjk and spacing then
                table.insert(out, "[spacing:0]")
                spacing = false
            end

            table.insert(out, text:sub(index, next_index - 1))
            index = next_index
        end
    end

    if spacing then
        table.insert(out, "[spacing:0]")
    end

    return table.concat(out)
end

local function addCjkTextSpacingValue(value, spacing_value, offset_y)
    if type(value) == "table" then
        local out = {}
        for key, item in pairs(value) do
            out[key] = addCjkTextSpacingValue(item, spacing_value, offset_y)
        end
        return out
    end
    return addCjkTextSpacing(value, spacing_value, offset_y)
end

local function localizeStaticText(text)
    if type(text) ~= "string" or not Game or Game.lang ~= "zh_hans" then
        return text
    end

    local id = STATIC_TEXT_IDS[text]
    if id then
        return Game:loc(text, id)
    end

    local prefix, gameover_party_text = text:match("^(%[speed:0%.5%]%[spacing:%d+%]%[voice:[^%]]+%])(.*)$")
    id = gameover_party_text and GAMEOVER_PARTY_TEXT_IDS[gameover_party_text]
    if id then
        return prefix .. Game:loc(gameover_party_text, id)
    end

    local slot = text:match("^Overwrite Slot (%d+)%?$")
    if slot then
        return Game:loc("Overwrite Slot [var:slot]?", "save_menu_overwrite_slot", { slot = slot })
    end

    return text
end

local function localizeStaticTextValue(value)
    if type(value) == "table" then
        local out = {}
        for key, item in pairs(value) do
            out[key] = localizeStaticTextValue(item)
        end
        return out
    end
    return localizeStaticText(value)
end

local function shouldPrintWithCjkSpacing(text)
    return type(text) == "string"
        and Game.lang == "zh_hans"
        and hasCjkText(text)
        and hasMultipleCodepoints(text)
end

local function getCjkPrintedTextWidth(font, text)
    local width = 0
    for _, codepoint in utf8.codes(text) do
        local char = utf8.char(codepoint)
        width = width + font:getWidth(char)
        if isCjkCodepoint(codepoint) then
            width = width + CJK_FIXED_TEXT_SPACING
        end
    end
    return width
end

local function printCjkTextWithSpacing(orig, text, x, y, r, sx, sy, ox, oy, kx, ky)
    text = localizeStaticText(text)

    if not shouldPrintWithCjkSpacing(text) then
        return orig(text, x, y, r, sx, sy, ox, oy, kx, ky)
    end

    local font = love.graphics.getFont()
    local cursor_x = 0
    local cursor_y = 0

    love.graphics.push()
    love.graphics.translate(x or 0, y or 0)
    if r then
        love.graphics.rotate(r)
    end
    love.graphics.scale(sx or 1, sy or sx or 1)
    if kx or ky then
        love.graphics.shear(kx or 0, ky or 0)
    end
    love.graphics.translate(-(ox or 0), -(oy or 0))

    for _, codepoint in utf8.codes(text) do
        local char = utf8.char(codepoint)
        if char == "\n" then
            cursor_x = 0
            cursor_y = cursor_y + font:getHeight()
        else
            orig(char, cursor_x, cursor_y)
            cursor_x = cursor_x + font:getWidth(char)
            if isCjkCodepoint(codepoint) then
                cursor_x = cursor_x + CJK_FIXED_TEXT_SPACING
            end
        end
    end

    love.graphics.pop()
end

local function printfCjkTextWithSpacing(print_orig, printf_orig, text, x, y, limit, align, r, sx, sy, ox, oy, kx, ky)
    text = localizeStaticText(text)

    if not shouldPrintWithCjkSpacing(text) or text:find("\n", 1, true) then
        return printf_orig(text, x, y, limit, align, r, sx, sy, ox, oy, kx, ky)
    end

    local font = love.graphics.getFont()
    local text_width = getCjkPrintedTextWidth(font, text)
    local print_x = x or 0
    limit = limit or text_width

    if align == "center" then
        print_x = print_x + ((limit - text_width) / 2)
    elseif align == "right" then
        print_x = print_x + limit - text_width
    end

    return printCjkTextWithSpacing(print_orig, text, print_x, y, r, sx, sy, ox, oy, kx, ky)
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

    Game.lang = resolveLanguageId(Game.lang or getConfig("defaultLanguage") or DEFAULT_LANGUAGE, Game.langAvailable)
        or getDefaultLanguage(Game.langAvailable)

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

    local graphics_print = love.graphics.print
    HookSystem.hook(love.graphics, "print", function(orig, text, ...)
        return printCjkTextWithSpacing(orig, text, ...)
    end)

    HookSystem.hook(love.graphics, "printf", function(orig, text, ...)
        return printfCjkTextWithSpacing(graphics_print, orig, text, ...)
    end)

    if GonerChoice then
        HookSystem.hook(GonerChoice, "getChoiceText", function(orig, self, choice, x, y)
            return localizeStaticText(orig(self, choice, x, y))
        end)
    end

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

    HookSystem.hook(Text, "setText", function(orig, self, text)
        text = localizeStaticTextValue(text)
        return orig(self, addCjkTextSpacingValue(text, CJK_FIXED_TEXT_SPACING))
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

    HookSystem.hook(DialogueText, "setText", function(orig, self, text, ...)
        text = localizeStaticTextValue(text)
        return orig(self, addCjkTextSpacingValue(text, CJK_DIALOGUE_TEXT_SPACING, CJK_DIALOGUE_Y_OFFSET), ...)
    end)

    HookSystem.hook(DialogueText, "updateTypewriter", function(orig, self)
        if Game.lang ~= "zh_hans"
            or type(self.text) ~= "string"
            or not hasCjkText(self.text)
            or not self.state
            or type(self.state.speed) ~= "number"
        then
            return orig(self)
        end

        local speed = self.state.speed
        self.state.speed = speed * CJK_TYPEWRITER_SPEED_MULTIPLIER
        local ok, result = pcall(orig, self)
        self.state.speed = speed

        if not ok then
            error(result)
        end

        return result
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

    Game.lang = resolveLanguageId(data.lang or Game.lang or getConfig("defaultLanguage") or DEFAULT_LANGUAGE, Game.langAvailable)
        or getDefaultLanguage(Game.langAvailable)
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

    lang = resolveLanguageId(lang or Game.lang or DEFAULT_LANGUAGE, Game.langAvailable)
        or getDefaultLanguage(Game.langAvailable)

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

    lang = resolveLanguageId(lang, Game.langAvailable)
    if not lang then
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

function Game:getSystemLanguage()
    ensureLanguageGlobals()
    return getSystemLanguage(Game.langAvailable) or getDefaultLanguage(Game.langAvailable)
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
