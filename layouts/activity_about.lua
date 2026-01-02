local bindClass = luajava.bindClass
local CoordinatorLayout = bindClass "androidx.coordinatorlayout.widget.CoordinatorLayout"
local RecyclerView = bindClass "androidx.recyclerview.widget.RecyclerView"
local NestedScrollView = bindClass "androidx.core.widget.NestedScrollView"
local LinearLayoutCompat = bindClass "androidx.appcompat.widget.LinearLayoutCompat"
local MaterialCardView = bindClass "com.google.android.material.card.MaterialCardView"
local AppCompatImageView = bindClass "androidx.appcompat.widget.AppCompatImageView"
local AppCompatTextView = bindClass "androidx.appcompat.widget.AppCompatTextView"
local Typeface = bindClass "android.graphics.Typeface"

return {
  CoordinatorLayout,
  layout_width = -1,
  layout_height = -1,
  require "layouts.appbar_layout"(res.string.about_software),
  {
    NestedScrollView,
    layout_width = -1,
    layout_height = -1,
    layout_behavior = "appbar_scrolling_view_behavior",
    {
      LinearLayoutCompat,
      orientation = "vertical",
      layout_width = -1,
      layout_height = -1,

      {
        MaterialCardView,
        layout_width = -1,
        layout_margin = "18dp",
        clickable = true,
        --StrokeColor = Colors.colorSurfaceVariant,
        {
          LinearLayoutCompat,
          orientation = "vertical",
          gravity = "center",
          layout_width = -1,
          layout_height = -1,
          {
            MaterialCardView,
            layout_margin = "24dp",
            layout_marginBottom = 0,
            layout_width = "60dp",
            radius = 360,
            layout_height = "60dp",
            --StrokeColor = Colors.colorSurfaceVariant,
            {
              AppCompatImageView,
              layout_width = -1,
              layout_height = -1,
              --ImageResource = R.mipmap.ic_launcher,
              src = "ic_launcher_playstore.png",
            },
          },
          {
            AppCompatTextView,
            text = res.string.app_name,
            gravity = "center",
            textSize = "15sp",
            Typeface = Typeface.DEFAULT_BOLD,
            layout_margin = "8dp",
            layout_marginBottom = 0,
            textColor = Colors.colorOnBackground,
          },
          {
            AppCompatTextView,
            text = res.string.welcome2,
            gravity="center",
            layout_marginTop = "8dp",
            layout_margin = "24dp",
          },
        },
      },
      {
        RecyclerView,
        layout_width = -1,
        layout_height = -1,
        id = "recycler_view",
      },
    }
  },
}