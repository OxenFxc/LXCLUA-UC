local _M = {}
local bindClass = luajava.bindClass
local Paint = bindClass "android.graphics.Paint"
local MotionEvent = bindClass "android.view.MotionEvent"
local System = bindClass "java.lang.System"
local GradientDrawable = bindClass "android.graphics.drawable.GradientDrawable"
local TypedValue = bindClass "android.util.TypedValue"
local ArrayAdapter = bindClass "android.widget.ArrayAdapter"
local ArrayList = bindClass "java.util.ArrayList"
local ArrayListAdapter = bindClass "android.widget.ArrayListAdapter"
local MaterialBlurDialogBuilder = require "dialogs.MaterialBlurDialogBuilder"
local FileUtil = require "utils.FileUtil"

function _M.showlayout(layout)
  root.removeAllViews()
  root.addView(layout)
  return _M
end

function _M.dumplayout(t, indent, isRoot)
  indent = indent or ""
  local nextIndent = indent .. "  " -- 每次多两个空格
  local ret = {}

  -- 对于根元素，不使用缩进
  local currentIndent = isRoot and "" or indent

  table.insert(ret, currentIndent .. "{\n")

  -- 检查是否为视图表（第一个元素是类）
  if type(t[1]) == "userdata" and t[1].getSimpleName then
    table.insert(ret, nextIndent .. tostring(t[1].getSimpleName()) .. ";\n")
   elseif type(t[1]) == "string" then
    -- 对于字符串数组等非视图表，直接输出第一个元素
    table.insert(ret, nextIndent .. "\"" .. tostring(t[1]) .. "\",\n")
   elseif type(t[1]) == "table" then
    -- 对于嵌套表，递归处理
    table.insert(ret, _M.dumplayout(t[1], nextIndent, false))
   else
    -- 其他情况也直接输出
    table.insert(ret, nextIndent .. tostring(t[1]) .. ",\n")
  end

  -- 处理键值对
  local count = 0
  for k, v in pairs(t) do
    if type(k) == "string" then
      count = count + 1
      if type(v) == "table" then
        table.insert(ret, nextIndent .. k .. " = " .. _M.dumplayout(v, nextIndent, false))
       elseif type(v) == "string" then
        if v:find("[\"\'\r\n]") then
          table.insert(ret, nextIndent .. k .. " = [==[" .. v .. "]==];\n")
         else
          table.insert(ret, nextIndent .. k .. " = \"" .. v .. "\";\n")
        end
       else
        table.insert(ret, nextIndent .. k .. " = " .. tostring(v) .. ";\n")
      end
    end
  end

  -- 处理子 table（数组部分，跳过第一个元素）
  for i = 2, #t do
    local v = t[i]
    if type(v) == "table" then
      table.insert(ret, _M.dumplayout(v, nextIndent, false))
     elseif type(v) == "string" then
      table.insert(ret, nextIndent .. "\"" .. tostring(v) .. "\",\n")
     else
      table.insert(ret, nextIndent .. tostring(v) .. ",\n")
    end
  end

  table.insert(ret, currentIndent .. "};\n")
  return table.concat(ret)
end

local function getDefaultLayoutDrawable()
  return GradientDrawable()
  .setStroke(dp2px(1.5), Colors.colorOutline, dp2px(4), dp2px(5))
  .setGradientRadius(700)
  .setGradientType(1)
end
_M.getDefaultLayoutDrawable = getDefaultLayoutDrawable

local function getSelectLayoutDrawable()
  return GradientDrawable()
  .setStroke(dp2px(1.5), Colors.colorPrimary, 0, 0)
  .setGradientRadius(700)
  .setGradientType(1)
end

local function getSpannableString(key, str)
  if bindClass "android.os.Build".VERSION.SDK_INT >= 28
    local Spannable = bindClass "android.text.Spannable"
    local ForegroundColorSpan = bindClass "android.text.style.ForegroundColorSpan"
    local SpannableString = bindClass "android.text.SpannableString"
    local Spanned = bindClass "android.text.Spanned"
    local s = key .. " = " .. tostring(str)
    local start_len = utf8.len(key .. " = ")
    local end_len = utf8.len(s)
    local spanned = Spanned.SPAN_EXCLUSIVE_EXCLUSIVE
    local spannableString = SpannableString(s)
    spannableString.setSpan(ForegroundColorSpan(Colors.colorPrimary), start_len, end_len, spanned)
    return spannableString
   else
    return key .. " = " .. tostring(str)
  end
end

local function getAbs(a, b, c)
  return (a < b and b) or (a > c and c) or (a)
end

local function toWH(n, t)
  return string.format("%s%s",
  tointeger(n / (t == true and activity.width or activity.height) * 100), (t == true and "%w" or "%h"))
end

local dm = activity.getResources().getDisplayMetrics()
local function dp(n)
  return TypedValue.applyDimension(1, n, dm)
end

local function to(n)
  return string.format("%ddp", n // dp(1))
end

local function isView(v, list)
  for _, cls in ipairs(list) do
    if luajava.instanceof(v, cls) then
      return true
    end
  end
  return false
end

function _M.adapter(id, list)
  id.setAdapter(ArrayListAdapter(activity, String(list)))
end

function getCurr(v)
  curr = v.Tag
  currView = v
  fd_title.setText(tostring(v.Class.getSimpleName()))
  if luajava.instanceof(v, GridLayout) then
    _M.adapter(fd_list, fds_grid)
   elseif isView(v, LINEARLAYOUT_COMPAT) then
    _M.adapter(fd_list, fds_linear)
   elseif isView(v, CAN_HAVE_CHILDREN) then
    _M.adapter(fd_list, fds_group)
   elseif isView(v, TEXTVIEW_COMPAT) then
    _M.adapter(fd_list, fds_text)
   elseif isView(v, IMAGEVIEW_COMPAT) then
    _M.adapter(fd_list, fds_image)
   else
    _M.adapter(fd_list, fds_view)
  end
  if luajava.instanceof(v.Parent, LinearLayout) then
    fd_list.getAdapter().add("layout_weight")
   elseif luajava.instanceof(v.Parent, AbsoluteLayout) then
    fd_list.getAdapter().insert(5, "layout_x")
    fd_list.getAdapter().insert(6, "layout_y")
   elseif luajava.instanceof(v.Parent, RelativeLayout) then
    local adp = fd_list.getAdapter()
    for k, v in ipairs(relative) do
      adp.add(v)
    end
  end

  local adapter = fd_list.adapter
  local put_position = 4
  local unknow_fd = table.clone(curr)

  for k, v in pairs(unknow_fd) do
    if tonumber(k) then
      unknow_fd[k] = 0
    end
  end

  for i = 0, adapter.count - 1 do
    local key = adapter.getItem(i)
    if key == "id" then
      put_position = i
    end
    if curr[key] then
      adapter.remove(i)
      adapter.insert(put_position, getSpannableString(key, curr[key]))
      unknow_fd[key] = nil
    end
  end

  for k, v in pairs(unknow_fd) do
    if not tonumber(k) then
      adapter.insert(put_position, getSpannableString(k, v))
    end
  end
  fd_dlg.show()
end

local lastX = 0
local lastY = 0
local vx = 0
local vy = 0
local vw = 0
local vh = 0
local zoomX = false
local zoomY = false

local function move(v, e)
  curr = v.tag
  currView = v

  if e.getAction() == MotionEvent.ACTION_DOWN then
    v.setForeground(getSelectLayoutDrawable())

    -- 只保留点击检测
    lastY = e.getRawY()
    lastX = e.getRawX()

   elseif e.getAction() == MotionEvent.ACTION_UP then
    v.setForeground(getDefaultLayoutDrawable())

    local rx = e.getRawX()
    local ry = e.getRawY()

    -- 检测是否为点击（移动距离很小）
    if (rx - lastX) ^ 2 < 100 and (ry - lastY) ^ 2 < 100 then
      getCurr(v)
    end
  end

  return true
end

function _M.onTouch(v, e)
  move(v, e)
  return true
end

return _M