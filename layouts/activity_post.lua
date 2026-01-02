local bindClass = luajava.bindClass
-- 公共组件绑定
local CoordinatorLayout = bindClass "androidx.coordinatorlayout.widget.CoordinatorLayout"
local AppBarLayout = bindClass "com.google.android.material.appbar.AppBarLayout"
local MaterialToolbar = bindClass "com.google.android.material.appbar.MaterialToolbar"
local LinearLayoutCompat = bindClass "androidx.appcompat.widget.LinearLayoutCompat"
local ExtendedFloatingActionButton = bindClass "com.google.android.material.floatingactionbutton.ExtendedFloatingActionButton"
local MaterialTextField = bindClass "com.difierline.lua.material.textfield.MaterialTextField"
local MaterialCardView = bindClass "com.google.android.material.card.MaterialCardView"
local AppCompatSpinner = bindClass "androidx.appcompat.widget.AppCompatSpinner"
local AppCompatImageView = bindClass "androidx.appcompat.widget.AppCompatImageView"
local HorizontalScrollView = bindClass "android.widget.HorizontalScrollView"
local AppCompatTextView = bindClass "androidx.appcompat.widget.AppCompatTextView"
local Typeface = bindClass "android.graphics.Typeface"
local TextInputLayout = bindClass"com.google.android.material.textfield.TextInputLayout"
local TextInputEditText = bindClass"com.google.android.material.textfield.TextInputEditText"
local UiUtil = bindClass "com.difierline.lua.luaappx.utils.UiUtil"
local FrameLayout = bindClass "android.widget.FrameLayout"
local MaterialButton = bindClass "com.google.android.material.button.MaterialButton"
local MaterialDivider = bindClass "com.google.android.material.divider.MaterialDivider"
local RecyclerView = bindClass "androidx.recyclerview.widget.RecyclerView"
local LinearProgressIndicator = bindClass "com.google.android.material.progressindicator.LinearProgressIndicator"

-- 常量定义
local COMMON_MARGIN = "16dp"
local CARD_STROKE_COLOR = Colors.colorSurfaceVariant

return {
  CoordinatorLayout,
  layout_width = -1,
  layout_height = -1,
  LayoutTransition = newLayoutTransition(),
  {
    AppBarLayout,
    liftOnScroll = true,
    fitsSystemWindows = true,
    layout_width = -1,
    {
      MaterialToolbar,
      id = "toolbar",
      layout_width = -1,
      backgroundColor = Colors.colorSurfaceContainer,
      title = res.string.post,
      layout_scrollFlags = 3,
      layout_height = UiUtil.getActionBarSize(activity) + dp2px(8),
    },
  },
  {
    LinearLayoutCompat,
    orientation = "vertical",
    layout_behavior = "appbar_scrolling_view_behavior",
    layout_width = -1,
    layout_height = -1,
    LayoutTransition = newLayoutTransition(),
    {
      LinearLayoutCompat,
      layout_width = -1,
      gravity = "center|left",
      LayoutTransition = newLayoutTransition(),
      {
        MaterialTextField,
        layout_width = -1,
        layout_weight = 1,
        singleLine = true,
        hint = res.string.title,
        BoxCornerRadii = "12dp",
        layout_margin = "12dp",
        layout_marginRight = "8dp",
        id = "title",
      },
      {
        AppCompatSpinner,
        PopupBackgroundDrawable = createCornerGradientDrawable(false, Colors.colorBackground, Colors.colorSurfaceVariant, dp2px(8), dp2px(8), 0),
        id = "tag",
      },
    },
    {
      MaterialDivider,
      layout_width = -1,
      layout_marginTop = "4dp",
    },
    {
      LinearProgressIndicator,
      layout_width = -1,
      Visibility = 8,
      indeterminate = true,
      id = "init_progress",
    },
    {
      LinearLayoutCompat,
      layout_width = -1,
      layout_height = -1,
      orientation = "vertical",
      LayoutTransition = newLayoutTransition(),
      {
        FrameLayout,
        layout_weight = 1,
        layout_width = -1,
        layout_height = -1,
        LayoutTransition = newLayoutTransition(),
        {
          LinearLayoutCompat,
          layout_width = -1,
          layout_height = -1,
          {
            EditView.getView(),
            id = "editor",
            layout_width = -1,
            layout_height = -1,
          },
        },
        {
          MaterialCardView,
          layout_gravity = "end",
          layout_width = "38dp",
          layout_height = "38dp",
          radius = 360,
          id = "color_value_card",
          --StrokeColor = Colors.colorSurfaceVariant,
          layout_margin = "8dp",
          Visibility = 8,
        },
        {
          ExtendedFloatingActionButton,
          layout_margin = COMMON_MARGIN,
          id = "fab",
          text = res.string.release,
          IconResource = R.drawable.ic_check,
          layout_gravity = "end|bottom"
        },
      },
      {
        LinearLayoutCompat,
        orientation = "vertical",
        layout_width = -1,
        {
          LinearLayoutCompat,
          layout_width = -1,
          id = "search_root",
          backgroundColor = Colors.colorBackground,
          orientation = "vertical",
          Visibility = 8,
          {
            MaterialDivider,
            layout_width = -1,
            --DividerColor = Colors.colorSurfaceVariant,
          },
          {
            LinearLayoutCompat,
            layout_width = -1,
            orientation = "vertical",
            {
              LinearLayoutCompat,
              layout_width = -1,
              backgroundColor = Colors.colorBackground,
              gravity = "center|left",
              {
                TextInputEditText,
                id = "search",
                layout_weight = 1,
                singleLine = true,
                layout_margin = "4dp",
                hint = res.string.text_to_search_for,
                layout_width = "fill"
              },
            },
            {
              TextInputEditText,
              id = "substitution",
              layout_width = -1,
              singleLine = true,
              Visibility = 8,
              layout_margin = "4dp",
              hint = res.string.text_to_be_replaced,
              layout_width = "fill"
            },
            {
              LinearLayoutCompat,
              layout_marginTop = 0,
              layout_margin = "4dp",
              layout_height = "45dp",
              layout_width = -1,
              {
                MaterialButton,
                text = res.string.previous,
                style = MDC_R.attr.materialButtonOutlinedStyle,
                StrokeWidth = 0,
                onClick = function()
                  EditView.gotoPrevMatch()
                end,
              },
              {
                MaterialButton,
                text = res.string.next,
                style = MDC_R.attr.materialButtonOutlinedStyle,
                StrokeWidth = 0,
                onClick = function()
                  EditView.gotoNextMatch()
                end,
              },
              {
                MaterialButton,
                text = res.string.replace_current,
                style = MDC_R.attr.materialButtonOutlinedStyle,
                StrokeWidth = 0,
                onClick = function()
                  if substitution.Visibility == 8 then
                    substitution.Visibility = 0
                   else
                    EditView.replaceCurrentMatch(substitution.text)
                  end
                end,
              },
              {
                MaterialButton,
                text = res.string.shut,
                style = MDC_R.attr.materialButtonOutlinedStyle,
                StrokeWidth = 0,
                onClick = function()
                  EditView.clearSearch()
                end,
              },
            }
          },
        }
      },
      {
        FrameLayout,
        layout_width = -1,
        --layout_height = -1,
        LayoutTransition = newLayoutTransition(),
        {
          LinearLayoutCompat,
          layout_width = -1,
          orientation = "vertical",
          layout_gravity = "bottom",
          backgroundColor = Colors.colorBackground,
          {
            MaterialDivider,
            layout_width = -1,
            --DividerColor = Colors.colorSurfaceVariant,
          },
          {
            LinearLayoutCompat,
            layout_width = -1,
            layout_height = "45dp",
            LayoutTransition = newLayoutTransition(),
            {
              AppCompatTextView,
              layout_height = -1,
              gravity = "center",
              paddingRight = "16dp",
              paddingLeft = "16dp",
              textColor = Colors.colorOnBackground,
              singleLine = true,
              id = "class_find",
              Visibility = 8,
              backgroundDrawable = getRipple(),
            },
            {
              RecyclerView,
              layout_weight = 1,
              layout_height = -1,
              layout_width = -1,
              id = "psbar",
            },
          },
        },
      },
    },
  },
}