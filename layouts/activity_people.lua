local bindClass = luajava.bindClass
local CoordinatorLayout = bindClass "androidx.coordinatorlayout.widget.CoordinatorLayout"
local RecyclerView = bindClass "androidx.recyclerview.widget.RecyclerView"
local LinearLayoutCompat = bindClass "androidx.appcompat.widget.LinearLayoutCompat"
local MaterialCardView = bindClass "com.google.android.material.card.MaterialCardView"
local AppCompatTextView = bindClass "androidx.appcompat.widget.AppCompatTextView"
local NestedScrollView = bindClass "androidx.core.widget.NestedScrollView"

return {
  CoordinatorLayout,
  layout_width = -1,
  layout_height = -1,
  require "layouts.appbar_layout"(res.string.more_people),
  {
    NestedScrollView,
    layout_width = -1,
    layout_height = -1,
    LayoutTransition = newLayoutTransition(),
    layout_behavior = "appbar_scrolling_view_behavior",
    {
      LinearLayoutCompat,
      layout_width = -1,
      layout_height = -1,
      orientation = "vertical",
      {
        MaterialCardView,
        layout_width = -1,
        layout_margin = "16dp",
        --StrokeColor = Colors.colorSurfaceVariant,
        {
          LinearLayoutCompat,
          layout_width = -1,
          layout_height = -1,
          orientation = "vertical",
          {
            AppCompatTextView,
            layout_margin = "16dp",
            layout_marginBottom= 0,
            text = "贡献者",
            textSize = "16dp",
            textColor = Colors.colorOnBackground,
          },
          {
            RecyclerView,
            layout_marginLeft = "8dp",
            layout_marginRight = "8dp",
            layout_marginBottom= "16dp",
            layout_width = -1,
            layout_height = -1,
            id = "recycler_view1",
          },
        },
      },
      {
        MaterialCardView,
        layout_width = -1,
        layout_margin = "16dp",
        layout_marginTop = 0,
        --StrokeColor = Colors.colorSurfaceVariant,
        {
          LinearLayoutCompat,
          layout_width = -1,
          layout_height = -1,
          orientation = "vertical",
          {
            AppCompatTextView,
            layout_margin = "16dp",
            layout_marginBottom= 0,
            text = "捐赠者",
            textSize = "16dp",
            textColor = Colors.colorOnBackground,
          },
          {
            RecyclerView,
            layout_width = -1,
            layout_height = -1,
            layout_marginLeft = "8dp",
            layout_marginRight = "8dp",
            layout_marginBottom= "16dp",
            id = "recycler_view2",
          },
        },
      },
    },
  }
}