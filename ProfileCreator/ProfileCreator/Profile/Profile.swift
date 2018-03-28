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
    
    internal var savedSettings = Dictionary<String, Any>()
    
    public var payloadSettings: Dictionary<String, Dictionary<String, Dictionary<String, Any>>>
    public var profilePayloads: String? // Change to payloads framework class. Unsure if it should be used like this.
    
    var alert: Alert?
    
    var conditionResults = Dictionary<String, Any>()
    weak var conditionSubkey: PayloadSourceSubkey?
    
    // View Settings
    public var viewSettings: Dictionary<String, Any>
    public var scope: String? // Change to scope enum
    // public var distribution: Distribution // Change to distribution enum
    public var sign = false
    
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
    // MARK: Key/Value Observing Variables
    
    // Disable Optional Keys
    @objc public var editorDisableOptionalKeys: Bool = false
    public let editorDisableOptionalKeysSelector: String
    
    // Distribution Method
    @objc public var editorDistributionMethod: String = DistributionString.any
    public let editorDistributionMethodSelector: String
    
    // Show Disabled
    @objc public var editorShowDisabled: Bool = false
    public let editorShowDisabledSelector: String
    
    // Show Hidden
    @objc public var editorShowHidden: Bool = false
    public let editorShowHiddenSelector: String
    
    // Show Supervised
    @objc public var editorShowSupervised: Bool = false
    public let editorShowSupervisedSelector: String
    
    // Show Platform iOS
    @objc public var editorShowIOS: Bool = false
    public let editorShowIOSSelector: String
    
    // Show Platform macOS
    @objc public var editorShowMacOS: Bool = false
    public let editorShowMacOSSelector: String
    
    // Show Platform tvOS
    @objc public var editorShowTvOS: Bool = false
    public let editorShowTvOSSelector: String
    
    // Show Column Enable
    @objc public var editorColumnEnable: Bool = false
    public let editorColumnEnableSelector: String
    
    // Show Scope User
    @objc public var editorShowScopeUser: Bool = false
    public let editorShowScopeUserSelector: String
    
    // Show Scope System
    @objc public var editorShowScopeSystem: Bool = false
    public let editorShowScopeSystemSelector: String
    
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
        //  Initialize Key/Value Observing Selector Strings
        // ---------------------------------------------------------------------
        self.editorDistributionMethodSelector = NSStringFromSelector(#selector(getter: self.editorDistributionMethod))
        self.editorDisableOptionalKeysSelector = NSStringFromSelector(#selector(getter: self.editorDisableOptionalKeys))
        self.editorColumnEnableSelector = NSStringFromSelector(#selector(getter: self.editorColumnEnable))
        self.editorShowDisabledSelector = NSStringFromSelector(#selector(getter: self.editorShowDisabled))
        self.editorShowHiddenSelector = NSStringFromSelector(#selector(getter: self.editorShowHidden))
        self.editorShowSupervisedSelector = NSStringFromSelector(#selector(getter: self.editorShowSupervised))
        self.editorShowIOSSelector = NSStringFromSelector(#selector(getter: self.editorShowIOS))
        self.editorShowMacOSSelector = NSStringFromSelector(#selector(getter: self.editorShowMacOS))
        self.editorShowTvOSSelector = NSStringFromSelector(#selector(getter: self.editorShowTvOS))
        self.editorShowScopeUserSelector = NSStringFromSelector(#selector(getter: self.editorShowScopeUser))
        self.editorShowScopeSystemSelector = NSStringFromSelector(#selector(getter: self.editorShowScopeSystem))
        
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
        
        // ---------------------------------------------------------------------
        //  Setup Notification Observers
        // ---------------------------------------------------------------------
        self.addObserver(self, forKeyPath: self.editorDistributionMethodSelector, options: .new, context: nil)
        self.addObserver(self, forKeyPath: self.editorDisableOptionalKeysSelector, options: .new, context: nil)
    }
    
    private func initialize(viewSettings: Dictionary<String, Any>) {
        
        // Disable Optional Keys
        if let editorDisableOptionalKeys = viewSettings[PreferenceKey.editorDisableOptionalKeys] as? Bool {
            self.editorDisableOptionalKeys = editorDisableOptionalKeys
        } else { self.editorDisableOptionalKeys = false }
        
        // Distribution Method
        if let editorDistributionMethod = viewSettings[PreferenceKey.editorDistributionMethod] as? String {
            self.editorDistributionMethod = editorDistributionMethod
        } else { self.editorDistributionMethod = DistributionString.any }
        
        // Editor Column Enable
        if let editorColumnEnable = viewSettings[PreferenceKey.editorColumnEnable] as? Bool {
            self.editorColumnEnable = editorColumnEnable
        } else { self.editorColumnEnable = false }
        
        // Show Disabled
        if let editorShowDisabled = viewSettings[PreferenceKey.editorShowDisabledKeys] as? Bool {
            self.editorShowDisabled = editorShowDisabled
        } else { self.editorShowDisabled = false }
        
        // Show Hidden
        if let editorShowHidden = viewSettings[PreferenceKey.editorShowHiddenKeys] as? Bool {
            self.editorShowHidden = editorShowHidden
        } else { self.editorShowHidden = false }
        
        // Show Supervised
        if let editorShowSupervised = viewSettings[PreferenceKey.editorShowSupervisedKeys] as? Bool {
            self.editorShowSupervised = editorShowSupervised
        } else { self.editorShowSupervised = false }
        
        // Show Platform iOS
        if let editorShowIOS = viewSettings[PreferenceKey.editorShowIOS] as? Bool {
            self.editorShowIOS = editorShowIOS
        } else { self.editorShowIOS = true }
        
        // Show Platform  macOS
        if let editorShowMacOS = viewSettings[PreferenceKey.editorShowMacOS] as? Bool {
            self.editorShowMacOS = editorShowMacOS
        } else { self.editorShowMacOS = true }
        
        // Show Platform  tvOS
        if let editorShowTvOS = viewSettings[PreferenceKey.editorShowTvOS] as? Bool {
            self.editorShowTvOS = editorShowTvOS
        } else { self.editorShowTvOS = true }
        
        // Show Scope User
        if let editorShowScopeUser = viewSettings[PreferenceKey.editorShowScopeUser] as? Bool {
            self.editorShowScopeUser = editorShowScopeUser
        } else { self.editorShowScopeUser = true }
        
        // Show Scope System
        if let editorShowScopeSystem = viewSettings[PreferenceKey.editorShowScopeSystem] as? Bool {
            self.editorShowScopeSystem = editorShowScopeSystem
        } else { self.editorShowScopeSystem = true }
    }
    
    deinit {
        self.removeObserver(self, forKeyPath: self.editorDistributionMethodSelector, context: nil)
        self.removeObserver(self, forKeyPath: self.editorDisableOptionalKeysSelector, context: nil)
    }
    
    // MARK: -
    // MARK: Key/Value Observing Functions
    
    override public func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        switch keyPath ?? "" {
        case self.editorDistributionMethodSelector,
             self.editorDisableOptionalKeysSelector:
            self.resetConditionResults()
        default:
            Swift.print("Class: \(self.self), Function: \(#function), observeValueforKeyPath: \(String(describing: keyPath))")
        }
    }
    
    // MARK: -
    // MARK: Private Functions
    
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
        viewSettings[PreferenceKey.editorDistributionMethod] = self.editorDistributionMethod
        viewSettings[PreferenceKey.editorDisableOptionalKeys] = self.editorDisableOptionalKeys
        viewSettings[PreferenceKey.editorShowDisabledKeys] = self.editorShowDisabled
        viewSettings[PreferenceKey.editorShowHiddenKeys] = self.editorShowHidden
        viewSettings[PreferenceKey.editorShowSupervisedKeys] = self.editorShowSupervised
        viewSettings[PreferenceKey.editorShowIOS] = self.editorShowIOS
        viewSettings[PreferenceKey.editorShowMacOS] = self.editorShowMacOS
        viewSettings[PreferenceKey.editorShowTvOS] = self.editorShowTvOS
        viewSettings[PreferenceKey.editorShowScopeUser] = self.editorShowScopeUser
        viewSettings[PreferenceKey.editorShowScopeSystem] = self.editorShowScopeSystem
        
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
        //  Get dictionary to sae to disk
        // ---------------------------------------------------------------------
        let saveDict = self.saveDict()
        
        // ---------------------------------------------------------------------
        //  DEBUG: Check that all current settings match those on disk
        // ---------------------------------------------------------------------
        #if DEBUG
            for (key, value) in self.savedSettings {
                self.saveCheck(key: key, value: value, newValue: saveDict[key])
            }
        #endif
        
        // ---------------------------------------------------------------------
        //  Update savedSettings variable with the saved dictionary
        // ---------------------------------------------------------------------
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
                                    self.updatePayloadSettings(value: newProfileName, key: PayloadKey.payloadDisplayName, domain: ManifestDomain.general, type: .manifest)
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
        var typeSettings = self.getPayloadTypeSettings(type: payloadSource.type)
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
        guard let profileFolderURL = applicationFolder(.profiles) else {
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
}

// MARK: -
// MARK: Payload Source

extension Profile {
    
    // MARK: -
    // MARK: Payload Source: Check
    
    func isEnabled(payloadSource: PayloadSource) -> Bool {
        let domainSettings = self.getPayloadDomainSettings(domain: payloadSource.domain, type: payloadSource.type)
        return domainSettings[SettingsKey.enabled] as? Bool ?? false
    }
}

// MARK: -
// MARK: Payload Subkey

extension Profile {
    
    // MARK: -
    // MARK: Payload Subkey: Check
    
    func isExcluded(subkey: PayloadSourceSubkey) -> Bool {
        return false
    }
    
    func isRequired(subkey: PayloadSourceSubkey) -> Bool {
        if subkey.require == .always {
            return true
        }
        
        let isDistributionMethodPush = self.editorDistributionMethod == DistributionString.push
        
        if isDistributionMethodPush, subkey.require == .push {
            return true
        }
        
        if let conditionSubkey = self.conditionSubkey, conditionSubkey == subkey { Swift.print("This is an infinite loop, returning false"); return false }
        
        let requiredConditionals = subkey.conditionals.flatMap({ $0.require != .none ? $0 : nil })
        if !requiredConditionals.isEmpty {
            return self.subkeyMatchConditionals(conditionals: requiredConditionals)
        }
        
        return false
    }
    
    func isEnabled(subkey: PayloadSourceSubkey, onlyByUser: Bool) -> Bool {
        
        var parentIsEnabled = true
        if !onlyByUser, let parentSubkeys = subkey.parentSubkeys {
            if !(parentSubkeys.count == 1 && parentSubkeys.first?.rootSubkey == nil && parentSubkeys.first?.type == .dictionary) {
                for parentSubkey in parentSubkeys {
                    if !self.isEnabled(subkey: parentSubkey, onlyByUser: false) {
                        parentIsEnabled = false
                    }
                }
            }
        }
        
        if parentIsEnabled, subkey.parentSubkey?.type == .array {
            return true
        }
        
        //Log.shared.debug(message: "Subkey parent is enabled: \(parentIsEnabled)", category: #function)
        
        var isEnabled = !self.editorDisableOptionalKeys
        if !onlyByUser, parentIsEnabled, self.isRequired(subkey: subkey) {
            //Log.shared.debug(message: "Subkey: \(subkey.keyPath) is enabled: \(true) (required)", category: #function)
            return true
        } else if
            let viewSettings = self.subkeyViewSettings(subkey: subkey),
            let enabled = viewSettings[SettingsKey.enabled] as? Bool {
            //Log.shared.debug(message: "Subkey: \(subkey.keyPath) is enabled: \(enabled) (user)", category: #function)
            isEnabled = enabled
        } else if !onlyByUser, parentIsEnabled, let enabledDefault = subkey.enabledDefault {
            //Log.shared.debug(message: "Subkey: \(subkey.keyPath) is enabled: \(enabledDefault) (default)", category: #function)
            isEnabled = enabledDefault
        } else if !onlyByUser, parentIsEnabled, subkey.parentSubkey?.type == .dictionary, (subkey.key == ManifestKeyPlaceholder.key || subkey.key == ManifestKeyPlaceholder.value) {
            //Log.shared.debug(message: "Subkey: \(subkey.keyPath) is enabled: \(true) (dynamic dictionary)", category: #function)
            return true
        }
        
        if !isEnabled {
            for childSubkey in subkey.subkeys {
                if self.isEnabled(subkey: childSubkey, onlyByUser: true) {
                    isEnabled = true
                    break
                }
            }
        }
        
        return isEnabled
    }
    
    // MARK: -
    // MARK: Payload Subkey: Get Value
    
    func getPlaceholderString(subkey: PayloadSourceSubkey) -> String? {
        if let valuePlaceholder = subkey.valuePlaceholder as? String {
            return valuePlaceholder
        } else if self.isRequired(subkey: subkey) {
            return NSLocalizedString("Required", comment: "")
        } else if subkey.require == .push {
            return NSLocalizedString("Set On Device", comment: "")
        }
        return nil
    }
    
    func subkeyMatch(targetCondition: PayloadSourceTargetCondition) -> Bool {
        
        // Check cached value
        if let conditionResult = self.conditionResults[targetCondition.identifier] as? Bool {
            #if DEBUG
                Log.shared.debug(message: "Returning cached condition result: \(conditionResult)", category: String(describing: self))
            #endif
            return conditionResult
        }
        
        // Verify we got a targetSubkey
        guard let targetSubkey = targetCondition.targetSubkey() else { return false }
        self.conditionSubkey = targetSubkey
        
        // Set match var
        var match = false
        
        // Present
        if let isPresent = targetCondition.isPresent, isPresent {
            match = self.isEnabled(subkey: targetSubkey, onlyByUser: false)
        }
        
        // Contains Any
        if let containsAny = targetCondition.containsAny {
            
            let export = ProfileExport()
            export.ignoreSave = true
            export.ignoreErrorInvalidValue = true
            
            var payloadContent = Dictionary<String, Any>()
            
            do {
                try export.updatePayloadContent(subkey: targetSubkey,
                                                typeSettings: self.getPayloadTypeSettings(type: targetSubkey.payloadSourceType),
                                                domainSettings: self.getPayloadDomainSettings(domain: targetSubkey.domain, type: targetSubkey.payloadSourceType),
                                                payloadContent: &payloadContent)
                
                if let targetValue = payloadContent[targetSubkey.key] {
                    match = containsAny.contains(value: targetValue, ofType: targetSubkey.type)
                }
            } catch { Log.shared.error(message: "Failed to get payload content for subkey with keyPath: \(targetSubkey.keyPath)", category: String(describing: self)) }
        }
        
        // Cache the condition result
        self.conditionResults[targetCondition.identifier] = match
        
        return match
    }
    
    func subkeyMatchConditionals(conditionals: [PayloadSourceCondition]) -> Bool {
        var match = false
        for sourceCondition in conditionals {
            for targetCondition in sourceCondition.conditions {
                match = self.subkeyMatch(targetCondition: targetCondition)
                
                // Reset subkey
                self.conditionSubkey = nil
                
                if !match {
                    return false
                }
            }
        }
        return match
    }
    
    func resetConditionResults() {
        self.conditionResults = Dictionary<String, Any>()
    }
    
    func subkeyViewSettings(subkey: PayloadSourceSubkey) -> Dictionary<String, Any>? {
        if
            let payloadViewDomainSettings = self.getPayloadViewDomainSettings(domain: subkey.domain, type: subkey.payloadSourceType),
            let viewSettings = payloadViewDomainSettings[subkey.keyPath] as? Dictionary<String, Any> {
            return viewSettings
        } else { return nil }
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
