local bindClass = luajava.bindClass
local CoordinatorLayout = bindClass "androidx.coordinatorlayout.widget.CoordinatorLayout"
local ViewPager = bindClass "androidx.viewpager.widget.ViewPager"
local MaterialTextField = bindClass "com.difierline.lua.material.textfield.MaterialTextField"
local TabLayout = bindClass "com.google.android.material.tabs.TabLayout"
local LinearLayoutCompat = bindClass "androidx.appcompat.widget.LinearLayoutCompat"

return {
  CoordinatorLayout,
  layout_width = -1,
  layout_height = -1,
  require "layouts.appbar_layout"("", true),
  {
    LinearLayoutCompat,
    layout_width = -1,
    layout_height = -1,
    orientation = "vertical",
    LayoutTransition = newLayoutTransition(),
    layout_behavior = "appbar_scrolling_view_behavior",
    {
      TabLayout,
      layout_width = -1,
      TabMode = 0,
      clipToPadding = false,
      inlineLabel = true,
      id = "mtabs",
    },
    {
      MaterialTextField,
      layout_width = -1,
      singleLine = true,
      hint = res.string.content,
      BoxCornerRadii = "12dp",
      layout_margin = "16dp",
      id = "content",
    },
    {
      ViewPager;
      id = "cvpg";
      layout_width = -1,
      layout_height = -1,
    };
  }
}