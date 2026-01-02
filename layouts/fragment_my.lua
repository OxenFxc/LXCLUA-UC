local bindClass = luajava.bindClass
local NestedScrollView = bindClass "androidx.core.widget.NestedScrollView"
local LinearLayoutCompat = bindClass "androidx.appcompat.widget.LinearLayoutCompat"
local MaterialCardView = bindClass "com.google.android.material.card.MaterialCardView"
local MaterialDivider = bindClass "com.google.android.material.divider.MaterialDivider"
local AppCompatImageView = bindClass "androidx.appcompat.widget.AppCompatImageView"
local AppCompatTextView = bindClass "androidx.appcompat.widget.AppCompatTextView"
local SwipeRefreshLayout = bindClass "androidx.swiperefreshlayout.widget.SwipeRefreshLayout"
local Typeface = bindClass "android.graphics.Typeface"
local RecyclerView = bindClass "androidx.recyclerview.widget.RecyclerView"
local MaterialButton = bindClass "com.google.android.material.button.MaterialButton"
local ColorStateList = bindClass "android.content.res.ColorStateList"
local Utils = require "utils.Utils"
local IconDrawable = require "utils.IconDrawable"

return {
  SwipeRefreshLayout,
  layout_width = -1,
  layout_height = -1,
  id = "mSwipeRefreshLayout3",
  {
    NestedScrollView,
    layout_height = -1,
    layout_width = -1,
    {
      LinearLayoutCompat,
      layout_height = -1,
      layout_width = -1,
      LayoutTransition = newLayoutTransition(),
      orientation = "vertical",
      {
        MaterialCardView,
        StrokeWidth = 0,
        layout_margin = "18dp",
        layout_marginBottom = "4dp",
        layout_width = -1,
        id = "login",
        radius = 0,
        backgroundDrawable = createCornerGradientDrawable(true, Colors.colorBackground, Colors.colorOutlineVariant, dp2px(12), getSQLite(1) and 0 or dp2px(12)),
        {
          LinearLayoutCompat,
          layout_width = -1,
          gravity = "center|left",
          layoutTransition = newLayoutTransition(),
          {
            MaterialCardView,
            radius = 360,
            layout_margin = "12dp",
            CardBackgroundColor = 0xFFE0E0E0,
            layout_width = "60dp",
            layout_height = "60dp",
            id = "logo2",
            StrokeWidth = 0,
            layoutTransition = newLayoutTransition(),
            {
              AppCompatImageView,
              layout_width = -1,
              layout_height = -1,
              id = "logo",
              ImageResource = R.drawable.avatar_placeholder,
              scaleType = "centerCrop",
            },
          },
          {
            LinearLayoutCompat,
            layout_weight = 1,
            layout_marginRight = "12dp",
            orientation = "vertical",
            layout_marginLeft = "4dp",
            {
              LinearLayoutCompat,
              layout_marginBottom = "2dp",
              layout_width = -1,
              layout_height = -1,
              {
                AppCompatTextView,
                textSize = "18sp",
                id = "nick",
                maxLines = "1",
                ellipsize = "end",
                textColor = Colors.colorOnBackground,
                Typeface = Typeface.DEFAULT_BOLD,
              },
              {
                MaterialCardView,
                layout_height = "25dp",
                StrokeWidth = 0,
                Visibility = 8,
                layout_marginLeft = "12dp",
                CardBackgroundColor = Utils.setColorAlpha(Colors.colorPrimary, 20),
                {
                  AppCompatTextView,
                  layout_height = -1,
                  gravity = "center",
                  id = "title",
                  text = res.string.administrator,
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
              layout_marginTop = "2dp",
              id = "email",
              Visibility = 8,
            },
          },
          {
            LinearLayoutCompat,
            layout_marginRight = "12dp",
            Visibility = 8,
            gravity = "end",
            LayoutTransition = newLayoutTransition(),            
            {
              MaterialButton,              
              id = "check",
              style = MDC_R.attr.materialIconButtonOutlinedStyle,
              Icon = IconDrawable("ic_calendar_check_outline"),
            },
          },
        },
      },
      {
        MaterialCardView,
        layout_margin = "18dp",
        layout_marginTop = "4dp",
        layout_width = -1,
        StrokeWidth = 0,
        backgroundDrawable = createCornerGradientDrawable(true, Colors.colorBackground, Colors.colorOutlineVariant, 0, dp2px(12)),
        {
          RecyclerView,
          layout_width = -1,
          layout_height = -1,
          id = "recycler_view_my",
        }
      },
    },
  },
}