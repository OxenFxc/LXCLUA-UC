require "env"
setStatus()

-- 绑定Java类
local bindClass = luajava.bindClass
local LinearLayoutManager = bindClass "androidx.recyclerview.widget.LinearLayoutManager"
local DecelerateInterpolator = luajava.newInstance "android.view.animation.DecelerateInterpolator"
local ObjectAnimator = bindClass "android.animation.ObjectAnimator"
local AnimatorSet = bindClass "android.animation.AnimatorSet"
local RecyclerView = bindClass "androidx.recyclerview.widget.RecyclerView"
local LuaCustRecyclerHolder = bindClass "github.znzsofficial.adapter.LuaCustRecyclerHolder"
local PopupRecyclerAdapter = bindClass "github.znzsofficial.adapter.PopupRecyclerAdapter"
local HandlerCompat = bindClass "androidx.core.os.HandlerCompat"
local Looper = bindClass "android.os.Looper"

-- 加载依赖库
local Utils = require "utils.Utils"
local ClassReflectUtil = require "activities.parsing.ClassReflectUtil"
local ActivityUtil = require "utils.ActivityUtil"
local MaterialBlurDialogBuilder = require "dialogs.MaterialBlurDialogBuilder"

-- 全局变量
local mainLooper = Looper.getMainLooper()
local handler = HandlerCompat.createAsync(mainLooper)
local debounceRunnable = nil
local searchText = "" -- 搜索文本
local class = ... -- 传入的类名
local tabAdapters = {} -- 存储每个Tab的适配器信息

-- 原始类型映射
local PRIMITIVE_MAP = {
  byte = "java.lang.Byte",
  short = "java.lang.Short",
  long = "java.lang.Long",
  float = "java.lang.Float",
  double = "java.lang.Double",
  char = "java.lang.Character",
  int = "java.lang.Integer",
  boolean = "java.lang.Boolean"
}

-- 规范化类名
class = PRIMITIVE_MAP[class] or class

-- ===== 辅助函数 =====
-- 添加条目到列表
local function addItem(items, key, value)
  if bindClass("android.os.Build").VERSION.SDK_INT >= 28 then
    local SpannableString = bindClass "android.text.SpannableString"
    local SpannableStringBuilder = bindClass "android.text.SpannableStringBuilder"
    local ForegroundColorSpan = bindClass "android.text.style.ForegroundColorSpan"
    local Spanned = bindClass "android.text.Spanned"

    local left = SpannableString(key)
    left.setSpan(
    ForegroundColorSpan(Colors.colorPrimary),
    0, utf8.len(key),
    Spanned.SPAN_EXCLUSIVE_EXCLUSIVE
    )

    local line = SpannableStringBuilder()
    line.append(left)
    line.append(": ")
    line.append(value)

    table.insert(items, line)
   else
    table.insert(items, key .. "：" .. value)
  end
end

-- 获取访问修饰符信息
local function getAccessInfo(modifiers)
  if not modifiers then return "", 0 end
  if modifiers:find("public") then
    return res.string.public, Colors.colorPrimary
   elseif modifiers:find("private") then
    return res.string.private, Colors.colorError
   elseif modifiers:find("protected") then
    return res.string.protected, 0xFFFF9800
  end
  return "", 0
end

-- 设置访问视图
local function setupAccessView(accessView, modifiers)
  local text, color = getAccessInfo(modifiers)
  accessView
  .setText(text)
  .setTextColor(color)
  .parent
  .setVisibility(text == "" and 8 or 0)
  .setCardBackgroundColor(Utils.setColorAlpha(color, 20))
end

-- 构建详情项
local function buildDetailItems(currentData, tabTitle)
  local items = {}
  addItem(items, res.string.name, tostring(currentData.name))
  addItem(items, res.string.modifier, currentData.modifiers or "")

  if currentData.returnType then
    addItem(items, res.string.return_type, currentData.returnType)
  end

  if currentData.params then
    addItem(items, res.string.parameter, "(" .. table.concat(currentData.params, ", ") .. ")")
  end

  pcall(function()
    if tabTitle == res.string.fields then
      local resource_id = tostring(bindClass(class)[tostring(currentData.name)])
      addItem(items, res.string.resource_id, currentData.type == "int" and resource_id)
    end
  end)

  if currentData.type then
    addItem(items, res.string["type"], currentData.type)
  end
  return items
end

-- 处理长按事件
local function handleLongClick(currentData, tabTitle)
  return function()
    if tabTitle == res.string.constructors or tabTitle == res.string.method or tabTitle == res.string.fields then
      local items = buildDetailItems(currentData, tabTitle)
      MaterialBlurDialogBuilder(activity)
      .setTitle(tabTitle)
      .setItems(items, function(l, v)
        if tostring(items[v+1]):find("%(") and tostring(items[v+1]):match("%((.-)%)") ~= "" then
          MaterialBlurDialogBuilder(activity)
          .setItems(currentData.params_fullname, function(l, v)
            ActivityUtil.new("parsing", { currentData.params_fullname[v + 1] })
          end)
          .show()
        end
      end)
      .setPositiveButton(res.string.ok, nil)
      .show()
     else
      activity.getSystemService("clipboard").setText(currentData)
      MyToast(res.string.copied_successfully)
    end
    return true
  end
end

-- 封装函数：为括号内内容添加颜色
function addStyledParenthesesContent(originalStr, color)
  local startIdx = string.find(originalStr, "%(")
  local endIdx = string.find(originalStr, "%)")
  if not startIdx or not endIdx or startIdx >= endIdx then
    local SpannableStringBuilder = bindClass "android.text.SpannableStringBuilder"
    return SpannableStringBuilder(originalStr)
  end

  local content = string.sub(originalStr, startIdx + 1, endIdx - 1)
  local processedContent = string.gsub(content, ",%s*", ", ")
  local newStr = string.sub(originalStr, 1, startIdx)
  .. processedContent
  .. string.sub(originalStr, endIdx)

  endIdx = startIdx + #processedContent + 1
  local SpannableStringBuilder = bindClass "android.text.SpannableStringBuilder"
  local ssb = SpannableStringBuilder(newStr)

  -- 判断SDK版本是否>=28
  if bindClass("android.os.Build").VERSION.SDK_INT >= 28 then
    local parts = {}
    for part in string.gmatch(processedContent, "([^,]+)") do
      table.insert(parts, part:match("^%s*(.-)%s*$"))
    end

    local currentPos = startIdx
    for i, part in ipairs(parts) do
      if part and #part > 0 then
        local partStart = currentPos
        local partEnd = partStart + #part - 1
        local ForegroundColorSpan = bindClass "android.text.style.ForegroundColorSpan"
        ssb.setSpan(ForegroundColorSpan(color), partStart, partEnd + 1, 0)
        currentPos = partEnd + 3
      end
    end
  end

  return ssb
end

-- ===== 适配器创建函数 =====
-- 根据数据类型创建适配器
local function createAdapterForType(dataType, data, tabTitle)
  -- 数据持有器（用于动态更新数据）
  local dataHolder = { data = data }

  -- 数据类型处理器映射
  local dataTypeHandlers = {
    constructors = function(currentData, views)
      setupAccessView(views.access, currentData.modifiers)
      local params = table.concat(currentData.params, ", ")
      return addStyledParenthesesContent(currentData.name .. "(" .. params .. ")", Colors.colorOnSurfaceVariant),
      currentData.returnType_fullname
    end,
    methods = function(currentData, views)
      setupAccessView(views.access, currentData.modifiers)
      local params = table.concat(currentData.params, ", ")
      return addStyledParenthesesContent(currentData.name .. "(" .. params .. ")", Colors.colorOnSurfaceVariant),
      currentData.returnType_fullname
    end,
    fields = function(currentData, views)
      setupAccessView(views.access, currentData.modifiers)
      return currentData.name:match("[^.]+$") or currentData.name,
      currentData.type
    end
  }

  return PopupRecyclerAdapter(activity, PopupRecyclerAdapter.PopupCreator({
    getItemCount = function() return #dataHolder.data end,
    getItemViewType = function() return 0 end,
    getPopupText = function() return "" end,
    onViewRecycled = function() end,
    onCreateViewHolder = function(parent, viewType)
      local views = {}
      local holder = LuaCustRecyclerHolder(loadlayout("layouts.parsing_item", views))
      holder.Tag = views
      return holder
    end,
    onBindViewHolder = function(holder, position)
      local views = holder.Tag
      local currentData = dataHolder.data[position + 1]
      local titleText, contentText

      -- 处理特殊类型（无访问修饰符）
      if dataType == "superClasses" or dataType == "interfaces" or dataType == "innerClasses" then
        titleText = string.match(currentData, "%w+$")
        contentText = currentData
        views.access.parent.setVisibility(8)
       else
        -- 使用类型处理器
        local handler = dataTypeHandlers[dataType]
        if handler then
          titleText, contentText = handler(currentData, views)
         else
          titleText = currentData
          contentText = currentData
        end
      end

      -- 设置文本
      views.title
      .setText(titleText)
      .getPaint().setFakeBoldText(true)
      views.content.setText(contentText)

      -- 点击事件
      views.card.onClick = function()
        if tabTitle == res.string.superClasses or
          tabTitle == res.string.internal_class or
          tabTitle == res.string.interface then
          ActivityUtil.new("parsing", { currentData })
         else
          activity.getSystemService("clipboard").setText(views.title.text)
          MyToast(res.string.copied_successfully)
        end
      end

      -- 长按事件
      activity.onLongClick(views.card, handleLongClick(currentData, tabTitle))
    end
  })), dataHolder
end

-- ===== 主执行逻辑 =====
-- 设置界面
activity
.setContentView(loadlayout("layouts.activity_parsing"))
.setSupportActionBar(toolbar)
.getSupportActionBar()
.setTitle(string.match(class, "%w+$"))
.setDisplayHomeAsUpEnabled(true)

activity.getSupportActionBar().setSubtitle(class)

-- 加载类信息
activity.newTask(function(classPath, loadClassInfo)
  return loadClassInfo(classPath)
  end, function(data)
  -- 检查哪些部分有数据
  local tabs = {}
  local tabTypes = {
    { type = "constructors", title = res.string.constructors },
    { type = "methods", title = res.string.method },
    { type = "fields", title = res.string.fields },
    { type = "superClasses", title = res.string.superClasses },
    { type = "interfaces", title = res.string.interface },
    { type = "innerClasses", title = res.string.internal_class }
  }

  for _, tab in ipairs(tabTypes) do
    if #data[tab.type] > 0 then
      table.insert(tabs, {
        title = tab.title,
        data = data[tab.type],
        type = tab.type
      })
    end
  end

  if #tabs == 0 then
    activity.finish()
    return
  end

  -- 创建视图列表和标题列表
  local pager_list = ArrayList()
  local title_list = {}

  -- 遍历tabs
  for i, tab in ipairs(tabs) do
    local recyclerView = RecyclerView(activity)
    recyclerView.setLayoutManager(LinearLayoutManager(activity))

    -- 创建适配器并获取数据持有器
    local adapter, dataHolder = createAdapterForType(tab.type, tab.data, tab.title)
    recyclerView.setAdapter(adapter)

    recyclerView.addItemDecoration(RecyclerView.ItemDecoration {
      getItemOffsets = function(outRect, view, parent, state)
        Utils.modifyItemOffsets(outRect, view, parent, adapter, 14)
      end
    })

    luajava.newInstance("me.zhanghai.android.fastscroll.FastScrollerBuilder", recyclerView)
    .useMd2Style()
    .setPadding(0, dp2px(8), dp2px(2), dp2px(8))
    .build()

    local Anim = ObjectAnimator.ofFloat(recyclerView, "alpha", {0, 1}).setDuration(400)
    Anim.start()

    pager_list.add(recyclerView)
    title_list[i] = tab.title

    -- 保存适配器信息用于搜索
    tabAdapters[i] = {
      recyclerView = recyclerView,
      adapter = adapter,
      originalData = tab.data,
      dataHolder = dataHolder,
      dataType = tab.type
    }
  end

  -- 设置分页适配器
  local LuaPagerAdapter = bindClass "github.daisukiKaffuChino.LuaPagerAdapter"
  cvpg.setAdapter(LuaPagerAdapter(pager_list))

  -- 设置TabLayout
  mtabs.setupWithViewPager(cvpg)
  Utils.setTabRippleEffect(mtabs)

  for i = 0, #tabs - 1 do
    local tab = mtabs.getTabAt(i)
    if tab then tab.setText(title_list[i + 1]) end
  end
end).execute({ class, ClassReflectUtil.load })

-- 文本变化监听器（带防抖的搜索）
local textChangedListener = {
  onTextChanged = function(s, start, before, count)
    searchText = tostring(s):lower()

    -- 防抖处理（300ms延迟）
    if debounceRunnable then
      handler.removeCallbacks(debounceRunnable)
    end

    debounceRunnable = Runnable {
      run = function()
        -- 遍历所有Tab进行过滤
        for i, tabInfo in ipairs(tabAdapters) do
          local filteredData = {}
          if searchText == "" then
            -- 搜索文本为空时显示全部数据
            filteredData = tabInfo.originalData
           else
            -- 根据数据类型进行过滤
            if tabInfo.dataType == "constructors"
              or tabInfo.dataType == "methods"
              or tabInfo.dataType == "fields" then

              -- 处理结构化数据
              for _, item in ipairs(tabInfo.originalData) do
                local searchContent = (item.name or ""):lower()
                .. " " .. (item.modifiers or ""):lower()
                .. " " .. (item.returnType or ""):lower()
                .. " " .. table.concat(item.params or {}, " "):lower()

                if searchContent:find(searchText, 1, true) then
                  table.insert(filteredData, item)
                end
              end
             else
              -- 处理简单字符串数据
              for _, item in ipairs(tabInfo.originalData) do
                if tostring(item):lower():find(searchText, 1, true) then
                  table.insert(filteredData, item)
                end
              end
            end
          end

          -- 更新数据并刷新适配器
          tabInfo.dataHolder.data = filteredData
          tabInfo.adapter.notifyDataSetChanged()
        end
      end
    }
    handler.postDelayed(debounceRunnable, 300)
  end
}

content.addTextChangedListener(textChangedListener)

-- ===== 生命周期函数 =====
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
  luajava.clear()
  collectgarbage("collect")
  collectgarbage("step")
end