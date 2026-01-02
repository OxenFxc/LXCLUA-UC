local _M = {}
local bindClass = luajava.bindClass
local File = bindClass "java.io.File"
local Ticker = bindClass "com.difierline.lua.Ticker"
local View = bindClass "android.view.View"
local MyBottomSheetDialog = require "dialogs.MyBottomSheetDialog"
local MaterialBlurDialogBuilder = require "dialogs.MaterialBlurDialogBuilder"
local Utils = require "utils.Utils"
local FileUtil = require "utils.FileUtil"
local PathUtil = require "utils.PathUtil"
local cjson = require "cjson"

local TEXT_FORMATS = {
  lua = true, aly = true, json = true, kt = true, java = true, txt = true
}

local selectedText2
_M.ticker = Ticker()

-- 解析项目清单文件
local function parseManifest(manifestPath)
  if not FileUtil.isExist(manifestPath) then return end
  local success, content = pcall(FileUtil.read, manifestPath)
  if not success then return end
  local s, v = pcall(cjson.decode, content)
  if not v then return end
  return {
    label = v.application.label or "Error",
  }
end

function ChangeTitle(path)
  local e, info = pcall(parseManifest, luaproject .. "/manifest.json")
  activity.getSupportActionBar().setTitle(e and info.label or res.string.app_name)
  activity.getSupportActionBar().setSubtitle(FileUtil.getName(path))
end

local function initTab()
  tabs.addOnTabSelectedListener({
    onTabReselected = function(tab)
      _M.save()
    end,
    onTabSelected = function(tab)
      _M.load(tab.tag.file)
    end,
    onTabUnselected = function(tab)
      _M.save()
    end,
  })
end

local function getError()

  local str = editor.getText().toString()
  local path = PathUtil.this_file
  if FileUtil.getFileExtension(path) == "aly" then
    str = "return " .. str
    local _, data = load(str)
    if data then
      local _, _, line, data = data:find(".(%d+).(.+)")
      return line .. ":" .. data
    end
   elseif FileUtil.getFileExtension(path) == "lua" then
    local _, data = load(str)
    if data then
      local _, _, line, data = data:find(".(%d+).(.+)")
      return line .. ":" .. data
    end
  end
  return false

end

-- 设置错误检查
local function setupErrorChecking()
  _M.ticker.Period = 200
  _M.ticker.start()
  _M.ticker.onTick = function()
    local error = getError()
    if error then
      error_text.Visibility = 0
      error_text.setText(error)
     else
      error_text.Visibility = 8
    end
  end
end

local function BackupFile(path, content)
  FileUtil.checkBackup()
  local _path = path:gsub(PathUtil.project_path, "")
  local backups = PathUtil.media_backup_path .. "/" .. os.date("%Y-%m-%d") .. "/" .. os.date("%H_%M") .. _path
  local backup_file = File(backups)
  if not backup_file.exists() then
    File(backup_file.getParent()).mkdirs()
    FileUtil.create(backups, content)
  end
  return _M
end

function _M.init()

  initTab()

  if is_sora then
    setupErrorChecking()
  end

  EditView
  .Search_Init()
  .TextSelectListener()
  .TextActionWindowListener()
  .EditorLanguageAsync(true)
  .EditorScheme()
  .EditorProperties()
  .EditorFont()

  return _M
end

function _M.save(path)
  local path = PathUtil.this_file

  if is_sora then
    fileTracker.putFile(db, ProjectName, path, tonumber(editor.getCursor().getLeftLine()), tonumber(editor.getCursor().getLeftColumn()))
   else
    fileTracker.putFile(db, ProjectName, path, tonumber(editor.getSelectionEnd()), 0)
  end

  -- 确保不重复添加已存在的路径
  local relativePath = path:match(luaproject .. "/(.+)")
  
  -- 先移除所有相同的路径（如果存在）
  local i = 1
  while i <= #files_histry do
    if files_histry[i] == relativePath then
      table.remove(files_histry, i)
    else
      i = i + 1
    end
  end
  
  -- 然后在开头添加路径（保持最近使用的在前面）
  table.insert(files_histry, 1, relativePath)

  if TEXT_FORMATS[FileUtil.getFileExtension(path)] then 
    local str = editor.getText().toString()
    FileUtil.write(path , str)
    BackupFile(path, str)
  end

  return _M
end

function _M.load(path)
  if TEXT_FORMATS[FileUtil.getFileExtension(path)] and FileUtil.isExist(path) then
    PathUtil.this_file = path
    ChangeTitle(path)
    FilesTabManager.addTab(path)
    Utils.setTabRippleEffect(tabs)
    editor.setText(FileUtil.read(path))

    local file_info, err = fileTracker.getFile(db, ProjectName, path)
    if file_info then
      local line = file_info.lines
      local col = file_info.columns

      if is_sora then
        editor.postInLifecycle(function()
          pcall(function()
            editor.setSelection(line, col, true)
          end)
        end)
       else
        editor.setSelection(line)
      end
    end
  end
  fileTracker.putInProject(db, ProjectName, "lastOpenedProjectPath", path)
  return _M
end

function _M.reopen(path)
  local f = io.open(path, "r")
  if f then
    local str = f:read("*all")
    if tostring(editor.getText()) ~= str then
      editor.setText(str)
    end
    f:close()
  end
  return _M
end

function _M.removeDuplicates(list)
  -- 用于记录已出现的元素
  local seen = {}
  -- 存储去重后的结果
  local result = {}

  -- 遍历原始列表
  for _, value in ipairs(list) do
    -- 若元素未出现过，则加入结果列表并标记为已出现
    if not seen[value] then
      seen[value] = true
      table.insert(result, value)
    end
  end

  return result
end

return _M