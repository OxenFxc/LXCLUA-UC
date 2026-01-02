local bindClass = luajava.bindClass
local CoordinatorLayout = bindClass "androidx.coordinatorlayout.widget.CoordinatorLayout"
local LinearLayoutCompat = bindClass "androidx.appcompat.widget.LinearLayoutCompat"
local ExtendedFloatingActionButton = bindClass "com.google.android.material.floatingactionbutton.ExtendedFloatingActionButton"
local NestedScrollView = bindClass "androidx.core.widget.NestedScrollView"
local MaterialCardView = bindClass "com.google.android.material.card.MaterialCardView"
local AppCompatImageView = bindClass "androidx.appcompat.widget.AppCompatImageView"
local MaterialTextField = bindClass "com.difierline.lua.material.textfield.MaterialTextField"
local AppCompatTextView = bindClass "androidx.appcompat.widget.AppCompatTextView"
local RecyclerView = bindClass "androidx.recyclerview.widget.RecyclerView"
local MaterialSwitchBar = bindClass "com.difierline.lua.material.switches.MaterialSwitchBar"

return {
  CoordinatorLayout,
  layout_width = -1,
  layout_height = -1,
  require "layouts.appbar_layout"(res.string.newproject),
  {
    NestedScrollView,
    layout_height = -1,
    layout_width = -1,
    layout_behavior = "appbar_scrolling_view_behavior",
    {
      LinearLayoutCompat,
      layout_height = -1,
      layout_width = -1,
      LayoutTransition = newLayoutTransition(),
      orientation = "vertical",
      {
        MaterialCardView,
        layout_height = "60dp",
        layout_width = "60dp",
        layout_margin = "16dp",
        radius = 360,
        id = "choose",
        --StrokeColor = Colors.colorSurfaceVariant,
        layout_gravity = "center",
        {
          AppCompatImageView,
          layout_height = -1,
          layout_width = -1,
          scaleType = "centerCrop",
          --ImageResource = R.mipmap.ic_launcher,
          src = "ic_launcher_playstore.png",
          id = "icon",
        },
      },
      {
        MaterialTextField,
        layout_width = -1,
        text = "My Application",
        hint = res.string.name_of_project,
        BoxCornerRadii = "12dp",
        layout_marginLeft = "20dp",
        layout_marginRight = "20dp",
        id = "name",
        singleLine = true,
      },
      {
        MaterialTextField,
        layout_width = -1,
        text = "dcore.myapplication",
        hint = res.string.project_package_name,
        BoxCornerRadii = "12dp",
        singleLine = true,
        layout_marginLeft = "20dp",
        layout_marginRight = "20dp",
        layout_marginTop = "14dp",
        id = "package",
      },
      {
        MaterialSwitchBar,
        layout_width = -1,
        id = "debugmode",
        text = res.string.debugmode,
        textColor = Colors.colorOnPrimaryContainer,
        layout_margin = "20dp",
        Checked = true,
        layout_marginBottom = 0,
      },
      {
        AppCompatTextView,
        layout_width = -1,
        gravity = "left",
        layout_margin = "20dp",
        textSize = "16sp",
        textColor = Colors.colorOnBackground,
        text = res.string.template,
      },
      {
        RecyclerView,
        layout_height = -1,
        layout_width = -1,
        layout_marginBottom = "60dp",
        id = "recycler_view",
      },
    },
  },
  {
    LinearLayoutCompat,
    layout_width = -1,
    layout_height = "60dp",
    layout_gravity = "bottom",
    backgroundColor = Colors.colorBackground,
  },
  {
    ExtendedFloatingActionButton,
    layout_margin = "16dp",
    id = "fab",
    text = res.string.new,
    -- textColor = 0xFFFFFFFF,
    IconResource = R.drawable.ic_check,
    layout_gravity = "end|bottom"
  },
}