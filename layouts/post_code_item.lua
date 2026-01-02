local bindClass = luajava.bindClass
local LinearLayoutCompat = bindClass "androidx.appcompat.widget.LinearLayoutCompat"
local AppCompatTextView = bindClass "androidx.appcompat.widget.AppCompatTextView"
local AppCompatImageView = bindClass "androidx.appcompat.widget.AppCompatImageView"
local MaterialCardView = bindClass "com.google.android.material.card.MaterialCardView"
local Utils = require "utils.Utils"

return {
  LinearLayoutCompat,
  layout_width = -1,
  orientation = "vertical",
  {
    MaterialCardView,
    layout_marginLeft = "14dp",
    layout_marginRight = "14dp",
    layout_width = -1,
    --StrokeColor = Colors.colorSurfaceVariant,
    id = "card",
    {
      LinearLayoutCompat,
      layout_width = -1,
      orientation = "vertical",
      {
        LinearLayoutCompat,
        layout_width = -1,
        --layoutTransition = newLayoutTransition(),
        {
          MaterialCardView,
          radius = 360,
          StrokeWidth = 0,
          layout_margin = "12dp",
          layout_width = "40dp",
          layout_height = "40dp",
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
              CardBackgroundColor = Utils.setColorAlpha(Colors.colorError, 40),
              {
                AppCompatTextView,
                layout_height = -1,
                gravity = "center",
                id = "price",
                textSize = "10sp",
                maxLines = "1",
                ellipsize = "end",
                textColor = Colors.colorError,
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
        LinearLayoutCompat,
        layout_width = -1,
        layout_height = -1,
        orientation = "vertical",
        {
          AppCompatTextView,
          id = "title",
          maxLines = "2",
          ellipsize = "end",
          layout_marginTop = 0,
          textColor = Colors.colorOnBackground,
          layout_margin = "12dp",
        },
        {
          AppCompatTextView,
          id = "content",
          textSize = "13sp",
          layout_marginTop = 0,
          maxLines = "3",
          ellipsize = "end",
          textColor = Colors.colorOnBackground,
          layout_margin = "12dp",
        }
      },
      {
        LinearLayoutCompat,
        layout_marginTop = 0,
        layout_margin = "12dp",
        layout_width = -1,
        gravity = "center",
        {
          LinearLayoutCompat,
          gravity = "center",
          layout_weight = 1,
          {
            AppCompatImageView,
            layout_width = "20dp",
            ColorFilter = Colors.colorOnBackground,
            layout_height = "20dp",
            src = "res/drawable/ic_thumb_up_outline.png",
          },
          {
            AppCompatTextView,
            gravity = "center",
            layout_marginLeft = "6dp",
            id = "thumb",
          },
        },
        {
          LinearLayoutCompat,
          gravity = "center",
          layout_weight = 1,
          {
            AppCompatImageView,
            ColorFilter = Colors.colorOnBackground,
            layout_width = "22dp",
            layout_height = "22dp",
            src = "res/drawable/ic_star_outline.png",
          },
          {
            AppCompatTextView,
            gravity = "center",
            layout_marginLeft = "6dp",
            id = "star",
          },
        },
        {
          LinearLayoutCompat,
          gravity = "center",
          layout_weight = 1,
          {
            AppCompatImageView,
            layout_width = "20dp",
            ColorFilter = Colors.colorOnBackground,
            layout_height = "20dp",
            src = "res/drawable/ic_comment_processing_outline.png",
          },
          {
            AppCompatTextView,
            gravity = "center",
            layout_marginLeft = "6dp",
            id = "reply",
          },
        },
        
        {
          LinearLayoutCompat,
          gravity = "center",
          layout_weight = 1,
          {
            AppCompatImageView,
            layout_width = "22dp",
            ColorFilter = Colors.colorOnBackground,
            layout_height = "22dp",
            src = "res/drawable/ic_eye_outline.png",
          },
          {
            AppCompatTextView,
            gravity = "center",
            layout_marginLeft = "6dp",
            id = "view_count",
          },
        },
      },
    },
  },
}