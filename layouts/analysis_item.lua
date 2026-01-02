local bindClass = luajava.bindClass
local LinearLayoutCompat = bindClass "androidx.appcompat.widget.LinearLayoutCompat"
local AppCompatTextView = bindClass "androidx.appcompat.widget.AppCompatTextView"
local MaterialCardView = bindClass "com.google.android.material.card.MaterialCardView"

return {
  LinearLayoutCompat,
  layout_width = -1,
  orientation = "vertical",
  {
    MaterialCardView,
    layout_marginLeft = "16dp",
    layout_marginRight = "16dp",
    layout_width = -1,
    --StrokeColor = Colors.colorSurfaceVariant,
    id = "card",
    checkable = true,
    focusable = true,
    clickable = true,
    {
      AppCompatTextView,
      id = "title",
      --textSize = "14sp",
      gravity = "center|left",
      layout_margin = "16dp",
      textColor = Colors.colorPrimary,
    },
  },
}