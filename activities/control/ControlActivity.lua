require "env"

-- 绑定Java类
local bindClass = luajava.bindClass
local View = bindClass "android.view.View"

local SharedPrefUtil = require "utils.SharedPrefUtil"
local IconDrawable = require "utils.IconDrawable"
local json = require "json"
EditView = require "activities.editor.EditView"

local classes_table = SharedPrefUtil.getTable("classes_table") or
{
  "android.widget.Button"
}

local function dump(val, indent)
  indent = indent or 0
  local prefix = string.rep("  ", indent)

  if type(val) == "table" then
    local pieces = {}
    table.insert(pieces, "{")

    -- 先打印数组部分，保持顺序
    for i, v in ipairs(val) do
      table.insert(pieces, prefix .. "  " .. dump(v, indent + 1) .. ",")
    end

    -- 再打印哈希部分（键值对）
    for k, v in pairs(val) do
      -- 跳过已经在 ipairs 里处理过的数组键
      if type(k) ~= "number" or k < 1 or k > #val or math.floor(k) ~= k then
        table.insert(pieces,
        prefix .. "  " .. "[" .. dump(k, 0) .. "] = " .. dump(v, indent + 1) .. ",")
      end
    end

    table.insert(pieces, prefix .. "}")
    return table.concat(pieces, "\n")
   else
    return type(val) == "string" and string.format("%q", val) or tostring(val)
  end
end

local function is_table_literal(src)
  -- 去掉首尾的空白
  src = src:match('^%s*(.-)%s*$')
  if not src then return false, 'empty input' end

  -- 初步包裹层：必须是 { ... }
  if not src:match('^%{.*%}$') then
    return false, 'outer layer must be table'
  end

  -- 为了用 load 做语法级检查，拼一段 return 语句
  local chunk = 'return ' .. src
  local f, err = load(chunk, '=(table_check)', 't')
  if not f then
    return false, 'syntax error: ' .. err
  end

  -- 运行它，拿到真正的值
  local ok, value = pcall(f)
  if not ok then
    return false, 'run error: ' .. value
  end

  -- 递归检查值类型
  local function check(v)
    local t = type(v)
    if t == 'table' then
      for k, v2 in pairs(v) do
        local kt = type(k)
        if kt ~= 'string' and kt ~= 'number'
          and kt ~= 'boolean' and k ~= nil then
          return false, 'invalid key type: ' .. kt
        end
        local ok2, err2 = check(v2)
        if not ok2 then return false, err2 end
      end
      return true
     elseif t == 'string' or t == 'number' or t == 'boolean' or v == nil then
      return true
     else
      return false, 'invalid value type: ' .. t
    end
  end

  return check(value)
end

-- 设置界面
activity
.setContentView(loadlayout("layouts.activity_control"))
.setSupportActionBar(toolbar)
.getSupportActionBar()
.setDisplayHomeAsUpEnabled(true)

-- 设置状态栏
activity.window.setStatusBarColor(Colors.colorSurfaceContainer)
activity.decorView.setSystemUiVisibility(View.SYSTEM_UI_FLAG_LIGHT_STATUS_BAR | View.SYSTEM_UI_FLAG_HIDE_NAVIGATION)

-- 初始化编辑器
task(1, function()
  EditView
  .EditorScheme()
  .EditorProperties()
  .EditorLanguageAsync()
  .EditorFont()
  editor.setText(tostring(dump(classes_table)))

end)

-- 创建菜单
function onCreateOptionsMenu(menu)
  menu.add(res.string.save)
  .setShowAsAction(2)
  .setIcon(IconDrawable("ic_content_save_outline", Colors.colorOnSurfaceVariant))
  .onMenuItemClick = function()
    local text = editor.getText().toString()
    if text:match("^%s*$") then
      MyToast(res.string.empty_code)
      return
    end

    local chunk, err = load("return " .. text, "classes_table", "t", _ENV)
    if not chunk then
      MyToast(res.string.syntax_error .. "." .. err)
      return
    end

    local ok, result = pcall(chunk)
    if not ok then
      MyToast(res.string.runtime_error .. "." .. tostring(result))
      return
    end

    local ok, error = is_table_literal(text)
    if not ok then
      MyToast(tostring(error))
      return
    end

    SharedPrefUtil.set("classes_table", result)
    MyToast(res.string.saved_successfully)
  end
end


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
  EditView.release()
  luajava.clear()
  collectgarbage("collect")
  collectgarbage("step")
end