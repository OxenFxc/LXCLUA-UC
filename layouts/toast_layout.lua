local bindClass = luajava.bindClass
local LinearLayoutCompat = bindClass "androidx.appcompat.widget.LinearLayoutCompat"
local MaterialCardView = bindClass "com.google.android.material.card.MaterialCardView"
local NestedScrollView = bindClass "androidx.core.widget.NestedScrollView"
local AppCompatTextView = bindClass "androidx.appcompat.widget.AppCompatTextView"

return {
  LinearLayoutCompat,
  layout_height = "fill",
  layout_width = "fill",
  gravity = "center",
  {
    MaterialCardView,
    CardBackgroundColor = Colors.colorPrimary,
    StrokeWidth = 0,
    --StrokeColor = Colors.colorSurfaceVariant,
    CardElevation = "2dp",
    radius = "14dp",
    layout_margin = "16dp",
    {
      NestedScrollView,
      layout_width = "fill",
      layout_height = "fill",
      overScrollMode = "2",
      VerticalScrollBarEnabled = false,
      {
        AppCompatTextView,
        textColor = Colors.colorBackground,
        ellipsize = "end",
        textIsSelectable = true,
        layout_margin = "14dp",
        id = "toast_text",
      },
    },
  },
}