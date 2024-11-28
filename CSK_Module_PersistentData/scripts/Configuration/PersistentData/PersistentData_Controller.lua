---@diagnostic disable: undefined-global, redundant-parameter, missing-parameter

--***************************************************************
-- Inside of this script, you will find the necessary functions,
-- variables and events to communicate via UI with the PersistentData_Model
--***************************************************************

--**************************************************************************
--************************ Start Global Scope ******************************
--**************************************************************************
local nameOfModule = 'CSK_PersistentData'

-- Reference to global handle
local persistentData_Model

-- Timer to notify all relevant events on-resume
local tmrPersistendData = Timer.create()
tmrPersistendData:setExpirationTime(300)
tmrPersistendData:setPeriodic(false)

-- Timer to check if all triggerd modules send their parametsr
local tmrCheckAllModules = Timer.create()
tmrCheckAllModules:setExpirationTime(10000)
tmrCheckAllModules:setPeriodic(false)

local currentSelectedParameters = '' -- Selected Parameter

-- ************************ UI Events Start ********************************
Script.serveEvent('CSK_PersistentData.OnNewStatusModuleVersion', 'PersistentData_OnNewStatusModuleVersion')
Script.serveEvent('CSK_PersistentData.OnNewStatusCSKStyle', 'PersistentData_OnNewStatusCSKStyle')
Script.serveEvent('CSK_PersistentData.OnNewStatusModuleIsActive', 'PersistentData_OnNewStatusModuleIsActive')

Script.serveEvent("CSK_PersistentData.OnNewDataPath", "PersistentData_OnNewDataPath")
Script.serveEvent("CSK_PersistentData.OnNewFeedbackStatus", "PersistentData_OnNewFeedbackStatus")
Script.serveEvent("CSK_PersistentData.OnNewContent", "PersistentData_OnNewContent")
Script.serveEvent("CSK_PersistentData.OnNewDatasetList", "PersistentData_OnNewDatasetList")
Script.serveEvent("CSK_PersistentData.OnNewParameterSelection", "PersistentData_OnNewParameterSelection")

Script.serveEvent("CSK_PersistentData.OnNewParameterTableInfo", "PersistentData_OnNewParameterTableInfo")
Script.serveEvent('CSK_PersistentData.OnNewStatusTempFileAvailable', 'PersistentData_OnNewStatusTempFileAvailable')

Script.serveEvent("CSK_PersistentData.OnUserLevelOperatorActive", "PersistentData_OnUserLevelOperatorActive")
Script.serveEvent("CSK_PersistentData.OnUserLevelMaintenanceActive", "PersistentData_OnUserLevelMaintenanceActive")
Script.serveEvent("CSK_PersistentData.OnUserLevelServiceActive", "PersistentData_OnUserLevelServiceActive")
Script.serveEvent("CSK_PersistentData.OnUserLevelAdminActive", "PersistentData_OnUserLevelAdminActive")

Script.serveEvent("CSK_PersistentData.OnInitialDataLoaded", "PersistentData_OnInitialDataLoaded")
Script.serveEvent('CSK_PersistentData.OnInstanceAmountAvailable', 'PersistentData_OnInstanceAmountAvailable')

Script.serveEvent('CSK_PersistentData.OnResetAllModules', 'PersistentData_OnResetAllModules')
Script.serveEvent('CSK_PersistentData.OnNewDataToLoad', 'PersistentData_OnNewDataToLoad')

Script.serveEvent('CSK_PersistentData.OnNewUserManagementTrigger', 'PersistentData_OnNewUserManagementTrigger')

-- ************************ UI Events End **********************************
--**************************************************************************
--********************** End Global Scope **********************************
--**************************************************************************
--**********************Start Function Scope *******************************
--**************************************************************************

-- Functions to forward logged in user roles via CSK_UserManagement module (if available)
-- ***********************************************
--- Function to react on status change of Operator user level
---@param status boolean Status if Operator level is active
local function handleOnUserLevelOperatorActive(status)
  Script.notifyEvent("PersistentData_OnUserLevelOperatorActive", status)
end

--- Function to react on status change of Maintenance user level
---@param status boolean Status if Maintenance level is active
local function handleOnUserLevelMaintenanceActive(status)
  Script.notifyEvent("PersistentData_OnUserLevelMaintenanceActive", status)
end

--- Function to react on status change of Service user level
---@param status boolean Status if Service level is active
local function handleOnUserLevelServiceActive(status)
  Script.notifyEvent("PersistentData_OnUserLevelServiceActive", status)
end

--- Function to react on status change of Admin user level
---@param status boolean Status if Admin level is active
local function handleOnUserLevelAdminActive(status)
  Script.notifyEvent("PersistentData_OnUserLevelAdminActive", status)
end

--- Function to get access to the persistentData_Model object
---@param handle handle Handle of persistentData_Model object
local function setPersistentData_Model_Handle(handle)
  persistentData_Model = handle
  if persistentData_Model.userManagementModuleAvailable then
    -- Register on events of CSK_UserManagement module if available
    Script.register('CSK_UserManagement.OnUserLevelOperatorActive', handleOnUserLevelOperatorActive)
    Script.register('CSK_UserManagement.OnUserLevelMaintenanceActive', handleOnUserLevelMaintenanceActive)
    Script.register('CSK_UserManagement.OnUserLevelServiceActive', handleOnUserLevelServiceActive)
    Script.register('CSK_UserManagement.OnUserLevelAdminActive', handleOnUserLevelAdminActive)
  end
  Script.releaseObject(handle)
end

--- Function to update user levels
local function updateUserLevel()
  if persistentData_Model.userManagementModuleAvailable then
    -- Trigger CSK_UserManagement module to provide events regarding user role
    Script.notifyEvent("PersistentData_OnNewUserManagementTrigger")
  else
    -- If CSK_UserManagement is not active, show everything
    Script.notifyEvent("PersistentData_OnUserLevelOperatorActive", true)
    Script.notifyEvent("PersistentData_OnUserLevelMaintenanceActive", true)
    Script.notifyEvent("PersistentData_OnUserLevelServiceActive", true)
    Script.notifyEvent("PersistentData_OnUserLevelAdminActive", true)
  end
end

--- Function to send all relevant values to UI on resume
local function handleOnExpiredTmrPersistendData()

  updateUserLevel()

  Script.notifyEvent("PersistentData_OnNewStatusModuleVersion", 'v' .. persistentData_Model.version)
  Script.notifyEvent("PersistentData_OnNewStatusCSKStyle", persistentData_Model.parameters.styleForUI or 'None')
  Script.notifyEvent("PersistentData_OnNewStatusModuleIsActive", _G.availableAPIs.default)
  Script.notifyEvent('PersistentData_OnNewDataPath', persistentData_Model.path)
  Script.notifyEvent('PersistentData_OnNewContent', persistentData_Model.contentList)
  Script.notifyEvent('PersistentData_OnNewFeedbackStatus', 'EMPTY')
  Script.notifyEvent('PersistentData_OnNewDatasetList', persistentData_Model.funcs.createJsonList(persistentData_Model.data))
  if currentSelectedParameters ~= '' then
    Script.notifyEvent('PersistentData_OnNewParameterSelection', currentSelectedParameters)
  end
  Script.notifyEvent('PersistentData_OnNewParameterTableInfo', persistentData_Model.funcs.createJsonListForTableView(persistentData_Model.data[currentSelectedParameters]))
  Script.notifyEvent('PersistentData_OnNewStatusTempFileAvailable', File.exists(persistentData_Model.tempPath))
end
Timer.register(tmrPersistendData, "OnExpired", handleOnExpiredTmrPersistendData)

local function pageCalled()
  updateUserLevel() -- try to hide user specific content asap
  tmrPersistendData:start()
  return ''
end
Script.serveFunction("CSK_PersistentData.pageCalled", pageCalled)

local function getStatusModuleActive()
  return _G.availableAPIs.default
end
Script.serveFunction('CSK_PersistentData.getStatusModuleActive', getStatusModuleActive)

local function setUIStyle(style)
  persistentData_Model.parameters.styleForUI = style
  Parameters.set('CSK_UI_Style', style)
  Script.notifyEvent("PersistentData_OnNewStatusCSKStyle", persistentData_Model.parameters.styleForUI)
end
Script.serveFunction('CSK_PersistentData.setUIStyle', setUIStyle)

local function getVersion()
  if _APPNAME == 'CSK_Module_PersistentData' then
    return Engine.getCurrentAppVersion()
  else
    return '3.0.0'
  end
end
Script.serveFunction("CSK_PersistentData.getVersion", getVersion)

local function addParameter(data, name)
  local dataTable = persistentData_Model.funcs.convertContainer2Table(data)
  persistentData_Model.addParameterTable(dataTable, name)
  Script.releaseObject(data)
  tmrPersistendData:start()
end
Script.serveFunction("CSK_PersistentData.addParameter", addParameter)

local function getParameter(name)
  if persistentData_Model.data[name] ~= nil then
    local dataContainer = persistentData_Model.funcs.convertTable2Container(persistentData_Model.data[name])
    _G.logger:fine(nameOfModule .. ": Provide parameter: " .. tostring(name))
    return dataContainer
  else
    _G.logger:info(nameOfModule .. ": Parameter not available: " .. tostring(name))
    return nil
  end
end
Script.serveFunction("CSK_PersistentData.getParameter", getParameter)

local function getParameterList()
 return persistentData_Model.contentList
end
Script.serveFunction("CSK_PersistentData.getParameterList", getParameterList)

local function getCurrentParameterInfo()
  return persistentData_Model.path
end
Script.serveFunction('CSK_PersistentData.getCurrentParameterInfo', getCurrentParameterInfo)

--- Function to check if all modules send their parameters within 5 seconds
local function handleOnCheckAllModulesSaved()
  local listOfFailedModules = ''
  local waitForOthers = false
  for key, value in pairs(persistentData_Model.moduleSaveCheck) do
    if value == true then
      listOfFailedModules = listOfFailedModules .. tostring(key) .. ','
      waitForOthers = true
    end
  end

  if waitForOthers then
    _G.logger:warning(nameOfModule .. ": Something went wrong while trying to save the parameters of theses modules: " .. string.sub(listOfFailedModules, 1, #listOfFailedModules-1))
    persistentData_Model.saveData()
  end
  persistentData_Model.moduleSaveCheck = {}
end
Timer.register(tmrCheckAllModules, 'OnExpired', handleOnCheckAllModulesSaved)

local function setModuleParameterName(module, name, loadOnReboot, instance, totalInstances)
  if instance then
    local pos = module .. instance
    _G.logger:fine(nameOfModule .. ': Set module parameter name: ' .. tostring(name) .. ' of instance no.' .. tostring(instance) .. ' of module ' .. tostring(module))
    persistentData_Model.parameters.parameterNames[pos] = name
    persistentData_Model.parameters.loadOnReboot[pos] = loadOnReboot

    if totalInstances then
      -- Store amount of instances to create for this module
      _G.logger:fine(nameOfModule .. ': Set total instances: ' .. tostring(totalInstances))
      persistentData_Model.parameters.totalInstances[module] = totalInstances
    end

  else
    _G.logger:fine(nameOfModule .. ': Set module parameter name: "' .. tostring(name) .. '" of module ' .. tostring(module))
    persistentData_Model.parameters.parameterNames[module] = name
    persistentData_Model.parameters.loadOnReboot[module] = loadOnReboot
  end

  CSK_PersistentData.addParameter(persistentData_Model.funcs.convertTable2Container(persistentData_Model.parameters), 'PersistentData_InitialParameterNames')

  persistentData_Model.moduleSaveCheck[module] = false

  local waitForOthers = false
  local multiSaveActive = false
  for key, value in pairs(persistentData_Model.moduleSaveCheck) do
    multiSaveActive = true
    if value == true then
      waitForOthers = true
    end
  end
  if multiSaveActive then
    if not waitForOthers then
      persistentData_Model.saveData()
      persistentData_Model.moduleSaveCheck = {}
    else
      tmrCheckAllModules:start()
    end
  end
end
Script.serveFunction("CSK_PersistentData.setModuleParameterName", setModuleParameterName)

local function getModuleParameterName(module, instance)
  if instance then
    local pos = module .. instance
    if persistentData_Model.parameters.parameterNames[pos] then
      if not persistentData_Model.parameters.totalInstances[module] then -- available since version 3.0.0
        return persistentData_Model.parameters.parameterNames[pos], persistentData_Model.parameters.loadOnReboot[pos]
      else
        return persistentData_Model.parameters.parameterNames[pos], persistentData_Model.parameters.loadOnReboot[pos], persistentData_Model.parameters.totalInstances[module]
      end
    else
      if persistentData_Model.parameters.totalInstances[module] then
        return nil, nil, persistentData_Model.parameters.totalInstances[module]
      else
        return nil
      end
    end
  else
    if persistentData_Model.parameters.parameterNames[module] then
      return persistentData_Model.parameters.parameterNames[module], persistentData_Model.parameters.loadOnReboot[module]
    else
      return nil
    end
  end
end
Script.serveFunction("CSK_PersistentData.getModuleParameterName", getModuleParameterName)

local function setSelectedParameterName(selection)
  if persistentData_Model.data[selection] then
    _G.logger:fine(nameOfModule .. ': Selected parameter: ' .. tostring(selection))
    currentSelectedParameters = selection
  else
    _G.logger:info(nameOfModule .. ': Parameter not available: ' .. tostring(selection))
  end
  Script.notifyEvent('PersistentData_OnNewParameterTableInfo', persistentData_Model.funcs.createJsonListForTableView(persistentData_Model.data[currentSelectedParameters]))
end
Script.serveFunction("CSK_PersistentData.setSelectedParameterName", setSelectedParameterName)

local function removeParameterViaUI()
  if currentSelectedParameters ~= '' then
    _G.logger:fine(nameOfModule .. ': Remove parameter: ' .. tostring(currentSelectedParameters))
    persistentData_Model.removeParameter(currentSelectedParameters)
    currentSelectedParameters = ''
    tmrPersistendData:start()
  else
    _G.logger:info(nameOfModule .. ': Parameter to remove not available.')
  end
end
Script.serveFunction("CSK_PersistentData.removeParameterViaUI", removeParameterViaUI)

local function fileUploadFinished(status)
  _G.logger:fine(nameOfModule .. ': File upload: ' .. tostring(status))
  if status then
    Script.notifyEvent('PersistentData_OnNewStatusTempFileAvailable', File.exists(persistentData_Model.tempPath))
  end
end
Script.serveFunction('CSK_PersistentData.fileUploadFinished', fileUploadFinished)

local function saveAllModuleConfigs(moduleList)
  local cskCrowns = {}

  persistentData_Model.moduleSaveCheck = {}
  tmrCheckAllModules:stop()

  if moduleList then
    local dataTable = persistentData_Model.funcs.convertContainer2Table(moduleList)
    for key, value in pairs(dataTable) do
      cskCrowns[key] = 'CSK_' .. value
    end
  else
    -- Get all available CROWNs
    cskCrowns = Engine.getCrowns()
  end

  for key, value in pairs(cskCrowns) do
    -- Check if CROWN is relevant
    local _, pos = string.find(value, 'CSK_')
    if pos then
      local exist = Script.isServedAsFunction(value .. '.sendParameters')
      if exist then
        local getStatus = Script.isServedAsFunction(value .. '.getStatusModuleActive')
        if getStatus then
          local isActive = Script.callFunction(value .. '.getStatusModuleActive')
          if isActive then
            local multiExist = Script.isServedAsFunction(value .. '.getInstancesAmount')
            if multiExist then
              local suc, amount = Script.callFunction(value .. '.getInstancesAmount')
              if suc then
                for i=1, amount do
                  local setInstanceExist = Script.isServedAsFunction(value .. '.setInstance')
                  if setInstanceExist then
                    Script.callFunctionAsync(value.. '.setInstance', i)
                    Script.callFunctionAsync(value .. '.setLoadOnReboot', true)
                    Script.callFunctionAsync(value .. '.sendParameters', true)
                    persistentData_Model.moduleSaveCheck[value] = true
                  else
                    local setSelectedInstanceExist = Script.isServedAsFunction(value .. '.setSelectedInstance')
                    if setSelectedInstanceExist then
                      Script.callFunctionAsync(value.. '.setSelectedInstance', i)
                      Script.callFunctionAsync(value .. '.setLoadOnReboot', true)
                      Script.callFunctionAsync(value .. '.sendParameters', true)
                      persistentData_Model.moduleSaveCheck[value] = true
                    else
                      _G.logger:warning(nameOfModule .. ': Set instance does not exist in module ' .. tostring(value))
                    end
                  end
                end
              end
            else
              Script.callFunctionAsync(value .. '.setLoadOnReboot', true)
              Script.callFunctionAsync(value .. '.sendParameters', true)
            end
          end
        end
      end
    end
  end
end
Script.serveFunction('CSK_PersistentData.saveAllModuleConfigs', saveAllModuleConfigs)

local function resetAllModules()
  Script.notifyEvent("PersistentData_OnResetAllModules")
end
Script.serveFunction('CSK_PersistentData.resetAllModules', resetAllModules)

local function removeData()
  persistentData_Model.removeCurrentData()
  pageCalled()
end
Script.serveFunction('CSK_PersistentData.removeData', removeData)

local function reloadApps()
  Engine.reloadApps()
end
Script.serveFunction('CSK_PersistentData.reloadApps', reloadApps)

local function rebootDevice()
  local typeName = Engine.getTypeName()
  if typeName == 'AppStudioEmulator' or typeName == 'SICK AppEngine' then
    _G.logger:warning(nameOfModule .. ': Function to reboot not supported by device!')
    Script.notifyEvent('PersistentData_OnNewFeedbackStatus', 'LOG')
  else
    _G.logger:info(nameOfModule .. ': Reboot triggered via CSK_PersistentData module.')
    Engine.reboot('Reboot triggered via CSK_PersistentData module.')
  end
end
Script.serveFunction('CSK_PersistentData.rebootDevice', rebootDevice)

return setPersistentData_Model_Handle

--**************************************************************************
--**********************End Function Scope *********************************
--**************************************************************************