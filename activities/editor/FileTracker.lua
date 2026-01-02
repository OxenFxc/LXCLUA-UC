--- FileTracker.lua
-- 基于LuaDB的文件跟踪系统
-- @module FileTracker

local db = require("utils.db")

local M = {}

-- 打开数据库连接
function M.open(fileTrackingPath)
  return db.open({
    path = fileTrackingPath,
    can_each = true,
    buffer_size = 4096,
    addr_size = db.BIT_32
  })
end

-- 添加/更新文件信息
function M.putFile(db, project, file_path, lines, columns)

  -- 获取或创建项目子数据库
  local projectDB = db:get(project)

  if not projectDB then

    -- 使用 setmetatable 创建新的数据库对象
    projectDB = setmetatable({}, db.TYPE_DB)

    -- 将新数据库保存到主数据库
    local success, err = pcall(function()
      db:set(project, projectDB)
    end)

    if not success then
      return false, "Failed to create project database"
    end
  end

  -- 存储文件信息
  local success, err = pcall(function()
    projectDB:set(file_path, {
      lines = lines,
      columns = columns,
    })
  end)

  if not success then
    return false, "Failed to store file data"
  end

  return true
end

-- 获取单个文件信息
function M.getFile(db, project, file_path)
  local projectDB = db:get(project)
  if not projectDB then
    return nil
  end

  local _, fileData = xpcall(function()
    return projectDB:get(file_path)
    end,function()
    return {
      lines = 1,
      columns = 1,
    }
  end)

  if not fileData then
    return nil
  end

  return {
    file_path = file_path,
    lines = fileData.lines,
    columns = fileData.columns,
  }
end

-- 在顶层数据库中存储键值对
function M.putGlobal(db, key, value)
  local success, err = pcall(function()
    db:set(key, value)
  end)

  if not success then
    return false, "Failed to store global data: " .. tostring(err)
  end

  return true
end

-- 从顶层数据库获取键值对
function M.getGlobal(db, key)
  local success, value = pcall(function()
    return db:get(key)
  end)

  if not success then
    print("Error retrieving global data for key '" .. key .. "':", value)
    return nil
  end

  return value
end

-- 在指定项目的子数据库中存储键值对
function M.putInProject(db, project, key, value)
  -- 先获取项目数据库
  local projectDB = db:get(project)
  if not projectDB then
    -- 如果项目数据库不存在，则创建
    projectDB = setmetatable({}, db.TYPE_DB)
    local success, err = pcall(function()
      db:set(project, projectDB)
    end)
    if not success then
      return false, "Failed to create project database: " .. tostring(err)
    end
  end

  -- 在项目数据库中存储
  local success, err = pcall(function()
    projectDB:set(key, value)
  end)

  if not success then
    return false, "Failed to store project data: " .. tostring(err)
  end

  return true
end

-- 从指定项目的子数据库中获取键值对
function M.getFromProject(db, project, key)
  local projectDB = db:get(project)
  if not projectDB then
    return nil
  end

  local success, value = pcall(function()
    return projectDB:get(key)
  end)

  if not success then
    print("Error retrieving project data for key '" .. key .. "' in project '" .. project .. "':", value)
    return nil
  end

  return value
end

-- 从顶层数据库删除键值对
-- @param db LuaDB 数据库实例
-- @param key string 要删除的键名
-- @return boolean 操作是否成功
-- @return string|nil 错误信息（如果失败）
-- 从顶层数据库删除键值对
function M.delGlobal(db, key)  
  -- 先检查键是否存在
  local exists = db:get(key)
  
  local success, err = pcall(function()
    db:del(key)
  end)

  if not success then
    return false, "Failed to delete global data: " .. tostring(err)
  end
  
  -- 验证删除是否成功
  local valueAfter = db:get(key)
  
  if valueAfter ~= nil then
    return false, "Key still exists after deletion"
  end

  return true
end

-- 从项目子数据库中删除键值对
-- @param db LuaDB 数据库实例
-- @param project string 项目名称
-- @param key string 要删除的键名
-- @return boolean 操作是否成功
-- @return string|nil 错误信息（如果失败）
function M.delProject(db, project, key)
  local projectDB = db:get(project)
  if not projectDB then
    return false, "Project database does not exist"
  end

  local success, err = pcall(function()
    projectDB:del(key)
  end)

  if not success then
    return false, "Failed to delete project data: " .. tostring(err)
  end

  return true
end

-- 删除整个项目及其所有文件跟踪数据
function M.deleteProject(db, projectName)
  local success, err = pcall(function()
    -- 直接删除项目键，这会删除整个子数据库
    db:del(projectName)
  end)

  if not success then
    return false, "Failed to delete project: " .. tostring(err)
  end

  return true
end

return M