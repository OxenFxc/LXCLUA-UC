require "import"
import "android.app.*"
import "android.os.*"
import "android.widget.*"
import "android.view.*"
import "utils.OkHttpUtil"

local MaterialBlurDialogBuilder = require "dialogs.MaterialBlurDialogBuilder"

activity.setTitle("RunCode")
--activity.getActionBar().setDisplayHomeAsUpEnabled(true)

function onOptionsItemSelected(item)
  local id = item.getItemId()
  if id == android.R.id.home then
    activity.finish()
  end
end

function onDestroy()
  luajava.clear()
  collectgarbage("collect")
  collectgarbage("step")
end

local hook = {}
hook["okhttp_post"] = _ENV["OkHttpUtil"].post
hook["okhttp_get"] = _ENV["OkHttpUtil"].get
hook["okhttp_upload"] = _ENV["OkHttpUtil"].upload

if activity.getSharedData("request_interception") then
  function OkHttpUtil.post(...)
    local cs = {...}
    MaterialBlurDialogBuilder(activity)
    .setTitle("检测到POST请求")
    .setMessage("请求URL: " .. cs[2] .. "\n请求参数: " .. dump(cs[3]))
    .setPositiveButton("允许", function()
      print("请求已被允许")
      return hook["okhttp_post"](unpack(cs))
    end)
    .setNegativeButton("拒绝", nil)
    .show()
  end

  function OkHttpUtil.upload(...)
    local cs = {...}
    MaterialBlurDialogBuilder(activity)
    .setTitle("检测到UPLOAD请求")
    .setMessage("请求URL: " .. cs[2] .. "\n请求参数: " .. dump(cs[3]) .. "\n上传文件: " .. dump(cs[4]))
    .setPositiveButton("允许", function()
      print("请求已被允许")
      return hook["okhttp_upload"](unpack(cs))
    end)
    .setNegativeButton("拒绝", nil)
    .show()
  end

  function OkHttpUtil.get(...)
    local cs = {...}
    MaterialBlurDialogBuilder(activity)
    .setTitle("检测到GET请求")
    .setMessage("请求URL: " .. cs[2])
    .setPositiveButton("允许", function()
      print("请求已被允许")
      return hook["okhttp_get"](unpack(cs))
    end)
    .setNegativeButton("拒绝", nil)
    .show()
  end

  Http.setLuaContext(activity)
  Http.setInterceptEnabled(true)

end

activity.doString(..., {})


pcall(function()
  activity.getSupportActionBar().setDisplayHomeAsUpEnabled(true)
end)