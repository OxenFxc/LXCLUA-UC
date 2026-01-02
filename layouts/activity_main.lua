local bindClass = luajava.bindClass
local CoordinatorLayout = bindClass "androidx.coordinatorlayout.widget.CoordinatorLayout"
local FragmentContainerView = bindClass "androidx.fragment.app.FragmentContainerView"
local BottomNavigationView = bindClass "com.google.android.material.bottomnavigation.BottomNavigationView"
local FloatingActionButton = bindClass "com.google.android.material.floatingactionbutton.FloatingActionButton"
local FabAboveBottomNavBehavior = bindClass "com.difierline.lua.luaappx.behavior.FabAboveBottomNavBehavior"(activity, nil)
local BottomNavigationBehavior = luajava.newInstance "com.difierline.lua.luaappx.behavior.BottomNavigationBehavior"
local HideBottomNavigationBehavior = luajava.newInstance "com.difierline.lua.luaappx.behavior.HideBottomNavigationBehavior"
local Utils = require "utils.Utils"

return {
  CoordinatorLayout,
  layout_width = -1,
  layout_height = -1,
  require "layouts.appbar_layout"(),
  {
    FragmentContainerView,
    id = "mfragment",
    layout_behavior = "appbar_scrolling_view_behavior",
    layout_width = -1,
    layout_height = -1,
  },
  {
    BottomNavigationView,
    id = "bottombar",
    layout_width = -1,
    layout_behavior = (function() if activity.getSharedData("offline_mode") return HideBottomNavigationBehavior else return BottomNavigationBehavior end end)(),
    backgroundColor = Utils.setColorAlpha(Colors.colorSurfaceContainer, 225),
    layout_gravity = "bottom",
    LabelVisibilityMode = 0,
  },
  {
    FloatingActionButton,
    id = "fab",
    layout_behavior = FabAboveBottomNavBehavior,
    ImageResource = R.drawable.ic_add,
  },
}