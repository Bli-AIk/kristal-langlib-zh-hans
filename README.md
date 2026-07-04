# langLib_zh_hans

[![license](https://img.shields.io/badge/license-MIT%2FApache--2.0-blue)](LICENSE-APACHE)
<br>
<img src="https://img.shields.io/badge/Lua-2C2D72?style=for-the-badge&logo=lua&logoColor=white" />
<img src="https://img.shields.io/badge/Kristal-FF6B35?style=for-the-badge&logo=love2d&logoColor=white" />

> 当前状态：✅ 稳定可用

![效果图](./screenshot.png)

**langLib_zh_hans** — Kristal `v0.10.x` 用中文本地化库，基于 GameBanana 上 Elioze 的 [LangLib](https://gamebanana.com/mods/627141) 改造，面向中文汉化工程使用。

| 简体中文 | English |
|---------|---------|
| 简体中文 | [English](./README_en.md) |

## 简介

`langLib_zh_hans` 为 Kristal 模组提供完整的中文汉化能力。它在保留 `Game:loc(default, id, var)` 主 API 的基础上，补充了中文工程常用特性：UTF-8 安全的变量替换、系统语言自动检测、运行时语言切换、以及覆盖字体/贴图/音频/视频的按语言资源系统。

引入本库后，模组只需编写语言表 JSON 文件即可实现完整中文化，无需修改游戏逻辑代码。

## 特性

- 🌐 `zh_hans` 语言 ID 及完整中文语言表
- 🔤 UTF-8 安全的 `[var:name]` 变量替换
- 👤 `Game:locName(category, id, default)` 支持角色名译名 / 原名切换
- 🔍 `auto` 模式自动检测系统语言并匹配最佳可用语言
- 🔄 运行时语言切换（F6 快捷键），切换结果写入存档
- 📝 `cutscene:text(..., {id = "text_id"})` 和 `cutscene:choicer(..., {ids = {...}})` 直接按 id 本地化
- 🎨 资源按语言覆盖：字体、贴图、音频、音乐、视频均可放到 `lang/<语言>/...` 路径
- 🔣 CJK 字符自动字间距调整与打字机速度修正
- 📋 文本、选项、Tiled NPC/Interactable、物品、技能、菜单等常见入口自动 hook
- 🖥️ 可选 `DarkConfigMenu` 集成，设置菜单中出现语言设置子页
- 🆓 双许可证授权（MIT / Apache 2.0）

## 安装

将整个目录放入目标模组：

```text
mods/your_mod/libraries/langLib_zh_hans/
```

目录中需要包含：

```text
lib.json
lib.lua
lang/en.json
lang/zh_hans.json
lang/names/en.json
lang/names/zh_hans.json
scripts/hooks/...
```

## 依赖

| 库 | 说明 |
|---|---|
| [Kristal](https://github.com/KristalTeam/Kristal) | 游戏引擎，`v0.10.0` 或更高版本 |

## 配置

默认配置在 `lib.json`：

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

也可以在目标模组的 `mod.json` 中覆盖：

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

`defaultLanguage` 可设置为具体语言 ID 或 `"auto"`。`"auto"` 会读取系统语言并从 `languages` 列表中选择最接近的可用语言；匹配不到时回退到列表首项或英文。

`defaultNameStyle` 可设置为 `"translated"` 或 `"original"`，控制默认使用译名还是原名。

## 使用方式

### 语言文件

模组翻译放在 `mods/your_mod/lang/zh_hans.json`，与库语言表同名 key 会被覆盖。

兼容以下命名：

```text
lang/zh_hans.json
lang/lang_zh_hans.json
lang/zh-hans.json
lang/lang_zh-hans.json
```

### 角色名

角色名可以单独放在：

```text
lang/names/zh_hans.json
```

格式：

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

`chara` 用于队伍成员等 UI 名称，`actor` 用于 Actor 名称。旧的 `chara_<id>_name`、`actor_<id>_name` 仍然兼容，加载时也会自动并入运行时 `names` 表。

正文里可以写名字占位符，让同一条翻译跟随设置切换：

```json
{
    "room1.hello": "* 你好，[name:chara:kris]。"
}
```

运行时也可以直接取名：

```lua
Game:locName("chara", "kris", "Kris")
Game:setNameStyle("original")
Game:setNameStyle("translated")
```

### 文本本地化

直接调用：

```lua
cutscene:text(Game:loc("* 你好，[var:name]。", "room1.hello", {name = "Kris"}))
```

语言表：

```json
{
    "room1.hello": "* 你好，[var:name]。"
}
```

也可以在 `cutscene:text` 中直接传 id：

```lua
cutscene:text("* Hello, [var:name].", "smile", "ralsei", {
    id = "room1.hello",
    var = {name = "Kris"}
})
```

### 选项本地化

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

### 资源本地化

当语言为 `zh_hans` 时，以下资源请求会优先查找语言覆盖路径，找不到则回退：

```lua
Assets.getTexture("ui/title")    -- → lang/zh_hans/ui/title.png
Assets.getFont("main")           -- → lang/zh_hans/main.ttf
Assets.playSound("voice/noelle") -- → lang/zh_hans/voice/noelle.wav
```

### 中文字体

库内已内置中文 fallback 字体配置。策略：

- 英文/ASCII 优先使用 Kristal 原版英文字体，避免中文模式下英文变糊
- 中文字符回退到内置中文字体

如需自定义中文字体，在目标模组中放同路径文件即可覆盖。

### 运行时切换

```lua
Game:setLanguage("zh_hans")
Game:setLanguage("en")
```

程序内按 F6 可直接切换。

语言和名字显示方式会写入存档：

```lua
data.lang
data.langSelected
data.langNameStyle
```

## 上游来源与参考

本库基于 GameBanana 的 [LangLib](https://gamebanana.com/mods/627141) 改造，并参考了以下汉化项目：

| 项目 | 作者/组织 |
|------|-----------|
| [LangLib](https://gamebanana.com/mods/627141) | Elioze |
| 若干其他 Kristal 项目的汉化参考 | [WasneetPotato](https://space.bilibili.com/1641628190) |
| [DeltaruneChinese](https://github.com/gm3dr/DeltaruneChinese) | dr好人汉化组 |
| 中文 fork | Aik/Codex |

## 参与贡献

欢迎提交 Issue 或 Pull Request。

## 许可证

本项目采用双许可证授权，您可以选择以下任一许可证：

- Apache License, Version 2.0 ([LICENSE-APACHE](LICENSE-APACHE) 或 http://www.apache.org/licenses/LICENSE-2.0)
- MIT license ([LICENSE-MIT](LICENSE-MIT) 或 http://opensource.org/licenses/MIT)
