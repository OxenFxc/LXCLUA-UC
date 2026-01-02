require "env"
setStatus()
local bindClass = luajava.bindClass
local ObjectAnimator = bindClass "android.animation.ObjectAnimator"
local Intent = bindClass "android.content.Intent"
local ProjectPermissionTool = require "activities.attribute.ProjectPermissionTool"
local FileUtil = require "utils.FileUtil"
local Utils = require "utils.Utils"
local cjson = require "cjson"
local GlideUtil = require "utils.GlideUtil"
path = ...

activity
.setContentView(loadlayout("layouts.activity_attribute"))
.setSupportActionBar(toolbar)
.getSupportActionBar()
.setDisplayHomeAsUpEnabled(true)

Utils
.changed(name_of_project)
.changed(project_package_name)

-- 解析manifest.json文件
local function parseManifest(manifestPath)

  if not FileUtil.isExist(manifestPath) then return end
  local success, content = pcall(FileUtil.read, manifestPath)
  if not success then return end
  local v = cjson.decode(content)
  local application = v.application
  local jmp = v.jmp
  local print2 = v.print or {
    type = "Snackbar",
    copy = true
  }
  local uses_sdk = v.uses_sdk

  if not v then return end
  return {
    label = application.label or "My Application",
    versionName = v.versionName or "1.0",
    versionCode = v.versionCode or "1",
    minSdkVersion = uses_sdk.minSdkVersion or "21",
    targetSdkVersion = uses_sdk.targetSdkVersion or "29",
    package = v.package or "dcore.myapplication",
    debugmode = application.debugmode,
    user_permission = v.user_permission or {},
    compilation = v.compilation,
    skip_compilation = v.skip_compilation or {},
    encryption = jmp.encryption or false,
    dump_obfuscate = jmp.dump_obfuscate or false,
    print2_type = print2.type or "Snackbar",
    print2_copy = print2.copy or "true",
    sharedUserId = application.sharedUserId or ""
  }
end

local function dump(t)
  local r = {}
  for k,v in ipairs(t) do
    r[k] = string.format('%q', v)
  end
  return table.concat(r, ",\n  ")
end

local success, message = pcall(parseManifest, path .. "/manifest.json")
if success and message then

  task(100,function()

    GlideUtil.set(FileUtil.isFile(path .. "/icon.png") and path .. "/icon.png" or activity.getLuaDir("ic_launcher_playstore.png"), icon)
    name_of_project.setText(tostring(message.label))
    project_package_name.setText(tostring(message.package))
    edition.setText(tostring(message.versionName))
    version_no.setText(tostring(message.versionCode))
    sdk.setText(tostring(message.minSdkVersion .. "/" .. message.targetSdkVersion))
    debugmode.setChecked(message.debugmode)
    share_id.setText(tostring(message.sharedUserId or ""))

    function app_permission.onClick()
      ProjectPermissionTool.permissionBottomSheetDialog(message.user_permission, function(mBottomSheetDialog, SelectedState)
        mBottomSheetDialog.setOnDismissListener({
          onDismiss = function(dialog)
            -- 将选中的权限转换回原始格式（去掉前缀）
            local selectedPermissions = {}
            for permission, selected in pairs(SelectedState) do
              if selected then
                table.insert(selectedPermissions, permission)
              end
            end

            message.user_permission = selectedPermissions
          end
        })
      end)
    end

    icon.parent.onClick = function()
      activity.startActivityForResult(
      Intent(Intent.ACTION_PICK)
      .setType("image/*"),
      1
      )
    end

    function fab.onClick()
      if name_of_project.Text == "" then
        name_of_project.setError(res.string.please_enter_a_project_name)
       elseif project_package_name.Text == "" then
        project_package_name.setError(res.string.please_enter_a_project_package_name)
       else
        local f = io.open(path .. "/manifest.json","w")
        f:write(string.format([[{
  "versionName": "%s",
  "versionCode": "%s",
  "uses_sdk": {
    "minSdkVersion": "%s",
    "targetSdkVersion": "%s"
  },
  "package": "%s",
  "application": {
    "label": "%s",
    "debugmode": %s,
    "sharedUserId": "%s"
  },
  "user_permission": [
  %s
  ],
  "compilation": %s,
  "skip_compilation": [
  %s
  ],
  "jmp": {
    "encryption": %s,
    "dump_obfuscate": %s
  },
  "print": {
    "type": "%s",
    "copy": %s
  }
}]],
        edition.Text,
        version_no.Text,
        (sdk.Text):match("(.+)%/") or 21,
        (sdk.Text):match("%/(.+)") or 29,
        project_package_name.Text,
        name_of_project.Text,
        debugmode.isChecked(),
        share_id.Text,
        dump(message.user_permission),
        message.compilation,
        dump(message.skip_compilation),
        message.encryption,
        message.dump_obfuscate,
        message.print2_type,
        message.print2_copy
        ))
        f:close()

        if image ~= nil
          LuaUtil.copyDir(image, path .. "/icon.png")
        end
        activity.result({ name_of_project.Text })
      end
    end

  end)

end

function onActivityResult(requestCode, resultCode, intent)
  if not intent then return end

  local uri = intent.data
  if requestCode == 1 then -- 图标选择
    image = Utils.uri2path(uri)
    GlideUtil.set(image, icon)
  end
end

function onOptionsItemSelected(item)
  if item.getItemId() == android.R.id.home then
    activity.finish()
    return true
  end
end

function onDestroy()
  luajava.clear()
  collectgarbage("collect")
  collectgarbage("step")
end