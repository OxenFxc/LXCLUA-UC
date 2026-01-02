require "env"
post_id = ...

-- 全局变量
local file_path = ""
local forum_id
local price = 0
local forum_ids = {} -- 存储论坛ID列表

-- 绑定Java类
local bindClass = luajava.bindClass
local View = bindClass "android.view.View"
local Intent = bindClass "android.content.Intent"
local ArrayAdapter = bindClass "android.widget.ArrayAdapter"
local LinearLayoutCompat = bindClass "androidx.appcompat.widget.LinearLayoutCompat"
local Slider = bindClass "com.google.android.material.slider.Slider"

-- 加载工具库
local MaterialBlurDialogBuilder = require "dialogs.MaterialBlurDialogBuilder"
local Utils = require "utils.Utils"
local OkHttpUtil = require "utils.OkHttpUtil"
local ActivityUtil = require "utils.ActivityUtil"
local IconDrawable = require "utils.IconDrawable"
local FileUtil = require "utils.FileUtil"
local EditorUtil = require "activities.editor.EditorUtil"
local Init = require "activities.editor.EditorActivity$init"
EditView = require "activities.editor.EditView"

-- 常量配置
local API_BASE_URL = "https://luaappx.top/forum/"
local TEXT_FORMATS = { zip = true, alp = true }
local MENU_ITEMS = {
  { id = "undo", icon = "ic_undo", action = function() editor.undo() end },
  { id = "redo", icon = "ic_redo", action = function() editor.redo() end },
  { id = "run", icon = "ic_play_outline", color = 0xFF4CAF50, action = function()
      ActivityUtil.new("runcode", { tostring(editor.text) })
  end}
}

-- 加载论坛列表
local function loadForums(data)
  local names = {}
  forum_ids = {} -- 清空旧数据
  for _, v in ipairs(data) do
    table.insert(names, v.name)
    table.insert(forum_ids, v.id) -- 存储ID到全局列表
  end

  local adapter = ArrayAdapter(activity,
  android.R.layout.simple_spinner_item, names)
  adapter.setDropDownViewResource(android.R.layout.simple_spinner_dropdown_item)
  tag.setAdapter(adapter)
  tag.onItemSelected = function(parent, view, pos, id)
    forum_id = tonumber(forum_ids[pos + 1]) -- 使用全局列表
  end
end

-- 获取论坛列表
local function fetchForums(callback)
  OkHttpUtil.get(false, API_BASE_URL .. "list_forums.php?time=" .. os.time(), nil, true, function(code, body)
    if code == 200 then
      local success, v = pcall(OkHttpUtil.decode, body)
      if success and v and v.data then
        loadForums(v.data)
        callback()
      end
    end
  end)
end

-- 加载帖子内容
local function loadPost()
  OkHttpUtil.get(false, API_BASE_URL .. "get_post.php?post_id=" .. post_id .. "&time=" .. os.time(), {
    Authorization = "Bearer " .. getSQLite(3),
    }, true, function(code, body)

    local success, v = pcall(OkHttpUtil.decode, body)
    if not (success and v and v.success) then
      MyToast(v and v.message or body)
      return
    end

    local post = v.data.post
    editor.setText(tostring(post.content))
    title.setText(tostring(post.title))

    -- 根据论坛ID查找索引位置
    local targetIndex = 0 -- 默认选择第一项
    for i, fid in ipairs(forum_ids) do
      if tonumber(fid) == tonumber(post.forum_id) then
        targetIndex = i - 1 -- 索引从0开始
        break
      end
    end
    tag.setSelection(targetIndex)
    price = post.price

    local hasAttachment = v.data.attachments and v.data.attachments.files and v.data.attachments.files[1]
    if hasAttachment then
      local fileInfo = v.data.attachments.files[1]
      activity.getSupportActionBar().setSubtitle(fileInfo.name)
    end
  end)
end

-- 提交帖子
local function submitPost()
  if #title.text == 0 then
    title.setError(res.string.please_enter_a_title)
    return
  end

  OkHttpUtil.upload(true,
  API_BASE_URL .. "create_post.php",
  {
    post_id = post_id,
    forum_id = forum_id,
    title = title.text,
    content = editor.text,
    price = price or 0,
    time = os.time()
  },
  {
    file = file_path and { file_path } or nil,
    ["images[]"] = ""
  },
  {
    Authorization = "Bearer " .. getSQLite(3),
  },
  function(code, body)
    local ok, v = pcall(OkHttpUtil.decode, body)
    if ok and v then
      MyToast(v.message)
      if v.success then
        activity.result({ v.message })
        activity.finish()
      end
     else
      OkHttpUtil.error(body)
    end
  end)
end

-- ===== 主执行逻辑 =====
-- 设置界面
activity
.setContentView(loadlayout("layouts.activity_post"))
.setSupportActionBar(toolbar)
.getSupportActionBar()
.setDisplayHomeAsUpEnabled(true)

-- 设置状态栏
activity.window.setStatusBarColor(Colors.colorSurfaceContainer)
activity.decorView.setSystemUiVisibility(View.SYSTEM_UI_FLAG_LIGHT_STATUS_BAR | View.SYSTEM_UI_FLAG_HIDE_NAVIGATION)

-- 初始化编辑器
task(1, function()
  Init.Bar()
  editor.setText(res.string.post_warning)

  EditView
  .Search_Init()
  .TextSelectListener()
  .TextActionWindowListener()
  .EditorLanguageAsync(false)
  .EditorScheme()
  .EditorProperties()
  .EditorFont()
end)

-- 获取论坛列表
fetchForums(function()
  if post_id then
    loadPost()
  end
end)

-- 设置提交按钮
fab.onClick = submitPost

-- ===== 生命周期函数 =====
-- 创建菜单
function onCreateOptionsMenu(menu)
  -- 添加普通菜单项
  for _, item in ipairs(MENU_ITEMS) do
    menu.add(res.string[item.id])
    .setShowAsAction(2)
    .setIcon(IconDrawable(item.icon, item.color or Colors.colorOnSurfaceVariant))
    .onMenuItemClick = item.action
  end

  --[[ 添加设置金币菜单
  menu.add(res.string.set_x_coins)
  .onMenuItemClick = function()
    MaterialBlurDialogBuilder(activity)
    .setTitle(res.string.set_x_coins)
    .setView(loadlayout({
      LinearLayoutCompat,
      layout_width = -1,
      layout_height = -1,
      {
        Slider,
        layout_width = -1,
        layout_margin = "26dp",
        layout_marginBottom = "8dp",
        ValueTo = 50,
        StepSize = 5,
        Value = price or 0,
        id = "slider",
      },
    }))
    .setPositiveButton(res.string.ok, function()
      price = slider.getValue()
    end)
    .show()
  end]]

  -- 添加上传附件菜单
  menu.add(res.string.upload_attachment)
  .onMenuItemClick = function()
    activity.startActivityForResult(
    Intent(Intent.ACTION_GET_CONTENT)
    .setType("*/*")
    .addCategory(Intent.CATEGORY_OPENABLE),
    444
    )
  end

  -- 添加格式化代码菜单
  menu.add(res.string.format)
  .onMenuItemClick = function()
    EditView.format()
  end

  -- 添加搜索菜单
  menu.add(res.string.search)
  .onMenuItemClick = function()
    EditView.search()
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

-- 处理返回结果
function onActivityResult(requestCode, resultCode, intent)
  if resultCode ~= activity.RESULT_OK or not intent then return end

  local uri = intent.data
  if requestCode == 444 then
    local path = Utils.uri2path(uri)
    if not path then
      return
    end
    local ext = FileUtil.getFileExtension(path)
    if not TEXT_FORMATS[ext] then
      MyToast(res.string.please_select_a_zip_files)
      return
    end
    file_path = path
    activity.getSupportActionBar().setSubtitle(FileUtil.getName(path))
  end
end

-- 清理资源
function onDestroy()
  EditView.release()
  luajava.clear()
  collectgarbage("collect")
  collectgarbage("step")
end