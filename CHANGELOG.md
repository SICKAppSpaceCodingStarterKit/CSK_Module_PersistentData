# Changelog
All notable changes to this project will be documented in this file.

## Release 4.2.1

### Bugfix
- Legacy bindings of ValueDisplay elements and FileUpload feature within UI did not work if deployed with VS Code AppSpace SDK
- UI differs if deployed via Appstudio or VS Code AppSpace SDK
- Fullscreen icon of iFrame was visible

## Release 4.2.0

### New features
- Edit values within parameters via UI
- Trigger other modules to load specific parameters

## Release 4.1.0

### New features
- Provide version of module via 'OnNewStatusModuleVersion'
- Function 'saveAllModuleConfigs' to trigger multiple / all running CSK modules to save their persistent data
- Function to reload all apps ('reloadApps')
- Function to reboot device ('rebootDevice')
- Check if features of module can be used on device and provide this via 'OnNewStatusModuleIsActive' event / 'getStatusModuleActive' function
- Function 'resetAllModules' and event 'OnResetAllModules' so that other modules can react by loading their default setup
- Function 'removeData' to remove all data of current DataSet
- Function 'getCurrentParameterInfo' to get info what parameter file is currently in use
- Extra thread to trigger other modules to load their specific parameters if event 'OnNewDataToLoad' was notified

### Improvements
- New parameter for 'loadContent' to controle if other modules directly should react to new parameters
- New UI design available (selectable via 'setUIStyle')
- Added UI icon and browser tab information
- Added some documentation

## Release 4.0.1

### Bugfix
- Module expected to always have a parameter for instance 1. If this was not the case it did not return amount of instances within function 'getModuleParameterName' but it is necessary for other modules to load setup correctly event without saving parameters for instance 1.

## Release 4.0.0

### Improvements
- Renamed abbreviations ('removeParameterViaUi' to 'removeParameterViaUI')
- Using recursive helper functions to convert Container <-> Lua table

## Release 3.5.0

### Improvements
- Update to EmmyLua annotations
- Usage of lua diagnostics
- Documentation updates

## Release 3.4.1

### Bugfix
- Adding missing docu
- Removed internal docu of functions if manifest docu is available in parallel

## Release 3.4.0

### Improvements
- Checking if a variable is named with "Password"/"password" to hide its content in UI list

## Release 3.3.0

### Improvements
- Check within "getVersion" function if module was merged, so the app version is not related to this module...
- Using internal moduleName variable to be usable in merged apps instead of _APPNAME

## Release 3.2.1

### Improvements
- Naming of UI elements and adding some mouse over info texts
- Appname added to log messages
- Added ENUM
- Minor edits, docu, logs

### Bugfix
- UI events notified after pageLoad after 300ms instead of 100ms to not miss

## Release 3.2.0

### New features
- Optionally hide content related to CSK_UserManagement

### Improvements
- Loading only required APIs ('LuaLoadAllEngineAPI = false') -> less time for GC needed
- Minor code edits / docu updates

## Release 3.1.2

### Bugfix
- Fix deadlock in combination with UserManagement module

## Release 3.1.1

### Bugfix
- Prevent infinity loop by getting data from UserManagement module

## Release 3.1.0

### Improvements
- Supports now 4-dim tables for params
- Do not show passwords within parameters in UI
- Increase size for parameter name to 500 (was 50 before)
- Prepared for all CSK_UserManagement user levels: Operator, Maintenance, Service, Admin (no influence yet)
- Renamed page folder accordingly to module name
- Updated documentation

### Bugfix
- Fixed problems with showing unknown parameter content in UI and switching after that to other parameters (there was a problem with from CSK_Module_UserManagement parameters

## Release 3.0.0

### New features
- Amount of instances of each 'MulitInstance'-module is now saved within parameter binary file instead of single entry within CID parameters for all 'MultiInstance' modules. MultiInstance module needs to be adapted to this.

### Improvements
- Periodical check of tempFile changed

## 2.0.0

### New features
- Show parameters of datasets on UI
- Store info of parameter used for other modules (incl. "loadOnReboot") within binary file instead of AppSpace parameters (no need to adapt the Parameter file for every module)
  INFO: Make sure to update CSK modules to work with this (already implemented into latest CSK template versions)
- Removing parameter datasets via UI

### Improvements
- Update UI if parameters were edited

## 1.3.0

### New feature
- New function to load/save parameters with SubContainer

### Improvements
- Renamed files/variables from "Helper/Interface" to "Model/Controller" (MVC)

## 1.2.0

### New features
- Module will notify "CSK_PersistentData.OnInitialDataLoaded"-event so that other modules can register on that event to load their specific parameters as soon as they are available

## 1.1.0

### Improvements
- Auto load latest DataSet during app start
- Using unique local event names
- Better parameter structure

## 1.0.0
- Initial commit