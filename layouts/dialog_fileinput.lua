local bindClass = luajava.bindClass
local LinearLayoutCompat = bindClass "androidx.appcompat.widget.LinearLayoutCompat"
local MaterialTextField = bindClass "com.difierline.lua.material.textfield.MaterialTextField"

return {
  LinearLayoutCompat,
  layout_width = -1,
  layout_height = -1,
  layoutTransition = newLayoutTransition(),
  {
    MaterialTextField,
    layout_width = -1,
    singleLine = true,
    hint = res.string.content,
    BoxCornerRadii = "12dp",
    layout_margin="26dp",
    layout_marginBottom="8dp",
    id = "content",
  },
}