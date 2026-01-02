local _M = {}
local bindClass = luajava.bindClass
local StaggeredGridLayoutManager = bindClass "androidx.recyclerview.widget.StaggeredGridLayoutManager"
local NavigationView = bindClass "com.google.android.material.navigation.NavigationView"
local File = bindClass "java.io.File"
local MaterialBlurDialogBuilder = require "dialogs.MaterialBlurDialogBuilder"
local LuaRecyclerAdapter = require "utils.LuaRecyclerAdapter"
local FileUtil = require "utils.FileUtil"
local SharedPrefUtil = require "utils.SharedPrefUtil"
local MyBottomSheetDialog = require "dialogs.MyBottomSheetDialog"
local PathUtil = require "utils.PathUtil"
local ProgressMaterialAlertDialog = require "dialogs.ProgressMaterialAlertDialog"
local Utils = require "utils.Utils"

local symbol = SharedPrefUtil.getTable("symbol")

-- 缓存常用函数以提高性能
local getParent = FileUtil.getParent
local getName = FileUtil.getName
local isFile = FileUtil.isFile
local isExists = FileUtil.isExists
local createFile = FileUtil.createFile
local createDirectory = FileUtil.createDirectory
local remove = FileUtil.remove
local format = string.format

-- 优化时间格式化函数
local function getFilelastTime(path)
  local f = File(path)
  if not f.exists() then
    return nil
  end
  local ms = f.lastModified()
  if ms == 0 then
    return nil
  end
  local sec = math.floor(ms / 1000)
  return os.date("%Y-%m-%d %H:%M:%S", sec)
end

function _M.LongMenu(path)
  local dialog = MyBottomSheetDialog(activity)
  .setView("layouts.tree_long_layout")
  .show()

  local name = getName(path)
  filename.setText(name).getPaint().setFakeBoldText(true)
  time.setText(getFilelastTime(path))

  -- 重命名处理
  local function handleRename()
    dialog.dismiss()
    if name == "main.lua" or name == "manifest.json" then
      MyToast(res.string.inoperable)
      return
    end

    local rename_dialog = MaterialBlurDialogBuilder(activity)
    .setTitle(res.string.rename)
    .setView(loadlayout("layouts.dialog_fileinput"))
    .setPositiveButton(res.string.ok, nil)
    .setNegativeButton(res.string.no, nil)
    .create()

    Utils.changed(content).onShow(rename_dialog, function()
      local newName = content.getText()
      local new_path = getParent(path) .. "/" .. newName

      if isExists(new_path) then
        content.setError(res.string.exists_file)
        return
      end

      if path == PathUtil.this_file then
        PathUtil.this_file = new_path
        ChangeTitle(new_path)
        fileTracker.putInProject(db, ProjectName, "lastOpenedProjectPath", new_path)
      end

      FileUtil.rename(path, new_path)
      tree.refresh(getParent(path))
      FilesTabManager.change(path, new_path)
      rename_dialog.dismiss()
    end)

    rename_dialog.show()
    content.setText(name)
  end

  -- 新建文件处理
  local function handleNewFile()
    dialog.dismiss()
    local new_file_dialog = MaterialBlurDialogBuilder(activity)
    .setTitle(res.string.new_file)
    .setView(loadlayout("layouts.dialog_fileinput"))
    .setPositiveButton(res.string.ok, nil)
    .setNegativeButton(res.string.no, nil)
    .create()

    Utils.changed(content).onShow(new_file_dialog, function()
      local new_path = isFile(path) and getParent(path) .. "/" .. content.getText() or path .. "/" .. content.getText()

      if isExists(new_path) then
        content.setError(res.string.exists_file)
        return
      end

      MyToast(createFile(new_path) and res.string.created_successfully or res.string.creation_failed)
      tree.refresh(isFile(path) and getParent(new_path) or path)
      new_file_dialog.dismiss()
    end)

    new_file_dialog.show()
  end

  -- 新建文件夹处理
  local function handleNewFolder()
    dialog.dismiss()
    local new_folder_dialog = MaterialBlurDialogBuilder(activity)
    .setTitle(res.string.new_folder)
    .setView(loadlayout("layouts.dialog_fileinput"))
    .setPositiveButton(res.string.ok, nil)
    .setNegativeButton(res.string.no, nil)
    .create()

    Utils.changed(content).onShow(new_folder_dialog, function()
      local new_path = isFile(path) and getParent(path) .. "/" .. content.getText() or path .. "/" .. content.getText()

      if isExists(new_path) then
        content.setError(res.string.exists_file)
        return
      end

      MyToast(createDirectory(new_path) and res.string.created_successfully or res.string.creation_failed)
      tree.refresh(isFile(path) and getParent(new_path) or path)
      new_folder_dialog.dismiss()
    end)

    new_folder_dialog.show()
  end

  -- 删除处理
  local function handleDelete()
    dialog.dismiss()
    if path == PathUtil.this_file or name == "main.lua" or name == "manifest.json" then
      MyToast(res.string.inoperable)
      return
    end

    local delete_dialog = MaterialBlurDialogBuilder(activity)
    .setTitle(res.string.tip)
    .setMessage(format((isFile(path) and res.string.delete_or_not_file or res.string.delete_or_not_folder), name))
    .setPositiveButton(res.string.ok, function()
      local wait_dialog = ProgressMaterialAlertDialog(activity).show()
      activity.newTask(function(MyToast, remove, path, res_string)
        MyToast(remove(path) and res_string.deleted_successfully or res_string.delete_failed)
        end, function()
        tree.refresh(getParent(path))
        FilesTabManager.remove(path)
        wait_dialog.dismiss()
      end).execute({MyToast, remove, path, res.string})
    end)
    .setNegativeButton(res.string.no, nil)
    .show()
  end

  -- 绑定点击事件
  rename.onClick = handleRename
  new_file.onClick = handleNewFile
  new_folder.onClick = handleNewFolder
  delete.onClick = handleDelete

  return _M
end

-- 符号表初始化（使用静态表避免重复创建）
function _M.setSymbol()
  if not symbol then
    local DEFAULT_SYMBOLS = {
      {title = "Fun()", content = "function"},
      {title = "(", content = "("},
      {title = ")", content = ")"},
      {title = "[", content = "["},
      {title = "]", content = "]"},
      {title = "{", content = "{"},
      {title = "}", content = "}"},
      {title = "\"", content = "\""},
      {title = "=", content = "="},
      {title = ":", content = ":"},
      {title = ".", content = "."},
      {title = ",", content = ","},
      {title = ";", content = ";"},
      {title = "_", content = "_"},
      {title = "+", content = "+"},
      {title = "-", content = "-"},
      {title = "*", content = "*"},
      {title = "/", content = "/"},
      {title = "\\", content = "\\"},
      {title = "%", content = "%"},
      {title = "#", content = "#"},
      {title = "^", content = "^"},
      {title = "$", content = "$"},
      {title = "?", content = "?"},
      {title = "&", content = "&"},
      {title = "|", content = "|"},
      {title = "<", content = "<"},
      {title = ">", content = ">"},
      {title = "~", content = "~"},
      {title = "'", content = "'"}
    }
    SharedPrefUtil.set("symbol", DEFAULT_SYMBOLS)
    symbol = DEFAULT_SYMBOLS
  end
end

-- 符号栏初始化（优化点击处理）
function _M.Bar()
  if symbol then
    -- 预定义点击处理函数
    local function symbolClickHandler(data)
      return function()
        if not readableEnabled then
          xpcall(function()
            if not activity.getSharedData("autofill") then
              editor.insertText(data.content, #data.content)
             else
              editor.pasteText(data.content)
            end
            end,function()
            editor.paste(data.content)
          end)
        end
      end
    end

    local barAdapter = LuaRecyclerAdapter(symbol, "layouts.bar_item", {
      onBindViewHolder = function(viewHolder, pos, views, data)
        views.symbol.setText(data.title)
        views.symbol.setTooltipText(data.title)
        views.symbol.setBackgroundDrawable(getRipple())

        -- 绑定预定义的处理函数
        views.symbol.onClick = symbolClickHandler(data)
      end
    })

    psbar.setAdapter(barAdapter)
    psbar.setLayoutManager(StaggeredGridLayoutManager(1, 0))
  end
  return _M
end

-- 导航菜单初始化（简化实现）
function _M.Nav()
  local MENU_ITEMS = {
    {id = 0, title = label, icon = R.drawable.ic_folder},
  }

  for _, item in ipairs(MENU_ITEMS) do
    nav.Menu.add(0, item.id, item.id, item.title)
    .setCheckable(true)
    .setIcon(item.icon)
  end

  nav.setOnItemSelectedListener {
    onNavigationItemSelected = function(item)
      if item.itemId == 1 then

        return false
      end
      return true
    end
  }

  return _M
end

return _M