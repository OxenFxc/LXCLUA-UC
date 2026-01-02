require "env"
setStatus()

is_sora = activity.getSharedData("is_sora")
if not is_sora then
  activity.finish()
  return
end

-- 绑定Java类
local bindClass = luajava.bindClass
local LinearLayoutManager = bindClass "androidx.recyclerview.widget.LinearLayoutManager"
local RecyclerView = bindClass "androidx.recyclerview.widget.RecyclerView"
local ColorPickerDialogBuilder = bindClass "com.difierline.lua.colorpicker.builder.ColorPickerDialogBuilder"
local ColorPickerView = bindClass "com.difierline.lua.colorpicker.ColorPickerView"
local LuaLanguage = bindClass "com.yan.luaeditor.lualanguage.LuaLanguage"
local EditorColorScheme = bindClass "io.github.rosemoe.sora.widget.schemes.EditorColorScheme"
local ValueAnimator = bindClass "android.animation.ValueAnimator"
local Utils = require "utils.Utils"
local EditView = require "activities.editor.EditView"
SettingsLayUtil = require "activities.settings.SettingsLayUtil"
local editconfig = require "activities.editconfig.editconfig"

-- 常量配置
local adapter -- 适配器对象
local status = true
local scheme = EditorColorScheme()

-- 列表项点击处理
local function onItemClick(view, views, key, data)
  local action = data.action
  if key == "hex_color_highlight" then
    editor.setEditorLanguage(LuaLanguage({}, {}, { "android.widget.TextView" }).setHexColorHighlightEnabled(activity.getSharedData("hex_color_highlight")))
    .setHighlightHexColorsEnabled(activity.getSharedData("hex_color_highlight"))
   elseif key == "editor_showBlankChars" then
    editor.setNonPrintablePaintingFlags(activity.getSharedData("editor_showBlankChars") and (editor.FLAG_DRAW_WHITESPACE_IN_SELECTION + editor.FLAG_DRAW_WHITESPACE_LEADING + editor.FLAG_DRAW_LINE_SEPARATOR) or 0)
   elseif key == "class_name_highlight"
    or key == "keyword_highlight"
    or key == "function_name_highlight"
    or key == "dividing_line_color"
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
      switch key
       case "class_name_highlight"
        editor.setColorScheme(scheme.setColor(EditorColorScheme.CLASS_NAME, activity.getSharedData("class_name_highlight") or 0xFF6E81D9))
       case "local_variable_highlight"
        editor.setColorScheme(scheme.setColor(EditorColorScheme.LOCAL_VARIABLE, activity.getSharedData("local_variable_highlight") or 0xFFAAAA88))
       case "keyword_highlight"
        editor.setColorScheme(scheme.setColor(EditorColorScheme.KEYWORD, activity.getSharedData("keyword_highlight") or 0xFFFF565E))
       case "function_name_highlight"
        editor.setColorScheme(scheme.setColor(EditorColorScheme.FUNCTION_NAME, activity.getSharedData("function_name_highlight") or 0xFF2196F3))
       case "dividing_line_color"
        editor.setColorScheme(scheme.setColor(EditorColorScheme.LINE_DIVIDER, activity.getSharedData("dividing_line_color") or 0xEEEEEEEE))
      end
    end)
    .setNegativeButton(res.string.no, nil)
    .build()
    .show()
  end
end

-- ===== 主执行逻辑 =====
-- 设置界面
activity
.setContentView(loadlayout("layouts.activity_editconfig"))
.setSupportActionBar(toolbar)
.getSupportActionBar()
.setDisplayHomeAsUpEnabled(true)

-- 初始化RecyclerView
adapter = SettingsLayUtil.newAdapter(editconfig, onItemClick)
recycler_view
.setAdapter(adapter)
.setLayoutManager(LinearLayoutManager(activity))

recycler_view.addItemDecoration(RecyclerView.ItemDecoration {
  getItemOffsets = function(outRect, view, parent, state)
    Utils.modifyItemOffsets2(outRect, view, parent, adapter, 12)
  end
})

scheme.setColor(EditorColorScheme.WHOLE_BACKGROUND, isDark() and 0xFF000000 or 0xFFFFFFFF)
scheme.setColor(EditorColorScheme.LOCAL_VARIABLE, activity.getSharedData("local_variable_highlight") or 0xFFAAAA88)
scheme.setColor(EditorColorScheme.CLASS_NAME, activity.getSharedData("class_name_highlight") or 0xFF6E81D9)
scheme.setColor(EditorColorScheme.KEYWORD, activity.getSharedData("keyword_highlight") or 0xFFFF565E)
scheme.setColor(EditorColorScheme.FUNCTION_NAME, activity.getSharedData("function_name_highlight") or 0xFF2196F3)
scheme.setColor(EditorColorScheme.LINE_NUMBER_BACKGROUND, isDark() and 0xFF000000 or 0xFFFFFFFF)
scheme.setColor(EditorColorScheme.LINE_NUMBER, Colors.colorOnBackground)

editor.setColorScheme(scheme)
.setEditorLanguage(LuaLanguage({}, {}, { "android.widget.TextView" }).setHexColorHighlightEnabled(activity.getSharedData("hex_color_highlight") or false))
.setHighlightHexColorsEnabled(activity.getSharedData("hex_color_highlight") or false)
.setEditable(false)
.setEnableLongPressSelection(false)
.setEnableDoubleTapSelection(false)
--.setLineNumberEnabled(false)
.setTextSizePx(40)
.setNonPrintablePaintingFlags(activity.getSharedData("editor_showBlankChars") and (editor.FLAG_DRAW_WHITESPACE_IN_SELECTION + editor.FLAG_DRAW_WHITESPACE_LEADING + editor.FLAG_DRAW_LINE_SEPARATOR) or 0)

EditView.EditorFont()

-- view：任意 View 对象
-- h   ：高度（单位 px）
local function setHeight(view, h)
  local lp = view.getLayoutParams()
  if lp then
    lp.height = h
    view.setLayoutParams(lp)
  end
end

expand.post{
  run = function(v)
    local h = expand.getHeight()
    local h3 = editor.getHeight()
    local h2 = h + 2 * dp2px(8)
    local animator -- 用于存储当前动画对象

    -- 动画更新监听器
    local animUpdate = {
      onAnimationUpdate = function(animation)
        local value = animation.getAnimatedValue()
        setHeight(editor.parent.parent, value)
      end
    }

    expand.onClick = function(v)
      -- 取消当前正在进行的动画
      if animator and animator.isRunning() then
        animator.cancel()
      end

      -- 计算目标高度和方向
      local startH = editor.getHeight()
      local endH = status and h2 or h3

      -- 创建新的动画
      animator = ValueAnimator.ofInt({startH, endH})
      animator.setDuration(200)
      animator.addUpdateListener(animUpdate)
      animator.addListener({
        onAnimationEnd = function()
          status = not status
          v.setIconResource(status and MDC_R.drawable.ic_expand_more_22px
          or MDC_R.drawable.ic_expand_less_22px)
        end
      })

      -- 启动动画
      animator.start()
    end
  end
}

-- ===== 生命周期函数 =====
-- 菜单项选择
function onOptionsItemSelected(item)
  if item.getItemId() == android.R.id.home then
    activity.finish()
    return true
  end
end

-- 清理资源
function onDestroy()
  adapter.release()
  luajava.clear()
  collectgarbage("collect")
  collectgarbage("step")
end