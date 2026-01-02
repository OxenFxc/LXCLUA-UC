local _M = {}
local bindClass = luajava.bindClass
local CodeEditor = bindClass "io.github.rosemoe.sora.widget.CodeEditor"
local ActionMode = bindClass "androidx.appcompat.view.ActionMode"
local Typeface = bindClass "android.graphics.Typeface"
local ColorDrawable = bindClass "android.graphics.drawable.ColorDrawable"
local EditorColorScheme = bindClass "io.github.rosemoe.sora.widget.schemes.EditorColorScheme"
local EditorSearcher = bindClass "io.github.rosemoe.sora.widget.EditorSearcher"
local EditorTextActionWindow = bindClass "io.github.rosemoe.sora.widget.component.EditorTextActionWindow"
local PackageUtil = bindClass "com.yan.luaeditor.tools.PackageUtil"
local PopupMenu = bindClass "androidx.appcompat.widget.PopupMenu"
local ScanUtil = bindClass "com.yan.luaeditor.tools.ScanUtil"
local Context = bindClass "android.content.Context"
local Sora_R = bindClass "io.github.rosemoe.sora.R"
local FileUtil = require "utils.FileUtil"
local MaterialBlurDialogBuilder = require "dialogs.MaterialBlurDialogBuilder"
local ActivityUtil = require "utils.ActivityUtil"
local Utils = require "utils.Utils"
local IconDrawable = require "utils.IconDrawable"
local LuaLanguage = bindClass "com.yan.luaeditor.lualanguage.LuaLanguage"

is_sora = activity.getSharedData("is_sora") or false

local function getActionMode(view)
  return ActionMode.Callback{
    onCreateActionMode = function(mode, menu)
      _clipboardActionMode = mode
      mode.setTitle(android.R.string.selectTextMode)

      local array = activity.getTheme().obtainStyledAttributes({
        android.R.attr.actionModeSelectAllDrawable,
        android.R.attr.actionModeCutDrawable,
        android.R.attr.actionModeCopyDrawable,
        android.R.attr.actionModePasteDrawable,
      })

      menu.add(0, 0, 0, android.R.string.selectAll)
      .setShowAsAction(2)
      .setIcon(array.getResourceId(0, 0))

      menu.add(0, 1, 0, android.R.string.cut)
      .setShowAsAction(2)
      .setIcon(array.getResourceId(1, 0))

      menu.add(0, 2, 0, android.R.string.copy)
      .setShowAsAction(2)
      .setIcon(array.getResourceId(2, 0))

      menu.add(0, 3, 0, android.R.string.paste)
      .setShowAsAction(2)
      .setIcon(array.getResourceId(3, 0))

      array.recycle()

      return true
    end,

    onActionItemClicked = function(mode, item)
      local id = item.getItemId()

      if id == 0 then
        view.selectAll()
       elseif id == 1 then
        view.cut()
        mode.finish()
       elseif id == 2 then
        view.copy()
        mode.finish()
       elseif id == 3 then
        view.paste()
        mode.finish()
      end
      return false
    end,

    onDestroyActionMode = function(mode)
      view.selectText(false)
      _clipboardActionMode = nil
    end,
  }
end

local function handleColorDetection(selectedText)
  -- 去掉首尾空白
  selectedText = tostring(selectedText or "")
  selectedText = selectedText:match("^%s*(.-)%s*$") or ""

  -- 仅允许 0x 或 0X 开头，且长度为 8 或 10 的十六进制
  if selectedText:match("^[0oO][xX][0-9a-fA-F]+$") then
    local len = #selectedText
    if len == 8 or len == 10 then
      color_value_card.setCardBackgroundColor(tonumber(selectedText))
      color_value_card.setVisibility(0)
    end
  end
end

local function javaClassAnalyse(selectedText)
  activity.newTask(function(selectedText)
    local classes = require "activities.javaapi.PublicClasses"
    local Import_class = {}
    for k, v in ipairs(classes) do
      local z = tostring(string.match(v, "%w+$"))
      if z == selectedText then
        table.insert(Import_class, v)
      end
    end
    return Import_class
    end, function(Import_class)
    local Import_class = luajava.astable(Import_class)
    local pos = #Import_class
    if pos ~= 0 then
      class_find
      .setVisibility(0)
      .setText(selectedText .. (function() if pos ~= 1 then return "[" .. pos .. "]" else return "" end end)())
      function class_find.onClick(v)
        local popupMenu = PopupMenu(activity, v)
        local popupMenux = PopupMenu(activity, v)
        for k, v in ipairs(Import_class) do
          local paths = tostring(v)
          popupMenu.Menu.add(paths).onMenuItemClick = function()
            popupMenux.Menu.add(res.string.copy_classes).onMenuItemClick = function()
              activity.getSystemService("clipboard").setText(string.format('local %s = luajava.bindClass "%s"', selectedText, paths))
            end
            popupMenux.Menu.add(res.string.see_api).onMenuItemClick = function()
              ActivityUtil.new("parsing", { paths })
              class_find.setVisibility(8)
            end
            popupMenux.show()
          end
        end
        popupMenu.show()
      end
    end
  end).execute({ selectedText })

end

function _M.getView()
  return is_sora and CodeEditor or LuaEditor
end

function _M.Search_Init()
  if is_sora then
    _M.searchState = {
      searcher = editor.getSearcher(),
      options = nil,
      active = false,
      caseSensitive = true,
      useRegex = false,
      searchType = 1
    }
  end
  return _M
end

function _M.gotoNextMatch()
  if is_sora and _M.searchState.active and _M.searchState.searcher then
    pcall(function()
      _M.searchState.searcher.gotoNext()
      table.insert(search_histry, search.text)
    end)
    return true
  end
  return false
end

function _M.gotoPrevMatch()
  if is_sora and _M.searchState.active and _M.searchState.searcher then
    pcall(function()
      _M.searchState.searcher.gotoPrevious()
      table.insert(search_histry, search.text)
    end)
    return true
  end
  return false
end

function _M.replaceCurrentMatch(replacement)
  if is_sora and _M.searchState.active and _M.searchState.searcher then
    pcall(function()
      _M.searchState.searcher.replaceCurrentMatch(replacement)
    end)
  end
  return _M
end

function _M.replaceAll(replacement)
  if is_sora and _M.searchState.active and _M.searchState.searcher then
    pcall(function()
      _M.searchState.searcher.replaceAll(replacement)
    end)
  end
  return _M
end

function _M.clearSearch()
  if is_sora and _M.searchState.searcher then
    _M.searchState.searcher.stopSearch()
  end
  _M.searchState.active = false
  search_root.Visibility = 8
  pcall(function()
    fileTracker.putInProject(db, ProjectName, "SearchHistory", search_histry)
  end)
end

function _M.refreshSearch()
  if is_sora and _M.searchState.active and _M.searchState.searcher then
    local searchText = tostring(search.getText())
    if #searchText > 0 then
      -- 更新搜索选项
      _M.searchState.options = EditorSearcher.SearchOptions(
      _M.searchState.searchType, -- 搜索类型
      _M.searchState.caseSensitive -- 是否区分大小写
      )
      pcall(function()
        _M.searchState.searcher.search(searchText, _M.searchState.options)
      end)
    end
  end
  return _M
end

function _M.search()
  if is_sora then
    substitution.Visibility = 8
    substitution.setText("")
    local searchText = editor.getSelectedText() or ""

    _M.searchState.searcher = editor.getSearcher()
    _M.searchState.options = EditorSearcher.SearchOptions(_M.searchState.caseSensitive, false)
    _M.searchState.active = true

    if #searchText > 0 then
      pcall(function()
        EditView.searchState.searcher.search(searchText, _M.searchState.options)
      end)
    end


    search.setText(searchText)

    _M.searchState.active = true
    search_root.Visibility = 0

    search.addTextChangedListener(luajava.createProxy("android.text.TextWatcher", {
      beforeTextChanged = function(s, start, count, after) end,
      onTextChanged = function(s, start, before, count)
        if _M.searchState.active then
          local text = tostring(s.toString())
          if #text > 0 then
            pcall(function()
              _M.searchState.searcher.search(text, _M.searchState.options)
            end)
           else
            _M.searchState.searcher.stopSearch()
          end
        end
      end,
      afterTextChanged = function(s) end
    }))

    task(100, function()
      search.requestFocus()
      local imm = activity.getSystemService(Context.INPUT_METHOD_SERVICE)
      imm.showSoftInput(search, imm.SHOW_IMPLICIT)
    end)

   else
    editor.search()
  end
end

function _M.format(callback)
  if is_sora then
    if editor.isTextSelected() then
      local selectedRange = editor.getCursorRange()
      editor.formatCodeAsync(selectedRange.getStart(), selectedRange.getEnd())
     else
      editor.formatCodeAsync()
    end
   else
    editor.format()
  end
  return _M
end

function _M.TextSelectListener()
  if is_sora then
    editor.addOnTextSelectStateChangeListener(function(isSelecting)
      if isSelecting then
        local selectedText = editor.getSelectedText()
        selectedText2 = selectedText
        handleColorDetection(selectedText)
        javaClassAnalyse(selectedText)
       else
        -- bindClass "io.github.rosemoe.sora.widget.component.EditorTextActionWindow"(_M.getView).dismiss()
        selectedText2 = ""
        color_value_card.setVisibility(8)
        class_find.setVisibility(8)
        task(20, function()
          editor.hideEditorWindows()
        end)
      end
    end)
   else
    editor.OnSelectionChangedListener = function(status, start, end_)
      if editor.getSelectedText() and status then
        local selectedText = editor.getSelectedText()
        selectedText2 = selectedText
        handleColorDetection(selectedText)
        javaClassAnalyse(selectedText)
       else
        selectedText2 = ""
        color_value_card.setVisibility(8)
        class_find.setVisibility(8)
      end

      if not(_clipboardActionMode) and status then
        activity.startSupportActionMode(getActionMode(editor))
        --MagnifierManager.Available = true
       elseif _clipboardActionMode and not status then
        _clipboardActionMode.finish()
        _clipboardActionMode = nil
        --MagnifierManager.hide()
        --MagnifierManager.Available = false
      end
    end
  end

  function color_value_card.onClick()
    bindClass "com.difierline.lua.colorpicker.builder.ColorPickerDialogBuilder"
    .with(activity)
    .setTitle(res.string.colorpicker)
    .initialColor(tonumber(selectedText2)) -- 当前选中的色值
    .showColorEdit(true)
    .showColorPreview(true)
    .showAlphaSlider(true)
    .wheelType(bindClass "com.difierline.lua.colorpicker.ColorPickerView".WHEEL_TYPE.FLOWER)
    .density(10)
    .setPositiveButton(res.string.ok, function(dialog, selectedColor, allColors)
      -- 将选定的颜色转换为十六进制字符串
      local newColorStr = "0x" .. string.sub(string.format("%X", selectedColor), -8)

      -- 获取编辑器当前选中的文本范围
      if is_sora then -- Sora编辑器处理
        local cursor = editor.getCursor()
        local startLine = cursor.getLeftLine()
        local startCol = cursor.getLeftColumn()
        local endLine = cursor.getRightLine()
        local endCol = cursor.getRightColumn()

        -- 替换选中文本
        editor.getText().replace(startLine, startCol, endLine, endCol, newColorStr)
       else -- 原始LuaEditor处理
        editor.paste(newColorStr) -- 替换当前选中内容
      end

      -- 更新卡片背景色预览
      color_value_card.setCardBackgroundColor(selectedColor)
    end)
    .setNegativeButton(res.string.no, nil)
    .build()
    .show()
  end

  return _M
end

function _M.TextActionWindowListener()
  if is_sora then
    editor.setTextActionWindowListener(luajava.createProxy("io.github.rosemoe.sora.widget.CodeEditor$TextActionWindowListener", {
      onTextActionWindowClick = function(id)
        switch id
         case bindClass "io.github.rosemoe.sora.R$id".panel_btn_search
          EditView.search()
        end
      end
    }))
  
    local actionWindow = EditorTextActionWindow.getInstance(editor)
    .setSearchButtonVisible(true)
    .addBtn(true, res.string.format, Sora_R.drawable.ic_format_indent_increase, function()
      EditView.format()
    end)
    .addBtn(true, res.string.annotation, IconDrawable("ic_text"), function()
      local cursor = editor.getCursor()
      if not cursor.isSelected() then
        return
      end

      local leftLine = cursor.getLeftLine()
      local leftCol = cursor.getLeftColumn()
      local rightLine = cursor.getRightLine()
      local rightCol = cursor.getRightColumn()

      editor.getText().replace(leftLine, leftCol, rightLine, rightCol, "--[==[" .. editor.getSelectedText() .. "]==]")
      editor.setSelection(leftLine, leftCol)
    end)

  end
  return _M
end


function _M.EditorLanguageAsync(code)

  if is_sora then
    local function setupEditorLanguage(base, classMap2)
      LuaLanguage().releaseMemory()
      local lang
      if base and classMap2 then
        -- 检查 base 和 classMap2 是否为 HashMap 类型，确保只传递构造函数支持的参数
        local baseIsTable = type(base) == "table"
        local classMap2IsTable = type(classMap2) == "table"
        
        if baseIsTable and classMap2IsTable then
          -- 只传递两个 HashMap 参数，因为第三个参数需要是 String[] 类型，而 require 返回的是 Lua 表
          lang = LuaLanguage(base, classMap2)
        else
          -- 如果参数类型不正确，使用无参构造函数
          lang = LuaLanguage()
        end
      else
        lang = LuaLanguage()
      end
      return lang
      .setCompletionCaseSensitive(activity.getSharedData("case_sensitive") or false)
      .setShowFullParameterType(activity.getSharedData("full_parameter_type") or false)
      .setHexColorHighlightEnabled(activity.getSharedData("hex_color_highlight") or false)
    end

    local function loadBaseMapsAsync(init_progress, callback)
      init_progress.Visibility = 0
      activity.newTask(function(act)
        act.loadBaseMaps(act)
        end, function()
        init_progress.Visibility = 8
        editor.setEditorLanguage(setupEditorLanguage(activity.base, activity.classMap2))
        if callback then callback() end
      end).execute({ activity })
    end

    if not code then
      if activity.getSharedData("edit_box_init") == true then
        editor.setEditorLanguage(setupEditorLanguage())
       else
        if activity.classMap2 then
          editor.setEditorLanguage(setupEditorLanguage(activity.base, activity.classMap2))
         else
          local completeBasePath = activity.getExternalCacheDir().getPath() .. "/complete.base"
          if FileUtil.isFile(completeBasePath) then
            loadBaseMapsAsync(init_progress, startLibsScan)
           else
            editor.setEditorLanguage(setupEditorLanguage())
          end
        end
      end
      return _M
    end

    local function handleGenerateCompleteData(callback)
      MaterialBlurDialogBuilder(activity)
      .setTitle(res.string.tip)
      .setMessage(res.string.edit_box_init)
      .setPositiveButton(res.string.ok, function()
        ScanUtil.generateCompleteData(activity, {
          onStart = function()
            init_progress.parent.Visibility = 0
          end,
          onProgress = function(msg, progress)
            init_progress.setProgressCompat(progress, true)
            init_text.setText(msg)
          end,
          onFinish = function()
            init_progress.parent.Visibility = 8
            editor.setEditorLanguage(setupEditorLanguage(activity.base, activity.classMap2))
            if callback then callback() end
          end,
          onError = function(err)
            MyToast(err)
            editor.setEditorLanguage(setupEditorLanguage())
            if callback then callback() end
          end
        })
      end)
      .setNegativeButton(res.string.no, function()
        activity.setSharedData("edit_box_init", true)
        editor.setEditorLanguage(setupEditorLanguage())
        if callback then callback() end
      end)
      .show()
      .setCancelable(false)
    end

    local function startLibsScan()
      if activity.getSharedData("analyse_the_data") then
        editor.postInLifecycle(function()
          ScanUtil.scanLibsDirectory(activity, luaproject, {
            onStart = function()
              init_progress.parent.Visibility = 0
            end,
            onProgress = function(message, progress)
              init_progress.setProgressCompat(progress, true)
              init_text.setText(message)
            end,
            onFinish = function()
              init_progress.parent.Visibility = 8
              editor.setEditorLanguage(setupEditorLanguage(activity.base, activity.classMap2))
            end,
            onError = function(error)
              init_progress.parent.Visibility = 8
              if not error:find("found") then
                MyToast(error)
              end
            end
          })
        end)
      end
    end

    if activity.getSharedData("edit_box_init") == true then
      editor.setEditorLanguage(setupEditorLanguage())
      startLibsScan()
     else
      if activity.classMap2 then
        editor.setEditorLanguage(setupEditorLanguage(activity.base, activity.classMap2))
        startLibsScan()
       else
        local completeBasePath = activity.getExternalCacheDir().getPath() .. "/complete.base"
        if FileUtil.isFile(completeBasePath) then
          loadBaseMapsAsync(init_progress.parent, startLibsScan)
         else
          handleGenerateCompleteData(startLibsScan)
        end
      end
    end

    PackageUtil.load(activity)
    editor.getComponent(bindClass "io.github.rosemoe.sora.widget.component.EditorAutoCompletion")
    .setEnabledAnimation(true)

   else

    thread(function(activity, editor)

      local jpairs = require "jpairs"
      local LuaActivity = luajava.bindClass "com.difierline.lua.LuaActivity"
      local act = {}
      local tmp = {}
      for k,v jpairs(LuaActivity.getMethods())
        v=v.getName()
        if not v:find("%$")
          if not tmp[v]
            tmp[v] = true
            act[#act+1] = v.."()"
          end
        end
      end

      local classes = require "activities.javaapi.PublicClasses"

      local ms = {
        "onCreateonCreate","onStart","onResume",
        "onPause","onStop","onDestroy","onError",
        "onActivityResult","onResult","onNightModeChanged",
        "onContentChanged","onConfigurationChanged",
        "onContextItemSelected","onCreateContextMenu",
        "onCreateOptionsMenu","onOptionsItemSelected","onRequestPermissionsResult",
        "onClick","onTouch","onLongClick",
        "onItemClick","onItemLongClick","onVersionChanged","this","android",
      }

      local l = #ms
      for k, v ipairs(classes)
        ms[l + k] = string.match(v, "%w+$")
      end

      editor.addNames(ms)
      .addPackage("activity",act)
      .addPackage("this",act)
    end, activity, editor)

  end
  return _M
end

function _M.EditorScheme()
  if is_sora then

    local scheme = EditorColorScheme()
    scheme.setColor(EditorColorScheme.IDENTIFIER_VAR, 0xFFFF9800)
    scheme.setColor(EditorColorScheme.LINE_NUMBER_BACKGROUND, Colors.colorBackground)
    scheme.setColor(EditorColorScheme.LINE_NUMBER, Colors.colorOnBackground)
    scheme.setColor(EditorColorScheme.WHOLE_BACKGROUND, Colors.colorBackground)
    scheme.setColor(EditorColorScheme.TEXT_NORMAL, Colors.colorOnBackground)
    scheme.setColor(EditorColorScheme.LINE_NUMBER_CURRENT, Colors.colorOnBackground)
    scheme.setColor(EditorColorScheme.CURRENT_LINE, 512264328)
    scheme.setColor(EditorColorScheme.BLOCK_LINE_CURRENT, Colors.colorOutline)
    scheme.setColor(EditorColorScheme.BLOCK_LINE, colorOutline2)
    scheme.setColor(EditorColorScheme.SELECTION_INSERT, Colors.colorPrimary)
    scheme.setColor(EditorColorScheme.SELECTION_HANDLE, 0xFFDCC2AE)
    scheme.setColor(EditorColorScheme.HIGHLIGHTED_DELIMITERS_FOREGROUND, -168430091)
    scheme.setColor(EditorColorScheme.SCROLL_BAR_TRACK, SCROLL_BAR_TRACK_COLOR)
    scheme.setColor(EditorColorScheme.SCROLL_BAR_THUMB_PRESSED, SCROLL_BAR_THUMB_PRESSED_COLOR)
    scheme.setColor(EditorColorScheme.SCROLL_BAR_THUMB, SCROLL_BAR_THUMB_COLOR)
    scheme.setColor(EditorColorScheme.LINE_NUMBER_PANEL, Colors.colorPrimary)
    scheme.setColor(EditorColorScheme.LINE_NUMBER_PANEL_TEXT, 0xFFFFFFFF)
    scheme.setColor(EditorColorScheme.TEXT_ACTION_WINDOW_BACKGROUND, Colors.colorBackground)
    scheme.setColor(EditorColorScheme.TEXT_ACTION_WINDOW_ICON_COLOR, Colors.colorOnBackground)
    scheme.setColor(EditorColorScheme.TEXT_ACTION_WINDOW_STROKE_COLOR, Colors.colorOutline)
    scheme.setColor(EditorColorScheme.COMPLETION_WND_TEXT_SECONDARY, Colors.colorOutline)
    scheme.setColor(EditorColorScheme.COMPLETION_WND_TEXT_PRIMARY, Colors.colorOnBackground)
    scheme.setColor(EditorColorScheme.HIGHLIGHTED_DELIMITERS_FOREGROUND, Colors.colorOnBackground)
    scheme.setColor(EditorColorScheme.MATCHED_TEXT_BACKGROUND, 0)
    scheme.setColor(EditorColorScheme.SELECTED_TEXT_BACKGROUND, Utils.setColorAlpha(Colors.colorPrimary, 22))
    scheme.setColor(EditorColorScheme.LOCAL_VARIABLE, activity.getSharedData("local_variable_highlight") or 0xFFAAAA88)
    scheme.setColor(EditorColorScheme.CLASS_NAME, activity.getSharedData("class_name_highlight") or 0xFF6E81D9)
    scheme.setColor(EditorColorScheme.KEYWORD, activity.getSharedData("keyword_highlight") or 0xFFFF565E)
    scheme.setColor(EditorColorScheme.FUNCTION_NAME, activity.getSharedData("function_name_highlight") or 0xFF2196F3)
    scheme.setColor(EditorColorScheme.LINE_DIVIDER, activity.getSharedData("dividing_line_color") or 0xEEEEEEEE)

    editor.setColorScheme(scheme)

   else

    editor.setBackground(ColorDrawable(Colors.colorBackground))

  end
  return _M
end

function _M.EditorProperties()
  if is_sora then

    local minValue = tonumber(activity.getSharedData("value_min")) or 20
    local maxValue = tonumber(activity.getSharedData("value_max")) or 80

    editor.setWordwrap(activity.getSharedData("word_wrap") or false)
    editor.setPinLineNumber(activity.getSharedData("fixed_line_number") or false)
    editor.setTabWidth(2)
    editor.setTextSizePx(45)
    editor.setScaleTextSizes(minValue, maxValue)
    --  editor.setDividerWidth(dp2px(2))
    editor.setHighlightHexColorsEnabled(activity.getSharedData("hex_color_highlight") or false)
    if activity.getSharedData("editor_showBlankChars") then
      editor.nonPrintablePaintingFlags = editor.FLAG_DRAW_WHITESPACE_IN_SELECTION + editor.FLAG_DRAW_WHITESPACE_LEADING + editor.FLAG_DRAW_LINE_SEPARATOR
    end
    --editor.setLigatureEnabled(false)

   else

    editor.setWordWrap(activity.getSharedData("word_wrap") or false)
    editor.setTextSize(45)
    editor.setNonPrintingCharVisibility(activity.getSharedData("editor_showBlankChars") or false)
    editor.setHighlightHexColorsEnabled(activity.getSharedData("hex_color_highlight") or false)
    editor.setCompletionCaseSensitive(activity.getSharedData("case_sensitive") or false)
    -- editor.setEnableDrawingErrMsg(false)

  end
  return _M
end

function _M.EditorFont()
  local function safeSetFont(fontPath)
    local success, font = pcall(function()
      return Typeface.createFromFile(fontPath)
    end)
    if success and font then
      if is_sora then
        editor.setTypefaceText(font)
        editor.setTypefaceLineNumber(font)
       else
        editor.setTypeface(font)
      end
      return true
    end
    return false
  end

  local fontPath = activity.getSharedData("font_path2")
  if fontPath and safeSetFont(fontPath) then
    return
  end

  -- 默认字体
  local defaultFont = activity.getLuaDir("res/fonts/jetbrains_mono.ttf")
  if safeSetFont(defaultFont) then
    activity.setSharedData("font_path2", defaultFont)
   else
    activity.setSharedData("font_path2", nil)
  end
  return _M
end

function _M.release()
  if is_sora then
    editor.release()
    LuaLanguage().releaseMemory()
  end
end
return _M