local bindClass = luajava.bindClass
local LinearLayoutCompat = bindClass "androidx.appcompat.widget.LinearLayoutCompat"
local BottomSheetDragHandleView = bindClass "com.google.android.material.bottomsheet.BottomSheetDragHandleView"
local MaterialCardView = bindClass "com.difierline.lua.material.card.MaterialCardView"
local AppCompatTextView = bindClass "androidx.appcompat.widget.AppCompatTextView"
local MaterialDivider = bindClass "com.google.android.material.divider.MaterialDivider"
local MaterialHeroButtonGroup = bindClass "com.difierline.lua.material.button.MaterialHeroButtonGroup"
local MaterialHeroButton = bindClass "com.difierline.lua.material.button.MaterialHeroButton"
local Typeface = bindClass "android.graphics.Typeface"
local IconDrawable = require "utils.IconDrawable"

return {
  LinearLayoutCompat,
  layout_height = -1,
  layout_width = -1,
  orientation = "vertical",
  {
    BottomSheetDragHandleView,
    layout_width = -1,
  },
  {
    MaterialCardView,
    layout_height = "52dp",
    layout_width = "52dp",
    CardBackgroundColor = Colors.colorPrimary,
    StrokeWidth = 0,
    layout_gravity = "center",
    {
      AppCompatTextView,
      layout_height = -1,
      layout_width = -1,
      gravity = "center",
      textSize = "21sp",
      textColor = 0xFFFFFFFF,
      id = "icon"
    }
  },
  {
    AppCompatTextView,
    layout_marginBottom = "8dp",
    ellipsize = "end",
    textSize = "16sp",
    layout_marginLeft = "16dp",
    layout_marginRight = "16dp",
    textColor = Colors.colorOnBackground,
    layout_marginTop = "16dp",
    maxLines = "1",
    Typeface = Typeface.DEFAULT_BOLD,
    layout_gravity = "center",
    id = "title"
  },
  {
    AppCompatTextView,
    layout_marginBottom = "8dp",
    ellipsize = "end",
    textSize = "15sp",
    textColor = Colors.colorOutline,
    layout_marginLeft = "16dp",
    layout_marginRight = "16dp",
    layout_marginTop = 0,
    maxLines = "1",
    layout_gravity = "center",
    id = "longpackage"
  },
  {
    MaterialDivider,
    --DividerColor = Colors.colorSurfaceVariant,
    layout_marginLeft = "22dp",
    layout_marginRight = "22dp",
  },
  {
    MaterialHeroButtonGroup,
    layout_width = "match_parent",
    {
      MaterialHeroButton,
      layout_height = -1,
      layout_width = -1,
      backgroundDrawable = getRipple(),
      Icon = IconDrawable("ic_package_variant"),
      layout_weight = 1,
      id = "build",
      text = res.string.build
    },
    {
      MaterialHeroButton,
      layout_height = -1,
      layout_width = -1,
      Icon = IconDrawable("ic_zip_box_outline"),
      layout_weight = 1,
      id = "backup",
      text = res.string.backup
    },
    {
      MaterialHeroButton,
      layout_height = -1,
      layout_width = -1,
      Icon = IconDrawable("ic_share_variant_outline"),
      layout_weight = 1,
      id = "share",
      text = res.string.share
    },

    {
      MaterialHeroButton,
      layout_height = -1,
      layout_width = -1,
      Icon = IconDrawable("ic_delete_forever_outline"),
      Color = Colors.colorError,
      backgroundDrawable = getRipple(false, 0x31FF0000),
      layout_weight = 1,
      id = "delete",
      text = res.string.delete
    }
  },
  {
    MaterialDivider,
    layout_marginLeft = "24dp",
    layout_marginRight = "24dp"
  }
}