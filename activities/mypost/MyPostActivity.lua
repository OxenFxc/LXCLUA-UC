require "env"
setStatus()
local OkHttpUtil = require "utils.OkHttpUtil"
local GlideUtil = require "utils.GlideUtil"
local Utils = require "utils.Utils"
local ActivityUtil = require "utils.ActivityUtil"
local MaterialBlurDialogBuilder = require "dialogs.MaterialBlurDialogBuilder"
local SharedPrefUtil = require "utils.SharedPrefUtil"

-- 绑定Java类
local bindClass = luajava.bindClass
local RecyclerView = bindClass "androidx.recyclerview.widget.RecyclerView"
local LinearLayoutManager = bindClass "androidx.recyclerview.widget.LinearLayoutManager"
local LuaCustRecyclerHolder = bindClass "github.znzsofficial.adapter.LuaCustRecyclerHolder"
local PopupRecyclerAdapter = bindClass "github.znzsofficial.adapter.PopupRecyclerAdapter"
local LuaPagerAdapter = bindClass "github.daisukiKaffuChino.LuaPagerAdapter"
local ArrayList = bindClass "java.util.ArrayList"
local DefaultItemAnimator = bindClass "androidx.recyclerview.widget.DefaultItemAnimator"
local LinearLayoutCompat = bindClass "androidx.appcompat.widget.LinearLayoutCompat"
local SwipeRefreshLayout = bindClass "androidx.swiperefreshlayout.widget.SwipeRefreshLayout"
local ObjectAnimator = bindClass "android.animation.ObjectAnimator"
local Handler = bindClass "android.os.Handler"

-- API设置
local API_BASE_URL = "https://luaappx.top/forum/"
local TAB_TITLES = {res.string.my_posts, res.string.purchased_post, res.string.favorites_post, res.string.off_the_shelf}
local PAGE_TYPES = {"my_posts", "purchased", "favorites", "removed"}

-- 全局变量
local dataList = {}
local pageList = {}
local hasMoreList = {}
local isLoadingList = {}
local adapters = {}
local recyclerViews = {}
local dataHolders = {}
local swipeRefreshLayouts = {}
local fadeInAnims = {}
local currentTab = 1
local searchHandler = Handler()
local searchRunnable = nil
local isSearchVisible = false

-- 为每个标签页创建独立的搜索状态
local searchKeywords = {"", "", "", ""} -- 每个标签页的搜索关键词
local isSearching = {false, false, false, false} -- 每个标签页的搜索状态
local initializedTabs = {false, false, false, false} -- 标记标签页是否已初始化

activity
.setContentView(loadlayout("layouts.activity_mypost"))
.setSupportActionBar(toolbar)
.getSupportActionBar()
.setTitle(res.string.my_post)
.setDisplayHomeAsUpEnabled(true)

-- 初始化页面数据
for i = 1, 4 do
  dataList[i] = {}
  pageList[i] = 1
  hasMoreList[i] = true
  isLoadingList[i] = false
end

-- 设置搜索功能可见性
function toggleSearchVisibility()
  isSearchVisible = not isSearchVisible
  content.setVisibility(isSearchVisible and 0 or 8)

  -- 清空搜索框当隐藏时
  if not isSearchVisible then
    content.setText("")
    -- 清除当前标签页的搜索状态
    searchKeywords[currentTab] = ""
    isSearching[currentTab] = false
    refreshData(currentTab)
   else
    -- 显示时设置当前标签页的搜索词
    content.setText(searchKeywords[currentTab])
  end
end

--[[设置菜单按钮
toolbar.getMenu().clear()
toolbar.inflateMenu(R.menu.menu_search)
toolbar.onMenuItemClick = function(item)
  if item.getItemId() == R.id.action_search then
    toggleSearchVisibility()
    return true
  end
  return false
end]]

-- 创建页面视图
local pagerList = ArrayList()
for i = 1, 4 do
  local layout = LinearLayoutCompat(activity)
  layout.orientation = 1

  -- 创建下拉刷新布局
  local swipeRefresh = SwipeRefreshLayout(activity)

  swipeRefresh.setProgressViewOffset(true, -100, 200)
  swipeRefresh.setColorSchemeColors({Colors.colorPrimary})

  -- 创建RecyclerView
  local recyclerView = RecyclerView(activity)

  recyclerView.setLayoutManager(LinearLayoutManager(activity))

  -- 添加滚动监听
  recyclerView.addOnScrollListener(RecyclerView.OnScrollListener{
    onScrolled = function(view, dx, dy)
      if isLoadingList[i] or not hasMoreList[i] then return end

      local layoutManager = view.getLayoutManager()
      local visibleItemCount = layoutManager.getChildCount()
      local totalItemCount = layoutManager.getItemCount()
      local firstVisibleItem = layoutManager.findFirstVisibleItemPosition()

      if (visibleItemCount + firstVisibleItem) >= totalItemCount then
        pageList[i] = pageList[i] + 1
        -- 加载数据时传入当前标签页的搜索关键词
        loadData(i, false, searchKeywords[i])
      end
    end
  })

  recyclerView.addItemDecoration(RecyclerView.ItemDecoration {
    getItemOffsets = function(outRect, view, parent, state)
      Utils.modifyItemOffsets(outRect, view, parent, recyclerView.adapter, 14)
    end
  })

  -- 设置下拉刷新监听
  swipeRefresh.setOnRefreshListener({
    onRefresh = function()
      refreshData(i)
    end
  })

  -- 添加到布局
  swipeRefresh.addView(recyclerView)
  layout.addView(swipeRefresh)
  pagerList.add(layout)

  -- 保存引用
  recyclerViews[i] = recyclerView
  swipeRefreshLayouts[i] = swipeRefresh
end

-- 设置ViewPager适配器
cvpg.setAdapter(LuaPagerAdapter(pagerList))

-- 设置TabLayout
mtabs.setupWithViewPager(cvpg)
Utils.setTabRippleEffect(mtabs)

-- 设置Tab标题
for i = 1, 4 do
  local tab = mtabs.getTabAt(i-1)
  if tab then tab.setText(TAB_TITLES[i]) end
end

-- 添加Tab切换监听
cvpg.addOnPageChangeListener({
  onPageSelected = function(position)
    currentTab = position + 1
    -- 仅设置当前标签页的搜索词，不再清空
    content.setText(searchKeywords[currentTab])

    -- 保持搜索框可见状态
    if isSearchVisible then
      content.setVisibility(0)
    end

    -- 确保数据加载：如果当前标签页未初始化，则加载数据
    if not initializedTabs[currentTab] then
      loadData(currentTab, true, searchKeywords[currentTab])
      initializedTabs[currentTab] = true
    end
  end
})

-- 初始化适配器
local function initAdapter(i)
  local dataHolder = { data = dataList[i] }
  dataHolders[i] = dataHolder

  adapters[i] = PopupRecyclerAdapter(activity, PopupRecyclerAdapter.PopupCreator({
    getItemCount = function() return #dataHolder.data end,
    getItemViewType = function() return 0 end,
    getPopupText = function() return "" end,
    onViewRecycled = function() end,
    onCreateViewHolder = function(parent, viewType)
      local views = {}
      local holder = LuaCustRecyclerHolder(loadlayout("layouts.post_code_item", views))
      holder.Tag = views
      return holder
    end,
    onBindViewHolder = function(holder, position)
      local views = holder.Tag
      -- 添加空值检查，防止数据为空导致崩溃
      if not dataHolder.data or not dataHolder.data[position + 1] then
        --print("Data missing at position:", position + 1)
        return
      end

      local currentData = dataHolder.data[position + 1]
      local avatar = tostring(currentData.avatar_url)

      views.admin.parent.setVisibility(currentData.is_admin and 0 or 8)
      GlideUtil.set((function() if avatar:find("http") ~= nil then return avatar else return "https://luaappx.top/public/uploads/avatars/default_avatar.png" end end)(), views.icon, true)

      views.nick.setText(tostring(currentData.nickname))
      views.time.setText(tostring(currentData.created_at))
      views.title.setText(tostring(currentData.title))
      .getPaint().setFakeBoldText(true)
      views.content.setText(tostring(currentData.content))
      views.thumb.setText(tostring(tointeger(currentData.like_count)))
      views.view_count.setText(tostring(tointeger(currentData.view_count)))
      views.reply.setText(tostring(tointeger(currentData.comment_count)))
      views.star.setText(tostring(tointeger(currentData.favorite_count)))

      if currentData.price and currentData.price ~= 0 then
        views.price.parent.setVisibility(8)
        views.price.setText(currentData.purchased and res.string.purchased or tostring(tointeger(currentData.price)) .. " X币")
       else
        views.price.parent.setVisibility(8)
      end

      function views.card.onClick(v)
        ActivityUtil.new("details", { OkHttpUtil.cecode(currentData) })
      end

      activity.onLongClick(views.card, function()
        local isAdmin = SharedPrefUtil.getBoolean("is_admin")
        local myUserId = SharedPrefUtil.getNumber("user_id")

        local rotateAnim = ObjectAnimator.ofFloat(views.card, "rotation", {0, 5, -5, 0})
        rotateAnim.setDuration(300)
        rotateAnim.start()

        local items = { res.string.copy_header }

        -- 获取当前页面位置，简化后续判断
        local currentItem = cvpg.getCurrentItem()
        -- 判断是否满足操作权限（除了第0页，其他页需要权限）
        local hasPermission = (currentItem == 0) or (isAdmin or myUserId == currentData.user_id)

        if hasPermission then
          -- 公共操作：删除、修改
          table.insert(items, res.string.delete_post)
          table.insert(items, res.string.modify_post)

          -- 根据页面位置添加不同的状态操作
          if currentItem == 0 or currentItem == 1 or currentItem == 2 then
            table.insert(items, res.string.off_the_shelf_post)
           elseif currentItem == 3 then
            table.insert(items, res.string.restore_post)
          end
        end

        MaterialBlurDialogBuilder(activity)
        .setTitle(res.string.menu)
        .setItems(items, function(l, v)
          if items[v+1] == res.string.copy_header then
            activity.getSystemService("clipboard").setText(currentData.title)
            MyToast(res.string.copied_successfully)
           elseif items[v+1] == res.string.delete_post then
            MaterialBlurDialogBuilder(activity)
            .setTitle(res.string.tip)
            .setMessage((res.string.delete_post_tip):format(currentData.title))
            .setPositiveButton(res.string.ok, function()
              OkHttpUtil.post(true, API_BASE_URL .. "delete_post.php", {
                post_id = currentData.id,
                user_id = currentData.user_id,
                time = os.time()
                }, {
                ["Authorization"] = "Bearer " .. tostring(getSQLite(3))
                }, function (code, body)
                local success, v = pcall(OkHttpUtil.decode, body)
                if success and v then
                  if v.success then
                    refreshData(i)
                  end
                  MyToast(v.message)
                 else
                  OkHttpUtil.error(body)
                end
              end)
            end)
            .setNegativeButton(res.string.no, nil)
            .show()
           elseif items[v+1] == res.string.modify_post then
            ActivityUtil.new("post", { currentData.id })
           elseif items[v+1] == res.string.restore_post then
            MaterialBlurDialogBuilder(activity)
            .setTitle(res.string.tip)
            .setMessage((res.string.restore_post_tip):format(currentData.title))
            .setPositiveButton(res.string.ok, function()
              OkHttpUtil.post(true, API_BASE_URL .. "restore_post.php", {
                post_id = currentData.id,
                user_id = currentData.user_id,
                time = os.time()
                }, {
                ["Authorization"] = "Bearer " .. tostring(getSQLite(3))
                }, function (code, body)
                local success, v = pcall(OkHttpUtil.decode, body)
                if success and v then
                  if v.success then
                    refreshData(i)
                  end
                  MyToast(v.message)
                 else
                  OkHttpUtil.error(body)
                end
              end)
            end)
            .setNegativeButton(res.string.no, nil)
            .show()
           elseif items[v+1] == res.string.off_the_shelf_post then
            MaterialBlurDialogBuilder(activity)
            .setTitle(res.string.tip)
            .setMessage((res.string.remove_post_tip):format(currentData.title))
            .setPositiveButton(res.string.ok, function()
              OkHttpUtil.post(true, API_BASE_URL .. "remove_post.php", {
                post_id = currentData.id,
                user_id = currentData.user_id,
                time = os.time()
                }, {
                ["Authorization"] = "Bearer " .. tostring(getSQLite(3))
                }, function (code, body)
                local success, v = pcall(OkHttpUtil.decode, body)
                if success and v then
                  if v.success then
                    refreshData(i)
                  end
                  MyToast(v.message)
                 else
                  OkHttpUtil.error(body)
                end
              end)
            end)
            .setNegativeButton(res.string.no, nil)
            .show()
          end
        end)
        .show()
        return true
      end)
    end
  }))

  recyclerViews[i].setAdapter(adapters[i])
  recyclerViews[i].setItemAnimator(DefaultItemAnimator())

  -- 初始化动画
  fadeInAnims[i] = ObjectAnimator.ofFloat(recyclerViews[i], "alpha", {0, 1})
  fadeInAnims[i].setDuration(250)
end

-- 加载数据
function loadData(tabIndex, isFirstLoad, keyword)
  -- 添加终止条件，避免无效请求
  if isLoadingList[tabIndex] or (not hasMoreList[tabIndex] and not isFirstLoad) then
    swipeRefreshLayouts[tabIndex].setRefreshing(false)
    return
  end

  isLoadingList[tabIndex] = true
  swipeRefreshLayouts[tabIndex].setRefreshing(true)

  local params = {
    ["page"] = pageList[tabIndex],
    ["page_size"] = 10,
    ["keyword"] = keyword or "",
    ["time"] = os.time()
  }

  -- 根据Tab类型设置参数
  if PAGE_TYPES[tabIndex] == "my_posts" then
    params["get_my_posts"] = 1
   elseif PAGE_TYPES[tabIndex] == "purchased" then
    params["get_my_purchased"] = 1
   elseif PAGE_TYPES[tabIndex] == "favorites" then
    params["get_my_favorites"] = 1
   elseif PAGE_TYPES[tabIndex] == "removed" then
    params["get_removed"] = 1 -- 新增的下架帖子参数
  end

  OkHttpUtil.post(false, API_BASE_URL .. "list_user_posts.php", params, {
    ["Authorization"] = "Bearer " .. tostring(getSQLite(3))
    }, function(code, body)

    isLoadingList[tabIndex] = false
    swipeRefreshLayouts[tabIndex].setRefreshing(false)

    local success, response = pcall(OkHttpUtil.decode, body)
    if success and response and response.data then
      local newData = response.data

      -- 确保数据更新到正确的标签页
      if pageList[tabIndex] == 1 then
        dataList[tabIndex] = newData

        if dataHolders[tabIndex] then
          dataHolders[tabIndex].data = dataList[tabIndex]
        end

        adapters[tabIndex].notifyDataSetChanged()
        hasMoreList[tabIndex] = true

        if fadeInAnims[tabIndex] then
          fadeInAnims[tabIndex].start()
        end
        recyclerViews[tabIndex].alpha = 1

       else
        if newData and #newData > 0 then
          for _, item in ipairs(newData) do
            table.insert(dataList[tabIndex], item)
          end
          adapters[tabIndex].notifyDataSetChanged()
         else
          pageList[tabIndex] = pageList[tabIndex] - 1
          hasMoreList[tabIndex] = false
          --         MyToast(res.string.no_more_data)
        end
      end
     else
      -- MyToast(res.string.data_load_failed)
    end
  end)
end

-- 添加搜索文本监听（带防抖功能）
content.addTextChangedListener({
  afterTextChanged = function(editable)
    -- 取消之前的搜索任务
    if searchRunnable then
      searchHandler.removeCallbacks(searchRunnable)
      searchRunnable = nil
    end

    -- 获取当前搜索词
    local keyword = tostring(editable)
    -- 更新当前标签页的搜索关键词
    searchKeywords[currentTab] = keyword
    isSearching[currentTab] = keyword ~= ""

    -- 设置新的搜索任务（500ms防抖）
    searchRunnable = Runnable {
      run = function()
        -- 确保搜索应用到当前标签页
        refreshData(currentTab, keyword)
      end
    }
    searchHandler.postDelayed(searchRunnable, 10)
  end
})

-- 刷新数据
function refreshData(tabIndex, keyword)
  pageList[tabIndex] = 1
  hasMoreList[tabIndex] = true
  -- 使用传入的关键词或当前标签页的关键词
  loadData(tabIndex, true, keyword or searchKeywords[tabIndex])
end

-- 初始化所有适配器（但不加载数据）
for i = 1, 4 do
  initAdapter(i)
  recyclerViews[i].alpha = 0
end

-- 只加载第一个页面的数据
initializedTabs[1] = true
loadData(1, true)

-- 菜单项选择
function onOptionsItemSelected(item)
  if item.getItemId() == android.R.id.home then
    activity.finish()
    return true
   elseif item.getItemId() == R.id.action_search then
    toggleSearchVisibility()
    return true
  end
  return false
end

-- 清理资源
function onDestroy()
  for i = 1, 4 do
    adapters[i].release()
  end
  luajava.clear()
  collectgarbage("collect")
  collectgarbage("step")
end