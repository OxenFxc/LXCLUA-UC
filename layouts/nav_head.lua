local bindClass = luajava.bindClass
local AppCompatImageView = bindClass "androidx.appcompat.widget.AppCompatImageView"
local MaterialCardView = bindClass "com.google.android.material.card.MaterialCardView"
local LinearLayoutCompat = bindClass "androidx.appcompat.widget.LinearLayoutCompat"

return {
  LinearLayoutCompat,
  layout_width = -1,
  gravity = "center",
  {
    MaterialCardView,
    layout_height = "50dp",
    layout_width = "50dp",
    radius = 360,
    StrokeWidth = 0,    
    {
      AppCompatImageView,
      layout_height = -1,
      layout_width = -1,
      scaleType = "centerCrop",
      ImageResource = R.drawable.ic_launcher_playstore,
      id = "icon",
    },
  }
}