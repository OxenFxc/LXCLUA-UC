local bindClass = luajava.bindClass
local CoordinatorLayout = bindClass "androidx.coordinatorlayout.widget.CoordinatorLayout"
local RecyclerView = bindClass "androidx.recyclerview.widget.RecyclerView"
local LinearLayoutCompat = bindClass "androidx.appcompat.widget.LinearLayoutCompat"
local MaterialTextField = bindClass "com.difierline.lua.material.textfield.MaterialTextField"
local TabLayout = bindClass "com.google.android.material.tabs.TabLayout"

return {
  CoordinatorLayout,
  layout_width = -1,
  layout_height = -1,
  require "layouts.appbar_layout"(res.string.logs),
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
      id = "tabs",
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
      RecyclerView,
      layout_width = -1,
      layout_height = -1,
      id = "recycler_view",
    },
  }
}