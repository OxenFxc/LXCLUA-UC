local bindClass = luajava.bindClass
-- 公共组件绑定
local CoordinatorLayout = bindClass "androidx.coordinatorlayout.widget.CoordinatorLayout"
local AppBarLayout = bindClass "com.google.android.material.appbar.AppBarLayout"
local MaterialToolbar = bindClass "com.google.android.material.appbar.MaterialToolbar"
local LinearLayoutCompat = bindClass "androidx.appcompat.widget.LinearLayoutCompat"
local UiUtil = bindClass "com.difierline.lua.luaappx.utils.UiUtil"

return {
  CoordinatorLayout,
  layout_width = -1,
  layout_height = -1,
  LayoutTransition = newLayoutTransition(),
  {
    AppBarLayout,
    liftOnScroll = true,
    fitsSystemWindows = true,
    layout_width = -1,
    {
      MaterialToolbar,
      id = "toolbar",
      layout_width = -1,
      backgroundColor = Colors.colorSurfaceContainer,
      title = res.string.layout_helper,
      layout_scrollFlags = 3,
      layout_height = UiUtil.getActionBarSize(activity) + dp2px(8),
    },
  },
  {
    LinearLayoutCompat,
    orientation = "vertical",
    layout_behavior = "appbar_scrolling_view_behavior",
    layout_width = -1,
    layout_height = -1,
    layout_margin = "12dp",
    layout_marginBottom = "16dp",
    id = "root",
--    LayoutTransition = newLayoutTransition(),
  },
}