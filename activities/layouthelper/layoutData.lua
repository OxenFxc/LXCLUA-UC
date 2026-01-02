relative = {
  "layout_above", "layout_alignBaseline", "layout_alignBottom", "layout_alignEnd", "layout_alignLeft", "layout_alignParentBottom", "layout_alignParentEnd", "layout_alignParentLeft", "layout_alignParentRight", "layout_alignParentStart", "layout_alignParentTop", "layout_alignRight", "layout_alignStart", "layout_alignTop", "layout_alignWithParentIfMissing", "layout_below", "layout_centerHorizontal", "layout_centerInParent", "layout_centerVertical", "layout_toEndOf", "layout_toLeftOf", "layout_toRightOf", "layout_toStartOf"
}

fds_grid = {
  res.string.add, res.string.delete, res.string.parent_control, res.string.child_control,
  "id", "orientation",
  "columnCount", "rowCount",
  "layout_width", "layout_height", "layout_gravity",
  "onClick", "onLongClick",
  "background", "backgroundColor", "gravity",
  "layout_margin", "layout_marginLeft", "layout_marginTop", "layout_marginRight", "layout_marginBottom",
  "padding", "paddingLeft", "paddingTop", "paddingRight", "paddingBottom",
  "Rotation", "RotationX", "RotationY",
}

fds_linear = {
  res.string.add, res.string.delete, res.string.parent_control, res.string.child_control,
  "id", "orientation", "layout_width", "layout_height", "layout_gravity",
  "onClick", "onLongClick",
  "fitsSystemWindows",
  "background", "backgroundColor", "gravity",
  "layout_margin", "layout_marginLeft", "layout_marginTop", "layout_marginRight", "layout_marginBottom",
  "padding", "paddingLeft", "paddingTop", "paddingRight", "paddingBottom",
  "Rotation", "RotationX", "RotationY",
}

fds_group = {
  res.string.add, res.string.delete, res.string.parent_control, res.string.child_control,
  "id", "layout_width", "layout_height", "layout_gravity",
  "onClick", "onLongClick",
  "fitsSystemWindows",
  "background", "backgroundColor", "gravity",
  "layout_margin", "layout_marginLeft", "layout_marginTop", "layout_marginRight", "layout_marginBottom",
  "padding", "paddingLeft", "paddingTop", "paddingRight", "paddingBottom",
  "Rotation", "RotationX", "RotationY",
  "CardElevation", "radius"
}

fds_text = {
  res.string.delete, res.string.parent_control,
  "id", "layout_width", "layout_height", "layout_gravity",
  "onClick", "onLongClick",
  "background", "backgroundColor", "text", "ellipsize",
  "hint", "textColor", "hintTextColor", "textSize", "singleLine", "maxLines", "maxEms", "maxHeight", "maxWidth", "minWidth", "gravity",
  "layout_margin", "layout_marginLeft", "layout_marginTop", "layout_marginRight", "layout_marginBottom",
  "padding", "paddingLeft", "paddingTop", "paddingRight", "paddingBottom",
  "Rotation", "RotationX", "RotationY",
  "CardElevation", "radius"
}

fds_image = {
  res.string.delete, res.string.parent_control,
  "id", "layout_width", "layout_height", "layout_gravity",
  "onClick", "onLongClick",
  "background", "backgroundColor", "src", "scaleType", "gravity",
  "layout_margin", "layout_marginLeft", "layout_marginTop", "layout_marginRight", "layout_marginBottom",
  "padding", "paddingLeft", "paddingTop", "paddingRight", "paddingBottom",
  "Rotation", "RotationX", "RotationY", "ColorFilter";
  "CardElevation", "radius"
}

fds_view = {
  res.string.delete, res.string.parent_control,
  "id", "layout_width", "layout_height", "layout_gravity",
  "onClick", "onLongClick",
  "fitsSystemWindows",
  "background", "gravity",
  "layout_margin", "layout_marginLeft", "layout_marginTop", "layout_marginRight", "layout_marginBottom",
  "padding", "paddingLeft", "paddingTop", "paddingRight", "paddingBottom",
  "Rotation", "RotationX", "RotationY", "StrokeWidth", "StrokeColor",
  "CardElevation", "radius"
}

--[[ns = {
  res.string.basic_controls,
  res.string.selection_switch_controls,
  res.string.list_pagination_controls,
  res.string.data_input_display_controls,
  res.string.layout_containers,
  res.string.material_components,
  res.string.navigation_action_controls,
  res.string.progress_indicators,
  res.string.special_views,
  res.string.date_time_controls
}]]

ns = {
  "Basic Controls",
  "Selection/Switch Controls",
  "List & Pagination Controls",
  "Data Input & Display Controls",
  "Layout Containers",
  "Material Components",
  "Navigation & Action Controls",
  "Progress & Indicators",
  "Special Views",
  "Date & Time Controls"
}

wds = {
  -- 基础控件
  {
    "AppCompatButton",
    "AppCompatEditText",
    "AppCompatTextView",
    "AppCompatImageView",
    "AppCompatImageButton",
    "CircleImageView",
    "TextView",
    "EditText",
    "Button",
    "ImageButton",
    "ImageView",
    "CheckedTextView",
    "Space"
  },

  -- 选择/开关控件
  {
    "AppCompatCheckBox",
    "AppCompatRadioButton",
    "AppCompatToggleButton",
    "SwitchMaterial",
    "MaterialSwitch",
    "MaterialCheckBox",
    "MaterialRadioButton",
    "MaterialSwitchBar",
    "CheckBox",
    "RadioButton",
    "ToggleButton",
    "Switch",
    "RatingBar"
  },

  -- 列表与翻页控件
  {
    "RecyclerView",
    "ListView",
    "ExpandableListView",
    "ViewPager",
    "ViewPager2",
    "AppCompatSpinner",
    "GridView",
    "HorizontalListView",
    "PageView",
    "PageLayout",
    "ExListView",
    "FlexibleListView",
    "StackView",
    "Spinner"
  },

  -- 数据输入与展示控件
  {
    "SeekBar",
    "ProgressBar",
    "NumberPicker",
    "AutoCompleteTextView",
    "AppCompatAutoCompleteTextView",
    "AppCompatMultiAutoCompleteTextView",
    "SearchView",
    "TextInputLayout",
    "TextInputEditText",
    "MaterialTextField",
    "NumberProgressBar",
    "MultiAutoCompleteTextView",
    "TextClock",
    "Chronometer",
    "QuickContactBadge"
  },

  -- 布局容器
  {
    "LinearLayout",
    "FrameLayout",
    "RelativeLayout",
    "ConstraintLayout",
    "CoordinatorLayout",
    "CardView",
    "GridLayout",
    "ScrollView",
    "HorizontalScrollView",
    "NestedScrollView",
    "AbsoluteLayout",
    "TableLayout",
    "TableRow",
    "SwipeRefreshLayout",
    "SlidingPaneLayout",
    "ViewAnimator",
    "ViewFlipper",
    "ViewSwitcher"
  },

  -- Material组件
  {
    "AppBarLayout",
    "BottomAppBar",
    "BottomNavigationView",
    "Chip",
    "ChipGroup",
    "FloatingActionButton",
    "ExtendedFloatingActionButton",
    "TabLayout",
    "NavigationView",
    "MaterialCardView",
    "Slider",
    "MaterialDivider",
    "CollapsingToolbarLayout",
    "MaterialToolbar",
    "MaterialButton",
    "MaterialTextView",
    "MaterialHeroButton",
    "MaterialHeroButtonGroup",
    "RangeSlider"
  },

  -- 导航与操作控件
  {
    "Toolbar",
    "MaterialToolbar",
    "SearchBar",
    "BottomNavigationView",
    "NavigationView",
    "TabHost",
    "TabWidget",
    "ZoomButton",
    "ZoomControls"
  },

  -- 进度与指示器
  {
    "ProgressBar",
    "LinearProgressIndicator",
    "CircularProgressIndicator",
    "SeekBar",
    "NumberProgressBar"
  },

  -- 特殊视图
  {
    "PhotoView",
    "GifView",
    "VideoView",
    "WebView",
    "AnalogClock",
    "PullingLayout",
  },

  -- 日期时间控件
  {
    "DatePicker",
    "TimePicker",
    "CalendarView"
  }
}

ns2 = {
    "基础控件",
    "选择/开关控件",
    "列表与分页控件",
    "数据输入与展示控件",
    "布局容器",
    "Material 组件",
    "导航与操作控件",
    "进度与指示器",
    "特殊视图",
    "日期与时间控件"
}

wds2 = {
    -- 基础控件
    {
        "兼容包按钮",
        "兼容包编辑文本",
        "兼容包文本视图",
        "兼容包图片视图",
        "兼容包图片按钮",
        "圆形图片视图",
        "文本视图",
        "编辑文本",
        "按钮",
        "图片按钮",
        "图片视图",
        "带复选框的文本视图",
        "空白占位视图"
    },

    -- 选择/开关控件
    {
        "兼容包复选框",
        "兼容包单选按钮",
        "兼容包切换按钮",
        "Material 开关",
        "Material 开关",
        "Material 复选框",
        "Material 单选按钮",
        "Material 开关栏",
        "复选框",
        "单选按钮",
        "切换按钮",
        "开关",
        "评分条"
    },

    -- 列表与分页控件
    {
        "循环视图",
        "列表视图",
        "可展开列表视图",
        "视图分页器",
        "视图分页器2",
        "兼容包下拉列表",
        "网格视图",
        "水平列表视图",
        "页面视图",
        "页面布局",
        "可扩展列表视图",
        "灵活列表视图",
        "栈视图",
        "下拉列表"
    },

    -- 数据输入与展示控件
    {
        "拖动条",
        "进度条",
        "数字选择器",
        "自动完成文本视图",
        "兼容包自动完成文本视图",
        "兼容包多自动完成文本视图",
        "搜索视图",
        "文本输入布局",
        "文本输入编辑文本",
        "Material 文本框",
        "数字进度条",
        "多自动完成文本视图",
        "文本时钟",
        "计时器",
        "快速联系人徽章"
    },

    -- 布局容器
    {
        "线性布局",
        "帧布局",
        "相对布局",
        "约束布局",
        "协调布局",
        "卡片视图",
        "网格布局",
        "滚动视图",
        "水平滚动视图",
        "嵌套滚动视图",
        "绝对布局",
        "表格布局",
        "表格行",
        "下拉刷新布局",
        "滑动面板布局",
        "视图动画器",
        "视图翻转器",
        "视图切换器"
    },

    -- Material 组件
    {
        "应用栏布局",
        "底部应用栏",
        "底部导航视图",
        "芯片",
        "芯片组",
        "悬浮操作按钮",
        "扩展悬浮操作按钮",
        "标签布局",
        "导航视图",
        "Material 卡片视图",
        "滑块",
        "Material 分割线",
        "折叠工具栏布局",
        "Material 工具栏",
        "Material 按钮",
        "Material 文本视图",
        "Material 英雄按钮",
        "Material 英雄按钮组",
        "范围滑块"
    },

    -- 导航与操作控件
    {
        "工具栏",
        "Material 工具栏",
        "搜索栏",
        "底部导航视图",
        "导航视图",
        "标签宿主",
        "标签组件",
        "缩放按钮",
        "缩放控件"
    },

    -- 进度与指示器
    {
        "进度条",
        "线性进度指示器",
        "圆形进度指示器",
        "拖动条",
        "数字进度条"
    },

    -- 特殊视图
    {
        "图片查看器",
        "动图视图",
        "视频视图",
        "网页视图",
        "模拟时钟",
        "下拉布局"
    },

    -- 日期与时间控件
    {
        "日期选择器",
        "时间选择器",
        "日历视图"
    }
}

CAN_HAVE_CHILDREN = {
  LinearLayoutCompat,
  Toolbar,
  MaterialCardView,
  TextInputLayout,
  ChipGroup,
  TabLayout,
  AppBarLayout,
  CollapsingToolbarLayout,
  ConstraintLayout,
  CoordinatorLayout,
  DrawerLayout,
  GridLayout,
  SwipeRefreshLayout,
  SlidingPaneLayout,
  ViewPager,
  ViewPager2,
  NestedScrollView,
  MaterialButtonToggleGroup,
  BottomAppBar,
  CardView,
  AbsoluteLayout,
  FrameLayout,
  GridLayout, -- android.widget.*
  LinearLayout,
  RelativeLayout,
  TableLayout,
  TableRow,
  ViewAnimator,
  ViewFlipper,
  ViewSwitcher,
  HorizontalScrollView,
  ScrollView,
  ListView,
  GridView,
  ExpandableListView,
  RadioGroup,
  TabHost,
  PullingLayout,
  PageLayout,
}

-- TextView 同效控件
TEXTVIEW_COMPAT = {
  AppCompatTextView, -- androidx.appcompat
  MaterialTextView, -- material
  AppCompatEditText, -- 输入型
  TextInputEditText, -- material 输入
  AppCompatAutoCompleteTextView,
  AppCompatMultiAutoCompleteTextView,
  AppCompatCheckedTextView,
  AppCompatButton, -- Button 也是 TextView 子类
  MaterialButton, -- material Button
  MaterialHeroButton, -- lemon 扩展
  MaterialRadioButton, -- 单选按钮
  MaterialCheckBox, -- 复选框
  AppCompatCheckBox,
  AppCompatRadioButton,
  AppCompatToggleButton,
  SwitchMaterial, -- material Switch
  MaterialSwitch, -- material Switch
  MaterialSwitchBar, -- lemon SwitchBar
  Chronometer, -- 计时器
  TextClock, -- 时钟
  CheckedTextView,
  EditText, -- 原生
  AutoCompleteTextView,
  MultiAutoCompleteTextView,
  TextView, -- 原生根类
  Button, -- 原生
  RadioButton,
  CheckBox,
  ToggleButton,
  Switch,
}

-- ImageView 同效控件
IMAGEVIEW_COMPAT = {
  AppCompatImageView, -- androidx.appcompat
  AppCompatImageButton, -- 兼具 ImageView + Button 特性
  ImageView, -- 原生根类
  ImageButton, -- 原生
  CircleImageView, -- 圆形图片（第三方 / 自定义）
  PhotoView, -- 手势缩放图（第三方）
  GifView, -- GIF 动图（第三方）
  QuickContactBadge, -- 联系人头像徽章（原生）
}

-- LinearLayout
LINEARLAYOUT_COMPAT = {
  LinearLayout, -- 原生
  LinearLayoutCompat, -- androidx.appcompat
  RadioGroup, -- 继承自 LinearLayout
  TabHost, -- 内部布局继承自 LinearLayout
  AppBarLayout, -- material，继承自 LinearLayout
  MaterialButtonToggleGroup, -- material，继承自 LinearLayout
  BottomAppBar, -- material，继承自 LinearLayout
  BottomNavigationView, -- material，内部继承自 LinearLayout
  ChipGroup, -- material，继承自 LinearLayout
}