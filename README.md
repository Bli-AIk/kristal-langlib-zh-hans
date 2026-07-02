# LangLib Zh-Hans

Kristal `v0.10.x` 用本地化库，基于 GameBanana 上 Elioze 的 `LangLib` 改造，面向中文汉化工程使用。

这个版本不考虑 Kristal 旧版兼容。它保留 `Game:loc(default, id, var)` 作为主 API，并补了中文工程常用能力：

- `zh_hans` 语言 ID 和基础中文语言表
- UTF-8 安全的 `[var:name]` 变量替换
- `Game:setLanguage(lang)` / `Game:getLanguages()` / `Game:getLanguageName()`
- 文本、选项、Tiled NPC/Interactable、物品、技能、菜单等常见入口 hook
- 资源按语言覆盖：字体、图片、音频、音乐、视频都可放到 `lang/<语言>/...` 路径
- `cutscene:text(..., {id = "text_id"})` 和 `cutscene:choicer(..., {ids = {...}})` 直接按 id 本地化

## 安装

把整个目录放进目标模组：

```text
mods/your_mod/libraries/langLib_zh_hans/
```

目录中需要有：

```text
lib.json
lib.lua
lang/en.json
lang/zh_hans.json
scripts/hooks/...
```

## 配置

默认配置在 `lib.json`：

```json
{
    "defaultLanguage": "en",
    "languages": ["en", "zh_hans"],
    "languageNames": {
        "en": "English",
        "zh_hans": "简体中文"
    }
}
```

也可以在你的 `mod.json` 覆盖：

```json
"config": {
    "langLibZh": {
        "defaultLanguage": "zh_hans",
        "languages": ["en", "zh_hans"],
        "languageNames": {
            "en": "English",
            "zh_hans": "简体中文"
        }
    }
}
```

## 语言文件

模组自己的翻译放在：

```text
mods/your_mod/lang/zh_hans.json
```

也兼容这些命名：

```text
lang/zh_hans.json
lang/lang_zh_hans.json
lang/zh-hans.json
lang/lang_zh-hans.json
```

库内语言表会先加载，模组语言表后加载并覆盖同名 key。

## 文本用法

直接调用：

```lua
cutscene:text(Game:loc("* Hello, [var:name].", "room1.hello", {name = "Kris"}))
```

语言表：

```json
{
    "room1.hello": "* 你好，[var:name]。"
}
```

也可以在 `cutscene:text` 里直接传 id：

```lua
cutscene:text("* Hello, [var:name].", "smile", "ralsei", {
    id = "room1.hello",
    var = {name = "Kris"}
})
```

选项：

```lua
local choice = cutscene:choicer({"Yes", "No"}, {
    ids = {"choice.yes", "choice.no"}
})
```

语言表：

```json
{
    "choice.yes": "是",
    "choice.no": "否"
}
```

## Tiled NPC / Interactable

原库约定仍保留：

```text
text1 = default text
id1   = text.id
```

多行文本可按 `id1_1`、`id1_2` 或 Tiled 多值属性方式配置，hook 会把 `id` 找不到的行回退到默认文本。

## 资源本地化

普通资源：

```lua
Assets.getTexture("ui/title")
Assets.getFont("main")
Assets.playSound("voice/noelle")
```

当当前语言是 `zh_hans` 时，库会优先查：

```text
assets/sprites/lang/zh_hans/ui/title.png
assets/fonts/lang/zh_hans/main.ttf
assets/sounds/lang/zh_hans/voice/noelle.wav
```

找不到时回退到原资源。

## 中文字体

库不自带中文字体文件，避免字体授权风险。要显示中文，你需要在游戏或模组里放支持中文的字体，并配置 `main.json`、`main_mono.json`、`plain.json` 等。

推荐方式是在目标模组加入语言专用字体：

```text
assets/fonts/lang/zh_hans/main.ttf
assets/fonts/lang/zh_hans/main.json
assets/fonts/lang/zh_hans/main_mono.ttf
assets/fonts/lang/zh_hans/main_mono.json
assets/fonts/lang/zh_hans/plain.ttf
assets/fonts/lang/zh_hans/plain.json
```

示例 `main.json`：

```json
{
    "defaultSize": 24,
    "fallbacks": [
        {
            "font": "ja_main",
            "size": 24
        }
    ]
}
```

如果你的工程已经在全局 `assets/fonts/main.ttf` 里替换了中文字体，也可以不放语言专用字体。

## 运行时切换语言

```lua
Game:setLanguage("zh_hans")
Game:setLanguage("en")
```

语言会写入存档：

```lua
data.lang
data.langSelected
```

如果启用了可选 `DarkConfigMenu` hook，设置菜单里会出现语言切换项。

## 常用 key

库自带基础 key：

```text
use_item
toss_item
key_item
attack_stat
defense_stat
magic_stat
master_volume_config
controls_config
fullscreen_config
auto_run_config
lang_config
back_config
item_battleText
spell_castMessage
```

物品、技能、角色等自动 key 规则沿用原 LangLib：

```text
item_<id>_name
item_<id>_description
item_<id>_check
spell_<id>_name
spell_<id>_description
chara_<id>_name
actor_<id>_name
```

## 上游来源

本库基于 GameBanana 的 `LangLib`：

```text
https://gamebanana.com/mods/627141
```

当前没有在包内发现 GitHub 远程信息，也没有在公开 GitHub 仓库搜索中找到明确上游仓库。若后续找到官方仓库，可以把本目录作为 fork 分支内容迁移过去。
