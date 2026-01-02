local bindClass = luajava.bindClass
local CoordinatorLayout = bindClass "androidx.coordinatorlayout.widget.CoordinatorLayout"
local RecyclerView = bindClass "androidx.recyclerview.widget.RecyclerView"
local LinearLayoutCompat = bindClass "androidx.appcompat.widget.LinearLayoutCompat"
local ExtendedFloatingActionButton = bindClass "com.google.android.material.floatingactionbutton.ExtendedFloatingActionButton"

return {
  CoordinatorLayout,
  layout_width = -1,
  layout_height = -1,
  require "layouts.appbar_layout"(res.string.custom_symbol_bar),
  {
    RecyclerView,
    layout_width = -1,
    layout_height = -1,
    id = "recycler_view",
    clipToPadding = true,
    layout_marginLeft = "8dp",
    layout_marginRight = "8dp",
    layout_marginBottom= "60dp",    
    layout_behavior = "appbar_scrolling_view_behavior",
  },
  {
    LinearLayoutCompat,
    layout_width = -1,
    layout_height = "60dp",
    layout_gravity = "bottom",
    backgroundColor = Colors.colorBackground,
  },
  {
    ExtendedFloatingActionButton,
    layout_margin = "16dp",
    id = "fab",
    text = res.string.add,
    IconResource = R.drawable.ic_add,
    layout_gravity = "end|bottom"
  },
}