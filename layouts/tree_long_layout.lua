local bindClass = luajava.bindClass
local LinearLayoutCompat = bindClass "androidx.appcompat.widget.LinearLayoutCompat"
local BottomSheetDragHandleView = bindClass "com.google.android.material.bottomsheet.BottomSheetDragHandleView"
local AppCompatTextView = bindClass "androidx.appcompat.widget.AppCompatTextView"
local MaterialDivider = bindClass "com.google.android.material.divider.MaterialDivider"
local MaterialHeroButtonGroup = bindClass "com.difierline.lua.material.button.MaterialHeroButtonGroup"
local MaterialHeroButton = bindClass "com.difierline.lua.material.button.MaterialHeroButton"
local IconDrawable = require "utils.IconDrawable"

return {
  LinearLayoutCompat,
  layout_height = -1,
  layout_width = -1,
  orientation = "vertical",
  {
    BottomSheetDragHandleView,
    layout_width = -1,
  },
  {
    LinearLayoutCompat,
    layout_marginLeft = "22dp",
    layout_marginRight = "22dp",
    orientation = "vertical",
    gravity = "center",
    layout_width = -1,
    {
      AppCompatTextView,
      id = "filename",
      gravity = "center",
      layout_marginBottom = "2dp",
      textSize = "18sp",
      textColor = Colors.colorOnBackground,
    },
    {
      AppCompatTextView,
      id = "time",
      layout_marginTop = "2dp",
      layout_marginBottom = "8dp",
      ellipsize = "middle",
      MaxLines = 1,
      gravity = "center",
      textSize = "15sp",
      textColor = Colors.colorOutline,
    },
    {
      MaterialDivider,
      --DividerColor = Colors.colorSurfaceVariant,
    },
  },
  {
    MaterialHeroButtonGroup,
    layout_width = "match_parent",
    {
      MaterialHeroButton,
      layout_height = -1,
      layout_width = -1,
      backgroundDrawable = getRipple(),
      Icon = IconDrawable("ic_pencil_outline"),
      layout_weight = 1,
      id = "rename",
      text = res.string.rename
    },
    {
      MaterialHeroButton,
      layout_height = -1,
      layout_width = -1,
      Icon = IconDrawable("ic_file_create_outline"),
      layout_weight = 1,
      id = "new_file",
      text = res.string.new_file
    },
    {
      MaterialHeroButton,
      layout_height = -1,
      layout_width = -1,
      Icon = IconDrawable("ic_create_new_folder"),
      layout_weight = 1,
      id = "new_folder",
      text = res.string.new_folder
    },
    {
      MaterialHeroButton,
      layout_height = -1,
      layout_width = -1,
      Icon = IconDrawable("ic_delete_forever_outline"),
      Color = Colors.colorError,
      backgroundDrawable = getRipple(false, 0x31FF0000),
      layout_weight = 1,
      id = "delete",
      text = res.string.delete
    }
  },
}