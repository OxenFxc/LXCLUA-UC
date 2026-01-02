local bindClass = luajava.bindClass
local LinearLayoutCompat = bindClass "androidx.appcompat.widget.LinearLayoutCompat"
local AppCompatTextView = bindClass "androidx.appcompat.widget.AppCompatTextView"
local MaterialCardView = bindClass "com.google.android.material.card.MaterialCardView"
local Utils = require "utils.Utils"

return {
  LinearLayoutCompat,
  layout_width = -1,
  orientation = "vertical",
  {
    MaterialCardView,
    layout_marginLeft = "16dp",
    layout_marginRight = "16dp",
    layout_width = -1,
    --StrokeColor = Colors.colorSurfaceVariant,
    id = "card",
    {
      LinearLayoutCompat,
      layout_width = -1,
      orientation = "vertical",
      {
        AppCompatTextView,
        id = "title",
        layout_weight = 1,
        layout_margin = "16dp",
        gravity = "center|left",
        textColor = Colors.colorPrimary,
      },
      {
        LinearLayoutCompat,
        layout_marginTop = "-6dp",
        layout_marginBottom = "14dp",
        layout_margin = "16dp",
        gravity = "center|left",
        {
          MaterialCardView,
          layout_height = "20dp",
          StrokeWidth = 0,
          Visibility = 8,
          layout_marginRight = "8dp",
          CardBackgroundColor = Utils.setColorAlpha(Colors.colorPrimary, 20),
          {
            AppCompatTextView,
            layout_width = -1,
            layout_height = -1,
            gravity = "center",
            id = "access",
            text = "public",
            textSize = "10sp",
            maxLines = "1",
            ellipsize = "end",
            textColor = Colors.colorPrimary,
            paddingRight = "6dp",
            paddingLeft = "6dp",
          },
        },
        {
          AppCompatTextView,
          id = "content",
          textSize = "13sp",
          gravity = "center|left",
        },
      }
    },
  },
}