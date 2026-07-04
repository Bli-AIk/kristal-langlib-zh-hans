# langLib_zh_hans

[![license](https://img.shields.io/badge/license-MIT%2FApache--2.0-blue)](LICENSE-APACHE)
<br>
<img src="https://img.shields.io/badge/Lua-2C2D72?style=for-the-badge&logo=lua&logoColor=white" />
<img src="https://img.shields.io/badge/Kristal-FF6B35?style=for-the-badge&logo=love2d&logoColor=white" />

> Current Status: ✅ Stable

![Screenshot](./screenshot.png)

**langLib_zh_hans** — a Chinese localization library for Kristal `v0.10.x`, forked from Elioze's [LangLib](https://gamebanana.com/mods/627141) on GameBanana and tailored for Chinese localization projects.

| English | 简体中文 |
|---------|---------|
| English | [简体中文](./README.md) |

## Introduction

`langLib_zh_hans` provides complete Chinese localization capabilities for Kristal mods. While retaining the `Game:loc(default, id, var)` main API, it adds features essential for Chinese localization: UTF-8-safe variable substitution, automatic system language detection, runtime language switching, and a per-language asset override system covering fonts, sprites, audio, and video.

Once the library is installed, a mod only needs a language JSON file to achieve full Chinese localization — no game logic changes required.

## Features

- 🌐 `zh_hans` language ID and complete Chinese language table
- 🔤 UTF-8-safe `[var:name]` variable substitution
- 👤 `Game:locName(category, id, default)` with translated/original character name styles
- 🔍 `auto` mode for automatic system language detection and best-match selection
- 🔄 Runtime language switching (F6 hotkey), persisted to save data
- 📝 `cutscene:text(..., {id = "text_id"})` and `cutscene:choicer(..., {ids = {...}})` for direct id-based localization
- 🎨 Language-specific asset overrides: fonts, sprites, audio, music, and video via `lang/<lang>/...` paths
- 🔣 Automatic CJK character spacing adjustment and typewriter speed correction
- 📋 Automatic hooks for text, choices, Tiled NPC/Interactable, items, spells, and menus
- 🖥️ Optional `DarkConfigMenu` integration with a language settings submenu
- 🆓 Dual-licensed (MIT / Apache 2.0)

## Installation

Place the entire directory into your target mod:

```text
mods/your_mod/libraries/langLib_zh_hans/
```

The directory must include:

```text
lib.json
lib.lua
lang/en.json
lang/zh_hans.json
lang/names/en.json
lang/names/zh_hans.json
scripts/hooks/...
```

## Dependencies

| Library | Description |
|---|---|
| [Kristal](https://github.com/KristalTeam/Kristal) | Game engine, `v0.10.0` or later |

## Configuration

Default configuration is in `lib.json`:

```json
{
    "defaultLanguage": "en",
    "defaultNameStyle": "translated",
    "languages": ["en", "zh_hans"],
    "languageNames": {
        "en": "English",
        "zh_hans": "简体中文"
    }
}
```

Override in your mod's `mod.json`:

```json
"config": {
    "langLibZh": {
        "defaultLanguage": "auto",
        "languages": ["en", "zh_hans"],
        "languageNames": {
            "en": "English",
            "zh_hans": "简体中文"
        }
    }
}
```

`defaultLanguage` can be a specific language ID or `"auto"`. `"auto"` reads the system language and selects the closest match from the `languages` list; if no match is found, it falls back to the first item or English.

`defaultNameStyle` can be `"translated"` or `"original"` and controls the default character name display style.

## Usage

### Language Files

Place your mod's translations in `mods/your_mod/lang/zh_hans.json`. Keys matching those in the library's language table will be overridden.

The following naming conventions are supported:

```text
lang/zh_hans.json
lang/lang_zh_hans.json
lang/zh-hans.json
lang/lang_zh-hans.json
```

### Character Names

Character names can be kept in:

```text
lang/names/zh_hans.json
```

Format:

```json
{
    "chara": {
        "kris": {
            "translated": "克里斯",
            "original": "Kris"
        }
    },
    "actor": {
        "starwalker": {
            "translated": "星之行者",
            "original": "Starwalker"
        }
    }
}
```

`chara` is used for party-member UI names, while `actor` is used for Actor names. Legacy `chara_<id>_name` and `actor_<id>_name` keys are still supported and are merged into the runtime `names` table.

You can reference names inside regular text so one translation follows the current setting:

```json
{
    "room1.hello": "* 你好，[name:chara:kris]。"
}
```

Runtime helpers:

```lua
Game:locName("chara", "kris", "Kris")
Game:setNameStyle("original")
Game:setNameStyle("translated")
```

### Text Localization

Direct call:

```lua
cutscene:text(Game:loc("* Hello, [var:name].", "room1.hello", {name = "Kris"}))
```

Language table:

```json
{
    "room1.hello": "* 你好，[var:name]。"
}
```

You can also pass the id directly in `cutscene:text`:

```lua
cutscene:text("* Hello, [var:name].", "smile", "ralsei", {
    id = "room1.hello",
    var = {name = "Kris"}
})
```

### Choice Localization

```lua
local choice = cutscene:choicer({"Yes", "No"}, {
    ids = {"choice.yes", "choice.no"}
})
```

```json
{
    "choice.yes": "是",
    "choice.no": "否"
}
```

### Asset Localization

When the language is `zh_hans`, asset requests will first look in the language-specific path before falling back:

```lua
Assets.getTexture("ui/title")    -- → lang/zh_hans/ui/title.png
Assets.getFont("main")           -- → lang/zh_hans/main.ttf
Assets.playSound("voice/noelle") -- → lang/zh_hans/voice/noelle.wav
```

### Chinese Fonts

The library includes built-in Chinese fallback fonts. The strategy is:

- English/ASCII characters use the original Kristal fonts to keep English crisp in Chinese mode
- Chinese characters fall back to the bundled CJK fonts

To use custom Chinese fonts, place files with the same paths in your mod to override.

### Runtime Switching

```lua
Game:setLanguage("zh_hans")
Game:setLanguage("en")
```

Press F6 in-game to toggle between languages.

Language and name display settings are persisted to save data:

```lua
data.lang
data.langSelected
data.langNameStyle
```

## Upstream & References

This library is based on [LangLib](https://gamebanana.com/mods/627141) from GameBanana and references the following Chinese localization projects:

| Project | Author/Organization |
|---------|---------------------|
| [LangLib](https://gamebanana.com/mods/627141) | Elioze |
| Chinese localization references from other Kristal projects | [WasneetPotato](https://space.bilibili.com/1641628190) |
| [DeltaruneChinese](https://github.com/gm3dr/DeltaruneChinese) | dr好人汉化组 |
| Chinese fork | Aik/Codex |

## Contributing

Issues and Pull Requests are welcome.

## License

This project is licensed under either of

- Apache License, Version 2.0 ([LICENSE-APACHE](LICENSE-APACHE) or http://www.apache.org/licenses/LICENSE-2.0)
- MIT license ([LICENSE-MIT](LICENSE-MIT) or http://opensource.org/licenses/MIT)

at your option.
