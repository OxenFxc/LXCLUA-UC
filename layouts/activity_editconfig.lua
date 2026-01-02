local bindClass = luajava.bindClass
local CoordinatorLayout = bindClass "androidx.coordinatorlayout.widget.CoordinatorLayout"
local RecyclerView = bindClass "androidx.recyclerview.widget.RecyclerView"
local LinearLayoutCompat = bindClass "androidx.appcompat.widget.LinearLayoutCompat"
local CodeEditor = bindClass "io.github.rosemoe.sora.widget.CodeEditor"
local NestedScrollView = bindClass "androidx.core.widget.NestedScrollView"
local MaterialCardView = bindClass "com.google.android.material.card.MaterialCardView"
local AppCompatTextView = bindClass "androidx.appcompat.widget.AppCompatTextView"
local AppCompatImageView = bindClass "androidx.appcompat.widget.AppCompatImageView"
local FrameLayout = bindClass "android.widget.FrameLayout"
local MaterialButton = bindClass "com.google.android.material.button.MaterialButton"

return {
  CoordinatorLayout,
  layout_width = -1,
  layout_height = -1,
  require "layouts.appbar_layout"(res.string.edit_config),
  {
    NestedScrollView,
    layout_width = -1,
    layout_behavior = "appbar_scrolling_view_behavior",
    {
      LinearLayoutCompat,
      layout_height = -1,
      layout_width = -1,
      orientation = "vertical",
      --LayoutTransition = newLayoutTransition(),
      {
        MaterialCardView,
        layout_width = -1,
        layout_margin = "16dp",
        layout_marginBottom = 0,
        {
          FrameLayout,
          layout_width = -1,
          --LayoutTransition = newLayoutTransition(),
          {
            CodeEditor,
            layout_width = -1,
            --layout_height = "100dp",
            id = "editor",
            text = [[-- 类名
TextView

-- 局部变量
local text = "default"

-- 关键词
local if then else end function return true false nil

-- 函数名
function setText()
  --缩进
end

-- 十六进制色值
0xFFFF0000 0xFFFF00
0xFF0000FF 0xFF00FF
#FFFF0000 #FFFF00
#FF0000FF #FF00FF]]
          },
          {
            MaterialButton,
            layout_gravity = "end",
            layout_margin = "8dp",
            IconResource = MDC_R.drawable.ic_expand_more_22px,
            style = MDC_R.attr.materialIconButtonOutlinedStyle,
            id = "expand",
          },
        },
      },

      {
        RecyclerView,
        layout_width = -1,
        id = "recycler_view",
        paddingTop = "12dp",
      },
    },
  }
}