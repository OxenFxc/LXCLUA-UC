require "env"
setStatus()

-- 绑定Java类
local bindClass = luajava.bindClass
local SimpleMenuPopupWindow = bindClass "com.difierline.lua.material.menu.SimpleMenuPopupWindow"
local LinearLayoutManager = bindClass "androidx.recyclerview.widget.LinearLayoutManager"
local RecyclerView = bindClass "androidx.recyclerview.widget.RecyclerView"
local AppCompatDelegate = bindClass "androidx.appcompat.app.AppCompatDelegate"
local Intent = bindClass "android.content.Intent"
local ColorPickerDialogBuilder = bindClass "com.difierline.lua.colorpicker.builder.ColorPickerDialogBuilder"
local ColorPickerView = bindClass "com.difierline.lua.colorpicker.ColorPickerView"

-- 加载工具库
local MaterialBlurDialogBuilder = require "dialogs.MaterialBlurDialogBuilder"
local ActivityUtil = require "utils.ActivityUtil"
local PluginsUtil = require "activities.plugins.PluginsUtil"
local FileUtil = require "utils.FileUtil"
local PathUtil = require "utils.PathUtil"
local Utils = require "utils.Utils"
SettingsLayUtil = require "activities.settings.SettingsLayUtil"
import "activities.settings.settings"

-- 常量配置
local TEXT_FORMATS = { ttf = true, otf = true }
local adapter -- 适配器对象

-- 初始化插件系统
PluginsUtil.clearOpenedPluginPaths()
PluginsUtil.setActivityName("SettingsActivity")

local function restartApp()
  local i = activity.getPackageManager()
  .getLaunchIntentForPackage(activity.getPackageName())
  i.addFlags(Intent.FLAG_ACTIVITY_CLEAR_TASK)
  i.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
  activity.startActivity(i)
  bindClass "java.lang.System".exit(0)
end

local function restartDialog()
  MaterialBlurDialogBuilder(activity)
  .setTitle(res.string.tip)
  .setMessage(res.string.restartapp_tip)
  .setPositiveButton(res.string.ok, function()
    restartApp()
  end)
  .setNegativeButton(res.string.no, nil)
  .show()
end

-- ===== 辅助函数 =====
-- 创建简单弹出菜单
local function Simple_Pop(view, key, items, width, callback)
  menu = SimpleMenuPopupWindow(activity)
  .setOnItemClickListener(function(i)
    -- 更新视图文本
    pcall(function()
      view.getChildAt(1).getChildAt(1).setText(items[i + 1])
    end)
    pcall(function()
      view.getChildAt(0).getChildAt(1).setText(items[i + 1])
    end)

    -- 设置选中项并保存
    menu.setSelectedIndex(i)
    activity.setSharedData(key, i + 1)
    adapter.notifyDataSetChanged()

    -- 执行回调
    if callback then callback(i + 1) end
  end)
  .setEntries(items)
  .show(view.parent, view.parent.parent, width)
  .setSelectedIndex(activity.getSharedData(key) - 1 or 0)
end

-- 自定义输入对话框
local function custom(title, message)
  MaterialBlurDialogBuilder(activity)
  .setTitle(title)
  .setMessage(message)
  .setView(loadlayout("layouts.dialog_slider"))
  .setPositiveButton(res.string.ok, function()
    local values = luajava.astable(slider.getValues())
    local minValue = tostring(values[1])
    local maxValue = tostring(values[2])
    activity.setSharedData("value_min", minValue)
    activity.setSharedData("value_max", maxValue)
    if adapter then adapter.notifyDataSetChanged() end
  end)
  .setNegativeButton(res.string.no, nil)
  .show()
  local minValue = tonumber(activity.getSharedData("value_min"))
  local maxValue = tonumber(activity.getSharedData("value_max"))
  local newValues = ArrayList()
  newValues.add(float(minValue))
  newValues.add(float(maxValue))
  slider.setValues(newValues)
  .setLabelBehavior(3)
end

-- 列表项点击处理
local function onItemClick(view, views, key, data)
  local action = data.action

  if key == "theme_light_dark" then
    Simple_Pop(view, key, data.items, dp2px(70), function(i)
      AppCompatDelegate.setDefaultNightMode(
      i == 1 and -1 or -- 跟随系统
      i == 2 and 2 or -- 深色模式
      i == 3 and 1 -- 浅色模式
      )
    end)
   elseif
    key == "eyedropper_variant"
    or key == "collapse_toolbar"
    or key == "show_item_icon"
    or key == "offline_mode" then
    restartDialog()
   elseif
    key == "fragment_animation"
    or key == "icon_load_mode" then
    Simple_Pop(view, key, data.items, dp2px(62), function()
      restartDialog()
    end)
   elseif
    key == "zoom_range" then
    custom(res.string.zoom_range, res.string.zoom_range_tip)
   elseif
    key == "class_name_highlight"
    or key == "keyword_highlight"
    or key == "function_name_highlight"
    or key == "local_variable_highlight" then
    ColorPickerDialogBuilder.with(activity)
    .setTitle(res.string.colorpicker)
    .initialColor(activity.getSharedData(key) or 0xFF2196F3)
    .showColorEdit(true)
    .showColorPreview(true)
    .showAlphaSlider(true)
    .wheelType(ColorPickerView.WHEEL_TYPE.FLOWER)
    .density(10)
    .setPositiveButton(res.string.ok, function(dialog, selectedColor, allColors)
      activity.setSharedData(key, selectedColor)
      adapter.notifyDataSetChanged()
    end)
    .setNegativeButton(res.string.no, nil)
    .build()
    .show()
   elseif key == "plugins_manager" then
    ActivityUtil.new("plugins")
   elseif key == "about" then
    ActivityUtil.new("about")
   elseif key == "custom_symbol_bar" then
    ActivityUtil.new("symbol")
   elseif key == "custom_control_class" then
    ActivityUtil.new("control")
   elseif key == "edit_config" then
    ActivityUtil.new("editconfig")
   elseif key == "theme_color" then
    Simple_Pop(view, key, data.items, dp2px(62), function(i)
      switch i
       case 3
        ColorPickerDialogBuilder.with(activity)
        .setTitle(res.string.colorpicker)
        .initialColor(activity.getSharedData("colorpicker") or 0xFF2196F3)
        .showColorEdit(true)
        .showColorPreview(true)
        .showAlphaSlider(false)
        .wheelType(ColorPickerView.WHEEL_TYPE.FLOWER)
        .density(10)
        .setPositiveButton(res.string.ok, function(dialog, selectedColor, allColors)
          activity.setSharedData("colorpicker", selectedColor)
          restartDialog()
        end)
        .setNegativeButton(res.string.no, function()
          activity.setSharedData(key, 1)
          adapter.notifyDataSetChanged()
        end)
        .setOnCancelListener(function(dialog)
          activity.setSharedData(key, 1)
          adapter.notifyDataSetChanged()
        end)
        .build()
        .show()
      end
    end)
   elseif key == "font_path" then
    Simple_Pop(view, key, data.items, dp2px(62), function(i)
      switch i
       case 1
        activity.setSharedData("font_path2", activity.getLuaDir("res/fonts/jetbrains_mono.ttf"))
       case 2
        activity.setSharedData("font_path2", activity.getLuaDir("res/fonts/fira_code.ttf"))
       case 3
        activity.startActivityForResult(
        Intent(Intent.ACTION_GET_CONTENT)
        .setType("*/*")
        .addCategory(Intent.CATEGORY_OPENABLE),
        100
        )
      end
    end)
  end

  -- 通知插件事件
  PluginsUtil.callElevents("onItemClick", views, key, data)
end

-- ===== 主执行逻辑 =====
-- 设置界面
activity
.setContentView(loadlayout("layouts.activity_settings"))
.setSupportActionBar(toolbar)
.getSupportActionBar()
.setDisplayHomeAsUpEnabled(true)

-- 添加插件设置项
for index, content in ipairs(settings) do
  if content.title == res.string.plugins then
    local pluginItems = {}
    PluginsUtil.callElevents("onLoadItemsList", pluginItems)

    for i, pluginItem in ipairs(pluginItems) do
      table.insert(settings, index + i, pluginItem)
    end
    break
  end
end

-- 初始化RecyclerView
adapter = SettingsLayUtil.newAdapter(settings, onItemClick)
recycler_view
.setAdapter(adapter)
.setLayoutManager(LinearLayoutManager(activity))

recycler_view.addItemDecoration(RecyclerView.ItemDecoration {
  getItemOffsets = function(outRect, view, parent, state)
    Utils.modifyItemOffsets2(outRect, view, parent, adapter, 12)
  end
})

function onCreateOptionsMenu(menu)
  menu.add(res.string.restore_default_settings)
  .onMenuItemClick = function()
    MaterialBlurDialogBuilder(activity)
    .setTitle(res.string.tip)
    .setMessage(res.string.restore_default_settings_tip)
    .setPositiveButton(res.string.ok, function()
      activity.clearSharedData()
      activity.setSharedData("welcome", true)
      restartApp()
    end)
    .setNegativeButton(res.string.no, nil)
    .show()
  end
end

-- 菜单项选择
function onOptionsItemSelected(item)
  if item.getItemId() == android.R.id.home then
    activity.finish()
    return true
  end
end

-- 处理返回结果
function onActivityResult(requestCode, resultCode, intent)
  if not intent then return end

  local uri = intent.data
  if requestCode == 100 then
    local path = Utils.uri2path(uri)
    if not path then return end

    local ext = FileUtil.getFileExtension(path)
    if not TEXT_FORMATS[ext] then
      MyToast(res.string.please_select_a_font_films)
      activity.setSharedData("font_path", 1)
      adapter.notifyDataSetChanged()
      return
    end

    -- 复制字体文件到安全位置
    local font_path = PathUtil.crash_path .. "/" .. FileUtil.getName(path)
    FileUtil.copy(path, font_path)
    activity.setSharedData("font_path2", font_path)
    MyToast(res.string.setup_succeeded)
    adapter.notifyDataSetChanged()

  end
end

-- 清理资源
function onDestroy()
  luajava.clear()
  collectgarbage("collect")
  collectgarbage("step")
end