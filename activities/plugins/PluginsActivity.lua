require "env"
setStatus()

-- 绑定Java类
local bindClass = luajava.bindClass
local LinearLayoutManager = bindClass "androidx.recyclerview.widget.LinearLayoutManager"
local LuaCustRecyclerHolder = bindClass "com.lua.custrecycleradapter.LuaCustRecyclerHolder"
local LuaCustRecyclerAdapter = bindClass "com.lua.custrecycleradapter.LuaCustRecyclerAdapter"
local AdapterCreator = bindClass "com.lua.custrecycleradapter.AdapterCreator"
local Build = bindClass "android.os.Build"
local View = bindClass "android.view.View"
local File = bindClass "java.io.File"
local ForegroundColorSpan = bindClass "android.text.style.ForegroundColorSpan"
local SpannableString = bindClass "android.text.SpannableString"
local PopupMenu = bindClass "androidx.appcompat.widget.PopupMenu"
local Spannable = bindClass "android.text.Spannable"
local Intent = bindClass "android.content.Intent"
local Activity = bindClass "android.app.Activity"
local Uri = bindClass "android.net.Uri"
local RecyclerView = bindClass "androidx.recyclerview.widget.RecyclerView"

-- 加载工具库
local UiUtil = require "utils.UiUtil"
local MaterialBlurDialogBuilder = require "dialogs.MaterialBlurDialogBuilder"
local PopupMenuUtils = require "utils.PopupMenuUtils"
local PluginsUtil = require "activities.plugins.PluginsUtil"
local PluginsManagerUtil = require "activities.plugins.PluginsManagerUtil"
local Utils = require "utils.Utils"

-- 导入设置相关
SettingsLayUtil = require "activities.settings.SettingsLayUtil"
import "activities.plugins.SettingsLayUtilPro"
import "activities.plugins.settings"

-- 全局常量
local REQUEST_INSTALLPLUGIN = 10
local PLUGINS_DIR = File(PluginsUtil.PLUGINS_PATH)

-- 全局变量
local settings2 = {}
local adapter
local layoutManager

-- 获取应用版本信息
local PackInfo = activity.PackageManager.getPackageInfo(activity.getPackageName(), 64)
local versionCode = PackInfo.versionCode

-- ===== 辅助函数 =====
-- 转换为布尔值
local function toboolean(value)
  return value and true or false
end

-- 从文件加载配置
local function getConfigFromFile(path)
  local env = {}
  assert(loadfile(tostring(path), "bt", env))()
  return env
end

-- 格式化资源字符串
local function formatResStr(id, values)
  return String.format(id, values)
end

-- 添加带颜色的摘要行
function addSummaryTextLine(summarySpanIndex, color, oldSummary, summary)
  local newSummary = oldSummary .. "\n" .. summary
  table.insert(summarySpanIndex, {color, utf8.len(oldSummary) + 1, utf8.len(newSummary)})
  return newSummary
end

-- ===== 事件处理函数 =====
-- 处理返回结果
function onActivityResult(requestCode, resultCode, data)
  if resultCode == Activity.RESULT_OK and requestCode == REQUEST_INSTALLPLUGIN then
    installPlugin(data.getData())
  end
end

-- 列表项点击事件
local function onItemClick(view, views, key, data)
  if key == "plugin_item" then
    local newState = data.checked
    if data.enableVer then
      PluginsUtil.setEnabled(data.dirName, newState and versionCode or false)
     else
      PluginsUtil.setEnabled(data.dirName, newState)
    end
    PluginsUtil.clearOpenedPluginPaths()
   elseif key == "install_plugin" then
    local intent = Intent(Intent.ACTION_GET_CONTENT)
    .setType("*/*")
    .addCategory(Intent.CATEGORY_OPENABLE)
    activity.startActivityForResult(intent, REQUEST_INSTALLPLUGIN)
   elseif key == "download_plugin" then
    pcall(activity.startActivity, Intent(Intent.ACTION_VIEW,
    Uri.parse(("mqqapi://card/show_pslcard?src_type=internal&version=1&uin=%s&card_type=group&source=qrcode"):format(818459127))))
  end
end

-- 列表项长按事件
local function onItemLongClick(view, views, key, data)
  if key == "plugin_item" then
    local config = data.config
    local pop = PopupMenu(activity, view.getChildAt(0).getChildAt(1).getChildAt(0))
    PopupMenuUtils.setHeaderTitle(pop, data.title)

    pop.Menu.add(res.string.plugins_uninstall).onMenuItemClick = function()
      PluginsManagerUtil.uninstall(data.path, config, function(state)
        if state == "success" then
          MyToast(res.string.uninstall_success)
          refresh()
         elseif state == "failed" then
          MyToast(res.string.uninstall_failed)
        end
      end)
    end

    pop.show()
    return true
  end
  return false
end

-- 信息按钮点击事件
function onItemInfoBtnClick(view)
  local data = view.tag
  local readmePath = data.path .. "/README.md"

  if File(readmePath).isFile() then
    MarkdownReaderDialog.init()
    MarkdownReaderDialog.load(readmePath)
    MarkdownReaderDialog.setTitle(data.title)
    MarkdownReaderDialog.show()
  end
end

-- 信息按钮点击监听器
onItemInfoBtnClickListener = View.OnClickListener({onClick = onItemInfoBtnClick})

-- ===== 核心功能 =====
-- 安装插件
function installPlugin(uri)
  PluginsManagerUtil.installByUri(uri, function(state)
    if state == "success" then
      MyToast(res.string.install_success)
      refresh()
     elseif state == "failed" then
      MyToast(res.string.install_failed)
    end
  end)
end

-- 刷新插件列表
function refresh()
  settings2 = {}

  -- 添加基础设置项
  for index, content in ipairs(settings) do
    table.insert(settings2, content)
  end

  -- 加载插件目录
  if PLUGINS_DIR.isDirectory() then
    local fileList = PLUGINS_DIR.listFiles()

    for index = 0, #fileList - 1 do
      local file = fileList[index]
      if file.isDirectory() then
        local path = file.getPath()
        local dirName = file.getName()
        local initPath = path .. "/init.lua"
        local icon = path .. "/icon.png"
        local icon_night = path .. "/icon-night.png"

        -- 加载插件配置
        local success, config = pcall(getConfigFromFile, initPath)
        local title, summary, spannableSummary, enableVer, checked, switchEnabled
        local summarySpanIndex = {}

        if success then
          -- 设置插件标题
          title = config.appname or dirName

          -- 设置插件描述
          local description = config.description
          summary = description and type(description) == "string" and description ~= ""
          and description .. "\n" or ""

          -- 添加版本信息
          local pluginVersionName = config.appver
          local pluginVersionCode = config.appcode
          if pluginVersionName then
            if versionCode then
              summary = summary .. formatResStr(res.string.plugins_info_version,
              {("%s (%s)"):format(pluginVersionName, pluginVersionCode)})
             else
              summary = summary .. formatResStr(res.string.plugins_info_version, {pluginVersionName})
            end
           elseif pluginVersionCode then
            summary = summary .. formatResStr(res.string.plugins_info_version, {pluginVersionCode})
           else
            summary = summary .. formatResStr(res.string.plugins_info_version, {"未知"})
          end

          -- 添加包名信息
          local packageName = config.packagename
          if packageName then
            summary = summary .. "\n" .. formatResStr(res.string.plugins_info_packageName, {packageName})
            if packageName ~= dirName then
              summary = summary .. "\n" .. formatResStr(res.string.plugins_info_folderName, {dirName})
              summary = addSummaryTextLine(summarySpanIndex, 0xFFFF9000, summary, res.string.plugins_warning_keepPFSame)
            end
           else
            summary = summary .. "\n" .. formatResStr(res.string.plugins_info_folderName, {dirName})
            summary = addSummaryTextLine(summarySpanIndex, 0xFFFF9000, summary, res.string.plugins_warning_addPackageName)
          end

          -- 检查插件状态
          checked = PluginsUtil.getEnabled(dirName)
          switchEnabled = true

          -- 检查兼容性
          local supports = config.supported2
          if supports then
            local versionConfig = supports["LuaAppX2"]
            if versionConfig then
              local minVerCode = versionConfig.mincode
              local targetVerCode = versionConfig.targetcode

              if not minVerCode or minVerCode <= versionCode then
                if targetVerCode and targetVerCode < versionCode then
                  checked = checked == versionCode
                  enableVer = true
                  summary = addSummaryTextLine(summarySpanIndex, 0xFFFF9000, summary, res.string.plugins_warning_update)
                end
               else
                switchEnabled = false
                summary = addSummaryTextLine(summarySpanIndex, Colors.colorError, summary, res.string.plugins_error_update_app)
              end
             else
              summary = addSummaryTextLine(summarySpanIndex, Colors.colorError, summary, res.string.plugins_error_unsupported)
            end
           elseif supports == nil then
            summary = addSummaryTextLine(summarySpanIndex, 0xFFFF9000, summary, res.string.plugins_warning_supported)
          end
         else
          -- 无效插件处理
          switchEnabled = false
          title = dirName
          summary = res.string.plugins_error
          table.insert(summarySpanIndex, {Colors.colorError, 0, utf8.len(summary)})
          summary = summary .. "\n" .. config
          config = {}
        end

        -- 处理摘要样式
        if #summarySpanIndex ~= 0 then
          spannableSummary = SpannableString(summary)
          for _, content in ipairs(summarySpanIndex) do
            spannableSummary.setSpan(ForegroundColorSpan(content[1]), content[2], content[3], Spannable.SPAN_INCLUSIVE_INCLUSIVE)
          end
        end

        -- 处理图标
        if UiUtil.isNightMode() and File(icon_night).isFile() then
          icon = icon_night
        end
        if not File(icon).isFile() then
          icon = "ic_puzzle_icon"
        end

        -- 添加到列表
        table.insert(settings2, {
          config.smallicon and SettingsLayUtil.ITEM_AVATAR_ICON_SWITCH or SettingsLayUtil.ITEM_AVATAR_SWITCH,
          icon = icon,
          title = title,
          summary = spannableSummary or summary,
          key = "plugin_item",
          checked = toboolean(checked),
          config = config,
          switchEnabled = switchEnabled,
          enableVer = enableVer,
          dirName = dirName,
          path = path,
          contextMenuEbaled = true,
          hasReadme = File(path .. "/README.md").isFile()
        })
      end
    end
  end

  -- 添加底部提示
  table.insert(settings2, {
    SettingsLayUtil.ITEM_ONLYSUMMARY,
    summary = res.string.plugins_reboot,
    clickable = false
  })

  -- 刷新适配器
  if adapter then
    adapter.notifyDataSetChanged()
  end
end

-- ===== 主执行逻辑 =====
-- 设置界面
activity
.setContentView(loadlayout("layouts.activity_plugins"))
.setSupportActionBar(toolbar)
.getSupportActionBar()
.setDisplayHomeAsUpEnabled(true)

-- 创建适配器
adapter = LuaCustRecyclerAdapter(AdapterCreator({
  getItemCount = function()
    return SettingsLayUtil.adapterEvents.getItemCount(settings2)
  end,
  getItemViewType = function(position)
    return SettingsLayUtil.adapterEvents.getItemViewType(settings2, position)
  end,
  onCreateViewHolder = function(parent, viewType)
    local holder = SettingsLayUtil.adapterEvents.onCreateViewHolder(onItemClick, onItemLongClick, parent, viewType)
    local ids = holder.view.tag
    local infoBtnView = ids.infoBtnView

    if infoBtnView then
      infoBtnView.setOnClickListener(onItemInfoBtnClickListener)
    end

    return holder
  end,
  onBindViewHolder = function(holder, position)
    local data = settings2[position + 1]
    local layoutView = holder.view
    local ids = layoutView.getTag()
    local infoBtnView = ids.infoBtnView

    if infoBtnView then
      infoBtnView.setVisibility(data.hasReadme and View.VISIBLE or View.GONE)
      infoBtnView.tag = data
    end

    SettingsLayUtil.adapterEvents.onBindViewHolder(settings2, holder, position)
  end,
}))

-- 设置RecyclerView
recycler_view
.setAdapter(adapter)
.setLayoutManager(LinearLayoutManager(activity))
.setTag({_type = "itemview"})

recycler_view.addItemDecoration(RecyclerView.ItemDecoration {
  getItemOffsets = function(outRect, view, parent, state)
    Utils.modifyItemOffsets2(outRect, view, parent, adapter, 12)
  end
})

activity.registerForContextMenu(recycler_view)

-- 检查传入的URI
local fileUri = activity.getIntent().getExtras() and activity.getIntent().getExtras().get("fileUri")
if fileUri then
  installPlugin(fileUri)
end

-- 初始刷新
refresh()

-- ===== 生命周期函数 =====
-- 菜单项选择
function onOptionsItemSelected(item)
  if item.getItemId() == android.R.id.home then
    activity.finish()
    return true
  end
  return false
end

-- 清理资源
function onDestroy()
  adapter.release()
  luajava.clear()
  collectgarbage("collect")
  collectgarbage("step")
end