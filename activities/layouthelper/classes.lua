local bindClass = luajava.bindClass
local File = bindClass "java.io.File"

local SharedPrefUtil = require "utils.SharedPrefUtil"

local classes_table = SharedPrefUtil.getTable("classes_table")  or {}

local function importClass(fullName)
  local shortName = fullName:match("[%w_]+$") -- 取最后一段
  _G[shortName] = bindClass(fullName) -- 直接放到全局
end

-- 类名列表
local classNames = {
  "androidx.appcompat.widget.AppCompatButton",
  "androidx.appcompat.widget.AppCompatEditText",
  "androidx.appcompat.widget.AppCompatTextView",
  "androidx.appcompat.widget.AppCompatImageView",
  "androidx.appcompat.widget.AppCompatCheckBox",
  "androidx.appcompat.widget.AppCompatRadioButton",
  "androidx.appcompat.widget.AppCompatSpinner",
  "androidx.appcompat.widget.AppCompatSeekBar",
  "androidx.appcompat.widget.AppCompatImageButton",
  "androidx.appcompat.widget.AppCompatAutoCompleteTextView",
  "androidx.appcompat.widget.AppCompatMultiAutoCompleteTextView",
  "androidx.appcompat.widget.AppCompatCheckedTextView",
  "androidx.appcompat.widget.AppCompatRatingBar",
  "androidx.appcompat.widget.Toolbar",
  "com.google.android.material.button.MaterialButton",
  "com.google.android.material.card.MaterialCardView",
  "com.google.android.material.textfield.TextInputLayout",
  "com.google.android.material.textfield.TextInputEditText",
  "com.google.android.material.textview.MaterialTextView",
  "com.google.android.material.chip.Chip",
  "com.google.android.material.chip.ChipGroup",
  "com.google.android.material.bottomnavigation.BottomNavigationView",
  "com.google.android.material.navigation.NavigationView",
  "com.google.android.material.tabs.TabLayout",
  "com.google.android.material.progressindicator.LinearProgressIndicator",
  "com.google.android.material.progressindicator.CircularProgressIndicator",
  "com.google.android.material.switchmaterial.SwitchMaterial",
  "com.google.android.material.materialswitch.MaterialSwitch",
  "com.google.android.material.slider.Slider",
  "com.google.android.material.floatingactionbutton.FloatingActionButton",
  "com.google.android.material.appbar.AppBarLayout",
  "com.google.android.material.appbar.CollapsingToolbarLayout",
  "com.google.android.material.appbar.SubtitleCollapsingToolbarLayout",
  "androidx.appcompat.widget.ContentFrameLayout",
  "com.google.android.material.loadingindicator.LoadingIndicator",
  "com.google.android.material.appbar.MaterialToolbar",
  "androidx.constraintlayout.widget.ConstraintLayout",
  "androidx.coordinatorlayout.widget.CoordinatorLayout",
  "androidx.drawerlayout.widget.DrawerLayout",
  "androidx.gridlayout.widget.GridLayout",
  "androidx.recyclerview.widget.RecyclerView",
  "androidx.swiperefreshlayout.widget.SwipeRefreshLayout",
  "androidx.slidingpanelayout.widget.SlidingPaneLayout",
  "androidx.viewpager.widget.ViewPager",
  "androidx.viewpager2.widget.ViewPager2",
  "androidx.core.widget.NestedScrollView",
  "androidx.fragment.app.FragmentContainerView",
  "com.google.android.material.radiobutton.MaterialRadioButton",
  "com.google.android.material.checkbox.MaterialCheckBox",
  "androidx.appcompat.widget.AppCompatToggleButton",
  "androidx.appcompat.widget.SearchView",
  "androidx.appcompat.widget.LinearLayoutCompat",
  "com.google.android.material.button.MaterialButtonToggleGroup",
  "com.google.android.material.floatingactionbutton.ExtendedFloatingActionButton",
  "com.google.android.material.bottomappbar.BottomAppBar",
  "com.google.android.material.divider.MaterialDivider",
  "com.google.android.material.datepicker.MaterialDatePicker",
  "com.google.android.material.timepicker.MaterialTimePicker",
  "com.google.android.material.slider.RangeSlider",
  "androidx.constraintlayout.widget.Barrier",
  "androidx.constraintlayout.widget.Guideline",
  "androidx.constraintlayout.widget.Group",
  "androidx.constraintlayout.widget.Placeholder",
  "androidx.cardview.widget.CardView",
  "com.difierline.lua.material.switches.MaterialSwitchBar",
  "com.difierline.lua.material.textfield.MaterialTextField",
  "com.difierline.lua.material.button.MaterialHeroButton",
  "com.difierline.lua.material.button.MaterialHeroButtonGroup",
  "android.widget.PhotoView",
  "android.widget.PullingLayout",
  "android.widget.HorizontalListView",
  "android.widget.PageView",
  "android.widget.PageLayout",
  "android.widget.ExListView",
  "android.widget.FlexibleListView",
  "android.widget.FloatButton",
  "android.widget.GifView",
  "android.widget.NumberProgressBar",
  "android.widget.DrawerLayout",
  "android.widget.CircleImageView",
  "android.widget.AbsoluteLayout",
  "android.widget.AnalogClock",
  "android.widget.AutoCompleteTextView",
  "android.widget.Button",
  "android.widget.CalendarView",
  "android.widget.CheckBox",
  "android.widget.CheckedTextView",
  "android.widget.Chronometer",
  "android.widget.CompoundButton",
  "android.widget.DatePicker",
  "android.widget.EditText",
  "android.widget.ExpandableListView",
  "android.widget.FrameLayout",
  "android.widget.GridLayout",
  "android.widget.GridView",
  "android.widget.HorizontalScrollView",
  "android.widget.ImageButton",
  "android.widget.ImageView",
  "android.widget.LinearLayout",
  "android.widget.ListPopupWindow",
  "android.widget.ListView",
  "android.widget.MediaController",
  "android.widget.MultiAutoCompleteTextView",
  "android.widget.NumberPicker",
  "android.widget.PopupMenu",
  "android.widget.PopupWindow",
  "android.widget.ProgressBar",
  "android.widget.QuickContactBadge",
  "android.widget.RadioButton",
  "android.widget.RadioGroup",
  "android.widget.RatingBar",
  "android.widget.RelativeLayout",
  "android.widget.RemoteViews",
  "android.widget.ScrollView",
  "android.widget.SeekBar",
  "android.widget.Space",
  "android.widget.Spinner",
  "android.widget.StackView",
  "android.widget.Switch",
  "android.widget.TabHost",
  "android.widget.TabWidget",
  "android.widget.TableLayout",
  "android.widget.TableRow",
  "android.widget.TextClock",
  "android.widget.TextView",
  "android.widget.TimePicker",
  "android.widget.Toast",
  "android.widget.ToggleButton",
  "android.widget.Toolbar",
  "android.widget.VideoView",
  "android.widget.ViewAnimator",
  "android.widget.ViewFlipper",
  "android.widget.ViewSwitcher",
  "android.widget.ZoomButton",
  "android.widget.ZoomControls",
  "android.view.View",
  "com.difierline.lua.luaappx.views.FileTreeView",
  "com.google.android.material.floatingtoolbar.FloatingToolbarLayout",
  "com.google.android.material.button.MaterialButtonGroup",
  "com.google.android.material.search.SearchBar",
}

local seen, classes = {}, {}
local keyValuePairs = {} -- 记录键值对以便打印

-- level == 1 表示最外层
local function collectStrings(t, level)
  level = level or 1
  for k, v in pairs(t) do
    -- 1. 处理键（只要键是字符串就收集）
    if type(k) == "string" and not seen[k] then
      seen[k] = true
      table.insert(classes, k)
      keyValuePairs[k] = v -- 保存键值对用于打印
    end

    -- 2. 处理值
    if type(v) == "string" then
      -- 仅在最外层(level==1)收集
      if level == 1 and not seen[v] then
        seen[v] = true
        table.insert(classes, v)
      end
     elseif type(v) == "table" then
      collectStrings(v, level + 1) -- 子表：层级+1，不再收集内部字符串
    end
  end
end

collectStrings(classes_table)

-- 3. 追加 classNames（同样视为最外层字符串）
for _, v in ipairs(classNames) do
  if not seen[v] then
    seen[v] = true
    table.insert(classes, v)
  end
end

-------------------------------------------------
-- 打印验证
-------------------------------------------------
for _, v in ipairs(classes) do
  if keyValuePairs[v] then
    local path = luaproject .. "/libs/" .. v .. ".dex"
    if File(path).exists() then
      pcall(function()
        local table = keyValuePairs[v]
        local dexLoader = activity.loadDex(path)
        for k, v in ipairs(table) do
          local shortName = v:match("[%w_]+$")
          _G[shortName] = dexLoader.loadClass(v)
        end
      end)
    end
   else
    importClass(v)
  end
end