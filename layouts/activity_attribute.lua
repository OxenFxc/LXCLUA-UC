local bindClass = luajava.bindClass
local CoordinatorLayout = bindClass "androidx.coordinatorlayout.widget.CoordinatorLayout"
local RecyclerView = bindClass "androidx.recyclerview.widget.RecyclerView"
local LinearLayoutCompat = bindClass "androidx.appcompat.widget.LinearLayoutCompat"
local MaterialTextField = bindClass "com.difierline.lua.material.textfield.MaterialTextField"
local NestedScrollView = bindClass "androidx.core.widget.NestedScrollView"
local MaterialCardView = bindClass "com.google.android.material.card.MaterialCardView"
local AppCompatImageView = bindClass "androidx.appcompat.widget.AppCompatImageView"
local MaterialSwitchBar = bindClass "com.difierline.lua.material.switches.MaterialSwitchBar"
local MaterialButton = bindClass "com.google.android.material.button.MaterialButton"
local ExtendedFloatingActionButton = bindClass "com.google.android.material.floatingactionbutton.ExtendedFloatingActionButton"

return {
  CoordinatorLayout,
  layout_width = -1,
  layout_height = -1,
  require "layouts.appbar_layout"(res.string.attribute),
  {
    NestedScrollView,
    layout_behavior = "appbar_scrolling_view_behavior",
    layout_width = -1,
    layout_height = -1,
    {
      LinearLayoutCompat,
      layout_width = -1,
      layout_height = -1,
      orientation = "vertical",
      LayoutTransition = newLayoutTransition(),
      {
        MaterialCardView,
        layout_height = "60dp",
        layout_width = "60dp",
        layout_margin = "16dp",
        layout_marginBottom = 0,
        radius = 360,
        --StrokeColor = Colors.colorSurfaceVariant,
        layout_gravity = "center",
        {
          AppCompatImageView,
          layout_height = -1,
          layout_width = -1,
          scaleType = "centerCrop",
          src = "ic_launcher_playstore.png",
          id = "icon",
        },
      },
      {
        MaterialTextField,
        layout_width = -1,
        hint = res.string.name_of_project,
        BoxCornerRadii = "12dp",
        layout_margin = "16dp",
        layout_marginBottom = 0,
        id = "name_of_project",
        singleLine = true,
      },
      {
        MaterialTextField,
        layout_width = -1,
        hint = res.string.project_package_name,
        BoxCornerRadii = "12dp",
        layout_margin = "16dp",
        layout_marginBottom = 0,
        id = "project_package_name",
        singleLine = true,
      },
      {
        LinearLayoutCompat,
        layout_width = -1,
        {
          MaterialTextField,
          layout_width = -1,
          layout_weight = 1,
          hint = res.string.edition,
          BoxCornerRadii = "12dp",
          layout_margin = "16dp",
          layout_marginBottom = 0,
          layout_marginRight = "8dp",
          id = "edition",
          singleLine = true,
        },
        {
          MaterialTextField,
          layout_width = -1,
          layout_weight = 1,
          hint = res.string.version_no,
          BoxCornerRadii = "12dp",
          layout_margin = "16dp",
          layout_marginBottom = 0,
          layout_marginLeft = "8dp",
          id = "version_no",
          singleLine = true,
        },
      },
      {
        MaterialTextField,
        layout_width = -1,
        hint = "SDK[" .. res.string.min .. "/" .. res.string.target .. "]",
        BoxCornerRadii = "12dp",
        layout_margin = "16dp",
        layout_marginBottom = 0,
        id = "sdk",
        singleLine = true,
      },
      {
        MaterialTextField,
        layout_width = -1,
        hint = "ShareId（相同ShareId的应用可共享数据）",
        BoxCornerRadii = "12dp",
        layout_margin = "16dp",
        layout_marginBottom = 0,
        id = "share_id",
        singleLine = true,
      },
      {
        MaterialSwitchBar,
        layout_width = -1,
        id = "debugmode",
        textColor = Colors.colorOnPrimaryContainer,
        text = res.string.debugmode,
        layout_margin = "16dp",
        Checked = true,
        layout_marginBottom = "16dp",
      },
      {
        MaterialButton,
        text = res.string.change_permission,
        layout_width = -1,
        layout_margin = "16dp",
        id = "app_permission",
      }
    }
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
    text = res.string.save,
    IconResource = R.drawable.ic_check,
    layout_gravity = "end|bottom"
  },
}