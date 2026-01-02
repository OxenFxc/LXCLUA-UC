local _M = {}
local bindClass = luajava.bindClass
local AppCompatTextView = bindClass "androidx.appcompat.widget.AppCompatTextView"
local GradientDrawable = bindClass "android.graphics.drawable.GradientDrawable"
local PorterDuff = bindClass "android.graphics.PorterDuff"
local PorterDuffColorFilter = bindClass "android.graphics.PorterDuffColorFilter"
local MaterialBlurDialogBuilder = require "dialogs.MaterialBlurDialogBuilder"
local IconDrawable = require "utils.IconDrawable"
local FileUtil = require "utils.FileUtil"
local PathUtil = require "utils.PathUtil"
local EditorUtil = require "activities.editor.EditorUtil"
local MaterialBlurDialogBuilder = require "dialogs.MaterialBlurDialogBuilder"
local Utils = require "utils.Utils"

_M.add=function(name,callback)
  function_menu_root.setVisibility(0)
  function_menu.addView(loadlayout({
    AppCompatTextView,
    text = name,
    layout_height = "32dp",
    gravity = "center",
    layout_width = -1,
    gravity = "center",
    TooltipText = name,
    paddingRight = "8dp",
    paddingLeft = "8dp",
    backgroundDrawable = getRipple(false, colorRipple),
    onClick = callback
  }))
  return _M
end

function _M.OpenGreateDialog()
  MaterialBlurDialogBuilder(this)
  .setTitle(res.string.c_f_f)
  .setItems({
    res.string.c_f,
    res.string.c_f2
    },function(l,v)
    local path = FileUtil.getParent(PathUtil.this_file)
    if v==0
      local Newdialog = MaterialBlurDialogBuilder(activity)
      .setTitle(res.string.c_f)
      .setMessage(path)
      .setView(loadlayout("layouts.dialog_fileinput"))
      .setPositiveButton(res.string.ok, nil)
      .setNegativeButton(res.string.no, nil)
      .create()
      Utils
      .changed(content)
      .onShow(Newdialog, function()
        local new_path = path .. "/" .. content.text
        if FileUtil.isExists(new_path)
          content.setError(res.string.exists_file)
          return
        end
        MyToast(FileUtil.createFile(new_path) and res.string.created_successfully or res.string.creation_failed)
        tree.refresh(path)
        Newdialog.dismiss()
      end)
      Newdialog.show()
     elseif v==1
      local Newdialog = MaterialBlurDialogBuilder(activity)
      .setTitle(res.string.c_f2)
      .setMessage(path)
      .setView(loadlayout("layouts.dialog_fileinput"))
      .setPositiveButton(res.string.ok, nil)
      .setNegativeButton(res.string.no, nil)
      .create()
      Utils
      .changed(content)
      .onShow(Newdialog, function()
        local new_path = path .. "/" .. content.text
        if FileUtil.isExists(new_path)
          content.setError(res.string.exists_file)
          return
        end
        MyToast(FileUtil.createDirectory(new_path) and res.string.created_successfully or res.string.creation_failed)
        tree.refresh(path)
        Newdialog.dismiss()
      end)
      Newdialog.show()
    end
  end)
  .setPositiveButton(res.string.no,nil)
  .show()
end

function _M.getLuaPath()
  return PathUtil.this_file
end

function _M.getProjectPath()
  return luaproject
end

return _M