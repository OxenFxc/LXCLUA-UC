-- 依赖导入
require "env"
local bindClass = luajava.bindClass
local File = bindClass "java.io.File"
local Intent = bindClass "android.content.Intent"
local StatService = import "com.baidu.mobstat.StatService"
local WindowManager = bindClass "android.view.WindowManager"
local ProgressMaterialAlertDialog = require "dialogs.ProgressMaterialAlertDialog"
local MaterialBlurDialogBuilder = require "dialogs.MaterialBlurDialogBuilder"
local LottieDrawable = require "utils.LottieDrawable"
local FragmentUtil = require "utils.FragmentUtil"
local ActivityUtil = require "utils.ActivityUtil"
local FileUtil = require "utils.FileUtil"
local PathUtil = require "utils.PathUtil"
local Utils = require "utils.Utils"
local cjson = require "cjson"
local OkHttpUtil = require "utils.OkHttpUtil"
local UpdateUtil = require "utils.UpdateUtil"
local IconDrawable = require "utils.IconDrawable"
local SharedPrefUtil = require "utils.SharedPrefUtil"

-- 组件导入
ProjectFragment = require "fragments.ProjectFragment"
SourceFragment = require "fragments.SourceFragment"
ShareFragment = require "fragments.ShareFragment"
MyFragment = require "fragments.MyFragment"

-- 常量定义
local API_BASE_URL = "https://luaappx.top/users/"
local TEXT_FORMATS = { zip = true, alp = true }
local MENU_ITEMS = {
  { title = res.string.item },
  { title = res.string.source_code },
--  { title = res.string.share },
  { title = res.string.my }
}
local menuItems = {
  { title = res.string.search, id = 1 },
  { title = res.string.import_source, id = 2 },
  { title = res.string.sort, id = 3 },
  { title = res.string.setting, id = 4 }
}
local DRAWABLES = { "ic_dashboard", "ic_forum", --[["ic_store" ,]] "ic_others"}
local ANIMATION_FRAMES = {
  SELECTED = { min = 10, max = 20 },
  UNSELECTED = { min = 0, max = 10 }
}
local MENU_IDS = { ITEM = 0, SOURCE = 1, --[[SHARE = 2,]] MY = 2 }
local LAYOUTS = {
  MAIN = "layouts.activity_main",
  FRAGMENTS = {
    "layouts.fragment_project",
    "layouts.fragment_source",
--    "layouts.fragment_share",
    "layouts.fragment_my"
  }
}
-- 排序选项键
local SORT_OPTION_KEY = "current_sort_option"
local SORT_OPTIONS = {
  NAME_ASC = "name_asc",
  NAME_DESC = "name_desc",
  TIME_ASC = "time_asc",
  TIME_DESC = "time_desc"
}
local currentSortOption = SharedPrefUtil.getString(SORT_OPTION_KEY) or SORT_OPTIONS.NAME_ASC

-- 全局状态
setStatus()
local keyCache = {}
local searchView = nil
local isSearchExpanded = false
local fragmentInitialized = {
  [0] = true, -- 项目
  [1] = false, -- 代码
--  [2] = false, -- 共享
  [3] = false -- 我的
}

-- 初始化函数
local function setupMenuItemIcon(item, drawableRes)
  local key = keyCache[drawableRes] or KeyPath { "**" }
  keyCache[drawableRes] = key
  local lottie = LottieDrawable(drawableRes)
  lottie.addValueCallback(
  key,
  LottieProperty.COLOR_FILTER,
  SimpleLottieValueCallback {
    getValue = function()
      return SimpleColorFilter(item.isChecked() and Colors.colorPrimary or Colors.colorOutline)
    end
  }
  )
  item.setIcon(lottie)
end

local function initBottomNavigation()
  for index, item in ipairs(MENU_ITEMS) do
    bottombar.menu.add(0, index-1, index-1, item.title)
  end

  for i = 1, bottombar.menu.size() do
    local menuItem = bottombar.menu.getItem(i-1)
    setupMenuItemIcon(menuItem, DRAWABLES[i])
  end

  local selectedItem = bottombar.menu.findItem(bottombar.selectedItemId)
  selectedItem.icon
  .setMinFrame(ANIMATION_FRAMES.SELECTED.min)
  .setMaxFrame(ANIMATION_FRAMES.SELECTED.max)
  .playAnimation()

  bottombar.menu.getItem(0).icon
  .setMinFrame(ANIMATION_FRAMES.UNSELECTED.min)
  .setMaxFrame(ANIMATION_FRAMES.UNSELECTED.max)
  .playAnimation()
end

local function initFragments()
  FragmentUtil = FragmentUtil(mfragment)
  for _, layout in ipairs(LAYOUTS.FRAGMENTS) do
    FragmentUtil.addFragment(loadlayout(layout))
  end
  FragmentUtil.commitFragment()
end

-- 事件处理器
local menuClickHandlers = {
  [MENU_IDS.ITEM] = function()
    fab.show()
    FragmentUtil.showFragment(MENU_IDS.ITEM)
  end,
  [MENU_IDS.SOURCE] = function()
    fab.show()
    FragmentUtil.showFragment(MENU_IDS.SOURCE)
    if not fragmentInitialized[MENU_IDS.SOURCE] then
      SourceFragment.onCreate()
      fragmentInitialized[MENU_IDS.SOURCE] = true
    end
  end,
--[[  [MENU_IDS.SHARE] = function()
    fab.show()
    FragmentUtil.showFragment(MENU_IDS.SHARE)
    if not fragmentInitialized[MENU_IDS.SHARE] then
      ShareFragment.onCreate()
      fragmentInitialized[MENU_IDS.SHARE] = true
    end
  end,]]
  [MENU_IDS.MY] = function()
    fab.hide()
    FragmentUtil.showFragment(MENU_IDS.MY)
    if not fragmentInitialized[MENU_IDS.MY] then
      fragmentInitialized[MENU_IDS.MY] = true
    end
  end
}

local function setupNavigationListener()
  bottombar.setOnNavigationItemSelectedListener {
    onNavigationItemSelected = function(selectedItem)
      if bottombar.selectedItemId == selectedItem.itemId then
        return true
      end

      local oldItem = bottombar.menu.findItem(bottombar.selectedItemId)
      oldItem.icon
      .setMinFrame(ANIMATION_FRAMES.SELECTED.min)
      .setMaxFrame(ANIMATION_FRAMES.SELECTED.max)
      .playAnimation()

      selectedItem.icon
      .setMinFrame(ANIMATION_FRAMES.UNSELECTED.min)
      .setMaxFrame(ANIMATION_FRAMES.UNSELECTED.max)
      .playAnimation()

      local handler = menuClickHandlers[selectedItem.getItemId()]
      if handler then handler() end

      return true
    end
  }
end

-- 应用初始化流程
activity
.setContentView(loadlayout(LAYOUTS.MAIN))
.setSupportActionBar(toolbar)
.getSupportActionBar()
activity.getWindow().setSoftInputMode(WindowManager.LayoutParams.SOFT_INPUT_ADJUST_PAN)

-- 目录初始化
FileUtil.createDirectory(PathUtil.root_path)
FileUtil.createDirectory(PathUtil.project_path)
FileUtil.createDirectory(PathUtil.crash_path)
FileUtil.createDirectory(PathUtil.backup_path)
FileUtil.createDirectory(PathUtil.bin_path)
FileUtil.createDirectory(PathUtil.cache_path)
FileUtil.createDirectory(PathUtil.plugins_path)

-- 模块初始化
UpdateUtil.check()
StatService()
.setAppKey("16494913a7")
.start(activity)

-- 界面初始化
initBottomNavigation()
setupNavigationListener()
initFragments()
ProjectFragment.onCreate()
MyFragment.onCreate()

-- UI事件绑定
fab.onClick = function()
  local p = FragmentUtil.getCurrentItem()
  if p == 1 then
    ActivityUtil.new("newproject")
   elseif p == 2 then
    if activity.getSharedData("offline_mode") then return end
    if SharedPrefUtil.getBoolean("is_login") then
      ActivityUtil.new("post", { })
     else
      MyToast(res.string.please_log_in_first)
    end
   elseif p == 3 then

  end
end

-- 辅助函数
local function dump(t)
  local r = {}
  for k, v in ipairs(t) do
    r[k] = string.format('  %q', v)
  end
  return table.concat(r, ",\n  ")
end

local function getalpinfoalp(path)
  if LuaUtil.isFileInZip(path, "manifest.json") then
    local str = tostring(String(LuaUtil.readZip(path, "manifest.json")))
    return pcall(function()
      local v = cjson.decode(str)
      local jmp = v.jmp or {}
      local print = v.print or {}
      return {
        label = v.application.label or "My Application",
        debugmode = v.application.debugmode or true,
        dynamic_permission = v.application.dynamic_permission or true,
        versionName = v.versionName or "1.0",
        versionCode = v.versionCode or "1",
        minSdkVersion = v.uses_sdk.minSdkVersion or "21",
        targetSdkVersion = v.uses_sdk.targetSdkVersion or "29",
        package = v.package or "dcore.myapplication",
        user_permission = v.user_permission or {
          "WRITE_EXTERNAL_STORAGE",
          "READ_EXTERNAL_STORAGE",
          "INTERNET"
        },
        compilation = v.compilation or true,
        skip_compilation = v.skip_compilation or {},
        encryption = jmp.encryption or false,
        dump_obfuscate = jmp.dump_obfuscate or false,
        type = print.type or "Snackbar",
        copy = print.copy or true,        
        path = path
      }
    end)
   elseif LuaUtil.isFileInZip(path, "config.json") then
    local str = tostring(String(LuaUtil.readZip(path, "config.json")))
    return pcall(function()
      local v = cjson.decode(str)
      return {
        label = v.label or "My Application",
        debugmode = v.debugmode or true,
        dynamic_permission = true,
        versionName = v.versionName or "1.0",
        versionCode = v.versionCode or "1",
        minSdkVersion = v.minSdkVersion or "21",
        targetSdkVersion = v.targetSdkVersion or "29",
        package = v.package or "xc.newapp",
        user_permission = v.user_permission or {
          "WRITE_EXTERNAL_STORAGE",
          "READ_EXTERNAL_STORAGE",
          "INTERNET"
        },
        compilation = v.compilation or true,
        skip_compilation = v.skip_compilation or {},
        encryption = false,
        dump_obfuscate = false,
        type = "Snackbar",
        copy = true,
        path = path
      }
    end)
   elseif LuaUtil.isFileInZip(path, "init.lua") then
    local str = tostring(String(LuaUtil.readZip(path, "init.lua")))
    return pcall(function()
      local v = {}
      loadstring(str, "bt", "bt", v)()
      return {
        label = v.appname or "My Application",
        debugmode = v.debugmode or true,
        dynamic_permission = true,
        versionName = v.appver or "1.0",
        versionCode = v.appCode or "1",
        minSdkVersion = "21",
        targetSdkVersion = "29",
        package = v.packagename or "xc.newapp",
        user_permission = v.user_permission or {
          "WRITE_EXTERNAL_STORAGE",
          "READ_EXTERNAL_STORAGE",
          "INTERNET"
        },
        compilation = true,
        skip_compilation = {},
        encryption = false,
        dump_obfuscate = false,
        type = "Snackbar",
        copy = true,
        path = path
      }
    end)
  end
end

-- 系统回调
function onResult(activityName, resultData)
  local fileName = File(activityName).getName()
  if fileName == "NewProjectActivity" then
    MyToast(resultData)
    ProjectFragment.update()
   elseif fileName == "SettingsActivity" then
    activity.recreate()
   elseif fileName == "LoginActivity" then
    MyToast(resultData)
    MyFragment.onCreate()
    SourceFragment.refreshData()
   elseif fileName == "PostActivity" then
    MyToast(resultData)
    SourceFragment.refreshData()
  end
end

function onResume()
  -- 获取当前底部导航栏选中的项
  local selectedItemId = bottombar.selectedItemId
  -- 获取当前显示的Fragment索引（0-based）
  local currentFragmentIndex = FragmentUtil.getCurrentItem()

  -- 如果不一致，以底部导航栏为准同步Fragment显示
  if selectedItemId ~= currentFragmentIndex then
    local handler = menuClickHandlers[selectedItemId]
    if handler then
      handler()
    end
  end
end

local function imposts(path)
  local status, config = getalpinfoalp(path)
  if status then
    local manifest = [[{
        "versionName": "]].. config.versionName .. [[",
        "versionCode": "]].. config.versionCode .. [[",
        "uses_sdk": {
            "minSdkVersion": "]].. config.minSdkVersion .. [[",
            "targetSdkVersion": "]].. config.targetSdkVersion .. [["
        },
        "package": "]].. config.package .. [[",
        "application": {
            "label": "]].. config.label .. [[",
            "debugmode": ]].. tostring(config.debugmode) .. "\n" .. [[
        },
        "user_permission": [
      ]].. dump(config.user_permission) .. "\n" .. [[
        ],
        "compilation": ]].. tostring(config.compilation) .. [[ ,
        "skip_compilation": [
        ]].. dump(config.skip_compilation) .. [[
      ],
      "jmp": {
        "encryption": ]].. tostring(config.encryption) .. [[,
        "dump_obfuscate": ]].. tostring(config.dump_obfuscate) .. "\n" .. [[
      },
      "print": {
        "type": "]].. tostring(config.type) .. [[",
        "copy": ]].. tostring(config.copy) .. "\n" .. [[
      }  
      }]]

    MaterialBlurDialogBuilder(activity)
    .setTitle(res.string.import_source)
    .setMessage(string.format("名称: %s\n版本: %s\n版本号: %s\n包名: %s",
    config.label, config.versionName, config.versionCode, config.package))
    .setPositiveButton(res.string.ok, function()
      if FileUtil.isExists(PathUtil.project_path .. "/" .. config.label) then
        MyToast(res.string.an_item_with_the_same_name_already_exists)
        return
      end

      local wait_dialog = ProgressMaterialAlertDialog(activity).show()
      activity.newTask(function(config, manifest)
        local FileUtil = require "utils.FileUtil"
        local PathUtil = require "utils.PathUtil"
        local path = PathUtil.project_path .. "/" .. config.label
        FileUtil.unzip(config.path, path)
        FileUtil.remove(path .. "/init.lua")
        FileUtil.write(path .. "/manifest.json", manifest)
        end, function()
        MyToast(res.string.import_successful)
        wait_dialog.dismiss()
        ProjectFragment.update()
      end).execute({config, manifest})
    end)
    .setNegativeButton(res.string.no, nil)
    .show()
   else
    MyToast(res.string.the_non_source_file)
  end
end

-- 显示排序选项对话框
local function showSortOptionsDialog()
  local items = {
    res.string.sort_by_name_asc,
    res.string.sort_by_name_desc,
    res.string.sort_by_time_asc,
    res.string.sort_by_time_desc
  }

  local checkedItem = 0
  if currentSortOption == SORT_OPTIONS.NAME_ASC then
    checkedItem = 0
   elseif currentSortOption == SORT_OPTIONS.NAME_DESC then
    checkedItem = 1
   elseif currentSortOption == SORT_OPTIONS.TIME_ASC then
    checkedItem = 2
   elseif currentSortOption == SORT_OPTIONS.TIME_DESC then
    checkedItem = 3
  end

  MaterialBlurDialogBuilder(activity)
  .setTitle(res.string.sort_options)
  .setSingleChoiceItems(items, checkedItem, {
    onClick = function(dialog, which)
      if which == 0 then
        currentSortOption = SORT_OPTIONS.NAME_ASC
       elseif which == 1 then
        currentSortOption = SORT_OPTIONS.NAME_DESC
       elseif which == 2 then
        currentSortOption = SORT_OPTIONS.TIME_ASC
       elseif which == 3 then
        currentSortOption = SORT_OPTIONS.TIME_DESC
      end

      -- 保存排序选项到 SharedPreferences
      SharedPrefUtil.set(SORT_OPTION_KEY, currentSortOption)

      -- 通知ProjectFragment进行排序
      if ProjectFragment and ProjectFragment.sort then
        ProjectFragment.sort(currentSortOption)
      end

      dialog.dismiss()
    end
  })
  .setNegativeButton(res.string.no, nil)
  .show()
end

function onActivityResult(requestCode, resultCode, intent)
  if not intent then return end
  local uri = intent.data
  if requestCode == 11 then
    local path = Utils.uri2path(uri)
    OkHttpUtil.upload(true, API_BASE_URL .. "set_avatar.php", {
      time = os.time()
      }, {
      avatar = path,
      }, {
      ["Authorization"] = "Bearer " .. getSQLite(3),
      ["User-Agent"] = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/114.0.0.0 Safari/537.36",
      ["Content-Type"] = "multipart/form-data; boundary=----WebKitFormBoundary7MA4YWxkTrZu0gW",
      }, function (code, body)
      local success, v = pcall(OkHttpUtil.decode, body)
      if success and v then
        MyToast(v.message)
        MyFragment.getProfile()
       else
        OkHttpUtil.print(body)
      end
    end)
   elseif requestCode == 2 then
    local path = Utils.uri2path(uri)
    local ext = FileUtil.getFileExtension(path)
    if not TEXT_FORMATS[ext] then
      MyToast(res.string.please_select_a_zip_films)
      return
    end
    imposts(path)
   elseif requestCode == 1726 and resultCode == -1 then
    local extras = intent.getExtras()
    local response = extras and extras.getString("key_response")

    if response then
      local ok, result = pcall(OkHttpUtil.decode, response)
      if not ok or not result then return end

      OkHttpUtil.post(true, "https://luaappx.top/account/binding.php", {
        username = getSQLite(1),
        password = getSQLite(2),
        openid = result.openid
        }, nil, function (code, body)
        local success, v = pcall(OkHttpUtil.decode, body)
        if success and v then
          MyToast(v.message)
          MyFragment.getProfile()
        end
      end)
    end
  end
end

function onCreateOptionsMenu(menu)

  local searchItem = menu.add(0, menuItems[1].id, 0, menuItems[1].title)
  searchItem.setShowAsAction(2)

  searchView = luajava.newInstance("androidx.appcompat.widget.SearchView", activity)
  -- 为SearchView设置一个唯一的ID
  searchView.setId(android.R.id.custom) -- 使用系统预定义的ID或生成新ID
  searchItem.setActionView(searchView)

  local searchAutoComplete = searchView.findViewById(AndroidX_R.id.search_src_text)
  searchAutoComplete.setHint(res.string.search)

  searchView.setOnQueryTextListener({
    onQueryTextChange = function(newText)
      local currentFragment = FragmentUtil.getCurrentItem()
      if currentFragment == 1 then
        ProjectFragment.search(newText)
       elseif currentFragment == 2 then
        SourceFragment.search(newText)
      end
      return true
    end
  })


  for i = 2, 4 do
    menu.add(0, menuItems[i].id, 0, menuItems[i].title)
    .onMenuItemClick = function()
      if menuItems[i].id == 2 then
        activity.startActivityForResult(
        Intent(Intent.ACTION_GET_CONTENT)
        .setType("*/*")
        .addCategory(Intent.CATEGORY_OPENABLE),
        2
        )
       elseif menuItems[i].id == 3 then
        showSortOptionsDialog()
       elseif menuItems[i].id == 4 then
        ActivityUtil.new("settings")
      end
    end
  end

end

function onDestroy()
  pcall(function()
    ProjectFragment.onDestroy()
    SourceFragment.onDestroy()
    MyFragment.onDestroy()
  end)
  luajava.clear()
  collectgarbage("collect")
  collectgarbage("step")
end

--[[OkHttpUtil.post(false, "https://luaappx.top/admin/add_xcoins_all.php",
{
  amount = "-200",
  include_usernames = {
    --"SMTPTX",
    
    },
  time = os.time()
  },
{
  ["Authorization"] = "Bearer " .. tostring(getSQLite(3))
},
function (code, body)
  OkHttpUtil.print(body)
end)]]


--[[OkHttpUtil.upload(true,
"https://tp.withtool.dpdns.org/upload",
{
  time = os.time()
},
{
  file = "/storage/emulated/0/MT2/apks/LXCLUA_3.4.3.APK"
},
{
},
function(code, body)
  print(body)
end)]]