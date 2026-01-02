local bindClass = luajava.bindClass
local LinearLayoutCompat = bindClass "androidx.appcompat.widget.LinearLayoutCompat"
local MaterialCardView = bindClass "com.google.android.material.card.MaterialCardView"
local AppCompatImageView = bindClass "androidx.appcompat.widget.AppCompatImageView"
local AppCompatTextView = bindClass "androidx.appcompat.widget.AppCompatTextView"

return {
  LinearLayoutCompat,
  layout_height = -2,
  layout_width = -1,
  gravity = "center",
  orientation = "vertical",
  {
    MaterialCardView,
    layout_margin = "16dp",
    StrokeWidth = 0,
    radius = "8dp",
    id = "card",
    {
      LinearLayoutCompat,
      layout_height = -1,
      layout_width = -1,
      gravity = "center",
      orientation = "vertical",
      {
        MaterialCardView,
        layout_height = -1,
        layout_width = -2,
        layout_marginBottom = "8dp",
        --StrokeColor = Colors.colorSurfaceVariant,
        layout_marginLeft = "16dp",
        layout_marginRight = "16dp",
        layout_marginTop = "16dp",
        radius = "8dp",
        {
          AppCompatImageView,
          layout_height = "140dp",
          layout_width = "95dp",
          scaleType = "centerCrop",
          id = "icon",
        },
      },
      {
        AppCompatTextView,
        layout_width = -1,
        gravity = "center",
        layout_margin = "8dp",
        ellipsize = "middle",
        textColor = Colors.colorOnBackground,
        maxLines = 1,
        id = "name",
      },
    },
    {
      MaterialCardView,
      layout_height = "36dp",
      layout_width = "36dp",
      radius = 360,
      id = "check",
      --StrokeColor = Colors.colorSurfaceVariant,
      layout_gravity = "center",

      {
        AppCompatImageView,
        layout_height = -1,
        layout_width = -1,
        ImageResource = R.drawable.ic_check,
        layout_margin = "8dp",
        ColorFilter = Colors.colorPrimary,
      },
    },
  },
}