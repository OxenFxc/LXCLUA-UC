local bindClass = luajava.bindClass
local LinearLayoutCompat = bindClass "androidx.appcompat.widget.LinearLayoutCompat"
local MaterialCardView = bindClass "com.google.android.material.card.MaterialCardView"
local AppCompatTextView = bindClass "androidx.appcompat.widget.AppCompatTextView"

return {
  LinearLayoutCompat,
  layout_width = -1,
  layout_height = -2,
  orientation = "vertical",
  {
    MaterialCardView,
    id = "card",
    radius = "16dp",
    layout_width = -1,
    layout_height = -2,
    layout_marginLeft = "24dp",
    layout_marginRight = "24dp",
    layout_marginTop = "8dp",
    layout_marginBottom = "8dp",
    --StrokeColor = Colors.colorSurfaceVariant,
    checkable = true,
    focusable = true,
    clickable = true,
    {
      LinearLayoutCompat,
      layout_width = -1,
      layout_height = -2,
      orientation = "vertical",
      layout_marginLeft = "12dp",
      layout_marginRight = "12dp",
      layout_marginTop = "12dp",
      layout_marginBottom = "12dp",
      {
        AppCompatTextView,
        --textSize = "15sp",
        id = "name",
        padding = "3dp",
        textColor = Colors.colorOnBackground,
      },
      {
        AppCompatTextView,
        textSize = "13sp",
        padding = "3dp",
        layout_marginTop = "3dp",
        id = "text",
      },
    },
  },
}