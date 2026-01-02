require "env"
setStatus()

-- 导入依赖
local bindClass = luajava.bindClass
local LinearLayoutManager = bindClass "androidx.recyclerview.widget.LinearLayoutManager"
local ObjectAnimator = bindClass "android.animation.ObjectAnimator"
local RecyclerView = bindClass "androidx.recyclerview.widget.RecyclerView"
local LuaCustRecyclerHolder = bindClass "github.znzsofficial.adapter.LuaCustRecyclerHolder"
local PopupRecyclerAdapter = bindClass "github.znzsofficial.adapter.PopupRecyclerAdapter"
local IconDrawable = require "utils.IconDrawable"
local Utils = require "utils.Utils"

-- 初始化全局状态
local path = ...
local SelectedState = {}
local Anim, adapter

-- 初始化UI
activity
.setContentView(loadlayout("layouts.activity_analysis"))
.setSupportActionBar(toolbar)
.getSupportActionBar()
.setDisplayHomeAsUpEnabled(true)

-- 设置RecyclerView装饰器
recycler_view.addItemDecoration(RecyclerView.ItemDecoration {
  getItemOffsets = function(outRect, view, parent, state)
    Utils.modifyItemOffsets(outRect, view, parent, adapter, 14)
  end
})

-- 初始化函数
local function init()
  -- 创建快速滚动条
  luajava.newInstance("me.zhanghai.android.fastscroll.FastScrollerBuilder", recycler_view)
  .useMd2Style()
  .setPadding(0, dp2px(8), dp2px(2), dp2px(8))
  .build()

  -- 初始化淡入动画
  Anim = ObjectAnimator.ofFloat(recycler_view, "alpha", {0, 1}).setDuration(400)

  -- 创建适配器
  adapter = PopupRecyclerAdapter(activity, PopupRecyclerAdapter.PopupCreator({
    getItemCount = function() return #data end,
    getItemViewType = function() return 0 end,
    getPopupText = function(view, position)
      return utf8.sub(string.match(data[position+1],"%w+$"), 1, 1)
    end,
    onViewRecycled = function(holder) end,
    onCreateViewHolder = function(parent, viewType)
      local views = {}
      local holder = LuaCustRecyclerHolder(loadlayout("layouts.analysis_item", views))
      holder.Tag = views
      return holder
    end,
    onBindViewHolder = function(holder, position)
      local views = holder.Tag
      local currentData = data[position+1]
      views.title.setText(currentData)

      -- 卡片状态管理
      local isChecked = SelectedState[currentData] or false
      views.card.setChecked(false) -- 重置避免过渡动画干扰
      views.card.setChecked(isChecked)
      views.card.setStrokeColor(isChecked and Colors.colorOutline or Colors.colorOutlineVariant)

      -- 点击事件
      views.card.onClick = function(v)
        v.setChecked(not v.isChecked())
      end

      -- 长按复制
      activity.onLongClick(views.card, function()
        activity.getSystemService("clipboard").setText(currentData)
        MyToast(res.string.copied_successfully)
        return true
      end)

      -- 状态变化监听
      views.card.setOnCheckedChangeListener(function(v, checked)
        if v.isPressed() then -- 仅处理用户交互
          SelectedState[currentData] = checked
          v.setStrokeColor(checked and Colors.colorOutline or Colors.colorOutlineVariant)
        end
      end)
    end
  }))

  -- 设置适配器和布局管理器
  recycler_view
  .setAdapter(adapter)
  .setLayoutManager(LinearLayoutManager(activity))
end

-- 修复导入
local function fiximport(path)
  activity.newTask(function(path)
    -- Java类处理
    local bindClass = luajava.bindClass
    local LuaLexer = bindClass "com.difierline.lua.tokenizer.LuaLexer"
    local LuaTokenTypes = bindClass "com.difierline.lua.tokenizer.LuaTokenTypes"
    local DOT, NAME = LuaTokenTypes.DOT, LuaTokenTypes.NAME

    -- 预处理Java类库
    local classes = require "activities.javaapi.PublicClasses"
    local classMap, lastPartCounts = {}, {}

    -- 统计类名后缀出现次数
    for _, className in ipairs(classes) do
      local lastPart = className:match("%w+$")
      if lastPart then lastPartCounts[lastPart] = (lastPartCounts[lastPart] or 0) + 1 end
    end

    -- 构建类映射（只保留出现次数≤5的）
    for _, className in ipairs(classes) do
      local lastPart = className:match("%w+$")
      if lastPart and lastPartCounts[lastPart] <= 5 then
        classMap[lastPart] = classMap[lastPart] or {}
        table.insert(classMap[lastPart], className)
      end
    end

    -- 设置搜索路径
    local directory = path:match("(.*)/[^/]+$") or "."
    local searchpath = table.concat({directory.."/?.lua", directory.."/?.aly"}, ";")..";"

    -- 递归检查函数
    local cache = {}
    local function checkClass(currentPath, result)
      if cache[currentPath] then return end
      cache[currentPath] = true

      local f = io.open(currentPath)
      if not f then return end
      local content = f:read("*a")
      f:close()

      -- 处理导入
      for importName in content:gmatch('import%s+"([%w%.]+)"') do
        local resolvedPath = package.searchpath(importName, searchpath)
        if resolvedPath then checkClass(resolvedPath, result) end
      end

      -- 分析标识符
      local lex = LuaLexer(content)
      local identifiers = {}
      local lastTokenType

      while true do
        local tokenType = lex.advance()
        if not tokenType then break end
        if lastTokenType ~= DOT and tokenType == NAME then
          identifiers[lex.yytext()] = true
        end
        lastTokenType = tokenType
      end

      -- 匹配Java类
      for ident in pairs(identifiers) do
        local lastPart = ident:match("%w+$") or ident
        local candidates = classMap[lastPart]
        if candidates then
          for _, className in ipairs(candidates) do
            if not cache[className] then
              table.insert(result, className)
              cache[className] = true
            end
          end
        end
      end
    end

    local result = {}
    checkClass(path, result)
    return result
    end, function(ret)
    -- 结果处理
    data = luajava.astable(ret)
    table.sort(data)
    init()
    Anim.start()
  end).execute({path})
end

-- 执行导入修复
fiximport(path)

-- 菜单项选择处理
function onOptionsItemSelected(item)
  if item.getItemId() == android.R.id.home then
    activity.finish()
    return true
  end
end

-- 创建选项菜单
function onCreateOptionsMenu(menu)
  -- 反选菜单
  menu.add(res.string.invert_selection)
  --  .setIcon(IconDrawable("ic_selection_multiple", Colors.colorOnSurfaceVariant))
  --  .setShowAsAction(2)
  .onMenuItemClick = function()
    if data then
      for _, v in ipairs(data) do
        SelectedState[v] = SelectedState[v] == nil or not SelectedState[v]
      end
      adapter.notifyDataSetChanged()
    end
  end

  -- 复制菜单
  menu.add(res.string.copy)
  --  .setIcon(IconDrawable("ic_content_copy", Colors.colorOnSurfaceVariant))
  --  .setShowAsAction(2)
  .onMenuItemClick = function()
    if data then
      local selected = {}
      for k, v in pairs(SelectedState) do
        if v then table.insert(selected, string.format("import \"%s\"", k)) end
      end
      activity.getSystemService("clipboard").setText(table.concat(selected, "\n"))
      MyToast(res.string.copied_successfully)
    end
  end
end

-- 清理资源
function onDestroy()
  adapter.release()
  luajava.clear()
  collectgarbage("collect")
  collectgarbage("step")
end
