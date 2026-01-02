local bindClass = luajava.bindClass
local AppCompatImageView = bindClass "androidx.appcompat.widget.AppCompatImageView"

return {
  AppCompatImageView,
  layout_height = "50dp",
  layout_width = "50dp",
  paddingRight = "14dp",
  paddingLeft = "14dp",
  ColorFilter = Colors.colorOnSurfaceVariant,
  id = "image",
}