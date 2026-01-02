local bindClass = luajava.bindClass
local AppBarLayout = bindClass"com.google.android.material.appbar.AppBarLayout"
local CollapsingToolbarLayout = bindClass"com.google.android.material.appbar.CollapsingToolbarLayout"
local MaterialToolbar = bindClass"com.google.android.material.appbar.MaterialToolbar"
local SubtitleCollapsingToolbarLayout = bindClass"com.google.android.material.appbar.SubtitleCollapsingToolbarLayout"
local UiUtil = bindClass "com.difierline.lua.luaappx.utils.UiUtil"

return function (title, code, view)
  if activity.getSharedData("collapse_toolbar") then
    return {
      AppBarLayout,
      fitsSystemWindows = true,
      layout_width = - 1,
      layout_height = -2,
      {
        MaterialToolbar,
        id = "toolbar",
        layout_width = - 1,
        layout_height = -2,
        backgroundColor = Colors.colorSurfaceContainer,
        layout_scrollFlags = 3,
        title = title
      },
    }
   elseif code then
    return {
      AppBarLayout,
      layout_width = - 1,
      liftOnScroll = true,
      fitsSystemWindows = true,
      {
        SubtitleCollapsingToolbarLayout,
        layout_width = - 1,
        ExpandedTitleMarginStart = "16dp",
        ContentScrimColor = Colors.colorSurfaceContainer,
        layout_height = "200dp",
        ExpandedTitleTextAppearance = R.style.TextAppearance_SubTitle2,
        CollapsedTitleTextAppearance = R.style.TextAppearance_SubTitle,
        layout_scrollFlags = 3,
        CollapsedSubtitleTextAppearance = R.style.TextAppearance_SubTitle4,
        ExpandedSubtitleTextAppearance = R.style.TextAppearance_SubTitle4,
        {
          MaterialToolbar,
          id = "toolbar",
          layout_collapseMode = "pin",
          layout_width = - 1,
          layout_height = UiUtil.getActionBarSize(activity) + dp2px(8),
        },
      },
    }
   else
    return {
      AppBarLayout,
      liftOnScroll = true,
      fitsSystemWindows = true,
      layout_width = -1,
      id = "appbar",
      {
        CollapsingToolbarLayout,
        layout_width = -1,
        layout_height = "140dp",
        ExpandedTitleTextAppearance = R.style.TextAppearance_SubTitle2,
        layout_scrollFlags = 3,
        title = title,
        CollapsedTitleTextAppearance = R.style.TextAppearance_SubTitle,
        TitleCollapseMode = 2,
        {
          MaterialToolbar,
          id = "toolbar",
          layout_width = -1,
          layout_collapseMode = "pin",
          layout_height = UiUtil.getActionBarSize(activity) + dp2px(8),
        },
      },
      view,
    }
  end
end