require "env"
local bindClass = luajava.bindClass
luapath, luaproject = ...
if not luaproject then
  luaproject = luajava.luaextdir
end

local TypedValue = bindClass "android.util.TypedValue"
local MotionEvent = bindClass "android.view.MotionEvent"
local ArrayExpandableListAdapter = bindClass "android.widget.ArrayExpandableListAdapter"
local ExpandableListView = bindClass "android.widget.ExpandableListView"
local LuaMaterialDialog = bindClass "com.difierline.lua.luaappx.dialogs.LuaMaterialDialog"
local View = bindClass "android.view.View"
local File = bindClass "java.io.File"
local MyBottomSheetDialog = require "dialogs.MyBottomSheetDialog"
local IconDrawable = require "utils.IconDrawable"
local MaterialBlurDialogBuilder = require "dialogs.MaterialBlurDialogBuilder"
FileUtil = require "utils.FileUtil"
require "activities.layouthelper.classes"
loadlayout2 = require "activities.layouthelper.loadlayout2"
layoutData = require "activities.layouthelper.layoutData"
method = require "activities.layouthelper.LayoutHelperActivity$method"

local layout_main = {
  LinearLayoutCompat,
  orientation = "vertical",
  layout_width = "match_parent",
  layout_height = "match_parent",
}

luadir = luapath:gsub("/[^/]+$", "")
package.path = package.path .. ";" .. luadir .. "/?.lua;"
if luapath and luapath:find("%.aly$") then
  local f = io.open(luapath)
  local s = f:read("*a")
  f:close()
  xpcall(function()
    layout_main = assert(loadstring("return " .. s))()
  end,
  function(e)
    activity.result({res.string.editing_this_layout_is_not_supported .. "." .. e})
    activity.finish()
  end)
 else
  activity.result({res.string.editing_this_layout_is_not_supported })
  activity.finish()
end

activity
.setContentView(loadlayout("layouts.activity_layouthelper"))
.setSupportActionBar(toolbar)
.getSupportActionBar()
.setDisplayHomeAsUpEnabled(true)
.setTitle(FileUtil.getName(luapath))

activity.window.setStatusBarColor(Colors.colorSurfaceContainer)
activity.decorView.setSystemUiVisibility(View.SYSTEM_UI_FLAG_LIGHT_STATUS_BAR | View.SYSTEM_UI_FLAG_HIDE_NAVIGATION)

curr = nil
xpcall(function()
  root.addView(loadlayout2(layout_main, {}))
end,
function(e)
  activity.result({res.string.editing_this_layout_is_not_supported .. "." .. e})
  activity.finish()
end)

--属性列表对话框
fd_dlg = MyBottomSheetDialog(activity).setView("layouts.dialog_item")
fd_list, fd_title = mDialogListView, mDialogTitle

--属性选择列表
checks = {}
checks.layout_width = {"match_parent", "wrap_content", "Fixed size..."}
checks.layout_height = {"match_parent", "wrap_content", "Fixed size..."}
checks.ellipsize = {"start", "end", "middle", "marquee"}
checks.singleLine = {"true", "false"}
checks.fitsSystemWindows = {"true", "false"}
checks.orientation = {"vertical", "horizontal"}
checks.gravity = {"left", "top", "right", "bottom", "start", "center", "end", "bottom|end", "end|center", "left|center", "top|center", "bottom|center"}
checks.layout_gravity = {"left", "top", "right", "bottom", "start", "center", "end", "bottom|end", "end|center", "left|center", "top|center", "bottom|center"}
checks.scaleType = {
  "matrix",
  "fitXY",
  "fitStart",
  "fitCenter",
  "fitEnd",
  "center",
  "centerCrop",
  "centerInside"
}

function addDir(out, dir, f)
  local ls = f.listFiles()
  for n = 0, #ls - 1 do
    local name = ls[n].getName()
    if ls[n].isDirectory() then
      addDir(out, dir .. name .. "/", ls[n])
     elseif name:find("%.j?pn?g$") then
      table.insert(out, dir .. name)
    end
  end
end

local function checkid()
  local cs = {}
  local parent = currView.Parent.Tag
  for k, v in ipairs(parent) do
    if v == curr then
      break
    end
    if type(v) == "table" and v.id then
      table.insert(cs, v.id)
    end
  end
  return cs
end

checks.src = function()
  local src = {}
  addDir(src, "", File(luadir))
  return src
end

fd_list.onItemClick = function(l, v, p, i)
  fd_dlg.dismiss()
  local fd = tostring(v.Text)
  if string.find(fd, " = ")
    fd = fd:gsub("% = .*", "")
  end
  if checks[fd] then
    if type(checks[fd]) == "table" then
      check_title.setText(fd)
      method.adapter(check_list, checks[fd])
      check_dlg.show()
     else
      check_title.setText(fd)
      method.adapter(check_list, checks[fd](fd))
      check_dlg.show()
    end
   else
    func[fd]()
  end
end

--子视图列表对话框
cd_dlg = MyBottomSheetDialog(activity).setView("layouts.dialog_item")
cd_list, cd_title = mDialogListView, mDialogTitle
cd_list.onItemClick = function(l, v, p, i)
  getCurr(chids[p])
  cd_dlg.dismiss()
end

--可选属性对话框
check_dlg = MyBottomSheetDialog(activity).setView("layouts.dialog_item")
check_list, check_title = mDialogListView, mDialogTitle
check_list.onItemClick = function(l, v, p, i)
  local v = tostring(v.text)
  if #v == 0 or v == "none" then
    v = nil
   elseif v == "Fixed size..."
    check_dlg.dismiss()
    func[check_title.Text]()
    return
  end
  local fld = check_title.Text
  local old = curr[tostring(fld)]
  curr[tostring(fld)] = v
  check_dlg.dismiss()
  local s, l = pcall(loadlayout2, layout_main, {})
  if s then
    method.showlayout(l)
   else
    curr[tostring(fld)] = old
    onError("Error", l)
  end
end

func = {}
setmetatable(func, {__index = function(t, k)
    return function()
      sfd_dlg.Title = k--tostring(currView.Class.getSimpleName())
      --sfd_dlg.Message=k
      fld.Text = curr[k] or ""
      sfd_dlg.show()
    end
  end
})
func[res.string.add] = function()
  add_title.setText(tostring(currView.Class.getSimpleName()))
  for n = 0, #ns - 1 do
    if n ~= i then
      el.collapseGroup(n)
    end
  end
  add_dlg.show()
end

func[res.string.delete] = function()
  local gp = currView.Parent.Tag
  if gp == nil then
    MyToast(res.string.top_controls_may_not_be_deleted)
    return
  end
  for k, v in ipairs(gp) do
    if v == curr then
      table.remove(gp, k)
      break
    end
  end
  method.showlayout(loadlayout2(layout_main, {}))
end

func[res.string.parent_control] = function()
  local p = currView.Parent
  if p.Tag == nil then
    MyToast(res.string.already_a_top_control)
   else
    getCurr(p)
  end
end

chids = {}
func[res.string.child_control] = function()
  chids = {}
  local arr = {}
  for n = 0, currView.ChildCount - 1 do
    local chid = currView.getChildAt(n)
    chids[n] = chid
    table.insert(arr, chid.Class.getSimpleName())
  end
  cd_title.setText(tostring(currView.Class.getSimpleName()))
  method.adapter(cd_list, arr)
  cd_dlg.show()
end

--添加视图对话框
add_dlg = MyBottomSheetDialog(activity).setView("layouts.dialog_expandablelist")
el, add_title = mDialogListView, mDialogTitle

local mAdapter = ArrayExpandableListAdapter(activity)
local chinese_name_of_control = activity.getSharedData("chinese_name_of_control")

for k, v in ipairs(ns) do
  for i = 1, #wds2[k] do
    wds2[k][i] = wds[k][i] .. (chinese_name_of_control and " - " .. wds2[k][i] or "")
  end

  ns[k] = ns[k] .. (chinese_name_of_control and " - " .. ns2[k] or "")
  mAdapter.add(ns[k], wds2[k])
end

el.setAdapter(mAdapter)

el.onChildClick = function(l, v, g, c)
  local w = {_G[wds[g + 1][c + 1]]}
  table.insert(curr, w)
  local s, l = pcall(loadlayout2, layout_main, {})
  if s then
    method.showlayout(l)
   else
    table.remove(curr)
    onError("Error", l)
  end
  add_dlg.dismiss()
end

local function ok()
  local v = tostring(fld.Text)
  if #v == 0 then
    v = nil
  end
  local fld = sfd_dlg.Title
  local old = curr[tostring(fld)]
  curr[tostring(fld)] = v
  local s, l = pcall(loadlayout2, layout_main, {})
  if s then
    method.showlayout(l)
   else
    curr[tostring(fld)] = old
    onError("Error", l)
  end
end

local function none()
  local key = sfd_dlg.title
  local old = curr[key]
  curr[key] = nil
  local s, l = pcall(loadlayout2, layout_main, {})
  if s then
    method.showlayout(l)
   else
    curr[key] = old
    onError("Error", l)
  end
end

--输入属性对话框
local ids = {}
sfd_dlg = LuaMaterialDialog(activity)
sfd_dlg.setView(loadlayout("layouts.dialog_fileinput", ids))
sfd_dlg.setPositiveButton(res.string.ok, ok)
sfd_dlg.setNegativeButton(res.string.no, nil)
sfd_dlg.setNeutralButton(res.string.none, none)
fld = ids.content.getEditText()

local function save()
  MaterialBlurDialogBuilder(activity)
  .setTitle(res.string.save)
  .setMessage((res.string.layouthelper_save_tip):format(luapath))
  .setPositiveButton(res.string.ok, function()
    xpcall(function()
      FileUtil.write(luapath, method.dumplayout(layout_main))
      activity.result({res.string.saved_successfully})
      activity.finish()
      end,function(e)
      onError("Error", e)
    end)
  end)
  .setNegativeButton(res.string.exit, function()
    activity.finish()
  end)
  .show()
end

function onCreateOptionsMenu(menu)
  menu.add(res.string.save)
  .setShowAsAction(2)
  .setIcon(IconDrawable("ic_content_save_outline", Colors.colorOnSurfaceVariant))
  .onMenuItemClick = function()
    save()
  end
end

function onOptionsItemSelected(item)
  local id = item.getItemId()
  if id == android.R.id.home then
    save()
  end
end

function onKeyDown(e)
  if e == 4 then
    save()
    return true
  end
end