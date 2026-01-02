local bindClass = luajava.bindClass
local AppCompatTextView = bindClass "androidx.appcompat.widget.AppCompatTextView"
local AppCompatImageView = bindClass "androidx.appcompat.widget.AppCompatImageView"
local LinearLayoutCompat = bindClass "androidx.appcompat.widget.LinearLayoutCompat"
local MaterialCardView = bindClass "com.google.android.material.card.MaterialCardView"
local Typeface = bindClass "android.graphics.Typeface"
--local Utils = require "utils.Utils"

return {
  LinearLayoutCompat,
  layout_height = -2,
  layout_width = -1,
  {
    MaterialCardView,
    layout_height = "70dp",
    layout_width = -1,
    --StrokeColor = Colors.colorSurfaceVariant,
    --CardBackgroundColor = Utils.setColorAlpha(Colors.colorSurfaceContainer, 80),
    layout_marginLeft = "14dp",
    layout_marginRight = "14dp",
    id = "card",
    {
      LinearLayoutCompat,
      layout_height = -1,
      layout_width = -1,
      {
        MaterialCardView,
        layout_height = "45dp",
        layout_width = "45dp",
        StrokeWidth = 0,
        --StrokeColor = Colors.colorSurfaceVariant,
        layout_marginLeft = "15dp",
        layout_gravity = "center",
        {
          AppCompatTextView,
          layout_height = -1,
          layout_width = -1,
          gravity = "center",
          textSize = "17sp",
          textColor = 0xFFFFFFFF,
          id = "icon"
        },
        {
          AppCompatImageView,
          layout_height = -1,
          layout_width = -1,
          scaleType = "centerCrop",
          id = "icon2",
        },
      },
      {
        LinearLayoutCompat,
        layout_height = -1,
        layout_width = -1,
        gravity = "center|left",
        orientation = "vertical",
        layout_marginLeft = "15dp",
        layout_marginRight = "8dp",
        layout_weight = 1,
        {
          LinearLayoutCompat,
          layout_marginBottom = "1dp",
          {
            AppCompatTextView,
            textColor = Colors.colorOnBackground,
            maxLines = "1",
            ellipsize = "end",
            gravity = "center",
            Typeface = Typeface.DEFAULT_BOLD,
            layout_weight = 1,
            id = "title"
          },
          {
            AppCompatTextView,
            ellipsize = "end",
            gravity = "center",
            textSize = "13sp",
            layout_weight = 1,
            layout_marginLeft = "5dp",
            layout_marginRight = "8dp",
            Typeface = Typeface.DEFAULT_BOLD,
            textColor = Colors.colorOnBackground,
            maxLines = "1",
            id = "version"
          },
        },
        {
          AppCompatTextView,
          layout_width = -1,
          gravity = "center|left",
          ellipsize = "end",
          textColor = Colors.colorOutline,
          layout_marginTop = "1dp",
          maxLines = "1",
          id = "package"
        },
      }
    }
  },
}