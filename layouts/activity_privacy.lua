local bindClass = luajava.bindClass
local CoordinatorLayout = bindClass "androidx.coordinatorlayout.widget.CoordinatorLayout"
local RecyclerView = bindClass "androidx.recyclerview.widget.RecyclerView"
local LinearLayoutCompat = bindClass "androidx.appcompat.widget.LinearLayoutCompat"
local NestedScrollView = bindClass "androidx.core.widget.NestedScrollView"
local MaterialCardView = bindClass "com.google.android.material.card.MaterialCardView"
local AppCompatImageView = bindClass "androidx.appcompat.widget.AppCompatImageView"
local AppCompatTextView = bindClass "androidx.appcompat.widget.AppCompatTextView"
local SwipeRefreshLayout = bindClass "androidx.swiperefreshlayout.widget.SwipeRefreshLayout"
local RecyclerView = bindClass "androidx.recyclerview.widget.RecyclerView"
local MaterialDivider = bindClass "com.google.android.material.divider.MaterialDivider"
local Typeface = bindClass "android.graphics.Typeface"
local Chip = bindClass "com.google.android.material.chip.Chip"
local ChipGroup = bindClass "com.google.android.material.chip.ChipGroup"
local Utils = require "utils.Utils"
local IconDrawable = require "utils.IconDrawable"

return {
  CoordinatorLayout,
  layout_width = -1,
  layout_height = -1,
  require "layouts.appbar_layout"(res.string.user_home_page),
  {
    LinearLayoutCompat,
    layout_width = -1,
    layout_height = -1,
    orientation = "vertical",
    layout_behavior = "appbar_scrolling_view_behavior",
    LayoutTransition = newLayoutTransition(),
    {
      SwipeRefreshLayout,
      id = "mSwipeRefreshLayout",
      layout_width = -1,
      layout_height = -1,
      {
        LinearLayoutCompat,
        layout_width = -1,
        orientation = "vertical",
        layoutTransition = newLayoutTransition(),
        {
          LinearLayoutCompat,
          layout_width = -1,
          gravity = "center|left",
          {
            MaterialCardView,
            radius = 360,
            CardBackgroundColor = 0xFFE0E0E0,
            layout_width = "60dp",
            layout_height = "60dp",
            layout_margin = "12dp",
            --StrokeColor = Colors.colorSurfaceVariant,
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
              LayoutTransition = newLayoutTransition(),
              {
                AppCompatTextView,
                textSize = "18sp",
                id = "nick",
                maxLines = "1",
                ellipsize = "end",
                textColor = Colors.colorOnBackground,
                Typeface = Typeface.DEFAULT_BOLD,
              },
            },
            {
              LinearLayoutCompat,
              layout_width = -1,
              LayoutTransition = newLayoutTransition(),
              {
                MaterialCardView,
                layout_height = "23dp",
                StrokeWidth = 0,
                Visibility = 8,
                layout_marginRight = "8dp",
                CardBackgroundColor = Utils.setColorAlpha(Colors.colorPrimary, 20),
                {
                  AppCompatTextView,
                  layout_height = -1,
                  gravity = "center",
                  id = "title",
                  text = res.string.administrator,
                  textSize = "12sp",
                  maxLines = "1",
                  ellipsize = "end",
                  textColor = Colors.colorPrimary,
                  paddingRight = "6dp",
                  paddingLeft = "6dp",
                },
              },
              {
                MaterialCardView,
                layout_height = "23dp",
                StrokeWidth = 0,
                layout_marginRight = "12dp",
                layout_marginLeft = 0,
                CardBackgroundColor = Utils.setColorAlpha(Colors.colorError, 20),
                {
                  AppCompatTextView,
                  layout_height = -1,
                  gravity = "center",
                  id = "price",
                  textSize = "12sp",
                  maxLines = "1",
                  ellipsize = "end",
                  textColor = Colors.colorError,
                  paddingRight = "6dp",
                  paddingLeft = "6dp",
                },
              },
            },
          },
        },
        {
          LinearLayoutCompat,
          layout_marginTop = "-6dp",
          layout_marginBottom = "2dp",
          layout_margin = "16dp",
          orientation = "vertical",
          {
            LinearLayoutCompat,
            --layout_marginBottom = "8dp",
            {
              Chip,
              ChipIcon = IconDrawable("ic_alarm", Colors.colorOnBackground),
              id = "member_since",
            },
          },
          {
            LinearLayoutCompat,
            Visibility = 8,
            layout_marginTop = "-8dp",
            layout_marginBottom = "0dp",
            {
              Chip,
              ChipIcon = IconDrawable("ic_email_outline", Colors.colorOnBackground),
              id = "email",
              --Visibility = 8,             
            },
            {
              Chip,
              chipEndPadding="-8dp",
              id = "is_banned",
            },
          },
        },
        {
          MaterialDivider,
        },
        {
          RecyclerView,
          layout_width = -1,
          layout_height = -1,
          id = "recycler_code",
        }
      },
    }
  }
}