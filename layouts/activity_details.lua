local bindClass = luajava.bindClass
local CoordinatorLayout = bindClass "androidx.coordinatorlayout.widget.CoordinatorLayout"
local AppBarLayout = bindClass "com.google.android.material.appbar.AppBarLayout"
local MaterialToolbar = bindClass "com.google.android.material.appbar.MaterialToolbar"
local LinearLayoutCompat = bindClass "androidx.appcompat.widget.LinearLayoutCompat"
local CodeEditor = bindClass "io.github.rosemoe.sora.widget.CodeEditor"
local MaterialCardView = bindClass "com.google.android.material.card.MaterialCardView"
local AppCompatImageView = bindClass "androidx.appcompat.widget.AppCompatImageView"
local AppCompatTextView = bindClass "androidx.appcompat.widget.AppCompatTextView"
local MaterialDivider = bindClass "com.google.android.material.divider.MaterialDivider"
local ViewPager = bindClass "androidx.viewpager.widget.ViewPager"
local FrameLayout = bindClass "android.widget.FrameLayout"
local TabLayout = bindClass "com.google.android.material.tabs.TabLayout"
local RecyclerView = bindClass "androidx.recyclerview.widget.RecyclerView"
local SwipeRefreshLayout = bindClass "androidx.swiperefreshlayout.widget.SwipeRefreshLayout"
local TextInputLayout = bindClass"com.google.android.material.textfield.TextInputLayout"
local FloatingActionButton = bindClass "com.google.android.material.floatingactionbutton.FloatingActionButton"
local TextInputEditText = bindClass"com.google.android.material.textfield.TextInputEditText"
local MaterialButton = bindClass "com.google.android.material.button.MaterialButton"
local LinearProgressIndicator = bindClass "com.google.android.material.progressindicator.LinearProgressIndicator"
local Utils = require "utils.Utils"
local UiUtil = bindClass "com.difierline.lua.luaappx.utils.UiUtil"

local function MyViewPager()
  return luajava.override(ViewPager,{
    onInterceptTouchEvent = function(super,event) return false end,
    onTouchEvent = function(super,event) return false end
  })
end

return {
  CoordinatorLayout,
  layout_width = -1,
  layout_height = -1,
  {
    AppBarLayout,
    id = "appbar",
    liftOnScroll = true,
    fitsSystemWindows = true,
    layout_width = -1,
    {
      MaterialToolbar,
      id = "toolbar",
      layout_width = -1,
      backgroundColor = Colors.colorSurfaceContainer,
      layout_scrollFlags = 3,
      layout_height = UiUtil.getActionBarSize(activity) + dp2px(8),
    },
    {
      TabLayout,
      layout_width = -1,
      layout_scrollFlags = 1,
      TabMode = 0,
      id = "tabs",
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
      MyViewPager,
      id = "cvpg",
      layout_width = -1,
      layout_height = -1,
      pagesWithTitle = {
        {
          {
            LinearLayoutCompat,
            orientation = "vertical",
            layout_width = -1,
            layout_height = -1,
            LayoutTransition = newLayoutTransition(),
            {
              LinearLayoutCompat,
              layout_width = -1,
              LayoutTransition = newLayoutTransition(),
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
                  AppCompatTextView,
                  id = "nick",
                  textColor = Colors.colorOnBackground,
                },
                {
                  LinearLayoutCompat,
                  layout_marginTop = "4dp",
                  {
                    MaterialCardView,
                    layout_height = "20dp",
                    layout_marginRight = "8dp",
                    StrokeWidth = 0,
                    Visibility = 8,
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
              },
              {
                LinearLayoutCompat,
                layout_width = -1,
                layout_height = -1,
                paddingRight = "12dp",
                gravity = "end|center",
                {
                  MaterialCardView,
                  id = "file",
                  --StrokeColor = Colors.colorSurfaceVariant,
                  CardBackgroundColor = 0,
                  layout_marginRight = "12dp",
                  layout_width = "38dp",
                  layout_height = "38dp",
                  radius = 360,
                  {
                    AppCompatImageView,
                    padding = "8dp",
                    layout_width = -1,
                    layout_height = -1,
                    ColorFilter = Colors.colorOnSurfaceVariant,
                    src = "res/drawable/ic_zip_box_outline.png",
                  }
                },
                {
                  MaterialCardView,
                  --StrokeColor = Colors.colorSurfaceVariant,
                  CardBackgroundColor = 0,
                  layout_marginRight = "12dp",
                  layout_width = "38dp",
                  layout_height = "38dp",
                  radius = 360,
                  {
                    AppCompatImageView,
                    padding = "8dp",
                    id = "thumb",
                    layout_width = -1,
                    layout_height = -1,
                    ColorFilter = Colors.colorOnSurfaceVariant,
                    src = "res/drawable/ic_thumb_up_outline.png",
                  }
                },
                {
                  MaterialCardView,
                  --StrokeColor = Colors.colorSurfaceVariant,
                  CardBackgroundColor = 0,
                  layout_width = "38dp",
                  layout_height = "38dp",
                  radius = 360,
                  {
                    AppCompatImageView,
                    padding = "8dp",
                    id = "star",
                    layout_width = -1,
                    layout_height = -1,
                    ColorFilter = Colors.colorOnSurfaceVariant,
                    src = "res/drawable/ic_star_outline.png",
                  }
                },
              },
            },
            {
              MaterialDivider,
              --DividerColor = Colors.colorSurfaceVariant,
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
          {
            LinearLayoutCompat,
            layout_width = -1,
            layout_height = -1,
            orientation = "vertical",
            {
              SwipeRefreshLayout,
              layout_width = -1,
              layout_height = -1,
              layout_weight = 1,
              id = "mSwipeRefreshLayout",
              {
                RecyclerView,
                id="recylerView",
                layout_width = -1,
                layout_height = -1,
              },
            },
            {
              LinearLayoutCompat,
              backgroundDrawable = createCornerGradientDrawable(true, Colors.colorBackground, Colors.colorSurfaceVariant, dp2px(16), 0, dp2px(1)),
              layout_width = -1,
              layout_margin = "-1dp",
              gravity = "center",
              {
                LinearLayoutCompat,
                layout_margin = "8dp",
                layout_marginRight = 0,
                layout_width = -1,
                layout_weight = 1,
                {
                  TextInputLayout,
                  id = "comment",
                  layout_width = -1,
                  hint = res.string.comment_tip,
                  HelperText = res.string.comment_alert,
                  layout_width = "fill",
                  {
                    TextInputEditText,
                    id = "comment_txt",
                    textSize = "15sp",
                    maxLines = "4",
                    layout_width = "fill"
                  },
                },
              },
              {
                FloatingActionButton,
                id = "fab",
                layout_margin = "8dp",
                src = "res/drawable/ic_send_check_outline.png",
              },
            },
          },
          {
            LinearLayoutCompat,
            layout_width = -1,
            layout_height = -1,
            orientation = "vertical",
            {
              SwipeRefreshLayout,
              id = "buyersSwipeRefresh",
              layout_width = -1,
              layout_height = -1,
              {
                RecyclerView,
                id = "buyersRecyclerView",
                layout_width = -1,
                layout_height = -1,
              }
            }
          }
        },
        {
          res.string.code,
          res.string.comment,
          res.string.purchased_post
        }
      }
    }
  }
}