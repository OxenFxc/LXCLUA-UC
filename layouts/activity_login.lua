local bindClass = luajava.bindClass
local CoordinatorLayout = bindClass"androidx.coordinatorlayout.widget.CoordinatorLayout"
local AppBarLayout = bindClass"com.google.android.material.appbar.AppBarLayout"
local CollapsingToolbarLayout = bindClass"com.google.android.material.appbar.CollapsingToolbarLayout"
local MaterialToolbar = bindClass"com.google.android.material.appbar.MaterialToolbar"
local LinearLayoutCompat = bindClass"androidx.appcompat.widget.LinearLayoutCompat"
local MaterialDivider = bindClass"com.google.android.material.divider.MaterialDivider"
local MaterialCardView = bindClass"com.google.android.material.card.MaterialCardView"
local AppCompatImageView = bindClass"androidx.appcompat.widget.AppCompatImageView"
local AppCompatTextView = bindClass"androidx.appcompat.widget.AppCompatTextView"
local MaterialTextField = bindClass"com.difierline.lua.material.textfield.MaterialTextField"
local MaterialButton = bindClass"com.google.android.material.button.MaterialButton"
local TextInputLayout = bindClass"com.google.android.material.textfield.TextInputLayout"
local TextInputEditText = bindClass"com.google.android.material.textfield.TextInputEditText"
local ColorStateList = bindClass"android.content.res.ColorStateList"
local Typeface = bindClass "android.graphics.Typeface"
local IconDrawable = require "utils.IconDrawable"
local UiUtil = bindClass "com.difierline.lua.luaappx.utils.UiUtil"

return {
  CoordinatorLayout,
  layout_width = - 1,
  layout_height = - 1,
  {
    MaterialToolbar,
    layout_width = - 1,
    id = "toolbar",
    title = "",
    layout_marginTop = UiUtil.getStatusBarHeight(activity),
    layout_height = UiUtil.getActionBarSize(activity),
  },
  {
    LinearLayoutCompat,
    gravity = "center",
    --layout_behavior = "appbar_scrolling_view_behavior" ,
    layout_width = - 1,
    layout_height = - 1,
    --paddingBottom = "120dp" ,
    orientation = "vertical",
    LayoutTransition = newLayoutTransition(),
    {
      AppCompatImageView,
      layout_width = "180dp",
      layout_height = "180dp",
      src = "res/drawable/ic_Illustration_login.png"

    },
    {
      AppCompatTextView,
      text = "Login",
      id = "title",
      textSize = "28sp",
      textColor = Colors.colorOnBackground,
    },
    {
      TextInputLayout,
      id = "user",
      hint = res.string.please_enter_an_account_number,
      startIconDrawable = IconDrawable("ic_account_outline", Colors.colorOutline),
      layout_marginTop = "8dp",
      layout_marginLeft = "20dp",
      layout_marginRight = "20dp",
      layout_width = "fill",
      {
        TextInputEditText,
        id = "user_txt",
        singleLine = true,
        textSize = "15sp",
        Typeface = Typeface.DEFAULT_BOLD,
        layout_width = "fill"
      },
    },
    {
      TextInputLayout,
      id = "password",
      endIconMode = 1,
      hint = res.string.please_enter_your_password,
      startIconDrawable = IconDrawable("ic_lock_outline", Colors.colorOutline),
      layout_marginTop = "8dp",
      layout_marginLeft = "20dp",
      layout_marginRight = "20dp",
      layout_width = "fill",
      {
        TextInputEditText,
        id = "password_txt",
        singleLine = true,
        textSize = "15sp",
        Typeface = Typeface.DEFAULT_BOLD,
        layout_width = "fill"
      },
    },
    {
      TextInputLayout,
      id = "email",
      Visibility = 8,
      layout_marginTop = "8dp",
      layout_marginLeft = "20dp",
      layout_marginRight = "20dp",
      hint = res.string.please_email,
      startIconDrawable = IconDrawable("ic_email_outline", Colors.colorOutline),
      layout_width = "fill",
      {
        TextInputEditText,
        id = "email_text",
        singleLine = true,
        Typeface = Typeface.DEFAULT_BOLD,
        textSize = "15sp",
        layout_width = "fill"
      },
    },
    {
      MaterialButton,
      backgroundColor = 0,
      layout_gravity = "end",
      text = res.string.forgot_password .. "?",
      StrokeWidth = 0,
      layout_marginTop = "8dp",
      id = "forgot",
      style = MDC_R.attr.materialButtonOutlinedStyle,
      layout_marginRight = "20dp",
    },
    {
      MaterialButton,
      text = res.string.login,
      layout_width = - 1,
      layout_marginTop = "8dp",
      layout_marginLeft = "50dp",
      layout_marginRight = "50dp",
      id = "login",
    },
    {
      LinearLayoutCompat,
      layout_width = - 1,
      layout_margin = "8dp",
      gravity = "center",
      {
        MaterialDivider,
        layout_width = "30dp",
        layout_marginRight = "8dp",
      },
      {
        AppCompatTextView,
        text = "or"
      },
      {
        MaterialDivider,
        layout_width = "30dp",
        layout_marginLeft = "8dp",
      },
    },
    {
      MaterialButton,
      backgroundColor = 0,
      text = res.string.registration,
      StrokeWidth = "1dp",
      StrokeColor = ColorStateList.valueOf(Colors.colorPrimary),
      layout_width = - 1,
      layout_marginLeft = "50dp",
      layout_marginRight = "50dp",
      id = "register",
      style = MDC_R.attr.materialButtonOutlinedStyle,
    },
  },
}