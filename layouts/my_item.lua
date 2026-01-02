local bindClass = luajava.bindClass
local AppCompatImageView = bindClass "androidx.appcompat.widget.AppCompatImageView"
local AppCompatTextView = bindClass "androidx.appcompat.widget.AppCompatTextView"
local MaterialCardView = bindClass "com.google.android.material.card.MaterialCardView"
local LinearLayoutCompat = bindClass "androidx.appcompat.widget.LinearLayoutCompat"

return {
  MaterialCardView,
  layout_width = -1,
  radius = 0,
  StrokeWidth = 0,
  CardBackgroundColor = 0,
  id = "card",
  {
    LinearLayoutCompat,
    layout_height = "45dp",
    layout_width = -1,
    {
      AppCompatImageView,
      layout_height = -1,
      layout_width = "45dp",
      layout_marginLeft = "8dp",
      padding = "11dp",
      ColorFilter = Colors.colorOnSurfaceVariant,
      id = "image",
    },
    {
      AppCompatTextView,
      layout_height = -1,
      maxLines = "1",
      ellipsize = "end",
      gravity = "center",
      layout_marginLeft = "12dp",
      layout_marginRight = "12dp",
      textColor = Colors.colorOnBackground,
      singleLine = true,
      id = "content",
    }
  }
}