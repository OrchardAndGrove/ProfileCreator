//
//  Profile.swift
//  ProfileCreator
//
//  Created by Erik Berglund.
//  Copyright © 2018 Erik Berglund. All rights reserved.
//

import Cocoa
import ProfilePayloads

public class Profile: NSDocument {
    
    // MARK: -
    // MARK: Variables
    
    // General Settings
    public var uuid: UUID
    public var identifier: UUID
    @objc public dynamic var title: String = ""
    
    private var savedSettings = Dictionary<String, Any>()
    
    public var payloadSettings: Dictionary<String, Dictionary<String, Dictionary<String, Any>>>
    public var profilePayloads: String? // Change to payloads framework class. Unsure if it should be used like this.
    
    var alert: Alert?
    
    // View Settings
    public var viewSettings: Dictionary<String, Any>
    public var scope: String? // Change to scope enum
    public var distribution: String? // Change to distribution enum
    public var sign = false
    
    @objc public var editorDisableOptionalKeys: Bool = false
    
    @objc public var editorShowHidden: Bool = false
    @objc public var editorShowSupervised: Bool = false
    @objc public var editorShowDisabled: Bool = false
    
    // Platform
    @objc public var editorShowIOS: Bool = false
    @objc public var editorShowMacOS: Bool = false
    @objc public var editorShowTvOS: Bool = false
    
    @objc public var editorColumnEnable: Bool = false
    
    public var enabledPayloadsCount: Int {
        var count = 0
        for typeDict in self.payloadSettings.values {
            for (domain, domainDict) in typeDict {
                if domain != ManifestDomain.general, let enabled = domainDict[SettingsKey.enabled] as? Bool, enabled {
                    count += 1
                }
            }
        }
        return count
    }
    
    // MARK: -
    // MARK: Initialization
    
    override convenience init() {
        self.init(title: nil, identifier: nil, payloadSettings: nil, viewSettings: nil)
    }
    
    init(title: String?, identifier: UUID?, payloadSettings: Dictionary<String, Dictionary<String, Dictionary<String, Any>>>?, viewSettings: Dictionary<String, Any>?) {
        
        let profileIdentifier = identifier ?? UUID()
        self.identifier = profileIdentifier
        self.payloadSettings = payloadSettings ?? Profile.defaultPayloadSettings(uuid: profileIdentifier)
        self.uuid = profileIdentifier
        self.viewSettings = viewSettings ?? Profile.defaultViewSettings()
        self.title = title ?? StringConstant.defaultProfileName
        
        // ---------------------------------------------------------------------
        //  Initialize Self
        // ---------------------------------------------------------------------
        super.init()
        
        // ---------------------------------------------------------------------
        //  Initialize View Settings
        // ---------------------------------------------------------------------
        self.initialize(viewSettings: self.viewSettings)
        
        // ---------------------------------------------------------------------
        //  Initialize Saved Settings
        // ---------------------------------------------------------------------
        self.savedSettings = self.saveDict()
    }
    
    // MARK: -
    // MARK: Private Functions
    
    private func initialize(viewSettings: Dictionary<String, Any>) {
        
        // Disable Optional Keys
        if let editorDisableOptionalKeys = viewSettings[PreferenceKey.editorDisableOptionalKeys] as? Bool {
            self.editorDisableOptionalKeys = editorDisableOptionalKeys
        } else { self.editorDisableOptionalKeys = false }
        
        // Editor Row Enable
        if let editorColumnEnable = viewSettings[PreferenceKey.editorColumnEnable] as? Bool {
            self.editorColumnEnable = editorColumnEnable
        } else { self.editorColumnEnable = false }
        
        // Editor Show Disabled
        if let editorShowDisabled = viewSettings[PreferenceKey.editorShowDisabledKeys] as? Bool {
            self.editorShowDisabled = editorShowDisabled
        } else { self.editorShowDisabled = false }
        
        // Editor Show Hidden
        if let editorShowHidden = viewSettings[PreferenceKey.editorShowHiddenKeys] as? Bool {
            self.editorShowHidden = editorShowHidden
        } else { self.editorShowHidden = false }
        
        // Editor Show Supervised
        if let editorShowSupervised = viewSettings[PreferenceKey.editorShowSupervisedKeys] as? Bool {
            self.editorShowSupervised = editorShowSupervised
        } else { self.editorShowSupervised = false }
        
        // Editor Show iOS
        if let editorShowIOS = viewSettings[PreferenceKey.editorShowIOS] as? Bool {
            self.editorShowIOS = editorShowIOS
        } else { self.editorShowIOS = true }
        
        // Editor Show macOS
        if let editorShowMacOS = viewSettings[PreferenceKey.editorShowMacOS] as? Bool {
            self.editorShowMacOS = editorShowMacOS
        } else { self.editorShowMacOS = true }
        
        // Editor Show tvOS
        if let editorShowTvOS = viewSettings[PreferenceKey.editorShowTvOS] as? Bool {
            self.editorShowTvOS = editorShowTvOS
        } else { self.editorShowTvOS = true }
    }
    
    private func saveDict() -> [String : Any] {
        
        // ---------------------------------------------------------------------
        //  Create dict to save
        // ---------------------------------------------------------------------
        var profileDict = Dictionary<String, Any>()
        
        profileDict[SettingsKey.title] = self.title
        profileDict[SettingsKey.identifier] = self.identifier.uuidString
        profileDict[SettingsKey.sign] = self.sign
        profileDict[SettingsKey.payloadSettings] = self.payloadSettings
        
        var viewSettings = self.viewSettings
        viewSettings[PreferenceKey.editorDisableOptionalKeys] = self.editorDisableOptionalKeys
        viewSettings[PreferenceKey.editorShowDisabledKeys] = self.editorShowDisabled
        viewSettings[PreferenceKey.editorShowHiddenKeys] = self.editorShowHidden
        viewSettings[PreferenceKey.editorShowSupervisedKeys] = self.editorShowSupervised
        viewSettings[PreferenceKey.editorShowIOS] = self.editorShowIOS
        viewSettings[PreferenceKey.editorShowMacOS] = self.editorShowMacOS
        viewSettings[PreferenceKey.editorShowTvOS] = self.editorShowTvOS
        
        profileDict[SettingsKey.viewSettings] = viewSettings
        
        return profileDict
    }
    
    func isSaved() -> Bool {
        
        // NOTE: Should maybe use: self.isDocumentEdited and update change counts instead
        
        // ---------------------------------------------------------------------
        //  Check if the profile settings has a url
        // ---------------------------------------------------------------------
        if self.fileURL == nil { return false }
        
        // ---------------------------------------------------------------------
        //  Check that all current settings match those on disk
        // ---------------------------------------------------------------------
        let saveDict = self.saveDict()
        for (key, value) in self.savedSettings {
            self.saveCheck(key: key, value: value, newValue: saveDict[key])
        }
        return self.savedSettings == self.saveDict()
    }
    
    // Check to debug save inconsistencies
    func saveCheck(key: String, value: Any, newValue: Any?) {
        if
            let valueDict = value as? Dictionary<String, Any>,
            let newValueDict = newValue as? Dictionary<String, Any> {
            if valueDict != newValueDict {
                Log.shared.debug(message: "The key: \(key) (Dictionary) has a new value")
                for (key, value) in valueDict {
                    self.saveCheck(key: key, value: value, newValue: newValueDict[key])
                }
                return
            }
        } else if
            let valueString = value as? String,
            let newValueString = newValue as? String {
            if valueString != newValueString {
                Log.shared.debug(message: "The key: \(key) (String) has a new value")
                Log.shared.debug(message: "The key: \(key) saved value: \(valueString)")
                Log.shared.debug(message: "The key: \(key) new value: \(newValueString)")
            }
            return
        } else if
            let valueInt = value as? Int,
            let newValueInt = newValue as? Int {
            if valueInt != newValueInt {
                Log.shared.debug(message: "The key: \(key) (Int) has a new value")
                Log.shared.debug(message: "The key: \(key) saved value: \(valueInt)")
                Log.shared.debug(message: "The key: \(key) new value: \(newValueInt)")
            }
            return
        } else if
            let valueBool = value as? Bool,
            let newValueBool = newValue as? Bool {
            if valueBool != newValueBool {
                Log.shared.debug(message: "The key: \(key) (Bool) has a new value")
                Log.shared.debug(message: "The key: \(key) saved value: \(valueBool)")
                Log.shared.debug(message: "The key: \(key) new value: \(newValueBool)")
            }
            return
        } else if
            let valueArray = value as? Array<Any>,
            let newValueArray = newValue as? Array<Any> {
            Log.shared.debug(message: "The key: \(key) (Array) might have a new value. Currently arrays can't be compared")
            Log.shared.debug(message: "The key: \(key) saved value: \(valueArray)")
            Log.shared.debug(message: "The key: \(key) new value: \(newValueArray)")
            /*
            if valueArray != newValueArray {
                Swift.print("This key has changed: \(key) (Array)")
                Swift.print("Saved Value: \(valueArray)")
                Swift.print("Edited Value: \(newValueArray)")
            }
 */
            return
        } else if let valueFloat = value as? Float,
            let newValueFloat = newValue as? Float {
            if valueFloat != newValueFloat {
                Log.shared.debug(message: "The key: \(key) (Float) has a new value")
                Log.shared.debug(message: "The key: \(key) saved value: \(valueFloat)")
                Log.shared.debug(message: "The key: \(key) new value: \(newValueFloat)")
            }
            return
        } else if let valueDate = value as? Date,
            let newValueDate = newValue as? Date {
            if valueDate != newValueDate {
                Log.shared.debug(message: "The key: \(key) (Date) has a new value")
                Log.shared.debug(message: "The key: \(key) saved value: \(valueDate)")
                Log.shared.debug(message: "The key: \(key) new value: \(newValueDate)")
            }
            return
        } else if let valueData = value as? Data,
            let newValueData = newValue as? Data {
            if valueData != newValueData {
                Log.shared.debug(message: "The key: \(key) (Data) has a new value")
                Log.shared.debug(message: "The key: \(key) saved value: \(valueData)")
                Log.shared.debug(message: "The key: \(key) new value: \(newValueData)")
            }
            return
        }
    }
    
    // MARK: -
    // MARK: NSDocument Functions
    
    override public func makeWindowControllers() {
        let windowController = ProfileEditorWindowController(profile: self)
        self.addWindowController(windowController)
    }
    
    override public func save(_ sender: Any?) {
        if self.title == StringConstant.defaultProfileName { self.showAlertUnsaved(closeWindow: false); return }
        self.save(operationType: .saveOperation) { saveError in
            if saveError == nil {
                Log.shared.log(message: "Saving profile: \"\(self.title)\" at path: \(self.fileURL?.path ?? "") was successful")
            } else {
                Log.shared.error(message: "Saving profile: \(self.title) failed with error: \(String(describing: saveError?.localizedDescription))")
            }
        }
    }
    
    override public func data(ofType typeName: String) throws -> Data {
        
        guard typeName == TypeName.profile else {
            // TODO: Proper Error
            throw NSError(domain: NSOSStatusErrorDomain, code: unimpErr, userInfo: nil)
        }
        
        
        do {
            let profileData = try PropertyListSerialization.data(fromPropertyList: self.saveDict(), format: .xml, options: 0)
            return profileData
        } catch let error {
            Swift.print("Error: \(error)")
            // TODO: Proper Logging
        }
        
        throw NSError(domain: NSOSStatusErrorDomain, code: unimpErr, userInfo: nil)
    }
    
    override public func read(from data: Data, ofType typeName: String) throws {
        
        guard typeName == TypeName.profile else {
            // TODO: Proper Error
            throw NSError(type: .unknown)
        }
        
        do {
            if let profileDict = try PropertyListSerialization.propertyList(from: data, options: [], format: nil) as? [String : Any] {
                guard let identifierString = profileDict[SettingsKey.identifier] as? String,
                    let identifier = UUID(uuidString: identifierString) else {
                        // TODO: Proper Error
                        throw NSError(domain: NSOSStatusErrorDomain, code: unimpErr, userInfo: nil)
                }
                self.restoreSavedSettings(identifier: identifier, savedSettings: profileDict)
                return
            }
        } catch {
            // TODO: Proper Logging
        }
        
        // Insert code here to read your document from the given data of the specified type. If outError != nil, ensure that you create and set an appropriate error when returning false.
        // You can also choose to override readFromFileWrapper:ofType:error: or readFromURL:ofType:error: instead.
        // If you override either of these, you should also override -isEntireFileLoaded to return false if the contents are lazily loaded.
        throw NSError(domain: NSOSStatusErrorDomain, code: unimpErr, userInfo: nil)
    }
    
    func showAlertUnsaved(closeWindow: Bool) {
        
        guard
            let windowController = self.windowControllers.first as? ProfileEditorWindowController,
            let window = windowController.window else { Swift.print("No window"); return }
        
        let alert = Alert()
        self.alert = alert
        
        let alertMessage = NSLocalizedString("Unsaved Settings", comment: "")
        let alertInformativeText = NSLocalizedString("If you close this window, all unsaved changes will be lost. Are you sure you want to close the window?", comment: "")
        
        if self.title == StringConstant.defaultProfileName {
            
            let firstButtonTitle: String
            if closeWindow {
                firstButtonTitle = ButtonTitle.saveAndClose
            } else {
                firstButtonTitle = ButtonTitle.save
            }
            
            let informativeText: String
            if self.isSaved() {
                informativeText = "You need to give your profile a name before it can be saved."
            } else {
                informativeText = alertInformativeText + "\n\nYou need to give your profile a name before it can be saved."
            }
            
            // ---------------------------------------------------------------------
            //  Show unnamed and unsaved settings alert to user
            // ---------------------------------------------------------------------
            alert.showAlert(message: alertMessage,
                            informativeText: informativeText,
                            window: window,
                            defaultString: StringConstant.defaultProfileName,
                            placeholderString: "Name",
                            firstButtonTitle: firstButtonTitle,
                            secondButtonTitle: ButtonTitle.close,
                            thirdButtonTitle: ButtonTitle.cancel,
                            firstButtonState: true,
                            sender: self,
                            returnValue: { (newProfileName, response) in
                                switch response {
                                case .alertFirstButtonReturn:
                                    self.updatePayloadSettings(value: newProfileName,
                                                               key: "PayloadDisplayName", // Somehow I cannot use the PayloadKey.payloadDisplayName here
                                        domain: ManifestDomain.general,
                                        type: .manifest, updateComplete: { (success, error) in
                                            if success {
                                                self.save(operationType: .saveOperation, completionHandler: { (saveError) in
                                                    if saveError == nil {
                                                        if closeWindow {
                                                            windowController.performSelector(onMainThread: #selector(windowController.windowClose), with: windowController, waitUntilDone: false)
                                                        }
                                                        Log.shared.log(message: "Saving profile: \"\(self.title)\" at path: \(self.fileURL?.path ?? "") was successful")
                                                    } else {
                                                        Log.shared.error(message: "Saving profile: \(self.title) failed with error: \(String(describing: saveError?.localizedDescription))")
                                                    }
                                                })
                                            }
                                    })
                                case .alertSecondButtonReturn:
                                    windowController.performSelector(onMainThread: #selector(windowController.windowClose), with: windowController, waitUntilDone: false)
                                case .alertThirdButtonReturn:
                                    Swift.print("Cancel")
                                default:
                                    Swift.print("Unknown Return")
                                }
            })
            
            // ---------------------------------------------------------------------
            //  Select the text field in the alert sheet
            // ---------------------------------------------------------------------
            if let textFieldInput = alert.textFieldInput {
                textFieldInput.selectText(self)
                alert.firstButton?.isEnabled = false
            }
        } else {
            
            // ---------------------------------------------------------------------
            //  Show unsaved settings alert to user
            // ---------------------------------------------------------------------
            self.alert?.showAlert(message: alertMessage,
                                  informativeText: alertInformativeText,
                                  window: window,
                                  firstButtonTitle: ButtonTitle.saveAndClose,
                                  secondButtonTitle: ButtonTitle.close,
                                  thirdButtonTitle: ButtonTitle.cancel,
                                  firstButtonState: true,
                                  sender: self,
                                  returnValue: { response  in
                                    
                                    switch response {
                                    case .alertFirstButtonReturn:
                                        self.save(operationType: .saveOperation, completionHandler: { (saveError) in
                                            if saveError == nil {
                                                windowController.performSelector(onMainThread: #selector(windowController.windowClose), with: windowController, waitUntilDone: false)
                                                Log.shared.log(message: "Saving profile: \"\(self.title)\" at path: \(self.fileURL?.path ?? "") was successful")
                                            } else {
                                                Log.shared.error(message: "Saving profile: \(self.title) failed with error: \(String(describing: saveError?.localizedDescription))")
                                            }
                                        })
                                    case .alertSecondButtonReturn:
                                        windowController.performSelector(onMainThread: #selector(windowController.windowClose), with: windowController, waitUntilDone: false)
                                    case .alertThirdButtonReturn:
                                        Swift.print("Cancel")
                                    default:
                                        Swift.print("Unknown")
                                    }
            })
        }
    }
    
    // MARK: -
    // MARK: Public Functions
    
    func restoreSavedSettings(identifier: UUID, savedSettings: Dictionary<String, Any>?) {
        let settingsDict = savedSettings ?? self.savedSettings
        self.savedSettings = settingsDict
        self.identifier = identifier
        
        // PayloadSettings
        self.payloadSettings = settingsDict[SettingsKey.payloadSettings] as? Dictionary<String, Dictionary<String, Dictionary<String, Any>>> ?? Dictionary<String, Dictionary<String, Dictionary<String, Any>>>()
        
        // ViewSettings
        self.viewSettings = settingsDict[SettingsKey.viewSettings] as? Dictionary<String, Any> ?? Dictionary<String, Any>()
        self.initialize(viewSettings: self.viewSettings)
        
        if let title = self.getPayloadSetting(key: PayloadKey.payloadDisplayName, domain: ManifestDomain.general, type: .manifest) as? String {
            self.title = title
        } else { self.title = StringConstant.defaultProfileName }
    }
    
    func updatePayloadSelection(selected: Bool, payloadSource: PayloadSource, updateComplete: @escaping (Bool, Error?) -> ()) {
        
        // ---------------------------------------------------------------------
        //  Get the current domain settings or create an empty set if they doesn't exist
        // ---------------------------------------------------------------------
        var typeSettings = self.payloadTypeSettings(type: payloadSource.type)
        var domainSettings = typeSettings[payloadSource.domain] ?? Dictionary<String, Any>()
        
        // ---------------------------------------------------------------------
        //  Verify the domain has the required settings
        // ---------------------------------------------------------------------
        self.updateDomainSettings(&domainSettings)
        
        // ---------------------------------------------------------------------
        //  Set the new value
        // ---------------------------------------------------------------------
        domainSettings[SettingsKey.enabled] = selected
        
        // ---------------------------------------------------------------------
        //  If disabled an no other settings are set, remove the domain
        // ---------------------------------------------------------------------
        if !selected, domainSettings.keys.count <= 3 {
            typeSettings.removeValue(forKey: payloadSource.domain)
        } else {
            typeSettings[payloadSource.domain] = domainSettings
        }
        
        // ---------------------------------------------------------------------
        //  Save the the changes to the current settings
        // ---------------------------------------------------------------------
        self.setPayloadTypeSettings(settings: typeSettings, type: payloadSource.type)
        
        // ---------------------------------------------------------------------
        //  Using closure for the option of a longer save time if needed in the future for more checking etc.
        // ---------------------------------------------------------------------
        updateComplete(true, nil)
    }
    
    func updateDomainSettings(_ domainSettings: inout Dictionary<String, Any>) {
        
        // Verify PayloadUUID
        if domainSettings[PayloadKey.payloadUUID] == nil { domainSettings[PayloadKey.payloadUUID] = UUID().uuidString }
        
        // Verify PayloadVersion
        if domainSettings[PayloadKey.payloadVersion] == nil { domainSettings[PayloadKey.payloadVersion] = 1 }
    }
    
    public func edit() {
        let windowController: NSWindowController
        if 0 < self.windowControllers.count {
            windowController = self.windowControllers.first!
        } else {
            windowController = ProfileEditorWindowController(profile: self)
            self.addWindowController(windowController)
        }
        
        windowController.window?.makeKeyAndOrderFront(self)
    }
    
    func save(operationType: NSDocument.SaveOperationType, completionHandler: @escaping (Error?) -> Void) {
        
        // ---------------------------------------------------------------------
        //  Get path to profile save folder
        // ---------------------------------------------------------------------
        guard let profileFolderURL = applicationFolder(Folder.profiles) else {
            // TODO: Proper logging
            return
        }
        
        // ---------------------------------------------------------------------
        //  Get or create a new path for the profile save file
        // ---------------------------------------------------------------------
        let saveURL = self.fileURL ?? profileFolderURL.appendingPathComponent(self.identifier.uuidString).appendingPathExtension(FileExtension.profile)
        
        // ---------------------------------------------------------------------
        //  Call the NSDocument save function
        // ---------------------------------------------------------------------
        super.save(to: saveURL, ofType: TypeName.profile, for: operationType) { (saveError) in
            if saveError == nil {
                // -----------------------------------------------------------------
                //  Post notification that this profile was renamed
                // -----------------------------------------------------------------
                NotificationCenter.default.post(name: .didSaveProfile, object: self, userInfo: [NotificationKey.identifier : self.identifier])
                self.savedSettings = self.saveDict()
                completionHandler(nil)
            } else { completionHandler(saveError) }
        }
    }
    
    func update(title: String) {
        
        // TODO: Update title and displayname in settings
        
        self.title = title
    }
    
    // MARK: -
    // MARK: Subkey Check
    
    func subkeyIsEnabled(subkey: PayloadSourceSubkey) -> Bool {
        var isEnabled = !self.editorDisableOptionalKeys
        if subkey.require == .always {
            return true
        } else if
            let domainViewSettings = self.payloadViewTypeSettings(type: subkey.payloadSourceType)[subkey.domain] as? Dictionary<String, Any>,
            let viewSettings = domainViewSettings[subkey.keyPath] as? Dictionary<String, Any>,
            let enabled = viewSettings[SettingsKey.enabled] as? Bool {
            isEnabled = enabled
        } else if let enabledDefault = subkey.enabledDefault {
            isEnabled = enabledDefault
        }
        
        if !isEnabled {
            for childSubkey in subkey.subkeys {
                if self.subkeyIsEnabled(subkey: childSubkey) {
                    isEnabled = true
                    break
                }
            }
        }
        
        return isEnabled
    }
    
    // MARK: -
    // MARK: View Settings
    
    class func defaultViewSettings() -> Dictionary<String, Any> {
        return [ PreferenceKey.editorDisableOptionalKeys : UserDefaults.standard.bool(forKey: PreferenceKey.editorDisableOptionalKeys),
                 PreferenceKey.editorColumnEnable : UserDefaults.standard.bool(forKey: PreferenceKey.editorColumnEnable),
                 PreferenceKey.editorShowDisabledKeys : UserDefaults.standard.bool(forKey: PreferenceKey.editorShowDisabledKeys),
                 PreferenceKey.editorShowHiddenKeys : UserDefaults.standard.bool(forKey: PreferenceKey.editorShowHiddenKeys),
                 PreferenceKey.editorShowSupervisedKeys : UserDefaults.standard.bool(forKey: PreferenceKey.editorShowSupervisedKeys) ]
    }
    
    func payloadViewTypeSettings(type: PayloadSourceType) -> Dictionary<String, Any> {
        return self.viewSettings[String(type.rawValue)] as? Dictionary<String, Any> ?? Dictionary<String, Any>()
    }
    
    func setPayloadViewTypeSettings(settings: Dictionary<String, Any>, type: PayloadSourceType) {
        self.viewSettings[String(type.rawValue)] = settings
    }
    
    func updateViewSettings(value: Any?, key: String, subkey: PayloadSourceSubkey, updateComplete: @escaping (Bool, Error?) -> ()) {
        self.updateViewSettings(value: value, key: key, keyPath: subkey.keyPath, domain: subkey.domain, type: subkey.payloadSourceType, updateComplete: updateComplete)
    }
    
    func updateViewSettings(value: Any?, key: String, keyPath: String?, domain: String, type: PayloadSourceType, updateComplete: @escaping (Bool, Error?) -> ()) {
        
        // ---------------------------------------------------------------------
        //  Get the current domain settings or create an empty set if they doesn't exist
        // ---------------------------------------------------------------------
        var typeSettings = self.payloadViewTypeSettings(type: type)
        var domainSettings = typeSettings[domain] as? Dictionary<String, Any> ?? Dictionary<String, Any>()
        
        // ---------------------------------------------------------------------
        //  Set the new value
        // ---------------------------------------------------------------------
        if let payloadKeyPath = keyPath {
            var keySettings = domainSettings[payloadKeyPath] as? Dictionary<String, Any> ?? Dictionary<String, Any>()
            keySettings[key] = value
            domainSettings[payloadKeyPath] = keySettings
            typeSettings[domain] = domainSettings
        } else {
            domainSettings[key] = value
            typeSettings[domain] = domainSettings
        }
        
        // ---------------------------------------------------------------------
        //  Save the the changes to the current settings
        // ---------------------------------------------------------------------
        self.setPayloadViewTypeSettings(settings: typeSettings, type: type)
        
        updateComplete(true, nil)
    }
    
    func isEnabled(payloadSource: PayloadSource) -> Bool {
        let domainSettings = self.payloadDomainSettings(domain: payloadSource.domain, type: payloadSource.type)
        return domainSettings[SettingsKey.enabled] as? Bool ?? false
    }
    
    // MARK: -
    // MARK: Payload Settings
    
    class func defaultPayloadSettings(uuid: UUID) -> Dictionary<String, Dictionary<String, Dictionary<String, Any>>> {
        
        let defaultOrganizationName = UserDefaults.standard.string(forKey: PreferenceKey.defaultOrganization) ?? "ProfileCreator"
        
        let defaultOrganizationIdentifier = UserDefaults.standard.string(forKey: PreferenceKey.defaultOrganizationIdentifier) ?? "com.profilecreator"
        let defaultIdentifier = defaultOrganizationIdentifier + ".\(uuid.uuidString)"
        
        let payloadDomainSettings: Dictionary<String, Any> = [
            PayloadKey.payloadVersion : 1,
            PayloadKey.payloadUUID : uuid.uuidString,
            PayloadKey.payloadIdentifier : defaultIdentifier,
            PayloadKey.payloadOrganization : defaultOrganizationName,
            PayloadKey.payloadDisplayName : StringConstant.defaultProfileName
        ]
        
        let payloadTypeSettings: Dictionary<String, Dictionary<String, Any>> = [
            ManifestDomain.general : payloadDomainSettings
        ]
        
        return [String(PayloadSourceType.manifest.rawValue) : payloadTypeSettings]
    }
    
    func payloadDomainSettings(domain: String, type: PayloadSourceType) -> Dictionary<String, Any> {
        let payloadTypeSettings = self.payloadTypeSettings(type: type)
        return payloadTypeSettings[domain] ?? Dictionary<String, Any>()
    }
    
    func payloadTypeSettings(type: PayloadSourceType) -> Dictionary<String, Dictionary<String, Any>> {
        return self.payloadSettings[String(type.rawValue)] ?? Dictionary<String, Dictionary<String, Any>>()
    }
    
    func setPayloadTypeSettings(settings: Dictionary<String, Dictionary<String, Any>>, type: PayloadSourceType) {
        self.payloadSettings[String(type.rawValue)] = settings
    }
    
    func updatePayloadSettings(value: Any?, subkey: PayloadSourceSubkey, updateComplete: @escaping (Bool, Error?) -> ()) {
        self.updatePayloadSettings(value: value, key: subkey.keyPath, domain: subkey.domain, type: subkey.payloadSourceType, updateComplete: updateComplete)
    }
    
    func updatePayloadSettings(value: Any?, key: String, subkey: PayloadSourceSubkey, updateComplete: @escaping (Bool, Error?) -> ()) {
        var keyPath = key
        var subkeyPathArray = subkey.keyPath.components(separatedBy: ".")
        if 1 < subkeyPathArray.count {
            subkeyPathArray.removeLast()
            keyPath = "\(subkeyPathArray.joined(separator: ".")).\(key)"
        }
        self.updatePayloadSettings(value: value, key: keyPath, domain: subkey.domain, type: subkey.payloadSourceType, updateComplete: updateComplete)
    }
    
    // For getting the currently in memory value
    func getPayloadSetting(key: String, domain: String, type: PayloadSourceType) -> Any? {
        var typeSettings = self.payloadTypeSettings(type: type)
        var domainSettings = typeSettings[domain] ?? Dictionary<String, Any>()
        return domainSettings[key]
    }
    
    func updatePayloadSettings(value: Any?, key: String, domain: String, type: PayloadSourceType, updateComplete: @escaping (Bool, Error?) -> ()) {
        
        // ---------------------------------------------------------------------
        //  Get the current domain settings or create an empty set if they doesn't exist
        // ---------------------------------------------------------------------
        var typeSettings = self.payloadTypeSettings(type: type)
        var domainSettings = typeSettings[domain] ?? Dictionary<String, Any>()
        
        // ---------------------------------------------------------------------
        //  Set the new value
        // ---------------------------------------------------------------------
        domainSettings[key] = value
        
        // ---------------------------------------------------------------------
        //  Verify the domain has the required settings
        // ---------------------------------------------------------------------
        self.updateDomainSettings(&domainSettings)
        
        // ---------------------------------------------------------------------
        //
        // ---------------------------------------------------------------------
        typeSettings[domain] = domainSettings
        
        // ---------------------------------------------------------------------
        //  Save the the changes to the current settings
        // ---------------------------------------------------------------------
        self.setPayloadTypeSettings(settings: typeSettings, type: type)
        
        // ---------------------------------------------------------------------
        //  If this is the payload name setting, then update the profile title
        // ---------------------------------------------------------------------
        if key == PayloadKey.payloadDisplayName, type == .manifest, let title = value as? String {
            self.title = title
        }
        
        // ---------------------------------------------------------------------
        //  Using closure for the option of a longer save time if needed in the future for more checking etc.
        // ---------------------------------------------------------------------
        updateComplete(true, nil)
    }
    
    // MARK: -
    // MARK: Saved Settings
    
    func savedPayloadTypeSettings(type: PayloadSourceType) -> Dictionary<String, Any> {
        let savedPayloadSettings = self.savedSettings[SettingsKey.payloadSettings] as? Dictionary<String, Any> ?? Dictionary<String, Any>()
        return savedPayloadSettings[String(type.rawValue)] as? Dictionary<String, Any> ?? Dictionary<String, Any>()
    }
    
    // For getting the currently saved on disk value
    func getSavedPayloadSetting(key: String, domain: String, type: PayloadSourceType) -> Any? {
        var typeSettings = self.savedPayloadTypeSettings(type: type)
        var domainSettings = typeSettings[domain] as? Dictionary<String, Any> ?? Dictionary<String, Any>()
        return domainSettings[key]
    }
}

// MARK: -
// MARK: NSTextFieldDelegate Functions
extension Profile: NSTextFieldDelegate {
    
    // -------------------------------------------------------------------------
    //  Used when selecting a new profile name to not allow default or empty name
    // -------------------------------------------------------------------------
    override public func controlTextDidChange(_ notification: Notification) {
        
        // ---------------------------------------------------------------------
        //  Get current text in the text field
        // ---------------------------------------------------------------------
        guard let userInfo = notification.userInfo,
            let fieldEditor = userInfo["NSFieldEditor"] as? NSTextView,
            let string = fieldEditor.textStorage?.string else {
                return
        }
        
        // ---------------------------------------------------------------------
        //  If current text in the text field is either:
        //   * Empty
        //   * Matches the default profile name
        //  Disable the OK button.
        // ---------------------------------------------------------------------
        if let alert = self.alert {
            if alert.firstButton!.isEnabled && (string.isEmpty || string == StringConstant.defaultProfileName) {
                alert.firstButton!.isEnabled = false
            } else {
                alert.firstButton!.isEnabled = true
            }
        }
    }
}
