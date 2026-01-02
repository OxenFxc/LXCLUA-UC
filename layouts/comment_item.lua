local bindClass = luajava.bindClass
local AppCompatTextView = bindClass "androidx.appcompat.widget.AppCompatTextView"
local AppCompatImageView = bindClass "androidx.appcompat.widget.AppCompatImageView"
local LinearLayoutCompat = bindClass "androidx.appcompat.widget.LinearLayoutCompat"
local MaterialCardView = bindClass "com.google.android.material.card.MaterialCardView"
local Typeface = bindClass "android.graphics.Typeface"
local RecyclerView = bindClass "androidx.recyclerview.widget.RecyclerView"
local Utils = require "utils.Utils"

return {
  LinearLayoutCompat,
  layout_height = -2,
  layout_width = -1,
  {
    MaterialCardView,
    layout_width = -1,
    --StrokeColor = Colors.colorSurfaceVariant,
    layout_marginLeft = "14dp",
    layout_marginRight = "14dp",
    id = "card",
    {
      LinearLayoutCompat,
      layout_height = -1,
      layout_width = -1,
      orientation = "vertical",
      {
        LinearLayoutCompat,
        layout_width = -1,
        {
          MaterialCardView,
          radius = 360,
          StrokeWidth = 0,
          layout_margin = "12dp",
          layout_width = "35dp",
          layout_height = "35dp",
          {
            AppCompatImageView,
            layout_width = -1,
            layout_height = -1,
            scaleType = "centerCrop",
            id = "icon",
          },
        },
        {
          LinearLayoutCompat,
          layout_height = -1,
          orientation = "vertical",
          gravity = "center|left",
          {
            LinearLayoutCompat,
            layout_marginBottom = "1dp",
            {
              AppCompatTextView,
              id = "nick",
              textColor = Colors.colorOnBackground,
            },
            {
              MaterialCardView,
              layout_height = "20dp",
              StrokeWidth = 0,
              Visibility = 8,
              layout_marginRight = 0,
              layout_marginLeft = "8dp",
              CardBackgroundColor = Utils.setColorAlpha(Colors.colorPrimary, 40),
              {
                AppCompatTextView,
                layout_height = -1,
                gravity = "center",
                id = "admin",
                text = res.string.administrator,
                textSize = "10sp",
                maxLines = "1",
                ellipsize = "end",
                textColor = Colors.colorPrimary,
                paddingRight = "6dp",
                paddingLeft = "6dp",
              },
            },
            {
              MaterialCardView,
              layout_height = "20dp",
              StrokeWidth = 0,
              Visibility = 8,
              layout_marginRight = "8dp",
              layout_marginLeft = "8dp",
              CardBackgroundColor = Utils.setColorAlpha(Colors.colorPrimary, 40),
              {
                AppCompatTextView,
                layout_width = -1,
                layout_height = -1,
                gravity = "center",
                id = "up",
                text = res.string.administrator,
                textSize = "10sp",
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
            textSize = "13sp",
            layout_marginTop = "1dp",
            id = "time",
          }

        }
      },
      {
        AppCompatTextView,
        id = "content",
        textColor = Colors.colorOnBackground,
        layout_marginTop = 0,
        textSize = "13dp",
        layout_marginLeft = "59dp",
        layout_margin = "12dp",
      },
      {
        RecyclerView,
        id="recylerView",
        layout_width = -1,
        layout_height = -2,
        layout_marginTop = 0,
        layout_marginBottom = "8dp",
        layout_marginLeft = "20dp",
      },
    }
  }
}