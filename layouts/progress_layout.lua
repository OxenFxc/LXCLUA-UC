local bindClass = luajava.bindClass
local LinearLayoutCompat = bindClass "androidx.appcompat.widget.LinearLayoutCompat"
local LoadingIndicator = bindClass "com.google.android.material.loadingindicator.LoadingIndicator"

return {
  LinearLayoutCompat,
  layout_width = -1,
  layout_height = -1,
  {
    LinearLayoutCompat,
    gravity = "center",
    orientation = "vertical",
    layout_width = -1,
    layout_height = "150dp",
    {
      LoadingIndicator,
      indicatorSize = "50dp",
    }
  }
}