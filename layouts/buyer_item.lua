local bindClass = luajava.bindClass
local AppCompatTextView = bindClass "androidx.appcompat.widget.AppCompatTextView"
local AppCompatImageView = bindClass "androidx.appcompat.widget.AppCompatImageView"
local LinearLayoutCompat = bindClass "androidx.appcompat.widget.LinearLayoutCompat"
local MaterialCardView = bindClass "com.google.android.material.card.MaterialCardView"

return {
  LinearLayoutCompat,
  layout_width = -1,
  orientation = "vertical",
  {
    MaterialCardView,
    layout_width = -1,
    layout_marginLeft = "14dp",
    layout_marginRight = "14dp",
    id = "card",
    --StrokeColor = Colors.colorSurfaceVariant,
    {
      LinearLayoutCompat,
      layout_width = -1,
      layout_height = -1,
      padding = "12dp",
      gravity = "center",
      {
        MaterialCardView,
        radius = 360,
        StrokeWidth = 0,
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
        layout_marginLeft = "16dp",
        layout_weight = 1,
        {
          AppCompatTextView,
          id = "nick",
          textColor = Colors.colorOnBackground,
        },
        {
          AppCompatTextView,
          id = "time",
          textSize = "12sp",
          textColor = Colors.colorOnSurfaceVariant,
          layout_marginTop = "4dp",
        },
      },
    }
  }
}