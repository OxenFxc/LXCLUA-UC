local bindClass = luajava.bindClass
local AppCompatTextView = bindClass "androidx.appcompat.widget.AppCompatTextView"

return
{
  AppCompatTextView,
  layout_height = "45dp",
  gravity = "center",
  paddingRight = "16dp",
  paddingLeft = "16dp",
  textColor = Colors.colorOnBackground,
  singleLine = true,
  id = "symbol",
}