local bindClass = luajava.bindClass
local LinearLayoutCompat = bindClass "androidx.appcompat.widget.LinearLayoutCompat"
local BottomSheetDragHandleView = bindClass "com.google.android.material.bottomsheet.BottomSheetDragHandleView"
local MaterialCardView = bindClass "com.difierline.lua.material.card.MaterialCardView"
local AppCompatTextView = bindClass "androidx.appcompat.widget.AppCompatTextView"
local AppCompatImageView = bindClass "androidx.appcompat.widget.AppCompatImageView"
local FrameLayout = bindClass "android.widget.FrameLayout"
local Typeface = bindClass "android.graphics.Typeface"
local MaterialButton = bindClass "com.google.android.material.button.MaterialButton"
local FrameLayout = bindClass "android.widget.FrameLayout"
local LinearProgressIndicator = bindClass "com.google.android.material.progressindicator.LinearProgressIndicator"
local NestedScrollView = bindClass "androidx.core.widget.NestedScrollView"
local packageInfo = activity.getPackageManager().getPackageInfo(activity.getPackageName(), 0)

return {
  FrameLayout,
  layout_height = -1,
  layout_width = -1,
  {
    LinearLayoutCompat,
    layout_height = -1,
    layout_width = -1,
    orientation = "vertical",
    LayoutTransition = newLayoutTransition(true),
    {
      BottomSheetDragHandleView,
      layout_width = -1,
    },
    {
      MaterialCardView,
      layout_height = "55dp",
      layout_width = "55dp",
      CardBackgroundColor = Colors.colorPrimary,
      StrokeWidth = 0,
      --StrokeColor = Colors.colorSurfaceVariant,
      layout_gravity = "center",
      {
        AppCompatImageView,
        layout_height = -1,
        layout_width = -1,
        src = "ic_launcher_playstore.png",
      }
    },
    {
      AppCompatTextView,
      ellipsize = "end",
      textSize = "16sp",
      layout_margin = "16dp",
      textColor = Colors.colorOnBackground,
      maxLines = "1",
      Typeface = Typeface.DEFAULT_BOLD,
      layout_gravity = "center",
      id = "title_filename"
    },
    {
      AppCompatTextView,
      text = res.string.update_content .. ":",
      textColor = Colors.colorPrimary,
      Typeface = Typeface.DEFAULT_BOLD,
      layout_marginLeft = "22dp",
      layout_marginRight = "22dp",
    },
    {
      NestedScrollView,
      layout_width = -1,
      layout_marginTop = "16dp",
      layout_marginLeft = "22dp",
      layout_marginRight = "22dp",
      layout_weight = 1,
      {
        AppCompatTextView,
        id = "update_content",
        layout_width = -1,
        layout_height = -1,
      },
    },
    {
      LinearLayoutCompat,
      layout_width = -1,
      Visibility = 8,
      layout_marginLeft = "22dp",
      layout_marginRight = "22dp",
      layout_marginTop = "16dp",
      orientation = "vertical",
      {
        AppCompatTextView,
        layout_gravity = "end",
        textSize = "13sp",
        id = "progresssize",
      },
      {
        LinearProgressIndicator,
        layout_width = -1,
        id = "progressindicator",
      },
    },
    {
      FrameLayout,
      layout_width = -1,
      layout_margin = "16dp",
      {
        MaterialButton,
        text = res.string.ignore_this_time,
        style = MDC_R.attr.materialButtonOutlinedStyle,
        StrokeWidth = 0,
        id = "ignore_this_time",
      },
      {
        LinearLayoutCompat,
        layout_gravity = "end",
        {
          MaterialButton,
          text = res.string.no,
          id = "no",
          layout_marginRight = "8dp",
          style = MDC_R.attr.materialButtonOutlinedStyle,
        },
        {
          MaterialButton,
          text = res.string.update,
          id = "update",
          layout_gravity = "end",
        },
      },
    },
  }
}