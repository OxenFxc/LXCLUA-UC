require "env"
local bindClass = luajava.bindClass
local View = bindClass "android.view.View"
activity.window.setStatusBarColor(Colors.colorSurfaceContainer)
activity.decorView.setSystemUiVisibility(View.SYSTEM_UI_FLAG_LIGHT_STATUS_BAR | View.SYSTEM_UI_FLAG_HIDE_NAVIGATION)

-- 提前绑定常用类
local Intent = bindClass "android.content.Intent"
local Uri = bindClass "android.net.Uri"
local SoraIds = bindClass "io.github.rosemoe.sora.R$id" -- 提前绑定
local LinearLayoutManager = bindClass "androidx.recyclerview.widget.LinearLayoutManager"
local AlphaAnimation = bindClass "android.view.animation.AlphaAnimation"
local ObjectAnimator = bindClass "android.animation.ObjectAnimator"
local RecyclerView = bindClass "androidx.recyclerview.widget.RecyclerView"
local Paint = bindClass "android.graphics.Paint"
local DefaultItemAnimator = bindClass "androidx.recyclerview.widget.DefaultItemAnimator"
local LayoutAnimationController = bindClass "android.view.animation.LayoutAnimationController"
local AnimationUtils = bindClass "android.view.animation.AnimationUtils"

-- 缓存常用模块
local PluginsUtil = require "activities.plugins.PluginsUtil"
local IconDrawable = require "utils.IconDrawable"
local MaterialBlurDialogBuilder = require "dialogs.MaterialBlurDialogBuilder"
local SharedPrefUtil = require "utils.SharedPrefUtil"
local OkHttpUtil = require "utils.OkHttpUtil"
local GlideUtil = require "utils.GlideUtil"
local Utils = require "utils.Utils"
local ActivityUtil = require "utils.ActivityUtil"
local EditorUtil = require "activities.editor.EditorUtil"
local Init = require "activities.editor.EditorActivity$init"
local LuaRecyclerAdapter = require "utils.LuaRecyclerAdapter"
EditView = require "activities.editor.EditView"

-- 常量提取
local API_BASE_URL = "https://luaappx.top/forum/"
local DEFAULT_AVATAR_URL = "https://luaappx.top/public/uploads/avatars/default_avatar.png"
local comments = {}
local replyToCommentId, replyToUserId = "", ""
local fadeInAnim = nil
local buyers = {}
local buyersAdapter
local buyersPage = 1 -- 当前页码
local buyersIsLoading = false
local buyersHasMore = true

data = OkHttpUtil.decode(...)

PluginsUtil.clearOpenedPluginPaths()
PluginsUtil.setActivityName("DetailsActivity")

-- 预定义请求参数
local token = tostring(getSQLite(3))
local headers = { ["Authorization"] = "Bearer " .. token }

-- 状态统一封装
local function setState(view, liked)
  view.setColorFilter(liked and Colors.colorPrimary or Colors.colorOnSurfaceVariant)
  view.parent.setCardBackgroundColor(liked and Utils.setColorAlpha(Colors.colorPrimary, 40) or Colors.colorBackground)
end

-- 购买回调优化
local purchaseCallback = function(code, body)
  local success, v = pcall(OkHttpUtil.decode, body)
  if not (success and v) then
    OkHttpUtil.error(body)
    return
  end

  if v.success then
    price.setText(res.string.purchased)
    editor.setText(v.data.content)

    local hasAttachment = v.data.attachments and v.data.attachments.files and v.data.attachments.files[1]
    if hasAttachment then
      local fileInfo = v.data.attachments.files[1]
      file.setVisibility(fileInfo.type == "file" and 0 or 8)
      path = fileInfo.path
     else
      file.setVisibility(8)
    end
  end

  MyToast(v.message)
end

-- 分割线装饰器
local function createDividerDecoration(level)
  local dividerHeight = dp2px(1) -- 分割线高度
  local leftMargin = dp2px(14 + level * 24) -- 根据层级计算左边距

  return RecyclerView.ItemDecoration {
    getItemOffsets = function(outRect, view, parent, state)
      local position = parent.getChildAdapterPosition(view)
      if position ~= RecyclerView.NO_POSITION and position < parent.getAdapter().getItemCount() - 1 then
        outRect.bottom = dividerHeight -- 在底部添加分割线空间
      end
    end,

    onDraw = function(canvas, parent, state)
      local rightMargin = dp2px(14) -- 右边距
      local left = leftMargin
      local right = parent.getWidth() - rightMargin

      -- 创建 Paint 对象并设置颜色
      local paint = Paint()
      paint.setColor(Colors.colorSurfaceVariant) -- 默认灰色
      paint.setStyle(Paint.Style.FILL)

      for i = 0, parent.getChildCount() - 1 do
        local child = parent.getChildAt(i)
        local position = parent.getChildAdapterPosition(child)

        -- 不在最后一项绘制分割线
        if position < parent.getAdapter().getItemCount() - 1 then
          local top = child.getBottom()
          local bottom = top + dividerHeight
          canvas.drawRect(left, top, right, bottom, paint) -- 使用 Paint 对象
        end
      end
    end
  }
end

-- 初始化评论列表
local function init_comment()
  -- 初始化主评论列表动画
  local itemAnimator = DefaultItemAnimator()
  itemAnimator.setAddDuration(180)
  itemAnimator.setRemoveDuration(180)
  itemAnimator.setMoveDuration(180)
  itemAnimator.setChangeDuration(180)
  recylerView.setItemAnimator(itemAnimator)

  -- 创建渐入动画
  fadeInAnim = ObjectAnimator.ofFloat(recylerView, "alpha", {0, 1})
  fadeInAnim.setDuration(180)

  -- 嵌套评论适配器（递归）
  local function createNestedAdapter(replyData, level)
    return LuaRecyclerAdapter(replyData, "layouts.comment_item", {
      onBindViewHolder = function(viewHolder, pos, views, currentData)
        local marginLeft = 14 + (level or 0) * 24
        local layoutParams = views.card.getLayoutParams()
        layoutParams.setMargins(dp2px(marginLeft), dp2px(0), dp2px(14), dp2px(0))
        views.card.setLayoutParams(layoutParams)

        local lp = views.content.getLayoutParams()
        if level == 1 then
          lp.setMargins(dp2px(12), 0, dp2px(12), dp2px(12))
          views.card.setStrokeColor(0)
         else
          lp.setMargins(dp2px(59), 0, dp2px(12), dp2px(12))
          views.card.setStrokeColor(Colors.colorOutlineVariant)
        end
        views.content.setLayoutParams(lp)

        -- 头像和基本信息
        local avatarUrl = tostring(currentData.user_info.avatar)
        GlideUtil.set((avatarUrl and avatarUrl:find("http")) and avatarUrl or DEFAULT_AVATAR_URL, views.icon, true)
        views.nick.setText(tostring(currentData.user_info.nickname))
        views.time.setText(tostring(currentData.created_at))

        if tostring(data.user_id) == tostring(currentData.user_info.user_id) then
          views.up.parent.setVisibility(0)
          views.up.setText("UP")
         else
          views.up.parent.setVisibility(8)
        end

        views.admin.parent.setVisibility(currentData.user_info.is_admin and 0 or 8)

        -- 处理回复内容格式
        local contentText = ""
        -- 构建带回复前缀的内容文本
        if currentData.reply_to_user and currentData.reply_to_user.nickname then
          local replyPrefix = "回复@" .. tostring(currentData.reply_to_user.nickname) .. ": "
          contentText = "<font color='" .. Colors.colorPrimary .. "'>" .. replyPrefix .. "</font>"
        end
        contentText = contentText .. tostring(currentData.content)

        -- 根据tertiary判断使用哪种文本
        if currentData.reply_to_user and currentData.reply_to_user.tertiary then
          -- 当tertiary为true时，使用带样式的contentText
          views.content.setText(bindClass "android.text.Html".fromHtml(contentText))
         else
          -- 当tertiary为false时，使用原始content
          views.content.setText(tostring(currentData.content))
        end

        -- 显示回复视图（最多显示两级）
        local replyRecyclerView = views.recylerView
        if currentData.replies and #currentData.replies > 0 and (level or 0) < 1 then
          replyRecyclerView.setVisibility(View.VISIBLE)
          replyRecyclerView.setLayoutManager(LinearLayoutManager(activity))
          replyRecyclerView.setAdapter(createNestedAdapter(currentData.replies, (level or 0) + 1))
          -- 添加分割线装饰
          replyRecyclerView.addItemDecoration(createDividerDecoration((level or 0) + 1))
         else
          replyRecyclerView.setVisibility(View.GONE)
        end

        local function generateMenuItems()
          local items = {}
          local isAdmin = SharedPrefUtil.getBoolean("is_admin")
          local myUserId = SharedPrefUtil.getNumber("user_id")

          table.insert(items, res.string.copy_content)

          if isAdmin or myUserId == currentData.user_info.user_id then
            table.insert(items, res.string.delete_comment)
          end

          return items
        end

        function views.icon.parent.parent.onClick()
          ActivityUtil.new("privacy", { currentData.user_info.user_id })
        end

        function views.card.onClick()
          comment.setHint(res.string.reply .. " @" .. tostring(currentData.user_info.nickname))
          replyToCommentId = currentData.comment_id
          replyToUserId = currentData.user_info.user_id
        end

        activity.onLongClick(views.card, function()
          -- 长按动画效果（缩短时长）
          local rotateAnim = ObjectAnimator.ofFloat(views.card, "rotation", {0, 5, -5, 0})
          rotateAnim.setDuration(300) -- 减少100ms
          rotateAnim.start()

          local item = generateMenuItems()
          local delete_post = tostring(res.string.delete_post)
          MaterialBlurDialogBuilder(activity)
          .setTitle(res.string.menu)
          .setItems(item, function(l, v)
            if item[v+1] == res.string.copy_content then
              activity.getSystemService("clipboard").setText(currentData.content)
              MyToast(res.string.copied_successfully)
             elseif item[v+1] == res.string.delete_comment then
              MaterialBlurDialogBuilder(activity)
              .setTitle(res.string.tip)
              .setMessage((res.string.delete_comment_tip):format(currentData.content))
              .setPositiveButton(res.string.ok, function()
                OkHttpUtil.post(true, API_BASE_URL .. "delete_comment.php", {
                  comment_id = currentData.comment_id,
                  user_id = currentData.user_info.user_id,
                  time = os.time()
                  }, {
                  ["Authorization"] = "Bearer " .. tostring(getSQLite(3))
                  }, function (code, body)
                  local success, v = pcall(OkHttpUtil.decode, body)
                  if success and v then
                    if v.success then
                      get_comment()
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
    })
  end

  -- 主评论适配器
  adapter = createNestedAdapter(comments, 0)
  recylerView.setAdapter(adapter)
  recylerView.setLayoutManager(LinearLayoutManager(activity))

  --设置主列表的布局动画
  local animation = AlphaAnimation(0, 1)
  animation.setDuration(180)
  local controller = LayoutAnimationController(animation)
  controller.setDelay(0.1)
  controller.setOrder(LayoutAnimationController.ORDER_NORMAL)
  recylerView.setLayoutAnimation(controller)
end

-- 获取评论数据
function get_comment()
  while #comments > 0 do
    table.remove(comments, 1)
  end

  -- 添加加载动画效果
  recylerView.alpha = 0.3 -- 淡出效果

  OkHttpUtil.get(false, API_BASE_URL .. "get_tree_comments.php?post_id=" .. data.id .. "&time=" .. os.time(), headers, true, function(code, body)
    local success, v = pcall(OkHttpUtil.decode, body)
    if not (success and v and v.success) then
      MyToast(v and v.message or body)
      mSwipeRefreshLayout.setRefreshing(false)
      recylerView.alpha = 1 -- 恢复透明度
      return
    end

    -- 插入新数据并刷新列表
    for _, item in ipairs(v.data.comments) do
      table.insert(comments, item)
    end
    adapter.notifyDataSetChanged()

    tabs.getTabAt(1).setText(res.string.comment .. "(" .. tostring(tointeger(v.data.total)) ..")")

    -- 播放列表加载完成动画
    if fadeInAnim then
      fadeInAnim.start()
    end
    recylerView.alpha = 1 -- 恢复透明度

    mSwipeRefreshLayout.setRefreshing(false)
  end)
end

-- 获取购买人员数据
local function getBuyers(page)
  if buyersIsLoading then
    return
  end

  buyersIsLoading = true
  buyersPage = page or buyersPage

  -- 移除可能存在的加载提示项
  local lastIndex = #buyers
  if lastIndex > 0 and buyers[lastIndex].load_more then
    table.remove(buyers, lastIndex)
    buyersAdapter.notifyItemRemoved(lastIndex-1)
  end

  -- 第一页时清空数据
  if buyersPage == 1 then
    while #buyers > 0 do
      table.remove(buyers, 1)
    end
    buyersAdapter.notifyDataSetChanged()
   else
    -- 非第一页显示加载动画
    buyersSwipeRefresh.setRefreshing(true)
  end

  OkHttpUtil.get(false,
  API_BASE_URL .. "post_purchasers.php?post_id=" .. data.id
  .. "&page=" .. buyersPage
  .. "&page_size=10"
  .. "&time=" .. os.time(),
  headers, true,
  function(code, body)

    buyersSwipeRefresh.setRefreshing(false)
    buyersIsLoading = false

    local success, v = pcall(OkHttpUtil.decode, body)
    if not (success and v and v.success) then
      MyToast(v and v.message or body)

      return
    end

    -- 更新购买人员总数显示
    tabs.getTabAt(2).setText(res.string.purchased_post
    .. "(" .. tointeger(v.data.pagination.total) ..")")

    -- 添加新数据
    for _, item in ipairs(v.data.purchasers) do
      table.insert(buyers, item)
    end

    -- 使用范围更新通知提高性能
    local startPos = #buyers - #v.data.purchasers + 1
    buyersAdapter.notifyItemRangeInserted(startPos-1, #v.data.purchasers)

    -- 更新是否有更多数据的标志
    buyersHasMore = buyersPage < v.data.pagination.total_pages

    -- 如果有更多数据，添加加载提示项
    if buyersHasMore then
      table.insert(buyers, {load_more = true})
      buyersAdapter.notifyItemInserted(#buyers-1)
    end
  end
  )
end

-- 初始化购买人员列表
local function initBuyersList()
  buyersAdapter = LuaRecyclerAdapter(buyers, "layouts.buyer_item", {
    onBindViewHolder = function(viewHolder, pos, views, currentData)

      GlideUtil.set(tostring(currentData.avatar_url), views.icon, true)
      views.nick.setText(tostring(currentData.nickname))
      views.time.setText(tostring(currentData.purchase_time))

      function views.card.onClick()
        ActivityUtil.new("privacy", { currentData.user_id })
      end

    end
  })
  buyersRecyclerView.setAdapter(buyersAdapter)
  buyersRecyclerView.setLayoutManager(LinearLayoutManager(activity))

  -- 添加滚动监听实现自动加载
  buyersRecyclerView.addOnScrollListener(RecyclerView.OnScrollListener {
    onScrolled = function(recyclerView, dx, dy)
      if not recyclerView.canScrollVertically(1) and
        not buyersIsLoading and
        buyersHasMore then
        getBuyers(buyersPage + 1)
      end
    end
  })
end


-- 初始化下拉刷新
local function initSwipeRefresh()
  recylerView.addItemDecoration(RecyclerView.ItemDecoration {
    getItemOffsets = function(outRect, view, parent, state)
      Utils.modifyItemOffsets(outRect, view, parent, adapter, 12)
    end
  })
  buyersRecyclerView.addItemDecoration(RecyclerView.ItemDecoration {
    getItemOffsets = function(outRect, view, parent, state)
      Utils.modifyItemOffsets(outRect, view, parent, adapter, 12)
    end
  })
  mSwipeRefreshLayout.setProgressViewOffset(true, -100, 250)
  buyersSwipeRefresh.setProgressViewOffset(true, -100, 250)

  mSwipeRefreshLayout.setColorSchemeColors({ Colors.colorPrimary })
  buyersSwipeRefresh.setColorSchemeColors({ Colors.colorPrimary })

  buyersSwipeRefresh.setOnRefreshListener({
    onRefresh = function()
      getBuyers()
    end
  })
  mSwipeRefreshLayout.setOnRefreshListener({
    onRefresh = function()
      -- 添加下拉刷新动画
      local fadeOut = AlphaAnimation(1, 0.3)
      fadeOut.setDuration(200)
      recylerView.startAnimation(fadeOut)

      get_comment()

      -- 3秒后停止旋转动画（防止刷新时间过长）
      local handler = luajava.bindClass("android.os.Handler")(luajava.bindClass("android.os.Looper").getMainLooper())
      handler.postDelayed(function()
        fadeOut.cancel()
      end, 300)
    end
  })
end

-- 菜单项优化
local MENU_ITEMS = {
  { id = "undo", icon = "ic_undo", action = function() editor.undo() end },
  { id = "redo", icon = "ic_redo", action = function() editor.redo() end },
  { id = "run", icon = "ic_play_outline", color = 0xFF4CAF50, action = function()
      ActivityUtil.new("runcode", { tostring(editor.text) })
  end},
}

-- 主执行代码开始
activity
.setContentView(loadlayout("layouts.activity_details"))
.setSupportActionBar(toolbar)
.getSupportActionBar()
.setDisplayHomeAsUpEnabled(true)

function onCreate(savedInstanceState)
  PluginsUtil.callElevents("onCreate", savedInstanceState)
end

tabs.setupWithViewPager(cvpg)
Utils.setTabRippleEffect(tabs)

task(1, function()
  Init.Bar()
end)

if bindClass "android.os.Build".VERSION.SDK_INT >= 28 then
  fab.setOutlineAmbientShadowColor(0)
  fab.setOutlineSpotShadowColor(0)
end

initSwipeRefresh()
init_comment()
get_comment()

OkHttpUtil.get(false, API_BASE_URL .. "get_post.php?post_id=" .. data.id .. "&time=" .. os.time(), headers, true, function(code, body)
  local success, v = pcall(OkHttpUtil.decode, body)
  if not (success and v and v.success) then
    MyToast(v and v.message or body)
    return
  end

  local post = v.data.post
  local avatarUrl = tostring(post.avatar_url)
  GlideUtil.set((avatarUrl and avatarUrl:find("http")) and avatarUrl or DEFAULT_AVATAR_URL, icon, true)

  admin.parent.setVisibility(post.is_admin and 0 or 8)
  nick.setText(tostring(post.nickname))
  editor.setText(tostring(post.content))
  tabs.getTabAt(1).setText(res.string.comment .. "(" .. tostring(tointeger(post.comment_count)) ..")")

  activity
  .getSupportActionBar()
  .setTitle(post.title)
  .setSubtitle(post.created_at)

  setState(thumb, post.is_liked)
  setState(star, post.is_favorited)

--[[
  -- 价格处理优化
  local priceVisible = post.price ~= 0
  price.parent.setVisibility(priceVisible and 0 or 8)
  if priceVisible then
    price.setText(post.purchased and res.string.purchased or tostring(tointeger(post.price)) .. " X币")
  end
]]

  -- 附件处理优化
  local hasAttachment = v.data.attachments and v.data.attachments.files and v.data.attachments.files[1]
  if hasAttachment then
    local fileInfo = v.data.attachments.files[1]
    file.setVisibility(fileInfo.type == "file" and 0 or 8)
    path = fileInfo.path
   else
    file.setVisibility(8)
  end

  -- 购买逻辑优化
  if not post.purchased and post.price ~= 0 then
    if not SharedPrefUtil.getBoolean("is_login") then
      MyToast(res.string.please_log_in_first)
     else
      MaterialBlurDialogBuilder(activity)
      .setTitle(res.string.tip)
      .setMessage(res.string.purchase_notification:format(tostring(tointeger(post.price))))
      .setPositiveButton(res.string.ok, function()
        OkHttpUtil.get(true, API_BASE_URL .. "purchase.php?post_id=" .. data.id .. "&time=" .. os.time(), {
          ["Authorization"] = "Bearer " .. token
        }, true, purchaseCallback)
      end)
      .setNegativeButton(res.string.no, nil)
      .show()
    end
  end

--[[
  -- 判断是否显示购买人员Tab
  local showBuyersTab = post.price ~= 0 and
  (SharedPrefUtil.getBoolean("is_admin") or
  tostring(SharedPrefUtil.getNumber("user_id")) == tostring(post.user_id))


  local buyersTab = tabs.getTabAt(2).view
  if showBuyersTab then
    buyersTab.setVisibility(0)
    initBuyersList()
    getBuyers(1)
   else
    buyersTab.setVisibility(8)
  end
]]
  tabs.getTabAt(2).view.setVisibility(8)
  
end)

EditView
.Search_Init()
.TextSelectListener()
.TextActionWindowListener()
.EditorLanguageAsync(false)
.EditorScheme()
.EditorProperties()
.EditorFont()

-- 按钮点击处理
star.parent.onClick = function()
  if not SharedPrefUtil.getBoolean("is_login") then
    MyToast(res.string.please_log_in_first)
   else
    OkHttpUtil.get(false, API_BASE_URL .. "favorite_post.php?post_id=" .. data.id .. "&time=" .. os.time(), headers, true, function(code, body)
      local success, v = pcall(OkHttpUtil.decode, body)
      if not (success and v and v.success) then
        MyToast(v and v.message or body)
        return
      end

      setState(star, v.data.is_favorited)
    end)
  end
end

thumb.parent.onClick = function()
  if not SharedPrefUtil.getBoolean("is_login") then
    MyToast(res.string.please_log_in_first)
   else
    OkHttpUtil.get(false, API_BASE_URL .. "like_post.php?post_id=" .. data.id .. "&time=" .. os.time(), headers, true, function(code, body)
      local success, v = pcall(OkHttpUtil.decode, body)
      if not (success and v and v.success) then
        MyToast(v and v.message or body)
        return
      end

      setState(thumb, v.data.is_liked)
    end)
  end
end

file.onClick = function()
  activity.startActivity(Intent(Intent.ACTION_VIEW, Uri.parse(path)))
end

fab.onClick = function()
  if not SharedPrefUtil.getBoolean("is_login") then
    MyToast(res.string.please_log_in_first)
   else
    if comment_txt.text == "" then
      MyToast(res.string.please_enter_content)
      return
    end

    -- 先创建基础参数表（必选参数）
    local params = {
      post_id = data.id,
      content = comment_txt.text,
      time = os.time()
    }

    -- 动态添加可选参数：仅当有值时才添加
    if replyToUserId and replyToUserId ~= "" then -- 存在且非空字符串时添加
      params.reply_to_user_id = replyToUserId
    end
    if replyToCommentId and replyToCommentId ~= "" then -- 存在且非空字符串时添加
      params.reply_to_comment_id = replyToCommentId
    end

    -- 发起请求时使用构建好的params
    OkHttpUtil.post(false, API_BASE_URL .. "comment_post.php",
    params, -- 这里传入动态构建的参数表
    {
      ["Authorization"] = "Bearer " .. tostring(getSQLite(3))
    },
    function (code, body)
      local success, v = pcall(OkHttpUtil.decode, body)
      if not (success and v and v.success) then
        MyToast(v and v.message or body)
        return
      end

      comment_txt.text = ""
      comment.setHint(res.string.comment_tip)
      replyToUserId = ""
      replyToCommentId = ""
      get_comment()
      mSwipeRefreshLayout.setRefreshing(true)
    end)
  end
end

function icon.parent.parent.onClick()
  ActivityUtil.new("privacy", { data.user_id })
end

-- 菜单创建
function onCreateOptionsMenu(menu)
  for _, item in ipairs(MENU_ITEMS) do
    menu.add(res.string[item.id])
    .setShowAsAction(2)
    .setIcon(IconDrawable(item.icon, item.color or Colors.colorOnSurfaceVariant))
    .onMenuItemClick = item.action
  end

  menu.add(res.string.format)
  .onMenuItemClick = function()
    EditView.format()
  end

  menu.add(res.string.search)
  .onMenuItemClick = function()
    EditView.search()
  end

  PluginsUtil.callElevents("onCreateOptionsMenu", menu)
end


-- 菜单项选择
function onOptionsItemSelected(item)
  if item.getItemId() == android.R.id.home then
    activity.finish()
    return true
  end
end

function onActivityResult(req, resx, intent)
  PluginsUtil.callElevents("onActivityResult", req, resx, intent)
end

-- 清理资源
function onDestroy()
  EditView.release()

  if OkHttpUtil.cancelAllRequests then
    OkHttpUtil.cancelAllRequests()
  end

  if OkHttpUtil.cleanupDialogs then
    OkHttpUtil.cleanupDialogs()
  end

  adapter.release()

  if buyersAdapter then
    buyersAdapter.release()
  end

  luajava.clear()
  collectgarbage("collect") --全回收
  collectgarbage("step") -- 增量回收
end

function onKeyDown(keycode, event)
  if keycode == 4 then
    local currentPage = cvpg.getCurrentItem()
    if currentPage == 2 then -- 购买人员页
      cvpg.setCurrentItem(1, true)
      return true
    end
    if currentPage == 1 then -- 评论页
      cvpg.setCurrentItem(0, true)
      return true
    end
    if currentPage == 0 then -- 代码页
      activity.finish()
      return true
    end
  end
  return false
end