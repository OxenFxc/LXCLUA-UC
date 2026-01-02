local bindClass = luajava.bindClass
local LinearLayoutCompat = bindClass "androidx.appcompat.widget.LinearLayoutCompat"
local MaterialCardView = bindClass "com.google.android.material.card.MaterialCardView"
local AppCompatImageView = bindClass "androidx.appcompat.widget.AppCompatImageView"
local AppCompatTextView = bindClass "androidx.appcompat.widget.AppCompatTextView"
local RecyclerView = bindClass "androidx.recyclerview.widget.RecyclerView"
local MovementMethodUtil = bindClass "com.difierline.lua.luaappx.utils.MovementMethodUtil"
local FastScrollScrollView = import "me.zhanghai.android.fastscroll.FastScrollScrollView"

return {
  LinearLayoutCompat,
  layout_width = -1,
  layout_height = -1,
  orientation = "vertical",
  gravity = "center",
  {
    MaterialCardView,
    radius = 360,
    layout_margin = "24dp",
    layout_marginBottom = 0,
    --StrokeColor = Colors.colorSurfaceVariant,
    CardBackgroundColor = Colors.colorSurfaceVariant,
    {
      AppCompatImageView,
      layout_margin = "16dp",
      layout_width = "65dp",
      layout_height = "65dp",
      src = "res/drawable/ic_shield_account_outline.png",
      ColorFilter = Colors.colorPrimary,
    },
  },
  {
    AppCompatTextView,
    layout_margin = "16dp",
    text = res.string.user_agreement,
    textSize = "26sp",
    textColor = Colors.colorPrimary,
  },
  {
    FastScrollScrollView,
    layout_width = -1,
    layout_weight = 1,
    id = "scrollView",
    fillViewport = true,
    {
      AppCompatTextView,
      padding = "16dp",
      id = "textView",
      layout_width = "fill",
      textIsSelectable = true,
      linksClickable = true,
      textColor = Colors.colorOnBackground,
      MovementMethod = MovementMethodUtil.getInstance(),
    },
  },
}