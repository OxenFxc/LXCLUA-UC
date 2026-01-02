local bindClass = luajava.bindClass
local CoordinatorLayout = bindClass "androidx.coordinatorlayout.widget.CoordinatorLayout"
local AppBarLayout = bindClass "com.google.android.material.appbar.AppBarLayout"
local MaterialToolbar = bindClass "com.google.android.material.appbar.MaterialToolbar"
local LinearLayoutCompat = bindClass "androidx.appcompat.widget.LinearLayoutCompat"
local LinearProgressIndicator = bindClass "com.google.android.material.progressindicator.LinearProgressIndicator"
local AppCompatTextView = bindClass "androidx.appcompat.widget.AppCompatTextView"
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
      title = res.string.custom_control_class,
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
    LayoutTransition = newLayoutTransition(),
    {
      LinearLayoutCompat,
      layout_width = -1,
      orientation = "vertical",
      Visibility = 8,
      LayoutTransition = newLayoutTransition(),
      {
        AppCompatTextView,
        id = "init_text",
      },
      {
        LinearProgressIndicator,
        layout_width = -1,
        indeterminate = true,
        id = "init_progress",
      },
    },
    {
      EditView.getView(),
      id = "editor",
      layout_width = -1,
      layout_height = -1,
    },
  },
}