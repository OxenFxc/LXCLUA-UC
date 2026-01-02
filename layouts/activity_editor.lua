local bindClass = luajava.bindClass
local CoordinatorLayout = bindClass "androidx.coordinatorlayout.widget.CoordinatorLayout"
local AppBarLayout = bindClass "com.google.android.material.appbar.AppBarLayout"
local MaterialToolbar = bindClass "com.google.android.material.appbar.MaterialToolbar"
local MaterialDivider = bindClass "com.google.android.material.divider.MaterialDivider"
local TabLayout = bindClass "com.google.android.material.tabs.TabLayout"
local DrawerLayout = bindClass "androidx.drawerlayout.widget.DrawerLayout"
local LinearLayoutCompat = bindClass "androidx.appcompat.widget.LinearLayoutCompat"
local FrameLayout = bindClass "android.widget.FrameLayout"
local RecyclerView = bindClass "androidx.recyclerview.widget.RecyclerView"
local MaterialCardView = bindClass "com.google.android.material.card.MaterialCardView"
local FileTreeView = bindClass "com.difierline.lua.luaappx.views.FileTreeView"
local AppCompatTextView = bindClass "androidx.appcompat.widget.AppCompatTextView"
local GradientDrawable = bindClass "android.graphics.drawable.GradientDrawable"
local CodeEditor = bindClass "io.github.rosemoe.sora.widget.CodeEditor"
local AppCompatImageView = bindClass "androidx.appcompat.widget.AppCompatImageView"
local NavigationRailView = bindClass "com.google.android.material.navigationrail.NavigationRailView"
local LinearProgressIndicator = bindClass "com.google.android.material.progressindicator.LinearProgressIndicator"
local MaterialButton = bindClass "com.google.android.material.button.MaterialButton"
local TextInputEditText = bindClass"com.google.android.material.textfield.TextInputEditText"
local HorizontalScrollView = bindClass "android.widget.HorizontalScrollView"
local PopupMenu = bindClass "androidx.appcompat.widget.PopupMenu"
local UiUtil = bindClass "com.difierline.lua.luaappx.utils.UiUtil"
local MaterialBlurDialogBuilder = require "dialogs.MaterialBlurDialogBuilder"

return {
  DrawerLayout,
  id = "drawer",
  layout_width = -1,
  layout_height = -1,
  {
    CoordinatorLayout,
    id = "coordinator",
    layout_width = -1,
    layout_height = -1,
    {
      AppBarLayout,
      layout_width = -1,
      backgroundColor = Colors.colorBackground,
      liftOnScroll = false,
      LayoutTransition = newLayoutTransition(),
      {
        MaterialToolbar,
        id = "toolbar",
        layout_scrollFlags = 3,
        layout_width = -1,
        layout_height = UiUtil.getActionBarSize(activity) + 24,
      },
      {
        LinearLayoutCompat,
        layout_width = -1,
        orientation = "vertical",
        Visibility = 8,
        layout_marginLeft = "12dp",
        layout_marginRight = "12dp",
        LayoutTransition = newLayoutTransition(),
        {
          AppCompatTextView,
          id = "init_text",
        },
        {
          LinearProgressIndicator,
          layout_width = -1,
          indeterminate = true,
          id = "init_progress",
        },
      },
      {
        HorizontalScrollView,
        layout_width = -1,
        id = "function_menu_root",
        Visibility = 8,
        backgroundColor = Colors.colorBackground,
        horizontalScrollBarEnabled = false,
        {
          LinearLayoutCompat,
          layout_width = -1,
          layout_height = -1,
          id = "function_menu",
          paddingLeft = "2dp",
          paddingRight = "2dp",
        },
      },
      {
        TabLayout,
        layout_width = -1,
        TabMode = 0,
        clipToPadding = false,
        inlineLabel = true,
        id = "tabs",
      },
    },
    {
      FrameLayout,
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
          FrameLayout,
          layout_width = -1,
          layout_height = -1,
          layout_weight = 1,
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
            AppCompatTextView,
            padding = "5dp",
            id = "error_text",
            layout_width = -1,
            Visibility = 8,
            layout_gravity = "bottom",
            gravity = "center|left",
            textColor = 0xFFFFFFFF,
            maxLines = "2",
            ellipsize = "end",
            backgroundColor = 0xFFFF0000,
          },
        },
        {
          LinearLayoutCompat,
          orientation = "vertical",
          layout_width = -1,
          layout_marginBottom = "45dp",
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
                {
                  AppCompatImageView,
                  layout_height = -1,
                  layout_margin = "4dp",
                  layout_width = "40dp",
                  padding = "8dp",
                  ColorFilter = Colors.colorPrimary,
                  backgroundDrawable = getRipple(),
                  ImageResource = MDC_R.drawable.material_ic_menu_arrow_down_black_24dp,
                  onClick = function()
                    local new_search_histry = EditorUtil.removeDuplicates(search_histry)
                    MaterialBlurDialogBuilder(activity)
                    .setTitle(res.string.search_record)
                    .setItems(new_search_histry, function(l, v)
                      search.text = tostring(new_search_histry[v+1])
                    end)
                    .setPositiveButton(res.string.empty, function()
                      fileTracker.delProject(db, ProjectName, "SearchHistory")
                      fileTracker.putInProject(db, ProjectName, "SearchHistory", {})
                      search_histry = {}
                    end)
                    .show()
                  end,
                },
                {
                  AppCompatImageView,
                  layout_height = -1,
                  layout_margin = "4dp",
                  layout_width = "40dp",
                  padding = "8dp",
                  ColorFilter = Colors.colorPrimary,
                  backgroundDrawable = getRipple(),
                  ImageResource = AndroidX_R.drawable.abc_ic_menu_overflow_material,
                  onClick = function(v)
                    local pop = PopupMenu(activity, v)
                    local menu = pop.Menu

                    local menuItems = {
                      {
                        title = res.string.case_sensitivity,
                        checked = EditView.searchState.caseSensitive,
                        action = function()
                          EditView.searchState.caseSensitive = not EditView.searchState.caseSensitive
                        end
                      },
                      {
                        title = res.string.whole_word_matching,
                        checked = EditView.searchState.searchType == 2,
                        action = function()
                          EditView.searchState.searchType = EditView.searchState.searchType == 2 and 1 or 2
                        end
                      },
                      {
                        title = res.string.use_regex,
                        checked = EditView.searchState.searchType == 3,
                        action = function()
                          EditView.searchState.searchType = EditView.searchState.searchType == 3 and 1 or 3
                        end
                      }
                    }

                    for _, itemConfig in ipairs(menuItems) do
                      local item = menu.add(itemConfig.title)
                      item.setCheckable(true)
                      item.setChecked((function() switch itemConfig.title
                         case res.string.case_sensitivity
                          return not itemConfig.checked
                         default
                          return itemConfig.checked
                        end
                      end)())
                      item.onMenuItemClick = function()
                        itemConfig.action()
                        if EditView.searchState.active then
                          EditView.refreshSearch()
                        end
                      end
                    end

                    menu.add(res.string.shut).onMenuItemClick = function()
                      EditView.clearSearch()
                    end

                    pop.show()
                  end
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
                  text = res.string.replace_all,
                  style = MDC_R.attr.materialButtonOutlinedStyle,
                  StrokeWidth = 0,
                  id = "replace_all",
                  onClick = function()
                    EditView.replaceAll(substitution.text)
                  end,
                },
              }
            },
            {
              MaterialDivider,
              layout_width = -1,
              --DividerColor = Colors.colorSurfaceVariant,
            },
          }
        },
      },
      {
        FrameLayout,
        layout_width = -1,
        layout_height = -1,
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
    MaterialCardView,
    layout_width = -1,
    layout_height = -1,
    StrokeWidth = 0,
    id = "left",
    backgroundDrawable=GradientDrawable()
    .setShape(0)
    .setColor(Colors.colorSurfaceContainer)
    .setCornerRadii( {
      0, 0, -- 左上 X/Y
      dp2px(18), dp2px(18), -- 右上 X/Y
      dp2px(18), dp2px(18), -- 右下 X/Y
      0, 0 -- 左下 X/Y
    }),
    layout_gravity = "left",
    {
      LinearLayoutCompat,
      layout_width = -1,
      layout_height = -1,
      {
        LinearLayoutCompat,
        layout_height = -1,
        layout_width = "70dp",
        orientation = "vertical",
        Visibility = 8,
        backgroundDrawable = GradientDrawable()
        .setShape(0)
        .setColor(Colors.colorSurfaceContainerHigh)
        .setCornerRadii( {
          0, 0, -- 左上 X/Y
          dp2px(8), dp2px(8), -- 右上 X/Y
          dp2px(8), dp2px(8), -- 右下 X/Y
          0, 0 -- 左下 X/Y
        }),
        {
          NavigationRailView,
          id = "nav",
          layout_height = -2,
          layout_marginBottom = "4dp",
          LabelVisibilityMode = 2,
          layout_width = -1,
          backgroundColor = 0,
        },
      },
      {
        LinearLayoutCompat,
        layout_width = -1,
        layout_height = -1,
        layout_marginBottom = "8dp",
        layout_marginTop = "8dp",
        orientation = "vertical",
        {
          AppCompatTextView,
          textSize = "16sp",
          layout_margin = "12dp",
          textColor = Colors.colorOnBackground,
          text = res.string.file_tree,
        },
        {
          FileTreeView,
          id = "tree",
          layout_width = -1,
          layout_height = -1,
          LineSpace = 0,
          NodeIndent = dp2px(6)
        },
      },
    },
  },
}
