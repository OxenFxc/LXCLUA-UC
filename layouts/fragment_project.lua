local bindClass = luajava.bindClass
local SwipeRefreshLayout = bindClass "androidx.swiperefreshlayout.widget.SwipeRefreshLayout"
local RecyclerView = bindClass "androidx.recyclerview.widget.RecyclerView"

return {
  SwipeRefreshLayout,
  layout_width = -1,
  layout_height = -1,
  id = "mSwipeRefreshLayout",
  {
    RecyclerView,
    --paddingBottom = "14dp",
    id="recylerView",
    layout_width = -1,
    layout_height = -1,
  }
}