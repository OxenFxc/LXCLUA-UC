local bindClass = luajava.bindClass
local CoordinatorLayout = bindClass "androidx.coordinatorlayout.widget.CoordinatorLayout"
local PageView = bindClass "android.widget.PageView"
local LinearLayoutCompat = bindClass "androidx.appcompat.widget.LinearLayoutCompat"
local AppCompatImageView = bindClass "androidx.appcompat.widget.AppCompatImageView"
local MaterialCardView = bindClass "com.google.android.material.card.MaterialCardView"
local LinearProgressIndicator = bindClass "com.google.android.material.progressindicator.LinearProgressIndicator"
local ViewPager = bindClass "androidx.viewpager.widget.ViewPager"
local UiUtil = bindClass "com.difierline.lua.luaappx.utils.UiUtil"

local function MyViewPager()
  return luajava.override(ViewPager,{
    onInterceptTouchEvent = function(super,event)
      return false
    end,
    onTouchEvent = function(super,event)
      return false
    end
  })
end

return {
  LinearLayoutCompat,
  layout_width = -1,
  layout_height = -1,
  orientation = "vertical",
  LayoutTransition = newLayoutTransition(),
  {
    MyViewPager,
    id = "vpg",
    layout_marginTop = UiUtil.getStatusBarHeight(activity),
    layout_width = -1,
    layout_height = -1,
    layout_weight = 1,
    pages = {
      "layouts.welcome_first",
      "layouts.welcome_second",
      "layouts.welcome_third",
    },
  },
  {
    LinearLayoutCompat,
    layout_width = -1,
    layout_margin = "16dp",
    {
      LinearLayoutCompat,
      LayoutTransition = newLayoutTransition(),
      {
        MaterialCardView,
        layout_margin = "8dp",
        layout_width = "60dp",
        layout_height = "60dp",
        radius = 360,
        StrokeWidth = 0,
        id = "previous",
        Visibility = 4,
        CardBackgroundColor = Colors.colorPrimary,
        {
          AppCompatImageView,
          layout_margin = "16dp",
          layout_width = -1,
          layout_height = -1,
          src = "res/drawable/ic_arrow_left.png",
          ColorFilter = "0xFFFFFFFF",
        }
      },

    },
    {
      LinearLayoutCompat,
      layout_weight = 1,
      layout_height = -1,
      layout_width = activity.width,
      gravity = "center",
      {
        LinearProgressIndicator,
        layout_marginLeft = "38dp",
        layout_marginRight = "38dp",
        layout_width = -1,
        progress = 0,
        id = "indicator",
        layout_gravity = "center",
      }
    },
    {
      LinearLayoutCompat,
      LayoutTransition = newLayoutTransition(),
      {
        MaterialCardView,
        layout_margin = "8dp",
        layout_width = "60dp",
        layout_height = "60dp",
        radius = 360,
        StrokeWidth = 0,
        id = "next",
        CardBackgroundColor = Colors.colorPrimary,
        {
          AppCompatImageView,
          layout_margin = "16dp",
          layout_width = -1,
          layout_height = -1,
          src = "res/drawable/ic_arrow_right.png",
          ColorFilter = "0xFFFFFFFF",
        }
      },
    },
  }
}