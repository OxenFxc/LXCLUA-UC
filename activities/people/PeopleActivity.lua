require "env"
setStatus()

-- 统一绑定类
local bindClass = luajava.bindClass
local StaggeredGridLayoutManager = bindClass "androidx.recyclerview.widget.StaggeredGridLayoutManager"
local ObjectAnimator = bindClass "android.animation.ObjectAnimator"
local LuaCustRecyclerHolder = bindClass "github.znzsofficial.adapter.LuaCustRecyclerHolder"
local PopupRecyclerAdapter = bindClass "github.znzsofficial.adapter.PopupRecyclerAdapter"

-- 加载工具库
local GlideUtil = require "utils.GlideUtil"
local OkHttpUtil = require "utils.OkHttpUtil"

-- 数据存储
local appData = {
  contributors = {},
  donors = {}
}

-- 适配器容器
local adapters = {}

-- ===== 核心函数 =====
-- 初始化RecyclerView
local function initRecyclerView(recyclerView, dataKey)
  adapters[dataKey] = PopupRecyclerAdapter(activity, PopupRecyclerAdapter.PopupCreator({
    getItemCount = function()
      return #appData[dataKey]
    end,
    getItemViewType = function() return 0 end,
    getPopupText = function() return "" end,
    onViewRecycled = function(holder)
      -- 清理图片资源
      local views = holder.Tag
      if views and views.icon then
        GlideUtil.clear(views.icon)
      end
    end,

    onCreateViewHolder = function(parent, viewType)
      local views = {}
      local holder = LuaCustRecyclerHolder(loadlayout("layouts.people_item", views))
      holder.Tag = views
      return holder
    end,

    onBindViewHolder = function(holder, position)
      local views = holder.Tag
      local currentData = appData[dataKey][position + 1]
      if currentData and currentData.qq then
        local avatarUrl = ("http://q.qlogo.cn/headimg_dl?spec=640&img_type=jpg&dst_uin=%s"):format(currentData.qq)
        GlideUtil.set(avatarUrl, views.icon)
      end
    end
  }))

  -- 设置布局和适配器
  recyclerView
  .setLayoutManager(StaggeredGridLayoutManager(4, StaggeredGridLayoutManager.VERTICAL))
  .setAdapter(adapters[dataKey])

  -- 添加淡入动画
  ObjectAnimator.ofFloat(recyclerView, "alpha", {0, 1})
  .setDuration(400)
  .start()
end

-- ===== 主执行逻辑 =====
-- 设置界面
activity
.setContentView(loadlayout("layouts.activity_people"))
.setSupportActionBar(toolbar)
.getSupportActionBar()
.setDisplayHomeAsUpEnabled(true)

-- 检查离线模式
if not activity.getSharedData("offline_mode") then
  -- 初始化RecyclerView
  initRecyclerView(recycler_view1, "contributors")
  initRecyclerView(recycler_view2, "donors")

  -- 获取数据
  OkHttpUtil.post(false, "https://luaappx.top/contributors_donors.php", nil, nil,
  function(code, body)
    if code ~= 200 then
      return
    end

    local success, response = pcall(OkHttpUtil.decode, body)
    if not success or not response then
      return
    end

    -- 更新数据
    if response.data then
      appData.contributors = response.data.contributors or {}
      appData.donors = response.data.donors or {}

      -- 刷新适配器
      if adapters.contributors then
        adapters.contributors.notifyDataSetChanged()
      end

      if adapters.donors then
        adapters.donors.notifyDataSetChanged()
      end
    end
  end)
end

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