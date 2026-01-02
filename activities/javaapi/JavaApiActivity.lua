require "env"
setStatus()
local bindClass = luajava.bindClass
local LinearLayoutManager = bindClass "androidx.recyclerview.widget.LinearLayoutManager"
local RecyclerView = bindClass "androidx.recyclerview.widget.RecyclerView"
local LuaCustRecyclerHolder = bindClass "github.znzsofficial.adapter.LuaCustRecyclerHolder"
local PopupRecyclerAdapter = bindClass "github.znzsofficial.adapter.PopupRecyclerAdapter"
local DecelerateInterpolator = luajava.newInstance "android.view.animation.DecelerateInterpolator"
local ObjectAnimator = bindClass "android.animation.ObjectAnimator"
local AnimatorSet = bindClass "android.animation.AnimatorSet"
local HandlerCompat = bindClass "androidx.core.os.HandlerCompat"
local Looper = bindClass "android.os.Looper"
local mainLooper = Looper.getMainLooper()
local handler = HandlerCompat.createAsync(mainLooper)
local Utils = require "utils.Utils"
local PublicClasses = require "activities.javaapi.PublicClasses"
local ActivityUtil = require "utils.ActivityUtil"

-- 全局变量用于保存初始化状态
local isInitialized = false
local adapter = nil
local data = {}
local searchText = ""
local debounceRunnable = nil
local categories = {}
local categoryOrder = {}
local positionToCategory = {}
local currentCategory = res.string.all -- 当前选中的分类
local originalCategories = {} -- 存储原始分类数据（未过滤）

-- 初始化分类
categories = {
  [res.string.all] = {},
  Android = {},
  AndroidX = {},
  AndroLua = {},
  Material = {},
  Glide = {},
  Sora = {},
  Java = {},
  Kotlin = {},
  Okhttp3 = {},
  Okio = {},
  [res.string.other] = {}
}

-- 存储原始分类数据（用于搜索过滤）
originalCategories = {
  [res.string.all] = {},
  Android = {},
  AndroidX = {},
  AndroLua = {},
  Material = {},
  Glide = {},
  Sora = {},
  Java = {},
  Kotlin = {},
  Okhttp3 = {},
  Okio = {},
  [res.string.other] = {}
}

categoryOrder = {
  res.string.all,
  "Android",
  "AndroidX",
  "AndroLua",
  "Material",
  "Glide",
  "Sora",
  "Java",
  "Kotlin",
  "Okhttp3",
  "Okio",
  res.string.other
}

-- 初始化函数（只执行一次）
local function initializeRecyclerView()
  if isInitialized then return end

  -- 创建快速滚动条
  luajava.newInstance("me.zhanghai.android.fastscroll.FastScrollerBuilder", recycler_view)
  .useMd2Style()
  .setPadding(0, dp2px(8), dp2px(2), dp2px(8))
  .build()

  local Anim = AnimatorSet()
  local Y = ObjectAnimator.ofFloat(recycler_view, "translationY", {50, 0})
  local A = ObjectAnimator.ofFloat(recycler_view, "alpha", {0, 1})
  Anim.play(A).with(Y)
  Anim.setDuration(400)
  .setInterpolator(DecelerateInterpolator)

  -- 创建适配器
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
      local holder = LuaCustRecyclerHolder(loadlayout("layouts.javaapi_item", views))
      holder.Tag = views
      return holder
    end,
    onBindViewHolder = function(holder, position)
      local views = holder.Tag
      local currentData = data[position+1]

      views.title
      .setText(currentData:match("[^.]+$"))
      .getPaint().setFakeBoldText(true)
      views.content.setText(currentData)

      views.card.onClick = function(v)
        ActivityUtil.new("parsing", { currentData })
      end

      activity.onLongClick(views.card, function()
        activity.getSystemService("clipboard").setText(currentData)
        MyToast(res.string.copied_successfully)
        return true
      end)
    end
  }))

  recycler_view.setAdapter(adapter)
  recycler_view.setLayoutManager(LinearLayoutManager(activity))

  -- 添加项目装饰
  recycler_view.addItemDecoration(RecyclerView.ItemDecoration {
    getItemOffsets = function(outRect, view, parent, state)
      Utils.modifyItemOffsets(outRect, view, parent, adapter, 14)
    end
  })

  isInitialized = true
end

-- 更新列表数据
local function updateDataForCategory(categoryName)
  currentCategory = categoryName

  local sourceData = originalCategories[categoryName] or {}
  if searchText and #searchText > 0 then
    data = {}
    local searchLower = string.lower(searchText)
    for _, item in ipairs(sourceData) do
      if item ~= nil and string.find(string.lower(item), searchLower, 1, true) then
        table.insert(data, item)
      end
    end
   else
    data = {}
    for _, item in ipairs(sourceData) do
      if item ~= nil then
        table.insert(data, item)
      end
    end
  end

  if adapter then
    adapter.notifyDataSetChanged()
  end
end

-- 分类函数
local function classifyItems(items)
  -- 重置分类
  for k in pairs(categories) do
    categories[k] = {}
    originalCategories[k] = {} -- 同时重置原始数据
  end

  for _, item in ipairs(items) do
    local category
    if string.find(item, "^android%.") then
      category = "Android"
     elseif string.find(item, "^androidx%.") then
      category = "AndroidX"
     elseif string.find(item, "^com%.androlua%.") or string.find(item, "^com%.luajava%.") or string.find(item, "^com%.nirenr%.") then
      category = "AndroLua"
     elseif string.find(item, "glide") then
      category = "Glide"
     elseif string.find(item, "^com%.google%.android%.material%.") then
      category = "Material"
     elseif string.find(item, "sora") then
      category = "Sora"
     elseif string.find(item, "^java%.") or string.find(item, "^javax%.") then
      category = "Java"
     elseif string.find(item, "^kotlin%.") or string.find(item, "^kotlinx%.") then
      category = "Kotlin"
     elseif string.find(item, "^net%.lingala%.zip4j%.") then
      category = "Zip4j"
     elseif string.find(item, "^okhttp3%.") then
      category = "Okhttp3"
     elseif string.find(item, "^okio%.") then
      category = "Okio"
     else
      category = res.string.other
    end
    table.insert(categories[category], item)
    table.insert(originalCategories[category], item) -- 同时存入原始数据
  end

  -- 添加"全部"分类数据（过滤空值）
  categories[res.string.all] = {}
  originalCategories[res.string.all] = {}
  for _, item in ipairs(items) do
    if item ~= nil then
      table.insert(categories[res.string.all], item)
      table.insert(originalCategories[res.string.all], item)
    end
  end
end

-- 主执行代码开始
activity
.setContentView(loadlayout("layouts.activity_javaapi"))
.setSupportActionBar(toolbar)
.getSupportActionBar()
.setDisplayHomeAsUpEnabled(true)

-- 分类数据
classifyItems(PublicClasses)

-- 预先生成 position 到 categoryName 的映射
positionToCategory = {}
for i = 1, #categoryOrder do
  positionToCategory[i - 1] = categoryOrder[i] -- Tab position 0对应categoryOrder[1]
end

-- 添加带数量的Tab
for _, categoryName in ipairs(categoryOrder) do
  local count = #categories[categoryName]
  local tabText = count > 0 and string.format("%s(%d)", categoryName, count) or categoryName
  tabs.addTab(tabs.newTab().setText(tabText))
end

Utils.setTabRippleEffect(tabs)

-- 初始化RecyclerView（只执行一次）
initializeRecyclerView()

-- 默认显示"全部"分类
updateDataForCategory(res.string.all)

-- 添加标签监听器
tabs.addOnTabSelectedListener(bindClass("com.google.android.material.tabs.TabLayout$OnTabSelectedListener")({
  onTabSelected = function(tab)
    local Anim = AnimatorSet()
    local Y = ObjectAnimator.ofFloat(recycler_view, "translationY", {50, 0})
    local A = ObjectAnimator.ofFloat(recycler_view, "alpha", {0, 1})
    Anim.play(A).with(Y)
    Anim.setDuration(400)
    .setInterpolator(DecelerateInterpolator)
    Anim.start()
    
    local position = tab.getPosition()
    local categoryName = positionToCategory[position]
    updateDataForCategory(categoryName)
  end
}))

-- 添加搜索监听器
searchText = ""

content.addTextChangedListener({
  onTextChanged = function(s, start, before, count)
    -- 更新搜索文本
    searchText = tostring(s)
    -- 使用防抖机制，避免频繁刷新（10毫秒）
    if debounceRunnable then
      handler.removeCallbacks(debounceRunnable)
    end

    debounceRunnable = Runnable {
      run = function()
        updateDataForCategory(currentCategory)
      end
    }
    handler.postDelayed(debounceRunnable, 10)
  end
})

-- 菜单项选择
function onOptionsItemSelected(item)
  if item.getItemId() == android.R.id.home then
    activity.finish()
    return true
  end
  return false
end

-- 清理资源
function onDestroy()
  adapter.release()
  luajava.clear()
  collectgarbage("collect")  --全回收
  collectgarbage("step")    -- 增量回收
end