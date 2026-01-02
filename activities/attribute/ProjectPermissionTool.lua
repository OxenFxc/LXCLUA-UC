local _M = {}
local newInstance = luajava.newInstance
local bindClass = luajava.bindClass
local LuaCustRecyclerHolder = bindClass "github.znzsofficial.adapter.LuaCustRecyclerHolder"
local PopupRecyclerAdapter = bindClass "github.znzsofficial.adapter.PopupRecyclerAdapter"
local BottomSheetDialog = bindClass "com.google.android.material.bottomsheet.BottomSheetDialog"
local LinearLayoutCompat = bindClass "androidx.appcompat.widget.LinearLayoutCompat"
local BottomSheetDragHandleView = bindClass "com.google.android.material.bottomsheet.BottomSheetDragHandleView"
local RecyclerView = bindClass "androidx.recyclerview.widget.RecyclerView"
local MaterialCardView = bindClass "com.google.android.material.card.MaterialCardView"
local LinearLayoutManager = bindClass "androidx.recyclerview.widget.LinearLayoutManager"
local Modifier = bindClass "java.lang.reflect.Modifier"
local String = bindClass "java.lang.String"
local MaterialTextField = bindClass "com.difierline.lua.material.textfield.MaterialTextField"

local UiUtil = require "utils.UiUtil"
local Utils = require "utils.Utils"
local packageManager = activity.getPackageManager()

local function containsChar(str, char)
  return string.find(str, char) ~= nil
end

local function containsChar(str, sub)
  return str and string.find(str, sub, 1, true) ~= nil
end

local function getPermissionChineseName(permission)

  if permission == "MANAGE_EXTERNAL_STORAGE" then
    return "所有文件访问权限"
  end
  
  local ok, result = xpcall(function()
    local permission2 = permission
    if not string.find(permission, "^android%.permission%.") then
      permission2 = "android.permission." .. permission
    end

    local permissionInfo = packageManager.getPermissionInfo(permission2, 0)
    local label = tostring(permissionInfo.loadLabel(packageManager) or "")

    -- 过滤掉包含 android.permission. 的默认值
    return containsChar(label, "android.permission.") and "" or label
  end, function(err)
    -- 静默失败，返回 nil
    return nil
  end)

  return ok and result or nil
end

local function loadPermissionList(permissionTable)
  -- 移除 xTask 异步调用，改为直接同步执行
  local table = {}
  for _, v in ipairs(permissionTable) do
    table[#table + 1] = {
      Text = v,
      name = getPermissionChineseName(v) or ""
    }
  end

  -- 使用自定义的冒泡排序代替 table.sort
  local n = #table
  local swapped
  repeat
    swapped = false
    for i = 1, n - 1 do
      local a = table[i]
      local b = table[i + 1]

      -- 检查是否需要交换位置
      local shouldSwap = false

      -- 检查a和b是否有名称
      local aHasName = a.name ~= "" and a.name ~= nil
      local bHasName = b.name ~= "" and b.name ~= nil

      -- 如果a没有名称而b有名称，需要交换
      if not aHasName and bHasName then
        shouldSwap = true
        -- 如果两者都有名称或都没有名称，则按权限名称排序
       elseif aHasName == bHasName then
        shouldSwap = a.Text > b.Text
      end

      if shouldSwap then
        table[i], table[i + 1] = b, a
        swapped = true
      end
    end
    n = n - 1
  until not swapped

  permissionTableZh = table
  if func then
    func(table) -- 直接在主线程执行回调
  end
end

-- 使用反射获取所有权限
activity.newTask(function()
  -- 绑定必要的Java类
  local Class = luajava.bindClass("java.lang.Class")
  local Modifier = luajava.bindClass("java.lang.reflect.Modifier") -- 修复点：导入Modifier类
  local String = luajava.bindClass("java.lang.String") -- 确保String类可用

  local list = {}
  local permissionClass = Class.forName("android.Manifest$permission")
  local fields = permissionClass.getFields()

  for _, field in ipairs(luajava.astable(fields)) do
    local modifiers = field.getModifiers()
    -- 使用导入的Modifier类检查修饰符

    if Modifier.isPublic(modifiers) and
      Modifier.isStatic(modifiers) and
      Modifier.isFinal(modifiers) and
      field.getType() == String then -- 直接比较类对象

      local permissionValue = field.getName()
      if permissionValue then
        table.insert(list, permissionValue)
      end
    end
  end
  

  local hasManageExternalStorage = false
  for _, perm in ipairs(list) do
    if perm == "MANAGE_EXTERNAL_STORAGE" then
      hasManageExternalStorage = true
      break
    end
  end
  
  if not hasManageExternalStorage then
    table.insert(list, "MANAGE_EXTERNAL_STORAGE")
  end
  
  return list
  end, function(list)
  local permissionTable = luajava.astable(list)

  loadPermissionList(permissionTable)

  function _M.permissionBottomSheetDialog(permission, func)

    local mBottomSheetDialog=BottomSheetDialog(activity)
    mBottomSheetDialog.setContentView(loadlayout(
    {
      LinearLayoutCompat;
      layout_width = -1,
      orientation="vertical",
      {
        BottomSheetDragHandleView,
        id = "drag_handle",
        layout_width = -1,
      },
      {
        MaterialTextField,
        layout_width = -1,
        hint = res.string.text_to_search_for,
        BoxCornerRadii = "12dp",
        layout_margin = "16dp",
        layout_marginTop = 0,
        id = "search",
        singleLine = true,
      },
      {
        RecyclerView,
        id="recycler_view",
        layout_width = -1,
        layout_height = -1,
      },
    })).setDismissWithAnimation(true)

    UiUtil.applyEdgeToEdgePreference(mBottomSheetDialog.getWindow())

    newInstance("me.zhanghai.android.fastscroll.FastScrollerBuilder", recycler_view)
    .useMd2Style()
    .setPadding(0,dp2px(8),dp2px(2),dp2px(8))
    .build()

    local SelectedState = {}

    for _,v in ipairs(permission) do
      SelectedState[v] = true
    end

    -- 保存原始权限列表
    local originalPermissionList = permissionTableZh
    -- 创建过滤后的列表
    local filteredPermissionList = {}
    for i, v in ipairs(originalPermissionList) do
      filteredPermissionList[i] = v
    end

    local adapter = PopupRecyclerAdapter(activity,
    PopupRecyclerAdapter.PopupCreator({
      getItemCount = function()
        return #filteredPermissionList
      end,
      getItemViewType = function(pos)
        return 0
      end,
      getPopupText=function(view, position)
        return utf8.sub(filteredPermissionList[position+1].Text or "",20,20)
      end,
      onViewRecycled = function(holder)
      end,
      onCreateViewHolder = function(parent, viewType)
        local tag = {}
        local holder = LuaCustRecyclerHolder(loadlayout("layouts.permission_item", tag))
        holder.views = tag
        return holder
      end,
      onBindViewHolder=function(holder,position)
        local view=holder.views
        local data = filteredPermissionList[position+1]
        switch data['_type'] do
         case nil
          view.text.text = data.Text
          view.name.setVisibility(data.name == "" and 8 or 0)
          view.name.text = data.name

          -- 关键修改：使用临时变量避免闭包问题
          local currentPermission = data.Text

          -- 移除旧的监听器防止多次绑定
          view.card.setOnCheckedChangeListener(nil)
          view.card.setChecked(SelectedState[data.Text] or false)
          view.card.setStrokeColor((SelectedState[data.Text] or false) and Colors.colorOutline or Colors.colorOutlineVariant)

          view.card.onClick = function(v)
            local newState = not v.isChecked()
            v.setChecked(newState)
            SelectedState[currentPermission] = newState
          end

          activity.onLongClick(view.card, function(v)
            local newState = not v.isChecked()
            v.setChecked(newState)
            SelectedState[currentPermission] = newState
            return true
          end)

          -- 添加状态变化监听器
          view.card.setOnCheckedChangeListener{
            onCheckedChanged=function(v, isChecked)
              SelectedState[currentPermission] = isChecked
              v.setStrokeColor(isChecked and Colors.colorOutline or Colors.colorOutlineVariant)
            end
          }
        end
      end

    }))

    recycler_view
    .setAdapter(adapter)
    .setLayoutManager(LinearLayoutManager(activity))

    recycler_view.addItemDecoration(RecyclerView.ItemDecoration {
      getItemOffsets = function(outRect, view, parent, state)
        Utils.modifyItemOffsets(outRect, view, parent, adapter, 6)
      end
    })

    -- 添加搜索功能
    local function filterPermissions(text)
      local searchText = utf8.lower(tostring(text or ""))

      -- 清空过滤列表
      table.clear(filteredPermissionList)

      if searchText == "" then
        -- 搜索框为空时显示所有权限
        for i, v in ipairs(originalPermissionList) do
          filteredPermissionList[i] = v
        end
       else
        -- 根据搜索条件过滤权限
        for _, perm in ipairs(originalPermissionList) do
          -- 检查权限名称或描述是否匹配搜索文本
          local permText = utf8.lower(tostring(perm.Text or ""))
          local permName = utf8.lower(tostring(perm.name or ""))

          if utf8.find(permText, searchText) or utf8.find(permName, searchText) then
            table.insert(filteredPermissionList, perm)
          end
        end
      end

      -- 关键修改：强制刷新所有可见项
      adapter.notifyDataSetChanged()
    end


    -- 设置搜索框文本变化监听器
    search.addTextChangedListener({
      onTextChanged = function(text)
        filterPermissions(text)
      end
    })

    -- 初始过滤（确保列表正确）
    filterPermissions("")

    mBottomSheetDialog.show()

    if func then
      func(mBottomSheetDialog,SelectedState)
    end
  end

end).execute({})


return _M