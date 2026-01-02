require "env"
setStatus()
local bindClass = luajava.bindClass
local LinearLayoutManager = bindClass "androidx.recyclerview.widget.LinearLayoutManager"
local ObjectAnimator = bindClass "android.animation.ObjectAnimator"
local RecyclerView = bindClass "androidx.recyclerview.widget.RecyclerView"
local LuaCustRecyclerHolder = bindClass "github.znzsofficial.adapter.LuaCustRecyclerHolder"
local PopupRecyclerAdapter = bindClass "github.znzsofficial.adapter.PopupRecyclerAdapter"
local FileUtil = require "utils.FileUtil"
local MaterialBlurDialogBuilder = require "dialogs.MaterialBlurDialogBuilder"
local PathUtil = require "utils.PathUtil"
local Utils = require "utils.Utils"
local cjson = require "cjson"
local Handler=luajava.bindClass "android.os.Handler"
local lastUpdateTime = System.currentTimeMillis() -- 使用系统毫秒时间
local updateHandler = Handler()
local updateQueue = {} --消息队列
local data = {}
project = ...


activity
.setContentView(loadlayout("layouts.activity_build"))
.setSupportActionBar(toolbar)
.getSupportActionBar()
.setDisplayHomeAsUpEnabled(true)



local function refreshMessage()
  if #updateQueue == 0 then return end

  --插入消息队列
  for i, msg in ipairs(updateQueue) do
    table.insert(data, msg)
  end
  updateQueue = {}

  adapter.notifyItemRangeInserted(#data - #updateQueue, #updateQueue)
  recycler_view.scrollToPosition(adapter.getItemCount() - 1)
end

function update(message)
  local now = System.currentTimeMillis()
  table.insert(updateQueue, tostring(message))

  --错误消息
  if message:find("error") or message:find("failed") then
    refreshMessage()
    lastUpdateTime = now
    return
  end
  --更新频率
  if now - lastUpdateTime > 1000 then
    refreshMessage()
    lastUpdateTime = now
   else
    --延迟处理消息，打包初始化时任务量较大，延迟更新主线程的首次打包信息
    updateHandler.removeCallbacksAndMessages(nil)
    updateHandler.postDelayed(refreshMessage, 150)
  end
end



function callback(s)
  update(s)
  if s:find("successful") then
    MaterialBlurDialogBuilder(activity)
    .setTitle(res.string.tip)
    .setMessage(s)
    .setPositiveButton(res.string.install, function()
      activity.installApk(tostring(s:match(": (.+)")))
    end)
    .setNegativeButton(res.string.no, nil)
    .show()
  end
end

local function binapk(luapath, apkpath, message)
  local luapath = luapath .. "/"
  require "import"
  import "console"
  local bindClass = luajava.bindClass
  compile"mao"
  compile"sign"
  local LuaUtil = bindClass"com.difierline.lua.LuaUtil"
  local ZipEntry = bindClass"java.util.zip.ZipEntry"
  local FileOutputStream = bindClass"java.io.FileOutputStream"
  local ZipOutputStream = bindClass"java.util.zip.ZipOutputStream"
  local ZipInputStream = bindClass"java.util.zip.ZipInputStream"
  local BufferedOutputStream = bindClass"java.io.BufferedOutputStream"
  local BufferedInputStream = bindClass"java.io.BufferedInputStream"
  local FileInputStream = bindClass"java.io.FileInputStream"
  local ApkEditor = bindClass"com.zzzmode.apkeditor.ApkEditor"
  local Signer = import "apksigner.Signer"
  local File = bindClass"java.io.File"
  local replace = {}

  -- 文件复制工具函数
  local function copy(input, output)
    LuaUtil.copyFile(input, output)
    input.close()
  end

  -- 文件复制工具函数（不关闭输入流）
  local function copy2(input, output)
    LuaUtil.copyFile(input, output)
  end

  -- 确保输出目录存在
  update("Checking output directory...")

  local temp = File(apkpath).getParentFile();

  if (not temp.exists()) then
    if (not temp.mkdirs()) then
      error("create file " .. temp.getName() .. " fail");
    end
  end

  -- 准备临时文件
  local tmp = activity.getLuaPath("tmp.apk")
  local tmp2 = activity.getLuaPath("tmp2.apk")

  local info = activity.getApplicationInfo()
  local ver = activity.getPackageManager().getPackageInfo(activity.getPackageName(), 0).versionName
  local code = activity.getPackageManager().getPackageInfo(activity.getPackageName(), 0).versionCode

  lualib = {}
  local md5s = {}

  -- 获取原生库列表
  update("Collecting native libraries...")
  local libs = File(activity.ApplicationInfo.nativeLibraryDir).list()
  libs = luajava.astable(libs)
  for k, v in ipairs(libs) do
    replace[v] = true
  end

  local mdp = activity.Application.MdDir
  -- 递归获取模块文件
  local function getmodule(dir)
    local mds = File(activity.Application.MdDir .. dir).listFiles()
    mds = luajava.astable(mds)
    for k, v in ipairs(mds) do
      if mds[k].isDirectory() then
        getmodule(dir .. mds[k].Name .. "/")
       else
        mds[k] = "lua" .. dir .. mds[k].Name
        replace[mds[k]] = true
      end
    end
  end

  getmodule("/")

  local zipFile = File(info.publicSourceDir)
  local fis = FileInputStream(zipFile);
  local zis = ZipInputStream(BufferedInputStream(fis));

  -- 创建输出流
  local fot = FileOutputStream(tmp)
  local out = ZipOutputStream(BufferedOutputStream(fot))
  local f = File(luapath)
  local errbuffer = {}
  local checked = {}
  local lualib = {}
  local md5s = {}

  -- 检查并处理依赖库
  local function checklib(path)
    if checked[path] then
      return
    end
    local cp, lp
    checked[path] = true
    local f = io.open(path)
    local s = f:read("*a")
    f:close()

    -- 提取模块名的通用函数
    local function process_require_import(modulename)
      -- 按点分割模块名
      local parts = {}
      for part in modulename:gmatch("([%w_]+)") do
        table.insert(parts, part)
      end
      if #parts == 0 then return end

      -- 生成C路径和Lua路径
      cp = string.format("lib%s.so", parts[1])
      lp = "lua/" .. table.concat(parts, "/") .. ".lua"

      -- 处理C路径
      if replace[cp] then
        replace[cp] = false
        update("Keeping native library: " .. cp)
      end

      -- 处理Lua路径
      if replace[lp] then
        -- 生成实际文件路径（假设mdp是模块基础路径）
        local filepath = mdp .. "/" .. table.concat(parts, "/") .. ".lua"
        checklib(filepath)
        replace[lp] = false
        update("Processing Lua module: " .. lp)
        lualib[lp] = filepath
      end
    end

    -- 匹配require语句（支持带括号和不带括号）
    for modulename in s:gmatch("require%s*%(?%s*\"([%w%.%_]+)\"") do
      process_require_import(modulename)
    end

    -- 匹配import语句（支持带括号和不带括号）
    for modulename in s:gmatch("import%s*%(?%s*\"([%w%.%_]+)\"") do
      process_require_import(modulename)
    end
  end

  replace["libluajava.so"] = false

  -- 检查文件是否在跳过编译列表中
  local function is_include(value, tab)
    for k, v in ipairs(luajava.astable(tab)) do
      if luapath .. v == value then
        return true
      end
    end
    return false
  end

  -- 递归添加目录到APK
  local function addDir(out, dir, f)
    update("Processing directory: assets/" .. dir)
    local entry = ZipEntry("assets/" .. dir)
    out.putNextEntry(entry)
    local ls = f.listFiles()

    for n = 0, #ls - 1 do

      local name = ls[n].getName()
      if dir == "" and name == "solibs" then
        update("Skipping solibs directory in assets")
       elseif name == (".using") then
        update("Checking dependencies for: " .. dir .. name)
        checklib(luapath .. dir .. name)
       elseif name:find("%.apk$") or name:find("%.luac$") or name:find("^%.") then
        -- 跳过不需要处理的文件
       elseif name:find("%.lua$") then
        update("Processing Lua file: " .. dir .. name)
        checklib(luapath .. dir .. name)
        Compile_TRUR = true

        if not is_include(tostring(luapath .. dir .. name), message.skip_compilation) then
          if message.compilation == true or message.compilation == nil then
            update("Compiling Lua: " .. dir .. name)
            path, err = console.build(luapath .. dir .. name)
           elseif message.compilation == false then
            path = luapath .. dir .. name
            Compile_TRUR = false
            update("Skipping compilation for: " .. dir .. name)
          end
         else
          path = luapath .. dir .. name
          Compile_TRUR = false
          update("Skipping compilation (excluded): " .. dir .. name)
        end

        if path then
          if replace["assets/" .. dir .. name] then
            table.insert(errbuffer, dir .. name .. "/.aly")
          end
          local entry = ZipEntry("assets/" .. dir .. name)
          out.putNextEntry(entry)

          replace["assets/" .. dir .. name] = true
          copy(FileInputStream(File(path)), out)
          table.insert(md5s, LuaUtil.getFileMD5(path))
          if Compile_TRUR then
            os.remove(path)
          end
         else
          table.insert(errbuffer, err)
          update("Compilation failed: " .. dir .. name .. " - " .. err)
        end
       elseif name:find("%.aly$") then
        update("Processing ALY file: " .. dir .. name)
        checklib(luapath .. dir .. name)
        Compile_TRUR = true

        if not is_include(tostring(luapath .. dir .. name), message.skip_compilation) then
          if message.compilation == true or message.compilation == nil then
            update("Compiling ALY: " .. dir .. name)
            path, err = console.build_aly(luapath .. dir .. name)
            name = name:gsub("aly$", "lua")
           elseif message.compilation == false then
            path = luapath .. dir .. name
            Compile_TRUR = false
            name = name:gsub("aly$", "aly")
            update("Skipping ALY compilation: " .. dir .. name)
          end
         else
          path = luapath .. dir .. name
          Compile_TRUR = false
          name = name:gsub("aly$", "aly")
          update("Skipping ALY compilation (excluded): " .. dir .. name)
        end

        if path then
          if replace["assets/" .. dir .. name] then
            table.insert(errbuffer, dir .. name .. "/.aly")
          end
          local entry = ZipEntry("assets/" .. dir .. name)
          out.putNextEntry(entry)
          replace["assets/" .. dir .. name] = true
          copy(FileInputStream(File(path)), out)
          table.insert(md5s, LuaUtil.getFileMD5(path))
          if Compile_TRUR then
            os.remove(path)
          end
         else
          table.insert(errbuffer, err)
          update("ALY compilation failed: " .. dir .. name .. " - " .. err)
        end
       elseif ls[n].isDirectory() then
        update("Entering subdirectory: " .. dir .. name .. "/")
        addDir(out, dir .. name .. "/", ls[n])
       else
        update("Adding resource file: " .. dir .. name)
        local entry = ZipEntry("assets/" .. dir .. name)
        out.putNextEntry(entry)
        replace["assets/" .. dir .. name] = true
        copy(FileInputStream(ls[n]), out)
        table.insert(md5s, LuaUtil.getFileMD5(ls[n]))
      end
    end
    update("Finished processing directory: assets/" .. dir)
  end



  -- 处理自定义so库
  local function customSolibs(p)
    update("Processing shared libraries...")
    local lualibsDir = luajava.astable(File(p).listFiles() or {})
    for _, v in pairs(lualibsDir) do
      if v.isFile() and v.name:find("%.so$") then
        local archDir = v.getParentFile().getName()
        if archDir == "arm64-v8a" or archDir == "armeabi-v7a" then
          local spath = "lib/" .. archDir .. "/" .. v.name
          local entry = ZipEntry(spath)
          out.putNextEntry(entry)
          replace[spath] = true
          copy(FileInputStream(tostring(v)), out)
          table.insert(md5s, LuaUtil.getFileMD5(tostring(v)))
        end
       elseif v.isDirectory() then
        customSolibs(tostring(v))
      end
    end
  end

  -- 处理自定义SO库目录
  if File(luapath .. "/solibs").isDirectory() then
    update("Adding custom shared libraries...")
    customSolibs(luapath .. "/solibs")
  end

  -- 开始编译阶段
  update("Compiling Lua scripts...")
  if f.isDirectory() then

    -- 加载init.lua配置（旧版兼容性）
    local p = {}
    local e, s = pcall(loadfile(luapath .. "init.lua", "bt", p))
    if e then
      update("Loading configuration from init.lua...")
      -- 合并init.lua配置到message中
      message.appname = p.appname or message.label
      message.appver = p.appver or message.versionName
      message.appcode = p.appcode or message.versionCode
      message.appsdk = p.appsdk or message.targetSdkVersion
      message.packagename = p.packagename or message.package
    end

    -- 添加主目录
    local ss, ee = pcall(addDir, out, "", f)
    if not ss then
      table.insert(errbuffer, ee)
      update("Directory processing error: " .. ee)
    end

    -- 添加应用图标
    local wel = File(luapath .. "icon.png")
    if wel.exists() then
      update("Adding application icon...")
      local entry = ZipEntry("res/drawable/icon.png")
      out.putNextEntry(entry)
      replace["res/drawable/icon.png"] = true
      copy(FileInputStream(wel), out)
    end

    -- 添加欢迎图片（旧版兼容性）
    local welcome = File(luapath .. "welcome.png")
    if welcome.exists() then
      update("Adding welcome image...")
      local entry = ZipEntry("res/drawable/welcome.png")
      out.putNextEntry(entry)
      replace["res/drawable/welcome.png"] = true
      copy(FileInputStream(welcome), out)
    end
   else
    update("Invalid directory: " .. luapath)
    return "error"
  end

  -- 处理Lua模块
  update("Processing Lua modules...")
  for name, v in pairs(lualib) do
    update("Building module: " .. name)
    local path, err = console.build(v)
    if path then
      local entry = ZipEntry(name)
      out.putNextEntry(entry)
      copy(FileInputStream(File(path)), out)
      table.insert(md5s, LuaUtil.getFileMD5(path))
      os.remove(path)
     else
      table.insert(errbuffer, err)
      update("Module build failed: " .. name .. " - " .. err)
    end
  end

  -- 打包阶段
  update("Packaging APK...")
  function touint32(i)
    local code = string.format("%08x", i)
    local uint = {}
    for n in code:gmatch("..") do
      table.insert(uint, 1, string.char(tonumber(n, 16)))
    end
    return table.concat(uint)
  end

  local entry = zis.getNextEntry();
  while entry do
    local name = entry.getName()
    local lib = name:match("([^/]+%.so)$")
    if replace[name] then
    elseif lib and replace[lib] then
    elseif name:find("^assets/") then
    elseif name:find("^lua/") then
    elseif name:find("META%-INF") then
    elseif not name:find("%a") then
    else
      local entry = ZipEntry(name)
      out.putNextEntry(entry)
      if not entry.isDirectory() then
        copy2(zis, out)
      end
    end
    entry = zis.getNextEntry()
  end
  out.setComment(table.concat(md5s))
  zis.close();
  out.closeEntry()
  out.close()

  --添加权限头
  function addPermissionPrefix(permissions)
    local prefixed = {}
    for i, perm in ipairs(permissions) do
      table.insert(prefixed, "android.permission." .. perm)
    end
    return prefixed
  end

  -- 错误处理和签名阶段
  if #errbuffer == 0 then
    os.remove(apkpath)

    editor = ApkEditor()
    .setOrigFile(tmp)
    .setOutFile(tmp2)
    .setAppName(message.label)
    .setVersionName(message.versionName)
    .setVersionCode(message.versionCode)
    .setMinSdkVersion(tonumber(message.minSdkVersion))
    .setTargetSdkVersion(tonumber(message.targetSdkVersion))
    .setPackageName(message["package"])
    .setPermissions(addPermissionPrefix(luajava.astable(message.user_permission)))
    .setSharedUserId(message.sharedUserId or "")

    .setCreateListener({
      onStart = function ()
        update("APK modification started")
      end ,

      onProgress = function (step, message) 
        update(message)
      end ,

      onError = function (e)
        return "Build error: " .. e
      end ,

      onComplete = function ()
        update("Process completed")
        editor.shutdown()
      end,

    })

    local future = editor.create()

    Signer.sign(tmp2, apkpath)
    os.remove(tmp)
    os.remove(tmp2)
    return "Build successful: " .. apkpath

   else
    os.remove(tmp)
    return "Build error:\n " .. table.concat(errbuffer, "\n")
  end
end

-- 解析manifest.json文件
local function parseManifest(manifestPath)
  update("Parsing manifest.json...")
  if not FileUtil.isExist(manifestPath) then return end
  local success, content = pcall(FileUtil.read, manifestPath)
  if not success then return end
  local v = cjson.decode(content)
  local application = v.application
  local jmp = v.jmp or {}
  local uses_sdk = v.uses_sdk

  if not v then return end
  return {
    label = application.label or "My Application",
    enableOnBackInvokedCallback = application.enableOnBackInvokedCallback,
    requestLegacyExternalStorage = application.requestLegacyExternalStorage,
    sharedUserId = application.sharedUserId or "",
    versionName = v.versionName or "1.0",
    versionCode = v.versionCode or "1",
    minSdkVersion = uses_sdk.minSdkVersion or "21",
    targetSdkVersion = uses_sdk.targetSdkVersion or "29",
    package = v.package or "dcore.myapplication",
    user_permission = v.user_permission or {},
    compilation = v.compilation,
    skip_compilation = v.skip_compilation or {},
    encryption = jmp.encryption or false,
    dump_obfuscate = jmp.dump_obfuscate or false
  }
end

luajava.newInstance("me.zhanghai.android.fastscroll.FastScrollerBuilder", recycler_view)
.useMd2Style()
.setPadding(0, dp2px(8), dp2px(2), dp2px(8))
.build()

adapter = PopupRecyclerAdapter(activity, PopupRecyclerAdapter.PopupCreator({
  getItemCount = function()
    return #data
  end,
  getItemViewType = function()
    return 0
  end,
  getPopupText = function(view, position)
    return ""
  end,
  onViewRecycled = function(holder)
  end,
  onCreateViewHolder = function(parent, viewType)
    local views = {}
    local holder = LuaCustRecyclerHolder(loadlayout("layouts.build_item", views))
    holder.Tag = views
    return holder
  end,
  onBindViewHolder = function(holder, position)
    local views = holder.Tag
    local data = data[position+1]
    if data:find("failed") or data:find("error") then
      views.card.setStrokeColor(Colors.colorError)
      views.title.setTextColor(Colors.colorError)
     else
      views.card.setStrokeColor(Colors.colorSurfaceVariant)
      views.title.setTextColor(Colors.colorPrimary)
    end
    views.title.setText(data)
  end
}))

recycler_view.setAdapter(adapter).setLayoutManager(LinearLayoutManager(activity))
recycler_view.addItemDecoration(RecyclerView.ItemDecoration {
  getItemOffsets = function(outRect, view, parent, state)
    Utils.modifyItemOffsets(outRect, view, parent, adapter, 14)
  end
})

task(100, function()
  local success, message = pcall(parseManifest, project .. "/manifest.json")
  if success and message then
    activity.newTask(binapk, update, callback).execute({project, PathUtil.bin_path .. "/" .. message.label .. "_" .. message.versionName .. ".apk", message})
   else
    update(res.string.engineering_configuration_file_error .. ": \n" .. tostring(message))
  end
end)

function onOptionsItemSelected(item)
  if item.getItemId() == android.R.id.home then
    activity.finish()
    return true
  end
end

function onDestroy()

end