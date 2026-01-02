local bindClass = luajava.bindClass
local File = bindClass "java.io.File"
local FileInputStream = bindClass "java.io.FileInputStream"
local FileOutputStream= bindClass "java.io.FileOutputStream"
local BufferedInputStream = bindClass "java.io.BufferedInputStream"
local BufferedOutputStream = bindClass "java.io.BufferedOutputStream"
local ZipFile = bindClass "java.util.zip.ZipFile"
local String = bindClass "java.lang.String"
local System = bindClass "java.lang.System"
local MaterialBlurDialogBuilder = require "dialogs.MaterialBlurDialogBuilder"
local PathUtil = require "utils.PathUtil"
local PluginsUtil = require "activities.plugins.PluginsUtil"

------------------------------------------------------------------
local PluginsManagerUtil = {}
local getAlpInfo, showInstallDialog

-- 添加操作跟踪表
local currentOperations = {}

local PackInfo = activity.PackageManager.getPackageInfo(activity.getPackageName(), 64)
local versionCode = PackInfo.versionCode

------------------------------------------------------------------
-- 读取插件 init.lua
function getAlpInfo(path)
  local config = {}
  local txt = String(LuaUtil.readZip(path, "init.lua"))
  loadstring(tostring(txt), "bt", "bt", config)()
  return config
end
PluginsManagerUtil.getAlpInfo = getAlpInfo

------------------------------------------------------------------
-- 标准 JDK ZipFile 解压全部条目
local function unzipAll(zipPath, destDir)
  local zip = ZipFile(zipPath)
  local entries = zip.entries()
  while entries.hasMoreElements() do
    local entry = entries.nextElement()
    local outFile = File(destDir, entry.getName())
    if entry.isDirectory() then
      outFile.mkdirs()
     else
      File(outFile.getParent()).mkdirs()
      local ins = BufferedInputStream(zip.getInputStream(entry))
      local outs = BufferedOutputStream(FileOutputStream(outFile))
      LuaUtil.copyFile(ins, outs)
      ins.close()
      outs.close()
    end
  end
  zip.close()
end

------------------------------------------------------------------
-- 显示安装确认对话框
function showInstallDialog(path, uri, config, callback, deleteFile)
  if not config then return end
  local mode = config.mode
  if mode ~= "plugin" and mode ~= nil then
    callback("failed")
    return
  end

  local packageName = config.packagename
  local message = string.format(
  "名称: %s\n版本: %s\n包名: %s\n作者: %s\n说明: %s\nURI: %s",
  config.appname, config.appver, packageName,
  config.developer, config.description, uri)

  local warningId
  local supported = config.supported2
  if supported then
    local limit = supported["LuaAppX2"]
    if limit then
      if limit.targetcode < versionCode then
        warningId = res.string.plugins_warning_update
      end
     else
      warningId = res.string.plugins_error_unsupported
    end
   else
    warningId = res.string.plugins_warning_supported
  end
  if warningId then
    message = message .. "\n\n" .. getString(warningId)
  end

  MaterialBlurDialogBuilder(activity)
  .setTitle(res.string.plugins_install)
  .setMessage(message)
  .setPositiveButton(res.string.install, function()
    local extractPath = PluginsUtil.getPluginPath(packageName)
    local extractDir = File(extractPath)
    if extractDir.exists() then
      LuaUtil.rmDir(extractDir)
    end
    -- 关键点：使用自己写的 unzipAll
    unzipAll(path, extractPath)
    PluginsUtil.clearOpenedPluginPaths()
    callback("success")
    if deleteFile then
      File(path).delete()
    end
  end)
  .setNegativeButton(res.string.no, nil)
  .show()
end
PluginsManagerUtil.showInstallDialog = showInstallDialog

------------------------------------------------------------------
-- 通过 URI 安装
function PluginsManagerUtil.installByUri(uri, callback)
  local scheme = uri.getScheme()
  local path, deleteFile

  if scheme == "content" then
    local ins = activity.getContentResolver().openInputStream(uri)
    path = PathUtil.cache_path .. "/" .. System.currentTimeMillis() .. ".zip"
    File(PathUtil.cache_path).mkdirs()
    local outs = FileOutputStream(path)
    LuaUtil.copyFile(ins, outs)
    ins.close(); outs.close()
    deleteFile = true
   elseif scheme == "file" or scheme == nil then
    path = uri.getPath()
    deleteFile = false
   else
    return
  end

  local ok, config = pcall(getAlpInfo, path)
  if not ok then
    MyToast(res.string.open_failed, config)
    return
  end

  -- 创建操作对象
  local operation = {
    path = path,
    deleteFile = deleteFile,
    callback = callback
  }
  table.insert(currentOperations, operation)
  
  local supported = config.supported2
  if supported then
    local limit = supported["LuaAppX2"]
    if limit then
      if limit.mincode > versionCode then
        MyToast(res.string.plugins_error_update_app)
        return
      end
     else
      MyToast(res.string.plugins_error_unsupported)
      return
    end
  end
  
  -- 使用包装回调以便在完成后移除操作
  local wrappedCallback = function(state)
    for i, op in ipairs(currentOperations) do
      if op == operation then
        table.remove(currentOperations, i)
        break
      end
    end
    callback(state)
  end
  
  showInstallDialog(path, uri, config, wrappedCallback, deleteFile)
end

------------------------------------------------------------------
-- 卸载插件
function PluginsManagerUtil.uninstall(path, config, callback)
  local dir = File(path)
  local dirName = dir.getName()
  
  -- 创建操作对象
  local operation = {
    path = path,
    callback = callback
  }
  table.insert(currentOperations, operation)
  
  -- 使用包装回调以便在完成后移除操作
  local wrappedCallback = function(state)
    for i, op in ipairs(currentOperations) do
      if op == operation then
        table.remove(currentOperations, i)
        break
      end
    end
    callback(state)
  end
  
  MaterialBlurDialogBuilder(activity)
  .setTitle((res.string.uninstall_withName):format(config.appname or dirName))
  .setMessage(res.string.plugins_uninstall_warning)
  .setPositiveButton(res.string.ok, function()
    if dir.exists() then
      LuaUtil.rmDir(dir)
      LuaUtil.rmDir(File(PluginsUtil.getPluginDataPath(dirName)))
      PluginsUtil.setEnabled(dirName, nil)
      PluginsUtil.clearOpenedPluginPaths()
      wrappedCallback("success")
     else
      wrappedCallback("failed")
    end
  end)
  .setNegativeButton(res.string.no, nil)
  .show()
end

return PluginsManagerUtil