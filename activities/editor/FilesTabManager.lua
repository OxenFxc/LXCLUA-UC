local _M = {}
local bindClass = luajava.bindClass
local File = bindClass "java.io.File"
local Context = bindClass "android.content.Context"
local PopupMenu = bindClass "androidx.appcompat.widget.PopupMenu"
local FileUtil = require "utils.FileUtil"
local PopupMenuUtils = require "utils.PopupMenuUtils"
local PathUtil = require "utils.PathUtil"
--local MarkDownUtil = require "utils.MarkDownUtil"

_M.tabData = {} -- 用于存储标签页信息
_M.tabPath = {} -- 新增：存储标签页路径的数组

local fileExtensionIcons = { -- 文件类型与图标映射表
  lua = R.drawable.ic_language_lua,
  aly = R.drawable.ic_code_braces,
  json = R.drawable.ic_code_json,
  png = R.drawable.ic_file_image_outline,
  jpg = R.drawable.ic_file_image_outline,
  gif = R.drawable.ic_file_image_outline,
  mp3 = R.drawable.ic_file_music_outline,
  java = R.drawable.ic_language_java,
  kt = R.drawable.ic_language_kotlin,
  gradle = R.drawable.ic_language_gradle,
  js = R.drawable.ic_language_javascript,
  py = R.drawable.ic_language_python,
  apk = R.drawable.ic_android,
  zip = R.drawable.ic_zip_box_outline
}

-- 创建弹出菜单
local function createPopupMenu(activityContext, path, tab, pathName, fileType)
  local popupMenu = PopupMenu(activityContext, tab)
  local menu = popupMenu.getMenu()

  PopupMenuUtils.setHeaderTitle(popupMenu, FileUtil.getName(luaproject) .. "/")

  -- 关闭当前标签
  menu.add(res.string.close_current).onMenuItemClick = function()
    if tabs.getTabCount() == 1 then
      MyToast(res.string.last_one_not_allowed)
     else
      _M.remove(path)
    end
  end

  -- 关闭其他标签
  menu.add(res.string.close_other).onMenuItemClick = function()
    if tabs.getTabCount() > 1 then
      -- 修复：将tabData改为_M.tabData
      for currentPath in pairs(_M.tabData) do
        if currentPath ~= path then
          _M.remove(currentPath)
        end
      end
    end
  end

  -- 配置文档（仅限manifest.json）
  --[[if pathName == "manifest.json" then
    menu.add(res.string.configuration_document).onMenuItemClick = function()
      MarkDownUtil.show(activityContext.getLuaDir("res/doc/Manifest.md"))
    end
  end]]

  -- 复制菜单
  local copySubMenu = menu.addSubMenu(res.string.copy .. "…")

  -- 复制文件名（不含扩展名）
  local baseName = pathName:match("(.+)%." .. (fileType or ".*") .. "$")
  if baseName then
    copySubMenu.add(baseName).onMenuItemClick = function()
      activityContext.getSystemService(Context.CLIPBOARD_SERVICE).setText(baseName)
    end
  end

  -- 复制完整文件名
  copySubMenu.add(pathName).onMenuItemClick = function()
    activityContext.getSystemService(Context.CLIPBOARD_SERVICE).setText(pathName)
  end

  -- 复制路径相关选项
  if not File(luaproject .. "/" .. pathName).isFile() then
    local relativePath = path:gsub(luaproject .. "/", "")
    copySubMenu.add(relativePath).onMenuItemClick = function()
      activityContext.getSystemService(Context.CLIPBOARD_SERVICE).setText(relativePath)
    end

    local dottedPath = relativePath:gsub("%/", ".")
    copySubMenu.add(dottedPath).onMenuItemClick = function()
      activityContext.getSystemService(Context.CLIPBOARD_SERVICE).setText(dottedPath)
    end
  end

  return popupMenu
end

function _M.addTab(path)
  if _M.tabData[path] then
    tab = _M.tabData[path].tab
   else
    local filePath = File(path)
    local pathName = filePath.Name
    local fileType = string.match(path, "%.(%w+)$")

    -- 创建新标签页
    tab = tabs.newTab()
    if activity.getSharedData("file_icon") then
      tab.setIcon(fileExtensionIcons[fileType] or R.drawable.ic_file_outline)
    end
    tab.setText(pathName)

    -- 设置长按事件
    activity.onLongClick(tab.view, function(v)
      local popupMenu = createPopupMenu(activity, path, v, pathName, fileType)
      popupMenu.show()
      v.setOnTouchListener(popupMenu.getDragToOpenListener())
    end)

    local tabTag = {
      tab=tab,
      file=path,
    }
    tab.tag = tabTag
    _M.tabData[path] = tabTag

    -- 新增：将路径添加到tabPath数组
    table.insert(_M.tabPath, path)

    tabs.addTab(tab)

    -- 设置内边距
    tab.view.getChildAt(0).setPadding(dp2px(2), dp2px(2), dp2px(2), dp2px(2))
  end
  if not(tabs.isSelected()) then--避免调用tab里面的重复点击事件
    task(1,function()
      tab.select()
    end)--选中Tab
  end
end

function _M.remove(path)
  if _M.tabData[path] and _M.tabData[path].tab then
    tabs.removeTab(_M.tabData[path].tab)
    _M.tabData[path] = nil

    -- 从tabPath数组中移除路径
    for i, p in ipairs(_M.tabPath) do
      if p == path then
        table.remove(_M.tabPath, i)
        break
      end
    end

    -- 触发移除回调
    if _M.onTabRemoved then
      _M.onTabRemoved(path)  -- 确保传递完整的路径
    end
  end
end

-- 设置标签页移除回调函数
function _M.setOnTabRemovedCallback(callback)
  _M.onTabRemoved = callback
end

function _M.checkAll()
  -- 新增：清空tabPath数组
  _M.tabPath = {}

  -- 重建tabPath数组并检查文件存在性
  local tempTabData = {}
  for currentPath, data in pairs(_M.tabData) do
    if File(data.tab.tag.file).exists() then
      table.insert(_M.tabPath, currentPath)
      tempTabData[currentPath] = data
     else
      tabs.removeTab(data.tab)
    end
  end
  _M.tabData = tempTabData
end

function _M.change(oldPath, newPath)
  if _M.tabData[oldPath] and FileUtil.getFileExtension(oldPath) == FileUtil.getFileExtension(newPath) then
    local tabTag = _M.tabData[oldPath]
    tabTag.file = newPath

    local existingTab = tabTag.tab
    existingTab.tag.file = newPath
    existingTab.setText(FileUtil.getName(newPath))

    _M.tabData[newPath] = tabTag
    _M.tabData[oldPath] = nil

    -- 新增：更新tabPath数组中的路径
    for i, p in ipairs(_M.tabPath) do
      if p == oldPath then
        _M.tabPath[i] = newPath
        break
      end
    end

    FileUtil.remove(oldPath)
   else
    _M.remove(oldPath)
  end
end

return _M
