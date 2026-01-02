local SettingsLayUtil = {}
local bindClass = luajava.bindClass
local Typeface = bindClass "android.graphics.Typeface"
local View = bindClass "android.view.View"
local LuaCustRecyclerHolder = bindClass "com.lua.custrecycleradapter.LuaCustRecyclerHolder"
local LuaCustRecyclerAdapter = bindClass "com.lua.custrecycleradapter.LuaCustRecyclerAdapter"
local AdapterCreator = bindClass "com.lua.custrecycleradapter.AdapterCreator"
local SwitchCompat = bindClass "androidx.appcompat.widget.SwitchCompat"
local AppCompatImageView = bindClass "androidx.appcompat.widget.AppCompatImageView"
local LinearLayoutCompat = bindClass "androidx.appcompat.widget.LinearLayoutCompat"
local AppCompatTextView = bindClass "androidx.appcompat.widget.AppCompatTextView"
local MaterialCardView = bindClass "com.google.android.material.card.MaterialCardView"
local MaterialSwitch = bindClass "com.google.android.material.materialswitch.MaterialSwitch"
local ColorStateList = bindClass "android.content.res.ColorStateList"
local GlideUtil = require "utils.GlideUtil"
local FileUtil = require "utils.FileUtil"

local contextMenuEnabled

SettingsLayUtil.TITLE = 1
SettingsLayUtil.ITEM = 2
SettingsLayUtil.ITEM_NOSUMMARY = 3
SettingsLayUtil.ITEM_SWITCH = 4
SettingsLayUtil.ITEM_SWITCH_NOSUMMARY = 5
SettingsLayUtil.ITEM_AVATAR = 6
SettingsLayUtil.ITEM_ONLYSUMMARY = 7
SettingsLayUtil.ITEM_CARD_NOSUMMARY = 8

local colorPrimary = Colors.colorPrimary
local colorOnBackground = Colors.colorOnBackground
local colorOutline = Colors.colorOutline

local leftIconLay = {
  AppCompatImageView,
  id = "icon",
  layout_margin = "16dp",
  layout_marginLeft = "12dp",
  layout_marginRight = "12dp",
  layout_width = "24dp",
  layout_height = "24dp",
  colorFilter = colorPrimary,
}

local leftCoverLay = {
  MaterialCardView,
  layout_height = "40dp",
  layout_width = "40dp",
  layout_margin = "16dp",
  layout_marginLeft = "12dp",
  layout_marginRight = "12dp",
  layout_marginRight = 0,
  radius = "20dp",
  {
    MaterialCardView,
    layout_height = "fill",
    layout_width = "fill",
    radius = "18dp",
    {
      AppCompatImageView,
      layout_height = "fill",
      layout_width = "fill",
      id = "icon",
    },
  },
}

local leftCoverIconLay = {
  MaterialCardView,
  layout_height = "40dp",
  layout_width = "40dp",
  layout_margin = "16dp",
  layout_marginLeft = "12dp",
  layout_marginRight = 0,
  radius = "20dp",
  {
    MaterialCardView,
    layout_height = "fill",
    layout_width = "fill",
    radius = "18dp",
    {
      AppCompatImageView,
      layout_height = "24dp",
      layout_width = "24dp",
      layout_gravity = "center",
      id = "icon",
    },
  },
}

local oneLineLay = {
  AppCompatTextView,
  id = "title",
  textSize = "16sp",
  textColor = colorOnBackground,
  layout_weight = 1,
  layout_marginLeft = "8dp",
  layout_marginRight = "8dp",
  layout_margin = "16dp",
}

local twoLineLay = {
  LinearLayoutCompat,
  orientation = "vertical",
  gravity = "center",
  layout_weight = 1,
  layout_marginLeft = "8dp",
  layout_marginRight = "8dp",
  layout_margin = "16dp",
  {
    AppCompatTextView,
    id = "title",
    textSize = "16sp",
    layout_width = "fill",
    textColor = colorOnBackground,
  },
  {
    AppCompatTextView,
    textSize = "14sp",
    id = "summary",
    textColor = colorOutline,
    layout_width = "fill",
  },
}

local rightSwitchLay = {
  MaterialSwitch,
  id = "switchView",
  layout_marginLeft = 0,
  layout_margin = "8dp",
  layout_marginRight = "12dp",
  clickable=false,
  focusable=false,
}

local rightCardLay = {
  MaterialCardView,
  id = "cardView",
  layout_marginLeft = 0,
  layout_margin = "8dp",
  layout_marginRight = "12dp",
  layout_height = "30dp",
  layout_width = "30dp",
  StrokeWidth = 0,
}

local rightNewPageIconLay = {
  AppCompatImageView,
  id = "rightIcon",
  layout_margin = "16dp",
  layout_marginRight = "12dp",
  layout_marginLeft = 0,
  layout_width = "24dp",
  layout_height = "24dp",
  colorFilter = colorOutline,
}

SettingsLayUtil.leftIconLay = leftIconLay
SettingsLayUtil.leftCoverLay = leftCoverLay
SettingsLayUtil.leftCoverIconLay = leftCoverIconLay
SettingsLayUtil.oneLineLay = oneLineLay
SettingsLayUtil.twoLineLay = twoLineLay
SettingsLayUtil.rightSwitchLay = rightSwitchLay
SettingsLayUtil.rightNewPageIconLay = rightNewPageIconLay

local itemsLay = {
  {--标题
    LinearLayoutCompat,
    layout_width = "fill",
    focusable = true,
    {
      AppCompatTextView,
      id = "title",
      textSize = "14sp",
      textColor = colorPrimary,
      layout_margin = "16dp",
      layout_marginBottom = "12dp",
    },
  },

  {--设置项(图片, 标题, 简介)
    LinearLayoutCompat,
    layout_width = "fill",
    gravity = "center",
    {
      MaterialCardView,
      layout_width = "fill",
      StrokeWidth = 0,
      layout_marginLeft = "8dp",
      layout_marginRight = "8dp",
      id = "card",
      {
        LinearLayoutCompat,
        gravity = "center",
        layout_width = "fill",
        focusable = true,
        leftIconLay,
        twoLineLay,
        rightNewPageIconLay,
      },
    },
  },

  {--设置项(图片, 标题)
    LinearLayoutCompat,
    layout_width = "fill",
    gravity = "center",
    {
      MaterialCardView,
      layout_width = "fill",
      StrokeWidth = 0,
      layout_marginLeft = "8dp",
      layout_marginRight = "8dp",
      id = "card",
      {
        LinearLayoutCompat,
        gravity = "center",
        layout_width = "fill",
        focusable = true,
        leftIconLay,
        oneLineLay,
        rightNewPageIconLay,
      },
    },
  },

  {--设置项(图片, 标题, 简介, 开关)
    LinearLayoutCompat,
    gravity = "center",
    layout_width = "fill",
    {
      MaterialCardView,
      layout_width = "fill",
      StrokeWidth = 0,
      layout_marginLeft = "8dp",
      layout_marginRight = "8dp",
      id = "card",
      {
        LinearLayoutCompat,
        gravity = "center",
        layout_width = "fill",
        focusable = true,
        leftIconLay,
        twoLineLay,
        rightSwitchLay,
      },
    },
  },


  {--设置项(图片, 标题, 开关)
    LinearLayoutCompat,
    gravity = "center",
    layout_width = "fill",
    {
      MaterialCardView,
      layout_width = "fill",
      StrokeWidth = 0,
      layout_marginLeft = "8dp",
      layout_marginRight = "8dp",
      id = "card",
      {
        LinearLayoutCompat,
        gravity = "center",
        layout_width = "fill",
        focusable = true,
        leftIconLay,
        oneLineLay,
        rightSwitchLay,
      },
    },
  },

  {--设置项(头像, 标题, 简介)
    LinearLayoutCompat,
    layout_width = "fill",
    gravity = "center",
    {
      MaterialCardView,
      layout_width = "fill",
      StrokeWidth = 0,
      layout_marginLeft = "8dp",
      layout_marginRight = "8dp",
      id = "card",
      {
        LinearLayoutCompat,
        gravity = "center",
        layout_width = "fill",
        focusable = true,
        leftCoverLay,
        twoLineLay,
        rightNewPageIconLay,
      },
    },
  },

  {--设置项(简介)
    LinearLayoutCompat,
    gravity = "center",
    layout_width = "fill",
    focusable = false,
    {
      MaterialCardView,
      layout_width = "fill",
      StrokeWidth = 0,
      layout_marginLeft = "8dp",
      layout_marginRight = "8dp",
      id = "card",
      {
        LinearLayoutCompat,
        gravity = "center",
        layout_width = "fill",
        {
          AppCompatTextView,
          layout_weight = 1,
          layout_marginLeft = "72dp",
          layout_margin = "16dp",
          layout_width = "fill",
          textSize = "14sp",
          id = "summary",
        },
      },
    },
  },

  {--设置项(图片, 标题, 卡片, 简介)
    LinearLayoutCompat,
    gravity = "center",
    layout_width = "fill",
    {
      MaterialCardView,
      layout_width = "fill",
      StrokeWidth = 0,
      layout_marginLeft = "8dp",
      layout_marginRight = "8dp",
      id = "card",
      {
        LinearLayoutCompat,
        gravity = "center",
        layout_width = "fill",
        focusable = true,
        leftIconLay,
        twoLineLay,
        rightCardLay,
      },
    },
  }

}

SettingsLayUtil.itemsLay = itemsLay
SettingsLayUtil.itemsNumber = #itemsLay

local function setAlpha(views, alpha)
  for index, content in pairs(views) do
    if content then
      content.setAlpha(alpha)
    end
  end
end
SettingsLayUtil.setAlpha = setAlpha

local function onItemViewClick(view)
  local ids = view.parent.tag
  local viewConfig = ids._config
  local data = ids._data
  local key = data.key
  local onItemClick = viewConfig.onItemClick
  viewConfig.allowedChange = false

  local switchView = ids.switchView
  if switchView and viewConfig.switchEnabled then
    local checked = not(switchView.checked)
    switchView.setChecked(checked)
    if data.checked ~= nil then
      data.checked = checked
     elseif data.key then
      activity.setSharedData(data.key, checked)
    end
  end

  if onItemClick then
    onItemClick(view, ids, key, data)
  end
  viewConfig.allowedChange = true
  return true
end
local onItemViewClickListener = View.OnClickListener({onClick = onItemViewClick})

local function onItemViewLongClick(view)
  local ids = view.parent.tag
  local viewConfig = ids._config
  local data = ids._data
  local key = data.key
  local result
  local onItemLongClick = viewConfig.onItemLongClick
  viewConfig.allowedChange = false
  if onItemLongClick then
    result = onItemLongClick(view, ids, key, data)
  end
  viewConfig.allowedChange = true
  return result
end
local onItemViewLongClickListener = View.OnLongClickListener({
  onLongClick = onItemViewLongClick,
  onLongClickUseDefaultHapticFeedback = function()
    return true
  end
})

local function onSwitchCheckedChanged(view, checked)
  local viewConfig = view.tag
  local allowedChange = viewConfig.allowedChange
  if allowedChange then
    local key = viewConfig.key
    local data = viewConfig.data
    local onItemClick = viewConfig.onItemClick
    if data.checked ~= nil then
      data.checked = checked
     elseif data.key then
      activity.setSharedData(data.key, checked)
    end
    if onItemClick then
      onItemClick(viewConfig.itemView, viewConfig.ids, key, data)
    end
  end
end

local adapterEvents = {
  getItemCount = function(data)
    return #data
  end,
  getItemViewType = function(data, position)
    local itemData = data[position+1]
    itemData.position = position
    return itemData[1]
  end,
  onCreateViewHolder = function(onItemClick, onItemLongClick, parent, viewType)
    local ids = {}
    local view = loadlayout(itemsLay[viewType], ids)
    local holder = LuaCustRecyclerHolder(view)
    --getFirstChild(ids.card).setTag(ids)
    view.setTag(ids)
    local viewConfig = {enabled = true,
      switchEnabled = true,
      onItemClick = onItemClick,
      onItemLongClick = onItemLongClick,
      itemView = view,
      ids = ids}
    ids._config = viewConfig
    if viewType ~= 1 then
      local switchView = ids.switchView
      view.setFocusable(true)
      --ids.card.setBackground(activity.Resources.getDrawable(activity.obtainStyledAttributes({android.R.attr.selectableItemBackground}).getResourceId(0,0)).setColor(ColorStateList({{}}, {colorRipple})))
      ids.card.setOnClickListener(onItemViewClickListener)
      ids.card.setOnLongClickListener(onItemViewLongClickListener)
      if switchView then
        switchView.tag = viewConfig
        switchView.setOnCheckedChangeListener({
          onCheckedChanged = onSwitchCheckedChanged})
      end
    end
    return holder
  end,

  onBindViewHolder = function(data, holder, position)
    local data = data[position+1]
    local layoutView = holder.view
    local ids = layoutView.getTag()
    local viewConfig = ids._config
    ids._data = data
    local title = data.title
    local icon = data.icon
    local summary = data.summary
    local enabled = data.enabled
    local switchEnabled = data.switchEnabled
    local cardEnabled = data.cardEnabled
    local key = data.key
    local action = data.action
    local chooseItems = data.items
    viewConfig.key = key
    viewConfig.data = data
    viewConfig.allowedChange = false

    --Views
    local titleView = ids.title
    local summaryView = ids.summary
    local switchView = ids.switchView
    local cardView = ids.cardView
    local rightIconView = ids.rightIcon
    local iconView = ids.icon
    if title and titleView then
      titleView.text = title
    end

    if summaryView then
      if summary then
        summaryView.text = summary
        if key == "class_name_highlight"
          or key == "keyword_highlight"
          or key == "function_name_highlight"
          or key == "dividing_line_color"
          or key == "local_variable_highlight" then
          cardView.setCardBackgroundColor(activity.getSharedData(key) or 0xFF2196F3)
        end
       elseif key == "theme_light_dark"
        or key == "fragment_animation"
        or key == "icon_load_mode"
        or key == "theme_color"
        or key == "font_path" then

        summaryView.text = chooseItems[activity.getSharedData(key)] or chooseItems[1]
        --[[elseif key == "font_path" then
        local font_path = activity.getSharedData("font_path")
        if font_path then
          summaryView.text = FileUtil.getName(font_path)
         else
          summaryView.text = "jetbrains_mono.ttf"
        end]]
       elseif key == "zoom_range" then
        local minValue = tointeger(activity.getSharedData("value_min"))
        local maxValue = tointeger(activity.getSharedData("value_max"))
        summaryView.text = minValue .. " ~ " .. maxValue
      end
    end
    if icon and iconView then
      if type(icon) == "number" then
        iconView.setImageResource(icon)
       elseif icon:find("%/")
        GlideUtil.set(icon, iconView)
       else
        GlideUtil.set(activity.getLuaDir("res/drawable/" .. icon .. ".png"), iconView)
      end
    end

    --设置启用状态透明
    local enabledNotFalse = not(enabled == false)
    local switchEnabledNotFalse = not(switchEnabled == false)
    local cardEnabledNotFalse = not(cardEnabled == false)
    if viewConfig.enabled ~= enabledNotFalse then
      viewConfig.enabled = enabledNotFalse
      layoutView.getChildAt(0).setEnabled(enabledNotFalse)
      local viewsList = {titleView, summaryView, cardView, iconView, rightIconView}
      if enabledNotFalse then
        setAlpha(viewsList, 1)
       else
        setAlpha(viewsList, 0.5)
      end
    end

    if viewConfig.switchEnabled ~= switchEnabledNotFalse then
      viewConfig.switchEnabled = switchEnabledNotFalse
      if switchView then
        switchView.setEnabled(switchEnabledNotFalse)
      end
    end

    if switchView then
      if data.checked ~= nil then
        switchView.setChecked(data.checked)
       elseif data.key then
        switchView.setChecked(activity.getSharedData(key) or false)
       else
        switchView.setChecked(false)
      end
    end

    if rightIconView then
      local newPage = data.newPage
      local visibility = rightIconView.getVisibility()
      if newPage then
        if newPage == "newApp" then
          GlideUtil.set(activity.getLuaDir("res/drawable/ic_launch.png"), rightIconView)
         else
          rightIconView.setImageResource(AndroidX_R.drawable.abc_ic_go_search_api_material)
        end
        if visibility ~= View.VISIBLE then
          rightIconView.setVisibility(View.VISIBLE)
        end
       else
        if visibility ~= View.GONE then
          rightIconView.setVisibility(View.GONE)
        end
      end
    end
    viewConfig.allowedChange = true
  end,
}
SettingsLayUtil.adapterEvents = adapterEvents

function SettingsLayUtil.newAdapter(data, onItemClick, onItemLongClick)
  return LuaCustRecyclerAdapter(AdapterCreator({
    getItemCount = function()
      return adapterEvents.getItemCount(data)
    end,
    getItemViewType = function(position)
      return adapterEvents.getItemViewType(data, position)
    end,
    onCreateViewHolder = function(parent, viewType)
      return adapterEvents.onCreateViewHolder(onItemClick, onItemLongClick, parent, viewType)
    end,
    onBindViewHolder = function(holder, position)
      adapterEvents.onBindViewHolder(data, holder, position)
    end,
  }))
end

return SettingsLayUtil