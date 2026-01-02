local bindClass = luajava.bindClass
local LinearLayoutCompat = bindClass "androidx.appcompat.widget.LinearLayoutCompat"
local TabLayout = bindClass "com.google.android.material.tabs.TabLayout"
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
    id = "mSwipeRefreshLayout2",
    layout_width = -1,
    layout_height = -1,
{
            LinearLayoutCompat,
            layout_width = -1,
            layout_height = -1,
            orientation = "vertical",
            {
              TabLayout,
              id = "mtab_tag",
              TabMode = 0,
              clipToPadding = false,
              inlineLabel = true,
              layout_width = -1,
            },
            {
              RecyclerView,
              layout_width = -1,
              layout_height = -1,
              id = "recycler_code",
            }
          },
  }
}