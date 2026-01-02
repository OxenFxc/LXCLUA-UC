require "env"
setStatus()

-- 绑定Java类
local bindClass = luajava.bindClass
local LinearLayoutManager = bindClass "androidx.recyclerview.widget.LinearLayoutManager"
local ObjectAnimator = bindClass "android.animation.ObjectAnimator"
local RecyclerView = bindClass "androidx.recyclerview.widget.RecyclerView"
local LuaCustRecyclerHolder = bindClass "github.znzsofficial.adapter.LuaCustRecyclerHolder"
local PopupRecyclerAdapter = bindClass "github.znzsofficial.adapter.PopupRecyclerAdapter"
local Handler = bindClass "android.os.Handler"
local Runnable = bindClass "java.lang.Runnable"

-- 加载工具库
local Utils = require "utils.Utils"
local OkHttpUtil = require "utils.OkHttpUtil"
local GlideUtil = require "utils.GlideUtil"
local ActivityUtil = require "utils.ActivityUtil"

-- 常量配置
local API_BASE_URL = "https://luaappx.top/users/"

-- 全局变量
local data = {}
local adapter
local current_user_rank
local refreshLock = false -- 刷新锁

-- ===== 辅助函数 =====
-- 初始化RecyclerView
local function initRecyclerView()
  adapter = PopupRecyclerAdapter(activity, PopupRecyclerAdapter.PopupCreator({
    getItemCount = function() return #data end,
    getItemViewType = function() return 0 end,
    getPopupText = function(view, position)
      local item = data[position + 1]
      if item and item.nickname then
        return utf8.sub(item.nickname, 1, 1):upper() -- 取昵称首字母并大写
      end
      return ""
    end,
    onViewRecycled = function(holder)
      -- 视图回收时清理资源
      local views = holder.Tag
    end,
    onCreateViewHolder = function(parent, viewType)
      local views = {}
      local holder = LuaCustRecyclerHolder(loadlayout("layouts.ranking_item", views))
      holder.Tag = views
      return holder
    end,
    onBindViewHolder = function(holder, position)
      local views = holder.Tag
      local currentData = data[position + 1]

      if currentData then
        -- 头像加载
        local avatar = tostring(currentData.avatar_url)
        GlideUtil.set(avatar:find("http") and avatar or
        "https://luaappx.top/public/uploads/avatars/default_avatar.png", views.avatar, true)

        -- 排名显示
        views.rank.setText(tostring(tointeger(currentData.rank)))
        
        views.title.setText(tostring(currentData.title)) 

        -- 设置排名颜色
        if currentData.rank == 1 then
          views.rank.setTextColor(0xFFFF5722) -- 第一名金色
         elseif currentData.rank == 2 then
          views.rank.setTextColor(0xFFFF9800) -- 第二名银色
         elseif currentData.rank == 3 then
          views.rank.setTextColor(0xFF2196F3) -- 第三名铜色
         else
          views.rank.setTextColor(Colors.colorOnBackground)
        end

        -- 用户标识
        if current_user_rank == currentData.rank then
          views.nick.setText(currentData.nickname .. " (" .. res.string.me .. ")")
          views.card.setCardBackgroundColor(Colors.colorSurfaceContainer)
         else
          views.nick.setText(currentData.nickname)
          views.card.setCardBackgroundColor(0)
        end

        -- 硬币数量
        views.coins.setText(tostring(tointeger(currentData.x_coins)) .. " " .. res.string.x_coin)

        function views.card.onClick(v)
          ActivityUtil.new("privacy", { currentData.user_id })
        end

      end
    end
  }))

  -- 设置RecyclerView
  recycler_view
  .setLayoutManager(LinearLayoutManager(activity))
  .setAdapter(adapter)
  .setHasFixedSize(true) -- 优化性能
  .setItemAnimator(nil) -- 禁用默认动画提升性能

  -- 添加Item装饰器
  recycler_view.addItemDecoration(RecyclerView.ItemDecoration {
    getItemOffsets = function(outRect, view, parent, state)
      Utils.modifyItemOffsets(outRect, view, parent, adapter, 14)
    end
  })

  -- 设置淡入动画
  ObjectAnimator.ofFloat(recycler_view, "alpha", {0, 1})
  .setDuration(400)
  .start()
end

-- 加载排行榜数据
local function loadRankingData()
  -- 显示加载状态
  recycler_view.setVisibility(8)

  OkHttpUtil.post(false, API_BASE_URL .. "wealth_ranking.php", {
    time = os.time()
    }, {
    ["Authorization"] = "Bearer " .. getSQLite(3)
    }, function(code, body)
    -- 停止刷新动画
    mSwipeRefreshLayout.setRefreshing(false)

    local success, response = pcall(OkHttpUtil.decode, body)
    if success and response and response.data and response.data.ranking_list then
      -- 清空旧数据
      data = {}
      current_user_rank = response.data.current_user_rank

      -- 处理新数据
      for _, item in ipairs(response.data.ranking_list) do
        table.insert(data, item)
      end

      -- 刷新UI
      if #data > 0 then
        adapter.notifyDataSetChanged()
        recycler_view.setVisibility(0)
       else
        recycler_view.setVisibility(8)
      end
    end
  end)
end

-- 初始化下拉刷新
local function initSwipeRefresh()
  mSwipeRefreshLayout
  .setProgressViewOffset(true, -100, 250)
  .setColorSchemeColors({ Colors.colorPrimary })
  .setProgressBackgroundColorSchemeColor(Colors.colorSurface)
  .setOnRefreshListener({
    onRefresh = function()
      -- 防抖机制，避免频繁刷新
      if not refreshLock then
        refreshLock = true
        loadRankingData()

        -- 1.5秒后解锁刷新
        Handler().postDelayed(Runnable({
          run = function() refreshLock = false end
        }), 1500)
       else
        mSwipeRefreshLayout.setRefreshing(false)
      end
    end
  })
end

-- ===== 主执行逻辑 =====
-- 设置界面
activity
.setContentView(loadlayout("layouts.activity_ranking"))
.setSupportActionBar(toolbar)
.getSupportActionBar()
.setDisplayHomeAsUpEnabled(true)

-- 初始化下拉刷新
initSwipeRefresh()

-- 初始化RecyclerView
initRecyclerView()

-- 加载数据
loadRankingData()

-- ===== 生命周期函数 =====
-- 菜单项选择
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