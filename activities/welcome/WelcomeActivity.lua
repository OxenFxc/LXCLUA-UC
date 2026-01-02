require "env"
setStatus()

-- 统一导入类和方法
local bindClass = luajava.bindClass
local ActivityUtil = require "utils.ActivityUtil"
local PermissionUtil = require "utils.PermissionUtil"
local LuaRecyclerAdapter = require "utils.LuaRecyclerAdapter"

-- Android 类
local Activity = bindClass "android.app.Activity"
local ViewPager = bindClass "androidx.viewpager.widget.ViewPager"
local PackageManager = bindClass "android.content.pm.PackageManager"
local LinearLayoutManager = bindClass "androidx.recyclerview.widget.LinearLayoutManager"
local Html = bindClass "android.text.Html"
local Intent = bindClass "android.content.Intent"
local Environment = bindClass "android.os.Environment"
local Uri = bindClass "android.net.Uri"
local Build = bindClass "android.os.Build"
local Settings = bindClass "android.provider.Settings"
local FastScrollerBuilder = import "me.zhanghai.android.fastscroll.FastScrollerBuilder"

-- 常量定义
local MAX_PAGE = 3
local PERMISSIONS = {
  {
    zh = Build.VERSION.SDK_INT >= 30 and
    res.string.all_file_acc or
    res.string.write_to_external_storage,
    en = Build.VERSION.SDK_INT >= 30 and
    "android.permission.MANAGE_EXTERNAL_STORAGE" or
    "android.permission.WRITE_EXTERNAL_STORAGE",
    action = function()
      if Build.VERSION.SDK_INT >= 30 then
        return Settings.ACTION_MANAGE_APP_ALL_FILES_ACCESS_PERMISSION
       else
        return Settings.ACTION_APPLICATION_DETAILS_SETTINGS
      end
    end
  },
  {
    zh = res.string.install_application,
    en = "android.permission.REQUEST_INSTALL_PACKAGES",
    action = function()
      if Build.VERSION.SDK_INT >= 26 then
        return Settings.ACTION_MANAGE_UNKNOWN_APP_SOURCES
       else
        return nil
      end
    end
  }
}

-- ===== 辅助函数 =====

-- 启动设置界面
local function startSettingsActivity(action)
  if not action then
    PermissionUtil.request({ PERMISSIONS[1].en })
    return
  end
  local intent = Intent(action)
  intent.setData(Uri.parse("package:" .. activity.getPackageName()))
  activity.startActivityForResult(intent, 2296)
end

-- 更新下一步按钮透明度
local function updateNextButtonAlpha(enabled)
  next.setAlpha(enabled and 1 or 0.5)
end

-- 检查权限状态
local function checkPermissionStatus(position)
  local permission = PERMISSIONS[position + 1]
  switch position
   case 0
    if Build.VERSION.SDK_INT >= 30 then
      return Environment.isExternalStorageManager()
     else
      return PermissionUtil.checkPermission(permission.en)
    end
   case 1
    if Build.VERSION.SDK_INT >= 26 then
      return activity.getPackageManager().canRequestPackageInstalls()
     else
      return true
    end
  end
  return PermissionUtil.checkPermission(permission.en)
end

-- 创建适配器
local function createAdapter()
  return LuaRecyclerAdapter(PERMISSIONS, "layouts.authority_item", {
    onBindViewHolder = function(viewHolder, pos, views)
      local data = PERMISSIONS[pos + 1]
      views.name.text = data.zh
      views.text.text = data.en
      views.card.setChecked(checkPermissionStatus(pos))

      -- 权限项点击处理
      views.card.onClick = function()
        if pos == 0 then -- 存储权限
          if Build.VERSION.SDK_INT >= 30 then
            if not checkPermissionStatus(0) then
              startSettingsActivity(data.action())
            end
           else
            if not checkPermissionStatus(0) then
              PermissionUtil.request({data.en})
            end
          end
         elseif pos == 1 then -- 安装权限
          if Build.VERSION.SDK_INT >= 26 then
            if not checkPermissionStatus(1) then
              startSettingsActivity(data.action())
            end
           else
            views.card.setChecked(true)
          end
         else
          PermissionUtil.request({data.en})
        end
      end
    end
  })
end

-- 创建页面切换动画
local function createPageTransformer()
  return luajava.createProxy("androidx.viewpager.widget.ViewPager$PageTransformer", {
    transformPage = function(page, position)
      page.setTranslationX(0)
      if position < -1 or position > 1 then
        page.setAlpha(0)
       else
        local scale = math.max(0.85, 1 - math.abs(position))
        page.setScaleX(scale)
        page.setScaleY(scale)
        page.setAlpha(1 - math.abs(position))
      end
    end
  })
end

-- ===== 主执行逻辑 =====

-- 设置界面
activity.setContentView(loadlayout("layouts.activity_welcome"))

-- 初始化协议文本
local agreementPath = activity.getLuaDir("activities/welcome/agreements/UserAgreement.html")
textView.setText(Html.fromHtml(io.open(agreementPath):read("*a")))
FastScrollerBuilder(scrollView).useMd2Style().build()

-- 配置 ViewPager
vpg.setPageTransformer(true, createPageTransformer())

-- 页面切换监听
vpg.setOnPageChangeListener(ViewPager.OnPageChangeListener {
  onPageSelected = function(position)
    indicator.setProgressCompat((position / MAX_PAGE) * 100, true)
    previous.setVisibility(position == 0 and 4 or 0)

    -- 根据页面位置更新按钮状态
    if position == 0 then
      updateNextButtonAlpha(true)
     elseif position == 1 then
      updateNextButtonAlpha(checkPermissionStatus(0))
    end
  end
})

-- 设置按钮事件
previous.onClick = function()
  if vpg.currentItem > 0 then
    vpg.setCurrentItem(vpg.currentItem - 1)
  end
end

next.onClick = function()
  if next.alpha == 0.5 then return end
  local targetPage = vpg.currentItem + 1
  if targetPage < MAX_PAGE then
    vpg.setCurrentItem(targetPage)
   else
    activity.setSharedData("welcome", true)
    ActivityUtil.new("main")
    activity.finish()
  end
end

-- 初始化权限列表
recycler_view.setLayoutManager(LinearLayoutManager(activity)).setAdapter(createAdapter())

-- ===== 生命周期函数 =====

-- 处理返回结果
function onActivityResult(req, resx, intent)
  if req == 2296 then
    -- 更新权限状态
    updateNextButtonAlpha(checkPermissionStatus(0))
    recycler_view.adapter.notifyDataSetChanged()
  end
end

-- 清理资源
function onDestroy()
  recycler_view.adapter.release()
  luajava.clear()
  collectgarbage("collect")
  collectgarbage("step")
end
