local bindClass = luajava.bindClass
local AppCompatImageView = bindClass "androidx.appcompat.widget.AppCompatImageView"
local AppCompatTextView = bindClass "androidx.appcompat.widget.AppCompatTextView"
local MaterialCardView = bindClass "com.google.android.material.card.MaterialCardView"
local LinearLayoutCompat = bindClass "androidx.appcompat.widget.LinearLayoutCompat"
local Typeface = bindClass "android.graphics.Typeface"
local Utils = require "utils.Utils"

return {
  LinearLayoutCompat,
  layout_width = -1,
  {
    MaterialCardView,
    layout_marginLeft = "16dp",
    layout_marginRight = "16dp",
    layout_width = -1,
    clickable = true,
    --StrokeColor = Colors.colorSurfaceVariant,
    id = "card",
    {
      LinearLayoutCompat,
      layout_height = -1,
      layout_width = -1,
      {
        MaterialCardView,
        radius = 360,
        layout_margin = "12dp",
        CardBackgroundColor = 0xFFE0E0E0,
        layout_width = "55dp",
        StrokeWidth = 0,
        layout_height = "55dp",
        layoutTransition = newLayoutTransition(),
        {
          AppCompatImageView,
          layout_width = -1,
          layout_height = -1,
          id = "avatar",
          scaleType = "centerCrop",
        },
      },
      {
        LinearLayoutCompat,
        layout_height = -1,
        layout_width = -1,
        layout_weight = 1,
        orientation = "vertical",
        gravity = "center|left",
        {
          LinearLayoutCompat,
          layout_marginLeft = "4dp",
          {
            AppCompatTextView,
            textSize = "16sp",
            id = "nick",
            textColor = Colors.colorOnBackground,
            Typeface = Typeface.DEFAULT_BOLD,
          },
          {
            MaterialCardView,
            layout_height = "25dp",
            StrokeWidth = 0,
            layout_marginLeft = "8dp",
            CardBackgroundColor = Utils.setColorAlpha(Colors.colorPrimary, 20),
            {
              AppCompatTextView,
              layout_height = -1,
              gravity = "center",
              id = "title",
              --text = res.string.administrator,
              textSize = "13sp",
              maxLines = "1",
              ellipsize = "end",
              textColor = Colors.colorPrimary,
              paddingRight = "6dp",
              paddingLeft = "6dp",
            },
          },
        },
        {
          AppCompatTextView,
          id = "coins",
          maxLines = "1",
          ellipsize = "end",
          layout_marginLeft = "4dp",
        },
      },
      {
        AppCompatTextView,
        textSize = "20sp",
        id = "rank",
        layout_margin = "12dp",
        layout_marginRight = "16dp",
        gravity = "center",
        layout_height = -1,
        Typeface = Typeface.DEFAULT_BOLD,
      },
    }
  }
}