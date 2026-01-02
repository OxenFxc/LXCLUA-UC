return 
{
  {--插件管理
    SettingsLayUtil.TITLE,
    title = res.string.plugins_manager,
  },
  {
    SettingsLayUtil.ITEM_NOSUMMARY,
    icon = "ic_puzzle_plus_outline",
    title = res.string.plugins_install,
    key = "install_plugin",
  },
  {
    SettingsLayUtil.ITEM_NOSUMMARY,
    icon = "ic_cloud_download_outline",
    title = res.string.plugins_download,
    key = "download_plugin",
    newPage = "newApp",
  },
  {--已安装的插件
    SettingsLayUtil.TITLE,
    title = res.string.plugins_installed,
  },
}