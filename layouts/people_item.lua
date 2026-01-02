local bindClass = luajava.bindClass
local LinearLayoutCompat = bindClass "androidx.appcompat.widget.LinearLayoutCompat"
local MaterialCardView = bindClass "com.google.android.material.card.MaterialCardView"
local AppCompatImageView = bindClass "androidx.appcompat.widget.AppCompatImageView"

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
    layout_height = "48dp",
    layout_width = "48dp",
    radius = 360,
    StrokeWidth = 0,
    id = "card",
    {
      AppCompatImageView,
      layout_height = -1,
      layout_width = -1,
      scaleType = "centerCrop",
      id = "icon",
    },
  },
}