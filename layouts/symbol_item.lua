local bindClass = luajava.bindClass
local LinearLayoutCompat = bindClass "androidx.appcompat.widget.LinearLayoutCompat"
local MaterialCardView = bindClass "com.google.android.material.card.MaterialCardView"
local MarText = bindClass "android.widget.MarText"

return {
  LinearLayoutCompat,
  layout_width = -1,
  orientation = "vertical",
  {
    MaterialCardView,
    layout_marginLeft = "10dp",
    layout_marginRight = "10dp",
    layout_marginTop = "14dp",
    layout_width = -1,
    --StrokeColor = Colors.colorSurfaceVariant,
    id = "card",
    {
      LinearLayoutCompat,
      layout_width = -1,
      orientation = "vertical",
      {
        MarText,
        id = "title",
        textSize = "14sp",
        layout_weight = 1,
        layout_margin = "16dp",
        gravity = "center|left",
        textColor = Colors.colorPrimary,
        focusableInTouchMode = true,
        focusable = true,
        singleLine = true,
      },
      {
        MarText,
        id = "content",
        textSize = "14sp",
        ellipsize = "marquee",
        focusableInTouchMode = true,
        focusable = true,
        singleLine = true,
        gravity = "center|left",
        layout_marginTop = "-6dp",
        layout_margin = "16dp",
      },
    },
  },
}