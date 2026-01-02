local bindClass = luajava.bindClass
local LinearLayoutCompat = bindClass "androidx.appcompat.widget.LinearLayoutCompat"
local RangeSlider = bindClass "com.google.android.material.slider.RangeSlider"
local List = bindClass "java.util.List"

return {
  LinearLayoutCompat,
  layout_width = -1,
  layout_height = -1,
  layoutTransition = newLayoutTransition(),
  {
    RangeSlider,
    layout_margin = "26dp",
    layout_marginTop = 0,
    layout_marginBottom = "8dp",
    id = "slider",
    stepSize = "1",
    valueTo = "100",
    valueFrom = "2",
    values = List({float(30), float(80)}),
  },
}