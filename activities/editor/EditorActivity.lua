require "env"
local bindClass = luajava.bindClass
local Color = bindClass "android.graphics.Color"
local View = bindClass "android.view.View"
local PluginsUtil = require "activities.plugins.PluginsUtil"
require "console"
activity.window.setStatusBarColor(Color.TRANSPARENT)
activity.decorView.setSystemUiVisibility(View.SYSTEM_UI_FLAG_LIGHT_STATUS_BAR | View.SYSTEM_UI_FLAG_HIDE_NAVIGATION)

local ActionBarDrawerToggle = bindClass "androidx.appcompat.app.ActionBarDrawerToggle"
local File = bindClass "java.io.File"
local DrawerLayout = bindClass "androidx.drawerlayout.widget.DrawerLayout"
local EditorSearcher = bindClass "io.github.rosemoe.sora.widget.EditorSearcher"
local ProgressMaterialAlertDialog = require "dialogs.ProgressMaterialAlertDialog"
local MaterialBlurDialogBuilder = require "dialogs.MaterialBlurDialogBuilder"
local IconDrawable = require "utils.IconDrawable"
local Init = require "activities.editor.EditorActivity$init"
local PathUtil = require "utils.PathUtil"
local FileUtil = require "utils.FileUtil"
local ActivityUtil = require "utils.ActivityUtil"
local Utils = require "utils.Utils"
EditView = require "activities.editor.EditView"
EditorUtil = require "activities.editor.EditorUtil"
FilesTabManager = require "activities.editor.FilesTabManager"
fileTracker = require "activities.editor.FileTracker"

luaproject, label = ...

ProjectName = FileUtil.getName(luaproject)

db = fileTracker.open(PathUtil.crash_path .. "/fileTracker.db")

search_histry = fileTracker.getFromProject(db, ProjectName, "SearchHistory") or {}
files_histry = fileTracker.getFromProject(db, ProjectName, "FilesHistory") or {}
luapath = fileTracker.getFromProject(db, ProjectName, "lastOpenedProjectPath")

if not luapath or not FileUtil.isExist(luapath) then
  luapath = luaproject .. "/main.lua"
end

PathUtil.this_file = luapath
PathUtil.this_project = luaproject

PluginsUtil.clearOpenedPluginPaths()
PluginsUtil.setActivityName("EditorActivity")

-- 主布局初始化
activity
.setContentView(loadlayout("layouts.activity_editor"))
.setSupportActionBar(toolbar)
.getSupportActionBar()
.setDisplayHomeAsUpEnabled(true)

local toggle = ActionBarDrawerToggle(activity, drawer, R.string.open_drawer, R.string.close_drawer)
drawer.addDrawerListener(toggle)
toggle.syncState()

task(100, function()
  Init
  .Bar()
  .Nav()

  -- 设置标签页移除回调
  FilesTabManager.setOnTabRemovedCallback(function(removedPath)
    -- 从文件历史中移除所有对应路径
    local relativePath = removedPath:match(luaproject .. "/(.+)")
    local i = 1
    while i <= #files_histry do
      if files_histry[i] == relativePath then
        table.remove(files_histry, i)
       else
        i = i + 1
      end
    end

    -- 立即更新数据库
    fileTracker.putInProject(db, ProjectName, "FilesHistory", files_histry)
  end)

  if activity.getSharedData("history_record") then
    for k, v ipairs(EditorUtil.removeDuplicates(files_histry)) do
      FilesTabManager.addTab(luaproject .. "/" .. v)
    end
  end

  EditorUtil
  .init()
  .load(PathUtil.this_file)

  EditView
  .Search_Init()
end)

local TEXT_FORMATS = {
  lua = true, aly = true, json = true, kt = true, java = true,
  txt = true
}

tree.init(luaproject)
--tree.setNodeNameTypeface(activity.getLuaDir("res/fonts/josefin_sans.ttf"))
tree.setOnFileClickListener(function(view, path)
  if not FileUtil.isExists(path) then
    MyToast(res.string.file_does_not_exist)
   elseif TEXT_FORMATS[FileUtil.getFileExtension(path)] then
    EditorUtil
    .save()
    .load(path)
    drawer.closeDrawer(3)
  end
end)

tree.setOnLongFileClickListener(function(view, path)
  if path == luaproject then
    tree.refresh(luaproject)
   else
    Init.LongMenu(path)
  end
  return true
end)


function error_text.onClick(v)
  local line = tonumber((v.Text):match("(.+):"))
  xpcall(function()
    editor.jumpToLine(line)
    end,function()
    editor.gotoLine(line)
  end)
end

function onCreate(savedInstanceState)
  PluginsUtil.callElevents("onCreate", savedInstanceState)
end

function onStart()
  local file = FileUtil.isExist(PathUtil.this_file) and PathUtil.this_file or luaproject .. "/main.lua"
  EditorUtil.reopen(file)
end

function onOptionsItemSelected(item)
  if item.getItemId() == android.R.id.home
    if not drawer.isDrawerOpen(3)
      drawer.openDrawer(3)
     else
      drawer.closeDrawer(3)
    end
  end
  PluginsUtil.callElevents("onOptionsItemSelected", item)
end

local function addCheckItem(menu, title, getter, setter)
  local state = getter()
  local item = menu.add(title)
  item.setCheckable(true)
  item.setChecked(state)

  item.onMenuItemClick = function()
    state = not state
    item.setChecked(state)
    setter(state)
  end
end

function onCreateOptionsMenu(menu)
  menu.add(res.string.undo)
  .setShowAsAction(2)
  .setIcon(IconDrawable("ic_undo", Colors.colorOnSurfaceVariant))
  .onMenuItemClick = function()
    editor.undo()
  end
  menu.add(res.string.redo)
  .setShowAsAction(2)
  .setIcon(IconDrawable("ic_redo", Colors.colorOnSurfaceVariant))
  .onMenuItemClick = function()
    editor.redo()
  end
  menu.add(res.string.run)
  .setShowAsAction(2)
  .setIcon(IconDrawable("ic_play_outline", 0xFF4CAF50))
  .onMenuItemClick = function()
    EditorUtil.save()
    activity.newActivity(luaproject .. "/main.lua")
  end
  local menu0 = menu.addSubMenu(res.string.file .. "…")
  menu0.add(res.string.compilation).onMenuItemClick = function()
    EditorUtil.save()
    local path, str = console.build(PathUtil.this_file)
    MyToast(path and res.string.compiled_successfully .. ": " .. path or res.string.compilation_failed .. ": " .. str)
    tree.refresh(FileUtil.getParent(PathUtil.this_file))
  end
  local menu1 = menu.addSubMenu(res.string.code .. "…")
  menu1.add(res.string.format).onMenuItemClick = function()
    EditView.format()
  end
  menu1.add(res.string.search).onMenuItemClick = function()
    EditorUtil.save()
    EditView.search()
  end
  menu1.add(res.string.analysis_import).onMenuItemClick = function()
    EditorUtil.save()
    ActivityUtil.new("analysis", { PathUtil.this_file })
  end
  local menu2 = menu.addSubMenu(res.string.item .. "…")
  menu2.add(res.string.attribute).onMenuItemClick = function()
    EditorUtil.save()
    ActivityUtil.new("attribute", { luaproject })
  end
  menu2.add(res.string.build).onMenuItemClick = function()
    EditorUtil.save()
    ActivityUtil.new("build", { luaproject })
  end
  menu2.add(res.string.backup).onMenuItemClick = function()
    EditorUtil.save()
    local wait_dialog = ProgressMaterialAlertDialog(activity).show()
    activity.newTask(function (path, MyToast, res)
      local FileUtil = require "utils.FileUtil"
      local e = FileUtil.backup(path)
      MyToast((function ()return e and res.string.backup_succeeded .. ": " .. e or res.string.backup_failed end )())
    end ,
    function ()
      wait_dialog.dismiss()
    end ).execute({luaproject, MyToast, res})
  end
  local menu3 = menu.addSubMenu(res.string.tool .. "…")
  menu3.add(res.string.javaapi).onMenuItemClick = function()
    ActivityUtil.new("javaapi")
  end
  menu3.add(res.string.logs).onMenuItemClick = function()
    ActivityUtil.new("logs")
  end
  menu3.add(res.string.layout_helper).onMenuItemClick = function()
    EditorUtil.save()
    if FileUtil.getFileExtension(PathUtil.this_file ) == "aly" then
      ActivityUtil.new("layouthelper", { PathUtil.this_file, luaproject })
     else
      MyToast(res.string.editing_this_layout_is_not_supported)
    end
  end
  local menu4 = menu.addSubMenu(res.string.edit .. "…")
  addCheckItem(menu4, res.string.word_wrap,
  function() return activity.getSharedData("word_wrap") or false end,
  function(value)
    activity.setSharedData("word_wrap", value)
    xpcall(function()
      editor.setWordwrap(value)
      end,function()
      editor.setWordWrap(value)
    end)
  end)
  if is_sora then
    addCheckItem(menu4, res.string.readable_mode,
    function() return false end,
    function(value)
      editor.setEditable(not value)
      psbar.parent.parent.setVisibility(value and 8 or 0)
    end)
    addCheckItem(menu4, res.string.fixed_line_number,
    function() return activity.getSharedData("fixed_line_number") or false end,
    function(value)
      activity.setSharedData("fixed_line_number", value)
      editor.setPinLineNumber(value)
    end)
  end
  PluginsUtil.callElevents("onCreateOptionsMenu", menu)
end

function onResult(name, str)
  local name = File(name).Name
  if name == "AttributeActivity" then
    activity.getSupportActionBar().setTitle(str)
    MyToast(res.string.saved_successfully)
    EditorUtil.load(PathUtil.this_file)
   elseif name == "LayoutHelperActivity" then
    MyToast(str)
    if str == res.string.saved_successfully then
      EditorUtil.load(PathUtil.this_file)
    end
  end
  PluginsUtil.callElevents("onResult", name, str)
end

function onActivityResult(req, resx, intent)
  pcall(function()
    if resx ~= 0 then
      local data = intent.getStringExtra("data")
      local _, _, path, line = data:find("\n[	 ]*([^\n]-):(%d+):")

      local classes = require "activities.javaapi.PublicClasses"
      local c = data:match("a nil value %(global '(%w+)'%)")
      if c then
        local cls = {}
        c = "%." .. c .. "$"
        for k, v ipairs(classes)
          if v:find(c)
            table.insert(cls, v)
          end
        end
        if #cls > 0 then
          MaterialBlurDialogBuilder(activity)
          .setTitle(res.string.classes_that_may_need_to_be_imported)
          .setItems(cls, function(l, v)
            local content = tostring(cls[v+1])
            MyToast(activity.getSystemService("clipboard").setText("import " .. "\"" .. content .. "\"") and res.string.copied_successfully)
          end)
          .setPositiveButton(res.string.ok, nil)
          .show()
        end
      end
    end
  end)
  PluginsUtil.callElevents("onActivityResult", req, resx, intent)
end

function onPause()
  EditorUtil.save()
  fileTracker.putInProject(db, ProjectName, "FilesHistory", files_histry)
end

local ticker = Ticker()
ticker.Period = 300000
ticker.onTick = function()
  activity.newTask(function (path, MyToast, res)
    local FileUtil = require "utils.FileUtil"
    local e = FileUtil.backup(path)
    MyToast((function ()return e and res.string.backup_succeeded .. ": " .. e or res.string.backup_failed end )())
  end).execute({luaproject, MyToast, res})
end

if activity.getSharedData("automatic_backup") then
  ticker.start()
end

function onDestroy()
  EditView.release()

  EditorUtil.ticker.stop()
  EditorUtil.ticker = nil
  ticker.stop()

  luajava.clear()
  collectgarbage("collect") --全回收
  collectgarbage("step") -- 增量回收

  PluginsUtil.callElevents("onDestroy")
end

function onKeyDown(key)
  if key == 4 then
    if drawer.isDrawerOpen(3) then
      drawer.closeDrawer(3)
     elseif search_root.Visibility == 0 then
      search_root.Visibility = 8
     else
      activity.finish()
    end
    return true
  end
end