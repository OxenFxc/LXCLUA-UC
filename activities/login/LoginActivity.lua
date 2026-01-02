require "env"
setStatus()
local bindClass = luajava.bindClass
local Build = bindClass"android.os.Build"
local WindowManager = bindClass"android.view.WindowManager"
local View = bindClass"android.view.View"
local Color = bindClass"android.graphics.Color"
local InputType = bindClass"android.text.InputType"
local SQLiteHelper = bindClass "com.difierline.lua.luaappx.utils.SQLiteHelper"(activity)
local AesUtil = bindClass "com.difierline.lua.luaappx.utils.AesUtil"
local MaterialBlurDialogBuilder = require "dialogs.MaterialBlurDialogBuilder"
local OkHttpUtil = require "utils.OkHttpUtil"
local Utils = require "utils.Utils"
local SharedPrefUtil = require "utils.SharedPrefUtil"
local IconDrawable = require "utils.IconDrawable"
local qq = require "qq"

-- 常量配置
local API_BASE_URL = "https://luaappx.top/account/"

-- 状态管理
local isRegisterMode = false
local forgotDialog = nil

-- 设置窗口属性
local window = activity.getWindow()
if Build.VERSION.SDK_INT >= 21 then
  window.clearFlags(WindowManager.LayoutParams.FLAG_TRANSLUCENT_STATUS)
  window.getDecorView().setSystemUiVisibility(
  View.SYSTEM_UI_FLAG_LAYOUT_FULLSCREEN |
  View.SYSTEM_UI_FLAG_LAYOUT_STABLE |
  View.SYSTEM_UI_FLAG_LIGHT_STATUS_BAR)
  window.addFlags(WindowManager.LayoutParams.FLAG_DRAWS_SYSTEM_BAR_BACKGROUNDS)
  window.setStatusBarColor(Color.TRANSPARENT)
  window.addFlags(WindowManager.LayoutParams.FLAG_LAYOUT_NO_LIMITS)
 else
  window.addFlags(WindowManager.LayoutParams.FLAG_TRANSLUCENT_STATUS)
  window.addFlags(WindowManager.LayoutParams.FLAG_TRANSLUCENT_NAVIGATION)
end

-- 设置软键盘模式
activity.getWindow().setSoftInputMode(WindowManager.LayoutParams.SOFT_INPUT_ADJUST_PAN)

-- 加载布局
activity
.setContentView(loadlayout("layouts.activity_login"))
.setSupportActionBar(toolbar)
.getSupportActionBar()
.setDisplayHomeAsUpEnabled(true)

title.getPaint().setFakeBoldText(true)

-- 通用网络请求处理
local function handleNetworkRequest(url, params, successCallback)
  OkHttpUtil.post(true, url, params, nil, function (code, body)
    local success, v = pcall(OkHttpUtil.decode, body)

    if success and v then
      if v.success then
        successCallback(v)
      end
      MyToast(v.message)
     else
      OkHttpUtil.error(body)
    end
  end)
end

-- 界面模式切换
local function toggleUIMode()
  isRegisterMode = not isRegisterMode
  local visibility = isRegisterMode and View.VISIBLE or View.GONE
  email.setVisibility(visibility)

  login.setText(isRegisterMode and res.string.registration or res.string.login)
  register.setText(isRegisterMode and res.string.login or res.string.registration)
  title.setText(isRegisterMode and "Register" or "Login")
end

-- 登录按钮点击
function login.onClick()
  local endpoint = isRegisterMode and "register.php" or "login.php"
  local params = {
    username = user_txt.text,
    password = password_txt.text,
    time = os.time()
  }

  if isRegisterMode then
    params.email = email_text.text
  end

  handleNetworkRequest(API_BASE_URL .. endpoint, params, function (v)
    if isRegisterMode then
      toggleUIMode()
     else
      SharedPrefUtil.set("username", user_txt.text)
      SharedPrefUtil.set("is_login", true)
      local user_txt2 = tostring(user_txt.text)
      SQLiteHelper.setUser(
      AesUtil.encryptToBase64(user_txt2, user_txt2),
      AesUtil.encryptToBase64(user_txt2, tostring(password_txt.text)),
      AesUtil.encryptToBase64(user_txt2, tostring(v.token))
      )
      activity.result({v.message})
      activity.finish()
    end
  end)
end

-- 切换注册/登录模式
function register.onClick()
  toggleUIMode()
end

-- 忘记密码处理
function forgot.onClick()
  forgotDialog = MaterialBlurDialogBuilder(activity) -- 保存对话框引用
  .setTitle(res.string.forgot_password)
  .setView(loadlayout("layouts.dialog_fileinput"))
  .setPositiveButton(res.string.ok, nil)
  .create()

  content.hint = res.string.please_email

  Utils.onShow(forgotDialog, function()
    handleNetworkRequest(API_BASE_URL .. "forgot_password.php", {
      email = content.text,
      time = os.time()
      }, function(v)
      MyToast(v.message)
      forgotDialog.hide()
    end)
  end)

  forgotDialog.show()
end

-- 菜单项选择
function onOptionsItemSelected(item)
  if item.getItemId() == android.R.id.home then
    activity.finish()
    return true
  end
end

-- 创建菜单
function onCreateOptionsMenu(menu)
  menu.add(res.string.qq_login)
  .setIcon(IconDrawable("ic_qq", Colors.colorOnSurfaceVariant))
  .setShowAsAction(2)
  .onMenuItemClick = function()
    qq.Login(102796665, function (code, body)
      if code == 200 then
        handleNetworkRequest(API_BASE_URL .. "login.php", {
          openid = body,
          time = os.time()
          }, function(v)
          SharedPrefUtil.set("username", "")
          SharedPrefUtil.set("is_login", true)
          SQLiteHelper.setUser("", "", AesUtil.encryptToBase64("", v.token))
          activity.result({v.message})
          activity.finish()
        end)
      end
    end)
  end
end

-- 清理资源
function onDestroy()
  luajava.clear()
  collectgarbage("collect") --全回收
  collectgarbage("step") -- 增量回收
end