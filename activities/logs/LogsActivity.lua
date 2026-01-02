require "env"
setStatus()

-- 绑定Java类
local bindClass = luajava.bindClass
local LinearLayoutManager = bindClass "androidx.recyclerview.widget.LinearLayoutManager"
local ObjectAnimator = bindClass "android.animation.ObjectAnimator"
local RecyclerView = bindClass "androidx.recyclerview.widget.RecyclerView"
local LuaCustRecyclerHolder = bindClass "github.znzsofficial.adapter.LuaCustRecyclerHolder"
local PopupRecyclerAdapter = bindClass "github.znzsofficial.adapter.PopupRecyclerAdapter"
local String = bindClass "java.lang.String"
local Utils = require "utils.Utils"
local IconDrawable = require "utils.IconDrawable"
local Context = bindClass "android.content.Context"

-- 初始化变量
local originalData = {} -- 原始日志数据
local searchText = "" -- 搜索关键词
local debounceRunnable = nil
local handler = bindClass("android.os.Handler")(bindClass("android.os.Looper").getMainLooper())
local items = {"All", "Lua", "Test", "Tcc", "Error", "Warning", "Info", "Debug", "Verbose"}
local items2 = {"", "lua:* *:S", "test:* *:S", "tcc:* *:S", "*:E", "*:W", "*:I", "*:D", "*:V"}
local data = {}
local adapter, Anim -- 适配器和动画对象

-- 初始化RecyclerView
local function init()
  luajava.newInstance("me.zhanghai.android.fastscroll.FastScrollerBuilder", recycler_view)
  .useMd2Style()
  .setPadding(0, dp2px(8), dp2px(2), dp2px(8))
  .build()

  Anim = ObjectAnimator.ofFloat(recycler_view, "alpha", {0, 1}).setDuration(400)

  adapter = PopupRecyclerAdapter(activity, PopupRecyclerAdapter.PopupCreator({
    getItemCount = function() return #data end,
    getItemViewType = function() return 0 end,
    getPopupText = function() return "" end,
    onViewRecycled = function() end,
    onCreateViewHolder = function(parent)
      local views = {}
      local holder = LuaCustRecyclerHolder(loadlayout("layouts.analysis_item", views))
      holder.Tag = views
      return holder
    end,
    onBindViewHolder = function(holder, position)
      local views = holder.Tag
      local currentData = data[position + 1]
      views.title.setText(currentData)

      if #searchText > 0 then
        local text = currentData:lower()
        local searchLower = searchText:lower()
        local startPos, endPos = text:find(searchLower, 1, true)

        if startPos and not currentData:find(res.string.contains_not_found, 1, true) then
          local safeStart = math.min(startPos, #currentData)
          local safeEnd = math.min(endPos, #currentData)

          local spannable = bindClass("android.text.SpannableString")(currentData)
          local color = bindClass("android.graphics.Color")
          local highlight = bindClass("android.text.style.BackgroundColorSpan")(color.parseColor("#FFFF00"))

          spannable.setSpan(highlight, safeStart - 1, safeEnd,
          bindClass("android.text.Spanned").SPAN_EXCLUSIVE_EXCLUSIVE)
          views.title.setText(spannable)
        end
      end
    end
  }))

  recycler_view
  .setAdapter(adapter)
  .setLayoutManager(LinearLayoutManager(activity))
end

-- 显示日志内容
function show(content)
  data = {}
  originalData = {}

  if #content ~= 0 then
    local l = 1
    for i in content:gfind("%[ *%d+%-%d+ *%d+:%d+:%d+%.%d+ *%d+: *%d+ *%a/[^ ]+ *%]") do
      if l ~= 1 then
        local line = String(content:sub(l, i - 1)).trim()
        table.insert(data, line)
        table.insert(originalData, line)
      end
      l = i
    end
    local lastLine = String(content:sub(l)).trim()
    table.insert(data, lastLine)
    table.insert(originalData, lastLine)
   else
    local msg = "<" .. res.string.run_the_application_to_view_its_log_output .. ">"
    table.insert(data, msg)
    table.insert(originalData, msg)
  end

  if adapter then
    filterData()
    if Anim and not Anim.isStarted() then
      Anim.start()
    end
  end
end

-- 过滤数据
function filterData()
  data = {}

  if #searchText == 0 then
    for _, line in ipairs(originalData) do
      table.insert(data, line)
    end
   else
    local lowerSearch = searchText:lower()
    for _, line in ipairs(originalData) do
      if line:lower():find(lowerSearch, 1, true) then
        table.insert(data, line)
      end
    end

    if #data == 0 then
      local notFoundMsg = res.string.contains_not_found .. " \"" .. searchText .. "\" " .. res.string.log_of
      table.insert(data, notFoundMsg)
    end
  end

  if adapter then
    adapter.notifyDataSetChanged()
  end
end

-- 读取日志
function readLog(value)
  -- 添加数量限制：只读取最近1000行
  local p = io.popen("logcat -d -v long -t 1000 " .. value)
  local chunks = {}
  while true do
    local chunk = p:read(4096) -- 分块读取避免大内存分配
    if not chunk then break end
    table.insert(chunks, chunk)
  end
  p:close()
  return table.concat(chunks):gsub("%-+ beginning of[^\n]*\n", "")
end

-- 清除日志
function clearLog()
  local p = io.popen("logcat -c")
  local s = p:read("*a")
  p:close()
  return s
end

-- 菜单项选择
function onOptionsItemSelected(item)
  if item.getItemId() == android.R.id.home then
    activity.finish()
    return true
  end
end

-- 创建菜单
function onCreateOptionsMenu(menu)
  menu.add(res.string.clear_logs)
  .setIcon(IconDrawable("ic_notification_clear_all", Colors.colorOnSurfaceVariant))
  .setShowAsAction(2)
  .onMenuItemClick = function()
    clearLog()
    task(readLog, tabs.getTabAt(tabs.getSelectedTabPosition()).tag, show)
  end
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
.setContentView(loadlayout("layouts.activity_logs"))
.setSupportActionBar(toolbar)
.getSupportActionBar()
.setDisplayHomeAsUpEnabled(true)

-- 初始化组件
init()

-- 添加列表装饰器
recycler_view.addItemDecoration(RecyclerView.ItemDecoration {
  getItemOffsets = function(outRect, view, parent, state)
    Utils.modifyItemOffsets(outRect, view, parent, adapter, 14)
  end
})

-- 添加标签页
for k, v in pairs(items) do
  tabs.addTab(tabs.newTab().setText(v).setTag(items2[k]))
end
Utils.setTabRippleEffect(tabs)

-- 标签选择监听
local tabSelectedListener = bindClass("com.google.android.material.tabs.TabLayout$OnTabSelectedListener")({
  onTabSelected = function(tab)
    task(readLog, tab.tag, show)
  end
})
tabs.addOnTabSelectedListener(tabSelectedListener)

-- 初始加载日志
task(readLog, "", show)

-- 搜索框文本监听
local textChangedListener = {
  onTextChanged = function(s)
    searchText = tostring(s)
    if debounceRunnable then
      handler.removeCallbacks(debounceRunnable)
    end
    debounceRunnable = Runnable {
      run = function() filterData() end
    }
    handler.postDelayed(debounceRunnable, 10)
  end
}
content.addTextChangedListener(textChangedListener)

-- 清除按钮监听
content.onTouchListener = {
  onTouch = function(v, event)
    if event.getAction() == event.ACTION_UP then
      local drawableRight = content.getCompoundDrawables()[3]
      if drawableRight then
        local width = content.getWidth()
        local x = event.getX()
        if x > (width - content.getPaddingRight() - drawableRight.getIntrinsicWidth()) then
          content.setText("")
          return true
        end
      end
    end
    return false
  end
}