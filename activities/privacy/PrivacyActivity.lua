require "env"
setStatus()
local bindClass = luajava.bindClass
local LinearLayoutManager = bindClass "androidx.recyclerview.widget.LinearLayoutManager"
local ObjectAnimator = bindClass "android.animation.ObjectAnimator"
local RecyclerView = bindClass "androidx.recyclerview.widget.RecyclerView"
local LuaCustRecyclerHolder = bindClass "github.znzsofficial.adapter.LuaCustRecyclerHolder"
local PopupRecyclerAdapter = bindClass "github.znzsofficial.adapter.PopupRecyclerAdapter"
local Intent = bindClass "android.content.Intent"
local LinearLayoutCompat = bindClass "androidx.appcompat.widget.LinearLayoutCompat"
local Slider = bindClass "com.google.android.material.slider.Slider"
local DefaultItemAnimator = bindClass "androidx.recyclerview.widget.DefaultItemAnimator"
local LayoutAnimationController = bindClass "android.view.animation.LayoutAnimationController"
local AlphaAnimation = bindClass "android.view.animation.AlphaAnimation"
local ColorStateList = bindClass "android.content.res.ColorStateList"
local MaterialBlurDialogBuilder = require "dialogs.MaterialBlurDialogBuilder"
local GlideUtil = require "utils.GlideUtil"
local OkHttpUtil = require "utils.OkHttpUtil"
local IconDrawable = require "utils.IconDrawable"
local SharedPrefUtil = require "utils.SharedPrefUtil"
local ActivityUtil = require "utils.ActivityUtil"
local Utils = require "utils.Utils"
user_id = tostring(tointeger(...))

local API_BASE_URL = "https://luaappx.top/users/"
local POSTS_API_URL = "https://luaappx.top/forum/"
local ADMIN_BASE_URL = "https://luaappx.top/admin/"
local data_code = {}
local page_code = 1
local isLoading = false
local hasMore = true
local adapter_code = nil
local fadeInAnim = nil
local currentKeyword = ""
local colorError = Utils.setColorAlpha(Colors.colorError, 40)

activity
.setContentView(loadlayout("layouts.activity_privacy"))
.setSupportActionBar(toolbar)
.getSupportActionBar()
.setDisplayHomeAsUpEnabled(true)

-- 初始化RecyclerView
local function initRecycler()
  -- 设置动画
  local itemAnimator = DefaultItemAnimator()
  itemAnimator.setAddDuration(180)
  itemAnimator.setRemoveDuration(180)
  itemAnimator.setMoveDuration(180)
  itemAnimator.setChangeDuration(180)
  recycler_code.setItemAnimator(itemAnimator)

  local animation = AlphaAnimation(0, 1)
  animation.setDuration(180)
  local controller = LayoutAnimationController(animation)
  controller.setDelay(0.1)
  controller.setOrder(LayoutAnimationController.ORDER_NORMAL)
  recycler_code.setLayoutAnimation(controller)

  fadeInAnim = ObjectAnimator.ofFloat(recycler_code, "alpha", {0, 1})
  fadeInAnim.setDuration(180)

  -- 创建适配器
  adapter_code = PopupRecyclerAdapter(activity, PopupRecyclerAdapter.PopupCreator({
    getItemCount = function()
      return #data_code
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
      local holder = LuaCustRecyclerHolder(loadlayout("layouts.post_code_item", views))
      holder.Tag = views
      return holder
    end,
    onBindViewHolder = function(holder, position)
      local views = holder.Tag
      local currentData = data_code[position+1]
      local avatar = tostring(currentData.avatar_url)
      views.admin.parent.setVisibility(currentData.is_admin and 0 or 8)
      GlideUtil.set((function()
        if avatar:find("http") ~= nil then
          return avatar
         else
          return "https://luaappx.top/public/uploads/avatars/default_avatar.png"
        end
      end)(), views.icon, true)

      views.nick.setText(tostring(currentData.nickname))
      views.time.setText(tostring(currentData.created_at))
      views.title.setText(tostring(currentData.title))
      views.title.getPaint().setFakeBoldText(true)
      views.content.setText(tostring(currentData.content))
      views.thumb.setText(tostring(tointeger(currentData.like_count)))
      views.view_count.setText(tostring(tointeger(currentData.view_count)))
      views.reply.setText(tostring(tointeger(currentData.comment_count)))
      views.star.setText(tostring(tointeger(currentData.favorite_count)))

      if currentData.price ~= 0 then
        views.price.parent.setVisibility(8)
        views.price.setText(currentData.purchased and res.string.purchased or tostring(tointeger(currentData.price)) .. " X币")
       else
        views.price.parent.setVisibility(8)
      end

      function views.card.onClick(v)
        ActivityUtil.new("details", { OkHttpUtil.cecode(currentData) })
      end

      activity.onLongClick(views.card, function()
        local rotateAnim = ObjectAnimator.ofFloat(views.card, "rotation", {0, 5, -5, 0})
        rotateAnim.setDuration(300)
        rotateAnim.start()

        local items = {res.string.copy_header}
        local isAdmin = SharedPrefUtil.getBoolean("is_admin")
        local myUserId = SharedPrefUtil.getNumber("user_id")

        if isAdmin or myUserId == currentData.user_id then
          table.insert(items, res.string.delete_post)
          table.insert(items, res.string.modify_post)
          table.insert(items, res.string.off_the_shelf_post)

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
              OkHttpUtil.post(true, POSTS_API_URL .. "delete_post.php", {
                post_id = currentData.id,
                user_id = currentData.user_id,
                time = os.time()
                }, {
                ["Authorization"] = "Bearer " .. tostring(getSQLite(3))
                }, function (code, body)
                local success, v = pcall(OkHttpUtil.decode, body)
                if success and v then
                  if v.success then
                    refreshData()
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
           elseif items[v+1] == res.string.off_the_shelf_post then
            MaterialBlurDialogBuilder(activity)
            .setTitle(res.string.tip)
            .setMessage((res.string.remove_post_tip):format(currentData.title))
            .setPositiveButton(res.string.ok, function()

              OkHttpUtil.post(true, POSTS_API_URL .. "remove_post.php", {
                post_id = currentData.id,
                user_id = currentData.user_id,
                time = os.time()
                }, {
                ["Authorization"] = "Bearer " .. tostring(getSQLite(3))
                }, function (code, body)

                local success, v = pcall(OkHttpUtil.decode, body)
                if success and v then
                  if v.success then
                    refreshData()
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

  recycler_code.setAdapter(adapter_code)
  recycler_code.setLayoutManager(LinearLayoutManager(activity))

  recycler_code.addItemDecoration(RecyclerView.ItemDecoration {
    getItemOffsets = function(outRect, view, parent, state)
      Utils.modifyItemOffsets(outRect, view, parent, adapter_code, 14)
    end
  })

end

-- 获取帖子数据
local function getPosts(page, isRefresh)
  if isLoading then return end
  isLoading = true

  local url = POSTS_API_URL .. "list_posts.php?user_id=" .. user_id .. "&page=" .. page .. "&page_size=10"
  if currentKeyword ~= "" then
    url = url .. "&keyword=" .. currentKeyword
  end
  url = url .. "&time=" .. os.time()

  OkHttpUtil.get(false, url, {
    ["Authorization"] = "Bearer " .. tostring(getSQLite(3))
    }, true, function(code, body)

    isLoading = false
    mSwipeRefreshLayout.setRefreshing(false)

    local success, response = pcall(OkHttpUtil.decode, body)
    if success and response and response.data then
      local newData = response.data

      if page == 1 then
        data_code = newData or {}
        adapter_code.notifyDataSetChanged()
        hasMore = #newData > 0

        if fadeInAnim then
          fadeInAnim.start()
        end
        recycler_code.alpha = 1
       else
        if newData and #newData > 0 then
          for _, item in ipairs(newData) do
            table.insert(data_code, item)
          end
          adapter_code.notifyDataSetChanged()
         else
          page_code = page_code - 1
          hasMore = false
        end
      end
    end
  end)
end

local function refreshBannedChip()
  is_banned
  .setChipBackgroundColor(
  ColorStateList.valueOf(is_banned2 and colorError or 0))
  .setChipIcon(
  is_banned2 and IconDrawable("ic_account_off_outline", Colors.colorOnBackground)
  or IconDrawable("ic_account_outline", Colors.colorOnBackground))
end

-- 加载用户信息
local function getProfile()
  OkHttpUtil.get(false, API_BASE_URL .. "get_profile.php?userid=" .. user_id .. "&time=" .. os.time(), nil, true, function(code, body)
    local success, v = pcall(OkHttpUtil.decode, body)
    if not (success and v and v.success) then
      MyToast(v and v.message or body)
      return
    end
    local isAdmin = SharedPrefUtil.getBoolean("is_admin")
    local myUserId = SharedPrefUtil.getNumber("user_id")
    is_banned2 = v.data.is_banned

    local avatar = tostring(v.data.avatar_url)
    GlideUtil.set((function()
      if avatar:find("http") ~= nil then
        return avatar
       else
        return "https://luaappx.top/public/uploads/avatars/default_avatar.png"
      end
    end)(), logo, true)
    nick.setText(tostring(v.data.nickname))
    price.setText(tostring(tointeger(v.data.x_coins)) .. " " .. res.string.x_coin)
    member_since.setText(tostring(v.data.member_since))
    if v.data.is_banned then
      is_banned.setVisibility(0)
      title.parent.setVisibility(0)
      .setCardBackgroundColor(Utils.setColorAlpha(Colors.colorError, 20))
      title.setText(res.string.ban)
      .setTextColor(Colors.colorError)
     else
      title.parent.setVisibility(0)
      title.setText(v.data.is_admin and res.string.administrator or v.data.title)      
    end
    if isAdmin then
      email.parent.setVisibility(0)
      email.setText(tostring(v.data.email))
      --.setVisibility(0)
      nick.setText(tostring(v.data.nickname) .. "(" .. tointeger(v.data.user_id) .. ")")
      -- 点击事件
      function is_banned.onClick()
        is_banned2 = not is_banned2
        OkHttpUtil.post(true, ADMIN_BASE_URL .. "api/ban_user.php", {
          user_id = v.data.user_id,
          ban = is_banned2,
          time = os.time()
          }, {
          ["Authorization"] = "Bearer " .. tostring(getSQLite(3))
          }, function (code, body)
          local success, v = pcall(OkHttpUtil.decode, body)
          if not (success and v and v.success) then
            MyToast(v and v.message or body)
            return
          end
          MyToast(v.message)
          getProfile()
          refreshBannedChip()
        end)
      end
    end
    refreshBannedChip()
  end)
end

-- 刷新数据
function refreshData()
  page_code = 1
  hasMore = true
  getPosts(page_code, true)
end

-- 初始化下拉刷新
local function initSwipeRefresh()
  mSwipeRefreshLayout.setProgressViewOffset(true, -100, 200)
  mSwipeRefreshLayout.setColorSchemeColors({ Colors.colorPrimary })
  mSwipeRefreshLayout.setOnRefreshListener({
    onRefresh = function()
      refreshData()
      getProfile()
    end
  })
end

getProfile()

-- 初始化RecyclerView和下拉刷新
initRecycler()
initSwipeRefresh()

-- 首次加载数据
refreshData()

-- 滚动加载更多
recycler_code.addOnScrollListener(RecyclerView.OnScrollListener{
  onScrolled = function(recyclerView, dx, dy)
    if isLoading or not hasMore then return end

    local layoutManager = recyclerView.getLayoutManager()
    local visibleItemCount = layoutManager.getChildCount()
    local totalItemCount = layoutManager.getItemCount()
    local firstVisibleItemPosition = layoutManager.findFirstVisibleItemPosition()

    if (visibleItemCount + firstVisibleItemPosition) >= totalItemCount then
      page_code = page_code + 1
      getPosts(page_code, false)
    end
  end
})

function searchPosts(keyword)
  currentKeyword = keyword or ""
  refreshData()
end

function onCreateOptionsMenu(menu)
  -- 添加搜索菜单项
  local searchItem = menu.add(0, 1, 0, res.string.search)
  searchItem.setShowAsAction(2)

  local searchView = luajava.newInstance("androidx.appcompat.widget.SearchView", activity)
  searchItem.setActionView(searchView)

  -- 为SearchView设置一个唯一的ID
  searchView.setId(android.R.id.custom) -- 使用系统预定义的ID或生成新ID
  searchItem.setActionView(searchView)

  local searchAutoComplete = searchView.findViewById(AndroidX_R.id.search_src_text)
  searchAutoComplete.setHint(res.string.search)

  searchView.setOnQueryTextListener({
    onQueryTextChange = function(newText)
      searchPosts(newText)
      return true
    end
  })

  -- 原有赠送X币菜单项
  menu.add(res.string.complimentary_x_coins)
  .onMenuItemClick = function()
    MaterialBlurDialogBuilder(activity)
    .setTitle(res.string.complimentary_x_coins)
    .setView(loadlayout({
      LinearLayoutCompat,
      layout_width = -1,
      layout_height = -1,
      {
        Slider,
        layout_width = -1,
        layout_margin = "26dp",
        layout_marginBottom = "8dp",
        ValueTo = 200,
        StepSize = 5,
        Value = 0,
        id = "slider",
      },
    }))
    .setPositiveButton(res.string.ok, function()
      OkHttpUtil.post(true, API_BASE_URL .. "transfer_coins.php", {
        userid = user_id,
        count = slider.getValue(),
        time = os.time()
        }, {
        ["Authorization"] = "Bearer " .. tostring(getSQLite(3))
        }, function (code, body)
        local success, v = pcall(OkHttpUtil.decode, body)
        if not (success and v and v.success) then
          MyToast(v and v.message or body)
          return
        end

        MyToast(v.message)
        price.setText(tostring(tointeger(v.data.new_total_coins)) .. " " .. res.string.x_coin)
      end)
    end)
    .show()
  end

end

function onOptionsItemSelected(item)
  if item.getItemId() == android.R.id.home then
    activity.finish()
    return true
  end
end

function onDestroy()
  adapter_code.release()
  luajava.clear()
  collectgarbage("collect")
  collectgarbage("step")
end