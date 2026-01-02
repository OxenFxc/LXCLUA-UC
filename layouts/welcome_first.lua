local bindClass = luajava.bindClass
local LinearLayoutCompat = bindClass "androidx.appcompat.widget.LinearLayoutCompat"
local MaterialCardView = bindClass "com.google.android.material.card.MaterialCardView"
local AppCompatImageView = bindClass "androidx.appcompat.widget.AppCompatImageView"
local AppCompatTextView = bindClass "androidx.appcompat.widget.AppCompatTextView"

return {
  LinearLayoutCompat,
  layout_width = -1,
  layout_height = -1,
  orientation = "vertical",
  gravity = "center",
  {
    MaterialCardView,
    radius = 360,
    CardElevation = "2dp",
    layout_width = "165dp",
    layout_height = "165dp",
    StrokeWidth = 0,
    --StrokeColor = Colors.colorSurfaceVariant,
    {
      AppCompatImageView,
      layout_width = -1,
      layout_height = -1,
      --ImageResource = R.mipmap.ic_launcher,
      src = "ic_launcher_playstore.png",
    },
  },
  {
    AppCompatTextView,
    layout_marginTop = "24dp",
    text = res.string.welcome,
    textSize = "34sp",
    textColor = Colors.colorPrimary,
  },
  {
    AppCompatTextView,
    layout_marginTop = "12dp",
    layout_marginLeft = "24dp",
    layout_marginRight = "24dp",
    text = res.string.welcome2,
    gravity = "center",
  },
  {
    AppCompatTextView,
    layout_marginTop = 0,
    layout_margin = "24dp",
    text = "LXCLUA",
    gravity = "center",
  },
}