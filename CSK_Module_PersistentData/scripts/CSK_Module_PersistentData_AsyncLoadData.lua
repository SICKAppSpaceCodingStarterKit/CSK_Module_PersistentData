---@diagnostic disable: undefined-global, redundant-parameter, missing-parameter

Script.serveEvent("CSK_PersistentData.OnNewThreadFeedbackStatus", "PersistentData_OnNewThreadFeedbackStatus")

-- If App property "LuaLoadAllEngineAPI" is FALSE, use this to load and check for required APIs
-- This can improve performance of garbage collection
local availableAPIs = require('Configuration/PersistentData/helper/checkAPIs') -- check for available APIs
local helperFuncs = require('Configuration/PersistentData/helper/funcs') -- Helper functions
-----------------------------------------------------------
local nameOfModule = 'CSK_PersistentData'

--Logger
_G.logger = Log.SharedLogger.create('ModuleLogger')
local json = require("Configuration.PersistentData.helper.Json")
local scriptParams = Script.getStartArgument() -- Get parameters from model

-- Timer to hide UI messages after 5 seconds
local logTmr = Timer.create()
logTmr:setExpirationTime(5000)
logTmr:setPeriodic(false)

--- Function to hide UI message
local function handleOnLogTmrExpired()
  Script.notifyEvent('PersistentData_OnNewThreadFeedbackStatus', 'EMPTY')
end
Timer.register(logTmr, 'OnExpired', handleOnLogTmrExpired)

--- Function to trigger other modules to load their specific parameters
---@param data Container Data container with parameters to load.
local function handleOnNewDataToLoad(data)
  local dataContent = helperFuncs.convertContainer2Table(data)
  local totalSuccess = true

  for key, value in pairs(dataContent.loadOnReboot) do
    if value == true then

      local moduleName = key

      -- Check if there is a number in ModuleName
      local posStart, posEnd = string.find(key, "%d")
      local instanceID = 1

      if posStart and posEnd then
        instanceID = tonumber(string.sub(key, posStart, posEnd))
        moduleName = string.sub(key, 1, posStart-1)
      end

      local instanceSelectionExists = Script.isServedAsFunction(moduleName .. '.setSelectedInstance')
      local setInstanceExists = Script.isServedAsFunction(moduleName .. '.setInstance')
      local instanceAmountExists = Script.isServedAsFunction(moduleName .. '.getInstancesAmount')
      local instanceAddExists = Script.isServedAsFunction(moduleName .. '.addInstance')
      local setParameterNameExists = Script.isServedAsFunction(moduleName .. '.setParameterName')
      local loadParametersExists = Script.isServedAsFunction(moduleName .. '.loadParameters')

      if setParameterNameExists and loadParametersExists then

        -- Check for Multi module
        if (instanceSelectionExists or setInstanceExists) and instanceAmountExists and instanceAddExists then

          if instanceID > 1 then

            --Check for amount if instance needs to be created
            local suc, amount = Script.callFunction(moduleName .. '.getInstancesAmount')
            while amount < instanceID do
              Script.callFunction(moduleName .. '.addInstance')
              suc, amount = Script.callFunction(moduleName .. '.getInstancesAmount')
            end

            if instanceSelectionExists then
              Script.callFunction(moduleName .. '.setSelectedInstance', instanceID)
            elseif setInstanceExists then
              Script.callFunction(moduleName .. '.setInstance', instanceID)
            end
          else
            if instanceSelectionExists then
              Script.callFunction(moduleName .. '.setSelectedInstance', 1)
            elseif setInstanceExists then
              Script.callFunction(moduleName .. '.setInstance', 1)
            end
          end
          Script.callFunction(moduleName .. '.setParameterName', dataContent.parameterNames[moduleName .. tostring(instanceID)])
        else
          Script.callFunction(moduleName .. '.setParameterName', dataContent.parameterNames[moduleName])
        end

        local _, loadSuccess = Script.callFunction(moduleName .. '.loadParameters')
        if loadSuccess ~= true then
          _G.logger:warning("Something went wrong when trying to load parameter '" .. tostring(value['parameterName']) .. "' for Module " .. tostring(moduleName))
          totalSuccess = false
        end

      else
        _G.logger:warning("Module '" .. moduleName .. '" does not support necessary persistent data functions.')
        totalSuccess = false
      end
    end
  end
end
Script.register('CSK_PersistentData.OnNewDataToLoad', handleOnNewDataToLoad)


--- Function to trigger other modules to load specific parameters
---@param moduleName string Name of module.
---@param parameterName string Name of parameters to load.
---@param instance? int Optional number of instance of module.
local function handleOnNewStatusSendParametersToModule(moduleName, parameterName, instance)

  local name = string.gsub(moduleName, '_1stModule_', '_')
  name = string.gsub(name, '_Module_', '_')
  name = string.gsub(name, '_Application_', '_')

  _G.logger:fine(nameOfModule .. ": Try to set parameters " .. tostring(parameterName) .. " to module " .. tostring(name) .. " (optional instance = " .. tostring(instance) .. ").")
  local instanceSelectionExists = false
  local setInstanceExists = false
  local instanceAmountExists = false

  if instance then
    instanceSelectionExists = Script.isServedAsFunction(name .. '.setSelectedInstance')
    setInstanceExists = Script.isServedAsFunction(name .. '.setInstance')
    instanceAmountExists = Script.isServedAsFunction(name .. '.getInstancesAmount')

    if instanceAmountExists then
      local _, amount = Script.callFunction(name .. '.getInstancesAmount')
      if amount <= instance then
        if instanceSelectionExists then
          Script.callFunction(name .. '.setSelectedInstance', instance)
        elseif setInstanceExists then
          Script.callFunction(name .. '.setInstance', instance)
        else
          _G.logger:warning(nameOfModule .. ": Not possible to set instance.")
          Script.notifyEvent('PersistentData_OnNewThreadFeedbackStatus', 'ERR')
          logTmr:start()
          return
        end
      else
        _G.logger:warning(nameOfModule .. ": Instance does not exists.")
        Script.notifyEvent('PersistentData_OnNewThreadFeedbackStatus', 'ERR')
        logTmr:start()
        return
      end
    end
  end

  local setParameterNameExists = Script.isServedAsFunction(name .. '.setParameterName')
  local loadParametersExists = Script.isServedAsFunction(name .. '.loadParameters')

  if setParameterNameExists and loadParametersExists then
    Script.callFunction(name .. '.setParameterName', parameterName)
    Script.sleep(1000)
    local _, suc = Script.callFunction(name .. '.loadParameters')
    if suc == nil or suc == false then
      Script.notifyEvent('PersistentData_OnNewThreadFeedbackStatus', 'ERR')
      logTmr:start()
    else
      Script.notifyEvent('PersistentData_OnNewThreadFeedbackStatus', 'OK')
      logTmr:start()
    end
  else
    _G.logger:warning(nameOfModule .. ": Not possible to load parameters.")
    Script.notifyEvent('PersistentData_OnNewThreadFeedbackStatus', 'ERR')
    logTmr:start()
  end
end
Script.register('CSK_PersistentData.OnNewStatusSendParametersToModule', handleOnNewStatusSendParametersToModule)
