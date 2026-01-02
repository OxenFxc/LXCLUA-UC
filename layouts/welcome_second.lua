local bindClass = luajava.bindClass
local LinearLayoutCompat = bindClass "androidx.appcompat.widget.LinearLayoutCompat"
local MaterialCardView = bindClass "com.google.android.material.card.MaterialCardView"
local AppCompatImageView = bindClass "androidx.appcompat.widget.AppCompatImageView"
local AppCompatTextView = bindClass "androidx.appcompat.widget.AppCompatTextView"
local RecyclerView = bindClass "androidx.recyclerview.widget.RecyclerView"

return {
  LinearLayoutCompat,
  layout_width = -1,
  layout_height = -1,
  orientation = "vertical",
  gravity = "center",
  {
    MaterialCardView,
    radius = 360,
    layout_margin = "16dp",
    layout_marginBottom = 0,
    --StrokeColor = Colors.colorSurfaceVariant,
    CardBackgroundColor = Colors.colorSurfaceVariant,
    {
      AppCompatImageView,
      layout_margin = "16dp",
      layout_width = "65dp",
      layout_height = "65dp",
      src = "res/drawable/ic_account_key_outline.png",
      ColorFilter = Colors.colorPrimary,
    },
  },
  {
    AppCompatTextView,
    layout_margin = "16dp",
    text = res.string.application_authority,
    textSize = "26sp",
    textColor = Colors.colorPrimary,
  },
  {
    RecyclerView,
    id = "recycler_view",
    layout_width = -1,
    layout_height = -2,
  },
}