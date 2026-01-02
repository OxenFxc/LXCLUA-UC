require "env"
setStatus()

-- 绑定Java类
local bindClass = luajava.bindClass
local StaggeredGridLayoutManager = bindClass "androidx.recyclerview.widget.StaggeredGridLayoutManager"
local Intent = bindClass "android.content.Intent"
local ObjectAnimator = bindClass "android.animation.ObjectAnimator"

-- 加载依赖库
local ProgressMaterialAlertDialog = require "dialogs.ProgressMaterialAlertDialog"
local MaterialBlurDialogBuilder = require "dialogs.MaterialBlurDialogBuilder"
local LuaRecyclerAdapter = require "utils.LuaRecyclerAdapter"
--local MarkDownUtil = require "utils.MarkDownUtil"
local PathUtil = require "utils.PathUtil"
local FileUtil = require "utils.FileUtil"
local Utils = require "utils.Utils"
local GlideUtil = require "utils.GlideUtil"
local IconDrawable = require "utils.IconDrawable"
local OkHttpUtil = require "utils.OkHttpUtil"

-- 常量定义
local VIEW_VISIBLE = 0
local VIEW_GONE = 8
local PREVIEW_IMAGE_NAME = "Preview.png"
local DEFAULT_TEMPLATE_NAME = "Default"
local TEXT_FORMATS = {zip = true, alp = true}

-- 全局变量
local selectedPosition = 0
local templateName = DEFAULT_TEMPLATE_NAME
local currentProjectPath = ""
local currentTemplateList = {}
local path -- 图标路径
local adapter, Anim -- 适配器和动画对象

-- ===== 项目管理模块 =====
local ProjectManager = {
  generateDefaultName = function()
    local baseName = "My Application"
    local counter = 1
    while FileUtil.isExist(PathUtil.project_path .. "/" .. baseName .. counter) do
      counter = counter + 1
    end
    return baseName .. counter
  end,

  createProject = function()
    local nameText = name.getText()
    local packageText = package.getText()
    local projectPath = PathUtil.project_path .. "/" .. nameText

    -- 验证输入
    if nameText == "" then
      name.setError(res.string.please_enter_a_project_name)
      return
     elseif packageText == "" then
      package.setError(res.string.please_enter_a_project_package_name)
      return
     elseif FileUtil.isExist(projectPath) then
      name.setError(res.string.an_item_with_the_same_name_already_exists)
      return
    end

    -- 创建项目
    if FileUtil.createDirectory(projectPath) then
      local wait_dialog = ProgressMaterialAlertDialog(activity).show()
      activity.newTask(function(templateName, projectPath, nameText, packageText, path, debugmode)
        local PathUtil = require "utils.PathUtil"
        local FileUtil = require "utils.FileUtil"

        -- 解压模板
        FileUtil.unzip(PathUtil.templates_path .. "/" .. templateName .. ".zip", projectPath)

        -- 替换占位符
        FileUtil.replaceFileString(projectPath .. "/manifest.json", "AppName", nameText)
        FileUtil.replaceFileString(projectPath .. "/manifest.json", "PackageName", packageText)
        FileUtil.replaceFileString(projectPath .. "/manifest.json", ": Debug", ": " .. tostring(debugmode.isChecked()))
        FileUtil.replaceFileString(projectPath .. "/main.lua", "AppName", nameText)

        -- 清理和添加图标
        FileUtil.remove(projectPath .. "/Preview.png")
        if path then
          FileUtil.copy(path, projectPath .. "/icon.png")
        end
        end, function()
        wait_dialog.dismiss()
        activity.result({ res.string.created_successfully })
        activity.finish()
      end).execute({templateName, projectPath, nameText, packageText, path, debugmode})
    end
  end
}

-- ===== UI管理模块 =====
local UIManager = {
  setupTextListeners = function()
    name.addTextChangedListener({
      onTextChanged = function(s)
        local input = tostring(s)
        currentProjectPath = PathUtil.project_path .. "/" .. input

        -- 自动生成包名
        activity.newTask(function(input)
          local PinyinUtil = require "utils.PinyinUtil"
          return string.lower(PinyinUtil.hanziToPinyin(input))
          end, function(s)
          package.setText("dcore." .. s:gsub("-", "."))
        end).execute({input})

        -- 验证项目名称
        if input == "" then
          name.setError(res.string.please_enter_a_project_name)
         else
          name.setErrorEnabled(false)
        end
      end
    })
  end,

  adjustLayoutParams = function()
    fab.post(function()
      local params = recycler_view.getLayoutParams()
      params.setMargins(0, 0, 0, fab.getHeight() + dp2px(32))
      recycler_view.setLayoutParams(params)
    end)
  end,

  -- 确保数据加载完成后再初始化UI
  loadTemplatesAfterData = function(data)
    Anim = ObjectAnimator.ofFloat(recycler_view, "alpha", {0, 1}).setDuration(400)

    adapter = LuaRecyclerAdapter(data, "layouts.template_item", {
      onBindViewHolder = function(viewHolder, pos, views, data)
        -- 设置选择状态
        views.check.setVisibility(selectedPosition == pos and VIEW_VISIBLE or VIEW_GONE)

        -- 显示模板信息
        views.name.setText(data.name)
        GlideUtil.set(data.src, views.icon)

        -- 点击选择模板
        views.card.onClick = function()
          selectedPosition = pos
          templateName = data.name
          adapter.notifyDataSetChanged()
        end

        -- 长按删除模板
        activity.onLongClick(views.card, function()
          if data.name == DEFAULT_TEMPLATE_NAME then
            MyToast(res.string.inoperable)
            return true
          end

          MaterialBlurDialogBuilder(activity)
          .setTitle(res.string.tip)
          .setMessage(res.string.import_template_tip2:format(data.name))
          .setPositiveButton(res.string.ok, function()
            local wait_dialog = ProgressMaterialAlertDialog(activity).show()
            activity.newTask(function(name)
              local FileUtil = require "utils.FileUtil"
              local PathUtil = require "utils.PathUtil"
              local success = FileUtil.remove(PathUtil.templates_path .. "/" .. name .. ".zip")
              return success
              end, function(success)
              if data.name == templateName then
                templateName = DEFAULT_TEMPLATE_NAME
                selectedPosition = 0
              end
              -- 重新加载数据而不是直接刷新UI
              getList()
              wait_dialog.dismiss()
              MyToast(success and res.string.deleted_successfully or res.string.delete_failed)
            end).execute({ data.name })
          end)
          .setNegativeButton(res.string.no, nil)
          .show()
          return true
        end)
      end
    })

    recycler_view
    .setAdapter(adapter)
    .setLayoutManager(StaggeredGridLayoutManager(2, StaggeredGridLayoutManager.VERTICAL))

    -- 启动淡入动画
    if Anim and not Anim.isStarted() then
      Anim.start()
    end
  end
}

-- ===== 模板管理函数 =====
-- 获取模板列表（带回调）
function getList()
  activity.newTask(FileUtil.traversalTemplate, function(list)
    local rawList = luajava.astable(list)
    local processedList = {}

    for _, path in ipairs(rawList) do
      local name = path:match(".+/(.+)%..+$")

      xpcall(function()
        previewImage = FileUtil.getBitmapFromZip(path, PREVIEW_IMAGE_NAME) or
        FileUtil.getBitmapFromZip(activity.getLuaDir("res/templates/Default.zip"), PREVIEW_IMAGE_NAME)
        end, function()
        previewImage = FileUtil.getBitmapFromZip(activity.getLuaDir("res/templates/Default.zip"), PREVIEW_IMAGE_NAME)
      end)

      local template = {
        name = name,
        src = previewImage,
        path = path
      }

      if name == DEFAULT_TEMPLATE_NAME then
        table.insert(processedList, 1, template)
       else
        table.insert(processedList, template)
      end
    end

    -- 确保至少有一个模板
    if #processedList == 0 then
      -- 添加默认模板
      local defaultPath = activity.getLuaDir("res/templates/Default.zip")
      local previewImage = FileUtil.getBitmapFromZip(defaultPath, PREVIEW_IMAGE_NAME)
      table.insert(processedList, {
        name = DEFAULT_TEMPLATE_NAME,
        src = previewImage,
        path = defaultPath
      })
    end

    -- 更新全局列表
    currentTemplateList = processedList

    -- 在UI线程初始化适配器
    activity.runOnUiThread(function()
      UIManager.loadTemplatesAfterData(currentTemplateList)
    end)
  end).execute()
end

-- ===== 其他功能函数 =====
-- 处理返回结果
function onActivityResult(requestCode, resultCode, intent)
  if not intent then return end

  local uri = intent.data
  if requestCode == 1 then -- 图标选择
    path = Utils.uri2path(uri)
    GlideUtil.set(path, icon)
   elseif requestCode == 2 then -- 模板导入
    local path = Utils.uri2path(uri)
    local ext = FileUtil.getFileExtension(path)

    if not TEXT_FORMATS[ext] then
      MyToast(res.string.please_select_a_zip_films)
      return
    end

    MaterialBlurDialogBuilder(activity)
    .setTitle(res.string.import_template)
    .setMessage(res.string.import_template_tip:format(FileUtil.getName(path), path))
    .setPositiveButton(res.string.ok, function()
      local wait_dialog = ProgressMaterialAlertDialog(activity).show()
      activity.newTask(function()
        local dest = PathUtil.templates_path .. "/" .. FileUtil.getName(path)
        return FileUtil.copy(path, dest)
        end, function(success)
        getList() -- 重新加载模板列表
        wait_dialog.dismiss()
        MyToast(success and res.string.import_successful or res.string.import_failed)
      end).execute()
    end)
    .show()
  end
end

-- 菜单处理
function onOptionsItemSelected(item)
  if item.getItemId() == android.R.id.home then
    activity.finish()
    return true
  end
end

-- 创建菜单
function onCreateOptionsMenu(menu)
  menu.add(res.string.import_template)
  .onMenuItemClick = function()
    activity.startActivityForResult(
    Intent(Intent.ACTION_GET_CONTENT)
    .setType("*/*")
    .addCategory(Intent.CATEGORY_OPENABLE),
    2
    )
  end

  local menu1 = menu.addSubMenu(res.string.official_template)

  OkHttpUtil.post(false, "https://luaappx.top/templates/api/get_templates.php", {
    time = os.time()
    }, nil, function (code, body)
    local success, v = pcall(OkHttpUtil.decode, body)
    if success and v then
      for k, v in pairs(v.templates) do
        local filename = FileUtil.getFileNameWithoutExt(tostring(v.filename))
        menu1.add(filename)
        .onMenuItemClick = function()
          MaterialBlurDialogBuilder(activity)
          .setTitle(res.string.tip)
          .setMessage((res.string.official_template_tip):format(filename))
          .setPositiveButton(res.string.ok, function()
            OkHttpUtil.download(
            true,
            v.link,
            PathUtil.templates_path .. "/" .. filename .. ".zip",
            nil,
            function(code, message)
              if code == 200 then
                MyToast(res.string.download_successful)
                getList()
               else
                MyToast(res.string.download_failed .. "." .. message)
                getList()
              end
              dialog_okhttp3.dismiss()
            end
            )
          end)
          .setNegativeButton(res.string.no, nil)
          .show()
        end
      end
    end
  end)

end

-- 清理资源
function onDestroy()
  adapter.release()
  luajava.clear()
  collectgarbage("collect")
  collectgarbage("step")
end

-- ===== 主执行逻辑 =====
-- 设置界面
activity
.setContentView(loadlayout("layouts.activity_new_project"))
.setSupportActionBar(toolbar)
.getSupportActionBar()
.setDisplayHomeAsUpEnabled(true)

-- 初始化UI
UIManager.setupTextListeners()
UIManager.adjustLayoutParams()
Utils.changed(package) -- 初始化包名输入框

-- 设置项目名称
name.setText(tostring(ProjectManager.generateDefaultName()))

-- 加载模板（关键修复：先加载数据再初始化UI）
getList()

-- 设置按钮事件
fab.onClick = function()
  ProjectManager.createProject()
end

choose.onClick = function()
  activity.startActivityForResult(
  Intent(Intent.ACTION_PICK)
  .setType("image/*"),
  1
  )
end