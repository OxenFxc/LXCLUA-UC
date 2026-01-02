return
{
  {--十六进制颜色高亮
    SettingsLayUtil.ITEM_SWITCH,
    icon = "ic_palette_outline",
    title = res.string.hex_color_highlight,
    key = "hex_color_highlight",
    summary = "#AARRGGBB 0xAARRGGBB",
    enabled = is_sora or false,
    switchEnabled = is_sora or false,
  },
  {--缩进提示符
    SettingsLayUtil.ITEM_SWITCH,
    icon = "ic_format_line_spacing_black",
    title = res.string.editor_showblankchars,
    key = "editor_showBlankChars",
    summary = res.string.editor_showblankchars_tip,
  },
  {--类名高亮
    SettingsLayUtil.ITEM_CARD_NOSUMMARY;
    icon = "ic_palette_outline",
    title = res.string.class_name_highlight,
    key = "class_name_highlight",
    summary = (res.string.highlight_summary):format("Class Name"),
    enabled = is_sora or false,
    cardEnabled = is_sora or false,
  },
  {--局部变量高亮
    SettingsLayUtil.ITEM_CARD_NOSUMMARY;
    icon = "ic_palette_outline",
    title = res.string.local_variable_highlight,
    key = "local_variable_highlight",
    summary = (res.string.highlight_summary):format("local name"),
    enabled = is_sora or false,
    cardEnabled = is_sora or false,
  },
  {--关键词高亮
    SettingsLayUtil.ITEM_CARD_NOSUMMARY;
    icon = "ic_palette_outline",
    title = res.string.keyword_highlight,
    key = "keyword_highlight",
    summary = (res.string.highlight_summary):format("keyword"),
    enabled = is_sora or false,
    cardEnabled = is_sora or false,
  },
  {--函数名高亮
    SettingsLayUtil.ITEM_CARD_NOSUMMARY;
    icon = "ic_palette_outline",
    title = res.string.function_name_highlight,
    key = "function_name_highlight",
    summary = (res.string.highlight_summary):format("function name"),
    enabled = is_sora or false,
    cardEnabled = is_sora or false,
  },
  {--分割线颜色
    SettingsLayUtil.ITEM_CARD_NOSUMMARY;
    icon = "ic_palette_outline",
    title = res.string.dividing_line_color,
    key = "dividing_line_color",
    summary = (res.string.highlight_summary):format("line divider"),
    enabled = is_sora or false,
    cardEnabled = is_sora or false,
  },
}