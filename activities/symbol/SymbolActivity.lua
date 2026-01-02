require "env"
setStatus()

-- 绑定Java类
local bindClass = luajava.bindClass
local StaggeredGridLayoutManager = bindClass "androidx.recyclerview.widget.StaggeredGridLayoutManager"
local ObjectAnimator = bindClass "android.animation.ObjectAnimator"
local RecyclerView = bindClass "androidx.recyclerview.widget.RecyclerView"
local LuaCustRecyclerHolder = bindClass "github.znzsofficial.adapter.LuaCustRecyclerHolder"
local PopupRecyclerAdapter = bindClass "github.znzsofficial.adapter.PopupRecyclerAdapter"
local PopupMenu = bindClass "androidx.appcompat.widget.PopupMenu"

-- 加载工具库
local Utils = require "utils.Utils"
local SharedPrefUtil = require "utils.SharedPrefUtil"
local IconDrawable = require "utils.IconDrawable"
local MaterialBlurDialogBuilder = require "dialogs.MaterialBlurDialogBuilder"

-- 全局变量
local symbol = SharedPrefUtil.getTable("symbol") or {}
local adapter

-- ===== 核心函数 =====
-- 添加/编辑符号
local function setSymbol(title, content, pos)
  local ids = {}
  MaterialBlurDialogBuilder(activity)
  .setTitle(title and res.string.modification or res.string.add)
  .setView(loadlayout("layouts.dialog_fileinput2", ids))
  .setPositiveButton(res.string.ok, function()
    if title then
      -- 编辑模式
      symbol[pos + 1].title = tostring(ids.title.text)
      symbol[pos + 1].content = tostring(ids.content.text)
      SharedPrefUtil.set("symbol", symbol)
      adapter.notifyItemChanged(pos) -- 仅刷新单个项目
     else
      -- 添加模式
      table.insert(symbol, {
        title = tostring(ids.title.text),
        content = tostring(ids.content.text),
      })
      SharedPrefUtil.set("symbol", symbol)
      adapter.notifyItemInserted(#symbol) -- 通知新增项
    end
  end)
  .setNegativeButton(res.string.no, nil)
  .show()

  -- 预填内容
  if title then
    ids.title.setText(title)
    ids.content.setText(content)
   else
    ids.title.setHint(res.string.title)
    ids.content.setHint(res.string.content)
  end
end

-- 初始化RecyclerView
local function init()
  adapter = PopupRecyclerAdapter(activity, PopupRecyclerAdapter.PopupCreator({
    getItemCount = function() return #symbol end,
    getItemViewType = function() return 0 end,
    getPopupText = function() return "" end,
    onViewRecycled = function() end,
    onCreateViewHolder = function(parent, viewType)
      local views = {}
      local holder = LuaCustRecyclerHolder(loadlayout("layouts.symbol_item", views))
      holder.Tag = views
      return holder
    end,
    onBindViewHolder = function(holder, position)
      local views = holder.Tag
      local data = symbol[position + 1]

      -- 设置文本
      views.title
      .setText(data.title)
      .getPaint().setFakeBoldText(true)
      views.content.setText(data.content)

      -- 点击编辑
      views.card.onClick = function()
        setSymbol(views.title.text, views.content.text, position)
      end

      -- 长按菜单
      activity.onLongClick(views.card, function(v)
        local currentPos = holder.getAdapterPosition()
        if currentPos == RecyclerView.NO_POSITION then
          return true
        end

        local pop = PopupMenu(activity, v)
        local menu = pop.Menu

        -- 置顶选项
        menu.add(res.string.topping).onMenuItemClick = function()
          if currentPos == 0 then return true end

          local item = symbol[currentPos + 1]
          table.remove(symbol, currentPos + 1)
          table.insert(symbol, 1, item)
          SharedPrefUtil.set("symbol", symbol)

          adapter.notifyItemMoved(currentPos, 0)
          adapter.notifyItemRangeChanged(0, currentPos + 1)
          return true
        end

        -- 删除选项
        menu.add(res.string.delete).onMenuItemClick = function()
          table.remove(symbol, currentPos + 1)
          SharedPrefUtil.set("symbol", symbol)

          adapter.notifyItemRemoved(currentPos)
          adapter.notifyItemRangeChanged(currentPos, #symbol - currentPos)
          return true
        end

        pop.show()
        return true
      end)
    end
  }))

  recycler_view
  .setAdapter(adapter)
  .setLayoutManager(StaggeredGridLayoutManager(4, 1))
end

-- 重置符号
local function resetSymbols()
  symbol = {
    { title = "Fun()", content = "function" },
    { title = "(", content = "(" },
    { title = ")", content = ")" },
    { title = "[", content = "[" },
    { title = "]", content = "]" },
    { title = "{", content = "{" },
    { title = "}", content = "}" },
    { title = "\"", content = "\"" },
    { title = "=", content = "=" },
    { title = ":", content = ":" },
    { title = ".", content = "." },
    { title = ",", content = "," },
    { title = ";", content = ";" },
    { title = "_", content = "_" },
    { title = "+", content = "+" },
    { title = "-", content = "-" },
    { title = "*", content = "*" },
    { title = "/", content = "/" },
    { title = "\\", content = "\\" },
    { title = "%", content = "%" },
    { title = "#", content = "#" },
    { title = "^", content = "^" },
    { title = "$", content = "$" },
    { title = "?", content = "?" },
    { title = "&", content = "&" },
    { title = "|", content = "|" },
    { title = "<", content = "<" },
    { title = ">", content = ">" },
    { title = "~", content = "~" },
    { title = "'", content = "'" }
  }
  SharedPrefUtil.set("symbol", symbol)
  if adapter then
    adapter.notifyDataSetChanged()
  end
end

-- ===== 主执行逻辑 =====
-- 设置界面
activity
.setContentView(loadlayout("layouts.activity_symbol"))
.setSupportActionBar(toolbar)
.getSupportActionBar()
.setDisplayHomeAsUpEnabled(true)

-- 初始化符号列表
init()

-- 设置添加按钮
fab.onClick = function()
  setSymbol()
end

-- ===== 生命周期函数 =====
-- 菜单项选择
function onOptionsItemSelected(item)
  if item.getItemId() == android.R.id.home then
    activity.finish()
    return true
  end
end

-- 创建菜单
function onCreateOptionsMenu(menu)
  menu.add(res.string.reset)
  .setShowAsAction(2)
  .setIcon(IconDrawable("ic_notification_clear_all", Colors.colorOnSurfaceVariant))
  .onMenuItemClick = function()
    MaterialBlurDialogBuilder(activity)
    .setTitle(res.string.tip)
    .setMessage(res.string.ok_reset)
    .setPositiveButton(res.string.ok, resetSymbols)
    .setNegativeButton(res.string.no, nil)
    .show()
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