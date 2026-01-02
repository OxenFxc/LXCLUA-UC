local bindClass = luajava.bindClass
local LinearLayoutCompat = bindClass "androidx.appcompat.widget.LinearLayoutCompat"
local AppCompatTextView = bindClass "androidx.appcompat.widget.AppCompatTextView"
local ExpandableListView = bindClass "android.widget.ExpandableListView"
local BottomSheetDragHandleView = bindClass "com.google.android.material.bottomsheet.BottomSheetDragHandleView"
local Typeface = bindClass "android.graphics.Typeface"

local function prepareListView(id)
  return id.setDividerHeight(2).setFastScrollEnabled(false).setVerticalScrollBarEnabled(false).setHorizontalScrollBarEnabled(false).setOverScrollMode(2)
end

return {
  LinearLayoutCompat,
  orientation = "vertical",
  layout_width = -1,
  layout_height = -1,
  gravity = "center",
  id = "mViewParent",
  {
    BottomSheetDragHandleView,
    layout_width = -1,
  },
  {
    AppCompatTextView,
    layout_marginBottom = "8dp",
    layout_marginTop = 0,
    layout_margin = "16dp",
    gravity = "center",
    textSize = "21dp",
    Typeface = Typeface.DEFAULT_BOLD,
    textColor = Colors.colorPrimary,
    id = "mDialogTitle"
  },
  {
    function(v)
      return prepareListView(ExpandableListView(v))
    end,
    layout_margin = "12dp",
    layout_width = -1,
    clipToPadding = false,
    nestedScrollingEnabled = true,
    id = "mDialogListView",
  }
}