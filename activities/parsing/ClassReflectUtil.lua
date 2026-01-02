local _M = {}

function _M.load(classPath)
  local success, classObj = pcall(luajava.bindClass, classPath)
  if not success then
    return
  end

  local Modifier = luajava.bindClass"java.lang.reflect.Modifier"
  local classInfo = {
    constructors = {},
    methods = {},
    fields = {},
    superClasses = {},
    interfaces = {},
    innerClasses = {}
  }

  -- 辅助函数：检查字符串是否包含两个或更多$
  local function hasTwoDollars(str)
    return string.find(str, "%$[^%$]*%$") ~= nil
  end

  -- 构建方法签名的辅助函数
  local function buildMethodSignature(methodName, paramTypeFullNames)
    return methodName .. "(" .. table.concat(paramTypeFullNames, ',') .. ")"
  end

  -- 获取构造函数
  for _, constructor in ipairs(luajava.astable(classObj.getDeclaredConstructors())) do
    local params = {}
    local params_fullname = {}

    for _, paramType in ipairs(luajava.astable(constructor.getParameterTypes())) do
      table.insert(params, paramType.getSimpleName())
      table.insert(params_fullname, paramType.getName())
    end

    table.insert(classInfo.constructors, {
      name = classObj.getSimpleName(),
      params = params,
      params_fullname = params_fullname,
      modifiers = Modifier.toString(constructor.getModifiers())
    })
  end

  -- 获取方法：先获取自身声明的方法，再获取继承的方法
  local methodSignatures = {}  -- 用于记录已添加的方法签名
  local methodList = {}        -- 临时存储方法列表
  
  -- 创建一个集合来存储自身声明的方法签名
  local declaredMethodSignatures = {}
  
  -- 首先：获取类自身声明的所有方法（包括非public）
  for _, method in ipairs(luajava.astable(classObj.getDeclaredMethods())) do
    local methodName = method.getName()
    if not hasTwoDollars(methodName) then
      local params = {}
      local params_fullname = {}
      for _, paramType in ipairs(luajava.astable(method.getParameterTypes())) do
        table.insert(params, paramType.getSimpleName())
        table.insert(params_fullname, paramType.getName())
      end

      local signature = buildMethodSignature(methodName, params_fullname)
      declaredMethodSignatures[signature] = true
      
      if not methodSignatures[signature] then
        methodSignatures[signature] = true
        table.insert(methodList, {
          name = methodName,
          returnType_fullname = method.getReturnType().getName(),
          returnType = method.getReturnType().getSimpleName(),
          params = params,
          params_fullname = params_fullname,
          modifiers = Modifier.toString(method.getModifiers()),
          declared = true  -- 标记为自身声明的方法
        })
      end
    end
  end

  -- 其次：获取所有公共方法（包括继承的方法）
  for _, method in ipairs(luajava.astable(classObj.getMethods())) do
    local methodName = method.getName()
    if not hasTwoDollars(methodName) then
      local params = {}
      local params_fullname = {}
      for _, paramType in ipairs(luajava.astable(method.getParameterTypes())) do
        table.insert(params, paramType.getSimpleName())
        table.insert(params_fullname, paramType.getName())
      end

      local signature = buildMethodSignature(methodName, params_fullname)
      if not methodSignatures[signature] then
        methodSignatures[signature] = true
        table.insert(methodList, {
          name = methodName,
          returnType_fullname = method.getReturnType().getName(),
          returnType = method.getReturnType().getSimpleName(),
          params = params,
          params_fullname = params_fullname,
          modifiers = Modifier.toString(method.getModifiers()),
          declared = false  -- 标记为继承的方法
        })
      elseif not declaredMethodSignatures[signature] then
        -- 如果方法已存在但不是自身声明的，更新其declared标记
        for _, m in ipairs(methodList) do
          if buildMethodSignature(m.name, m.params_fullname) == signature then
            m.declared = false
            break
          end
        end
      end
    end
  end

  -- 将临时方法列表存入classInfo
  classInfo.methods = methodList

  -- 获取字段
  for _, field in ipairs(luajava.astable(classObj.getDeclaredFields())) do
    local fieldName = field.getName()
    if not hasTwoDollars(fieldName) then
      table.insert(classInfo.fields, {
        name = fieldName,
        type = field.getType().getSimpleName(),
        modifiers = Modifier.toString(field.getModifiers())
      })
    end
  end

  -- 获取父类
  local superClass = classObj.getSuperclass()
  while superClass do
    local className = superClass.getName()
    if not hasTwoDollars(className) then
      table.insert(classInfo.superClasses, className)
    end
    superClass = superClass.getSuperclass()
  end

  -- 获取接口
  for _, interface in ipairs(luajava.astable(classObj.getInterfaces())) do
    local interfaceName = interface.getName()
    if not hasTwoDollars(interfaceName) then
      table.insert(classInfo.interfaces, interfaceName)
    end
  end

  -- 获取内部类
  for _, innerClass in ipairs(luajava.astable(classObj.getDeclaredClasses())) do
    local innerClassName = innerClass.getName()
    if not hasTwoDollars(innerClassName) then
      table.insert(classInfo.innerClasses, innerClassName)
    end
  end

  return classInfo
end

return _M