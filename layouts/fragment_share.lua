local bindClass = luajava.bindClass
local LinearLayoutCompat = bindClass "androidx.appcompat.widget.LinearLayoutCompat"
local SwipeRefreshLayout = bindClass "androidx.swiperefreshlayout.widget.SwipeRefreshLayout"
local RecyclerView = bindClass "androidx.recyclerview.widget.RecyclerView"

return
{
  LinearLayoutCompat,
  layout_width = -1,
  layout_height = -1,
  orientation = "vertical",
  {
    SwipeRefreshLayout,
    id = "mSwipeRefreshLayout4",
    layout_width = -1,
    layout_height = -1,
            {
              RecyclerView,
              layout_width = -1,
              layout_height = -1,
              id = "recycler_share",
          },
  }
}