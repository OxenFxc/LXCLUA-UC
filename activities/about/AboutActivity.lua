require "env"
setStatus()

-- 导入依赖
local bindClass = luajava.bindClass
local SimpleMenuPopupWindow = bindClass "com.difierline.lua.material.menu.SimpleMenuPopupWindow"
local Intent = bindClass "android.content.Intent"
local Uri = bindClass "android.net.Uri"
local LinearLayoutManager = bindClass "androidx.recyclerview.widget.LinearLayoutManager"
local RecyclerView = bindClass "androidx.recyclerview.widget.RecyclerView"
local MaterialBlurDialogBuilder = require "dialogs.MaterialBlurDialogBuilder"
local ActivityUtil = require "utils.ActivityUtil"
local SettingsLayUtil = require "activities.settings.SettingsLayUtil"
local PluginsUtil = require "activities.plugins.PluginsUtil"
local Utils = require "utils.Utils"

-- 初始化UI
activity
.setContentView(loadlayout("layouts.activity_about"))
.setSupportActionBar(toolbar)
.getSupportActionBar()
.setDisplayHomeAsUpEnabled(true)

-- 获取应用信息
local PackInfo = activity.PackageManager.getPackageInfo(activity.getPackageName(), 64)

-- 功能函数
local function openInBrowser(url)
  local intent = Intent("android.intent.action.VIEW", Uri.parse(url))
  if intent.resolveActivity(activity.getPackageManager()) then
    activity.startActivity(intent)
  end
end

local function onItemClick(view, views, key, data)
  if data.url then
    openInBrowser(data.url)
   elseif key == "qq" then
    pcall(activity.startActivity, Intent(Intent.ACTION_VIEW, Uri.parse("mqqapi://card/show_pslcard?uin=" .. data.qq)))
   elseif key == "qq_group" then
    pcall(activity.startActivity, Intent(Intent.ACTION_VIEW, Uri.parse(("mqqapi://card/show_pslcard?src_type=internal&version=1&uin=%s&card_type=group&source=qrcode"):format(data.groupId))))
   elseif key == "openSourceLicenses" then
    ActivityUtil.new("openSourceLicenses")
   elseif key == "more_people" then
    ActivityUtil.new("people")
  end
end

-- 构建数据
local data = {
  {
    SettingsLayUtil.TITLE,
    title = res.string.about_software,
  },
  {
    SettingsLayUtil.ITEM,
    title = res.string.nowversion_app,
    summary = ("%s(%s)"):format(PackInfo.versionName, PackInfo.versionCode),
    icon = "ic_information_outline",
    key = "update",
  },
  {
    SettingsLayUtil.ITEM,
    title = res.string.pluginsutil_version,
    summary = PluginsUtil._VERSION,
    icon = "ic_puzzle_outline",
  },

}

-- 添加开发者信息
table.insert(data, {
  SettingsLayUtil.TITLE,
  title = res.string.developerInfo
})

local developers = {
  {
    name = "DifierLine",
    qq = 1434436108,
    message = res.string.app_name .. " " .. res.string.developer,
  },
  {
    name = "Irreplaceable",
    qq = 2707271920,
    message = res.string.back_end_technology_provid,
  },
  {
    name = "PotMik",
    qq = 1550792499,
    message = res.string.back_end_technology_provid,
  },
  {
    name = "Viru",
    qq = 3177375945,
    message = res.string.debug_collaborative_development,
  },
}

for _, dev in ipairs(developers) do
  table.insert(data, {
    SettingsLayUtil.ITEM_AVATAR,
    title = "@"..dev.name,
    summary = dev.message,
    icon = ("http://q.qlogo.cn/headimg_dl?spec=640&img_type=jpg&dst_uin=%s"):format(dev.qq),
    qq = dev.qq,
    key = "qq",
    newPage = "newApp",
  })
end

-- 添加其他信息
local additionalItems = {
  {
    SettingsLayUtil.ITEM,
    title = res.string.more_people,
    summary = res.string.contributors_and_donor,
    icon = "ic_heart_outline",
    key = "more_people",
    newPage = true,
  },
  {
    SettingsLayUtil.ITEM_NOSUMMARY,
    title = res.string.opensourcelicense,
    icon = "ic_github",
    key = "openSourceLicenses",
    newPage = true,
  },
  {
    SettingsLayUtil.TITLE,
    title = res.string.morecontent
  },
  {
    SettingsLayUtil.ITEM,
    title = res.string.qqgroup,
    icon = "ic_account_group_outline",
    groupId = 818459127,
    summary = "818459127",
    key = "qq_group",
    newPage = "newApp",
  },
  {
    SettingsLayUtil.ITEM,
    title = res.string.copyright,
    summary = "Copyright (c) " .. (os.date("%Y") == "2026" and "2026" or os.date("2026 - %Y")) .. " DifierLine. All Rights Reserved",
    icon = "ic_copyright",
    key = "copyright",
  },
}

for _, item in ipairs(additionalItems) do
  table.insert(data, item)
end

-- 设置RecyclerView
local adapter = SettingsLayUtil.newAdapter(data, onItemClick)
recycler_view
.setAdapter(adapter)
.setLayoutManager(LinearLayoutManager(activity))

recycler_view.addItemDecoration(RecyclerView.ItemDecoration {
  getItemOffsets = function(outRect, view, parent, state)
    Utils.modifyItemOffsets2(outRect, view, parent, adapter, 12)
  end
})

-- 菜单项选择处理
function onOptionsItemSelected(item)
  if item.getItemId() == android.R.id.home then
    activity.finish()
    return true
  end
end

-- 清理资源
function onDestroy()
  adapter.release()
  luajava.clear()
  collectgarbage("collect")
  collectgarbage("step")
end
