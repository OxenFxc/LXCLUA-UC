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
    CardBackgroundColor = 0,
    --StrokeColor = Colors.colorSurfaceVariant,
    id = "card",
    checkable = true,
    focusable = true,
    clickable = true,
    {
      LinearLayoutCompat,
      layout_width = -1,
      orientation = "vertical",
      {
        AppCompatTextView,
        id = "text",
        layout_weight = 1,
        layout_margin = "16dp",
        gravity = "center|left",
        textColor = Colors.colorPrimary,
      },
      {
        AppCompatTextView,
        id = "name",
        textSize = "13sp",
        gravity = "center|left",
        layout_marginTop = "-6dp",
        layout_margin = "16dp",
      },
    },
  },
}