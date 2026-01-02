local bindClass = luajava.bindClass
local Build = bindClass "android.os.Build"
local packageInfo = activity.getPackageManager().getPackageInfo(activity.getPackageName(), 0)
local is_sora = activity.getSharedData("is_sora")

return
{
  {--界面
    SettingsLayUtil.TITLE,
    title = res.string.interfaces,
  },
  {--主题颜色
    SettingsLayUtil.ITEM,
    icon = "ic_palette_outline",
    title = res.string.theme_color,
    key = "theme_color",
    items = {
      res.string.theme_blue,
      res.string.theme_green,
      res.string.customize
    },
  },
  {--动态取色
    SettingsLayUtil.ITEM_SWITCH,
    icon = "ic_eyedropper_variant",
    title = res.string.dynamic_color_extraction,
    key = "eyedropper_variant",
    summary = res.string.dynamic_color_extraction_summary,
    enabled = (function() if Build.VERSION.SDK_INT >= 31 return true else return false end end)(),
    switchEnabled = (function() if Build.VERSION.SDK_INT >= 31 return true else return false end end)(),
  },
  {--深色模式
    SettingsLayUtil.ITEM,
    icon = "ic_theme_light_dark",
    title = res.string.theme_light_dark,
    key = "theme_light_dark",
    items = {
      res.string.lollower_system,
      res.string.always_on,
      res.string.always_closed,
    },
  },
  {--折叠工具栏
    SettingsLayUtil.ITEM_SWITCH_NOSUMMARY;
    icon = "ic_collapse_up",
    title = res.string.collapse_toolbar,
    key = "collapse_toolbar",
  },
  {--显示项目图标
    SettingsLayUtil.ITEM_SWITCH_NOSUMMARY;
    icon = "ic_image_outline",
    title = res.string.show_item_icon,
    key = "show_item_icon",
  },
  {--Fragment动画
    SettingsLayUtil.ITEM,
    icon = "ic_google_assistant",
    title = res.string.fragment_animation,
    key = "fragment_animation",
    items = {
      "Bottom Sheet Slide",
      "Fade Animation"
    },
  },
  {--插件
    SettingsLayUtil.TITLE,
    title = res.string.plugins,
  };
  {--插件管理
    SettingsLayUtil.ITEM_NOSUMMARY,
    icon = "ic_puzzle_outline",
    title = res.string.plugins_manager,
    key = "plugins_manager",
    newPage = true,
  },
  {--标签栏
    SettingsLayUtil.TITLE,
    title = res.string.label_bar,
  },
  {--文件图标
    SettingsLayUtil.ITEM_SWITCH_NOSUMMARY;
    icon = "ic_file_eye_outline",
    title = res.string.file_icon,
    key = "file_icon",
  },
  {--历史记录
    SettingsLayUtil.ITEM_SWITCH_NOSUMMARY;
    icon = "ic_file_clock_outline",
    title = res.string.history_record,
    key = "history_record",
  },
  {--编辑器
    SettingsLayUtil.TITLE,
    title = res.string.editor,
  },
  {--自动备份
    SettingsLayUtil.ITEM_SWITCH,
    icon = "ic_zip_box_outline",
    title = res.string.automatic_backup,
    key = "automatic_backup",
    summary = res.string.automatic_backup_tip,
  },
  {--Sora
    SettingsLayUtil.ITEM_SWITCH_NOSUMMARY;
    icon = "ic_circle_edit_outline",
    title = res.string.sora_editor,
    key = "is_sora",
  },
  {--完整参数类型
    SettingsLayUtil.ITEM_SWITCH,
    icon = "ic_eye_outline",
    title = res.string.full_parameter_type,
    key = "full_parameter_type",
    summary = res.string.full_parameter_type_summary,
    enabled = is_sora or false,
    switchEnabled = is_sora or false,
  },
  {--分析导入类
    SettingsLayUtil.ITEM_SWITCH,
    icon = "ic_language_java",
    title = res.string.analyse_the_data,
    key = "analyse_the_data",
    summary = res.string.analyse_the_data_summary,
    enabled = is_sora or false,
    switchEnabled = is_sora or false,
  },
  {--区分大小写
    SettingsLayUtil.ITEM_SWITCH,
    icon = "ic_format_letter_case",
    title = res.string.case_sensitive,
    key = "case_sensitive",
    summary = res.string.case_sensitive_summary,
  },
  {--编辑框配置
    SettingsLayUtil.ITEM_NOSUMMARY;
    icon = "ic_circle_edit_outline",
    title = res.string.edit_config,
    key = "edit_config",
    enabled = is_sora or false,
    switchEnabled = is_sora or false,
    newPage = true,
  },
  {--缩放范围
    SettingsLayUtil.ITEM,
    icon = "ic_cursor_pointer",
    title = res.string.zoom_range,
    key = "zoom_range",
    enabled = is_sora or false,
    switchEnabled = is_sora or false,
  },
  {--字体
    SettingsLayUtil.ITEM,
    icon = "ic_format_font",
    title = res.string.font,
    key = "font_path",
    items = {
      "Jetbrains Mono",
      "Fira Code",
      res.string.customize
    },
  },
  {--符号栏
    SettingsLayUtil.TITLE,
    title = res.string.symbols_field,
  },
  {--自动填充
    SettingsLayUtil.ITEM_SWITCH_NOSUMMARY;
    icon = "ic_symbol",
    title = res.string.autofill,
    key = "autofill",
    enabled = is_sora or false,
    switchEnabled = is_sora or false,
  },
  {--自定义符号
    SettingsLayUtil.ITEM_NOSUMMARY;
    icon = "ic_symbol",
    title = res.string.custom_symbol_bar,
    key = "custom_symbol_bar",
    newPage = true,
  },
  {--布局助手
    SettingsLayUtil.TITLE,
    title = res.string.layout_helper,
  },
  {--控件中文名
    SettingsLayUtil.ITEM_SWITCH_NOSUMMARY;
    icon = "ic_ideogram_cjk",
    title = res.string.chinese_name_of_control,
    key = "chinese_name_of_control",
  },
  {--自定义控件类
    SettingsLayUtil.ITEM_NOSUMMARY;
    icon = "ic_view_list_outline",
    title = res.string.custom_control_class,
    key = "custom_control_class",
    newPage = true,
  },
  {--网络
    SettingsLayUtil.TITLE,
    title = res.string.network,
  },
{--请求拦截
    SettingsLayUtil.ITEM_SWITCH,
    icon = "ic_shield_check_outline",
    title = res.string.request_interception,
    key = "request_interception",
    summary = res.string.request_interception_tip,
  },
  {--离线模式
    SettingsLayUtil.ITEM_SWITCH,
    icon = "ic_wifi_off",
    title = res.string.offline_mode,
    key = "offline_mode",
    summary = res.string.offline_mode_tip,
  },
  {--软件
    SettingsLayUtil.TITLE,
    title = res.string.software,
  },
  {--检查更新
    SettingsLayUtil.ITEM_SWITCH_NOSUMMARY;
    icon = "ic_search",
    title = res.string.check_for_updated,
    key = "check_for_updated",
  },
  {
    SettingsLayUtil.ITEM,
    icon = "ic_information_outline",
    title = res.string.about_software,
    summary = res.string.current_version .. "：" .. ("%s(%s)"):format(packageInfo.versionName, packageInfo.versionCode);
    key = "about",
    newPage = true,
  },

}