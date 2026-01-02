local bindClass = luajava.bindClass
local LinearLayoutCompat = bindClass "androidx.appcompat.widget.LinearLayoutCompat"
local MaterialTextField = bindClass "com.difierline.lua.material.textfield.MaterialTextField"

return {
  LinearLayoutCompat,
  layout_width = -1,
  layout_height = -1,
  orientation = "vertical",
  layoutTransition = newLayoutTransition(),
  {
    MaterialTextField,
    layout_width = -1,
    hint = res.string.title,
    BoxCornerRadii = "12dp",
    layout_margin = "26dp",
    layout_marginBottom = 0,
    id = "title",
  },
  {
    MaterialTextField,
    layout_width = -1,
    hint = res.string.content,
    BoxCornerRadii = "12dp",
    layout_margin = "26dp",
    layout_marginTop = "20dp",
    layout_marginBottom="8dp",
    id = "content",
  },
}