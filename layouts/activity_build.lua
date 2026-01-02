local bindClass = luajava.bindClass
local CoordinatorLayout = bindClass "androidx.coordinatorlayout.widget.CoordinatorLayout"
local RecyclerView = bindClass "androidx.recyclerview.widget.RecyclerView"

return {
  CoordinatorLayout,
  layout_width = -1,
  layout_height = -1,
  require "layouts.appbar_layout"(res.string.build_project),
  {
    RecyclerView,
    layout_width = -1,
    layout_height = -1,
    id = "recycler_view",
    layout_behavior = "appbar_scrolling_view_behavior",
  },
}