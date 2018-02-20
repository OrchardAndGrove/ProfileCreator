//
//  Profile.swift
//  ProfileCreator
//
//  Created by Erik Berglund on 2017-07-15.
//  Copyright © 2017 Erik Berglund. All rights reserved.
//

import Cocoa
import ProfilePayloads

public class Profile: NSDocument {
    
    // MARK: -
    // MARK: Variables
    
    // General Settings
    public var uuid: UUID
    public var identifier: UUID
    @objc public var title: String
    
    private var savedSettings = Dictionary<String, Any>()
    
    public var payloadSettings: Dictionary<String, Any>
    public var profilePayloads: String? // Change to payloads framework class. Unsure if it should be used like this.
    
    // View Settings
    public var viewSettings: Dictionary<String, Any>
    public var scope: String? // Change to scope enum
    public var distribution: String? // Change to distribution enum
    public var sign = false
    
    @objc public var editorShowHidden: Bool = false
    @objc public var editorShowSupervised: Bool = false
    @objc public var editorShowDisabled: Bool = false
    
    @objc public var editorColumnEnable: Bool = false
    
    // MARK: -
    // MARK: Initialization
    
    override convenience init() {
        self.init(title: nil, identifier: nil, payloadSettings: nil, viewSettings: nil)
    }
    
    init(title: String?, identifier: UUID?, payloadSettings: Dictionary<String, Any>?, viewSettings: Dictionary<String, Any>?) {
        
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
        viewSettings[PreferenceKey.editorShowDisabledKeys] = self.editorShowDisabled
        viewSettings[PreferenceKey.editorShowHiddenKeys] = self.editorShowHidden
        viewSettings[PreferenceKey.editorShowSupervisedKeys] = self.editorShowSupervised
        
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
        Swift.print("self.savedSettings: \(self.savedSettings)")
        Swift.print("self.saveDict(): \(self.saveDict())")
        return self.savedSettings == self.saveDict()
    }
    
    // MARK: -
    // MARK: NSDocument Functions
    
    override public func makeWindowControllers() {
        let windowController = ProfileEditorWindowController(profile: self)
        self.addWindowController(windowController)
    }
    
    override public func save(_ sender: Any?) {
        self.save(operationType: .saveOperation) { saveError in
            
            // TODO: Proper Logging
            if saveError == nil {
                self.savedSettings = self.saveDict()
                Swift.print("Class: \(self.self), Function: \(#function), Save Successful!")
            } else {
                Swift.print("Class: \(self.self), Function: \(#function), Error: \(String(describing: saveError))")
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
    
    // MARK: -
    // MARK: Public Functions
    
    func restoreSavedSettings(identifier: UUID, savedSettings: Dictionary<String, Any>?) {
        Swift.print("restoreSavedSettings for: \(identifier)")
        let settingsDict = savedSettings ?? self.savedSettings
        self.identifier = identifier
        self.payloadSettings = settingsDict[SettingsKey.payloadSettings] as? Dictionary<String, Any> ?? Dictionary<String, Any>()
        self.viewSettings = settingsDict[SettingsKey.viewSettings] as? Dictionary<String, Any> ?? Dictionary<String, Any>()
        if let title = self.getPayloadSetting(key: PayloadKey.payloadDisplayName, domain: ManifestDomain.general, type: .manifest) as? String {
            self.title = title
        } else { self.title = StringConstant.defaultProfileName }
    }
    
    func updatePayloadSelection(selected: Bool, payloadSource: PayloadSource, updateComplete: @escaping (Bool, Error?) -> ()) {
        
        // ---------------------------------------------------------------------
        //  Get the current domain settings or create an empty set if they doesn't exist
        // ---------------------------------------------------------------------
        var typeSettings = self.payloadTypeSettings(type: payloadSource.type)
        var domainSettings = typeSettings[payloadSource.domain] as? Dictionary<String, Any> ?? Dictionary<String, Any>()
        
        // ---------------------------------------------------------------------
        //  Set the new value
        // ---------------------------------------------------------------------
        domainSettings[SettingsKey.enabled] = selected
        typeSettings[payloadSource.domain] = domainSettings
        
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
        
        Swift.print("Domain Settings: \(domainSettings)")
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
        super.save(to: saveURL, ofType: TypeName.profile, for: operationType, completionHandler: completionHandler)
    }
    
    func update(title: String) {
        
        // TODO: Update title and displayname in settings
        
        self.title = title
    }
    
    // MARK: -
    // MARK: Subkey Check
    
    func subkeyIsEnabled(subkey: PayloadSourceSubkey) -> Bool {
        var isEnabled = false // FIXME: This should be a setting, to default enable or disable a key
        if subkey.require == .always {
            isEnabled = true
        } else if
            let domainViewSettings = self.payloadViewTypeSettings(type: subkey.payloadSourceType)[subkey.domain] as? Dictionary<String, Any>,
            let viewSettings = domainViewSettings[subkey.keyPath] as? Dictionary<String, Any>,
            let enabled = viewSettings[SettingsKey.enabled] as? Bool {
            isEnabled = enabled
        } else if let enabledDefault = subkey.enabledDefault {
            isEnabled = enabledDefault
        }
        return isEnabled
    }
    
    // MARK: -
    // MARK: View Settings
    
    class func defaultViewSettings() -> Dictionary<String, Any> {
        var viewSettings = Dictionary<String, Any>()
        viewSettings[PreferenceKey.editorColumnEnable] = UserDefaults.standard.bool(forKey: PreferenceKey.editorColumnEnable)
        viewSettings[PreferenceKey.editorShowDisabledKeys] = UserDefaults.standard.bool(forKey: PreferenceKey.editorShowDisabledKeys)
        viewSettings[PreferenceKey.editorShowHiddenKeys] = UserDefaults.standard.bool(forKey: PreferenceKey.editorShowHiddenKeys)
        viewSettings[PreferenceKey.editorShowSupervisedKeys] = UserDefaults.standard.bool(forKey: PreferenceKey.editorShowSupervisedKeys)
        return viewSettings
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
    
    // MARK: -
    // MARK: Payload Settings
    
    class func defaultPayloadSettings(uuid: UUID) -> Dictionary<String, Any> {
        
        let defaultOrganization = UserDefaults.standard.string(forKey: PreferenceKey.defaultOrganizationIdentifier) ?? "com.profilecreator"
        let defaultIdentifier = defaultOrganization + ".\(uuid.uuidString)"
        
        let payloadDomainSettings: Dictionary<String, Any> = [
            PayloadKey.payloadVersion : 1,
            PayloadKey.payloadUUID : uuid.uuidString,
            PayloadKey.payloadIdentifier : defaultIdentifier
        ]
        let payloadTypeSettings: Dictionary<String, Any> = [
            ManifestDomain.general : payloadDomainSettings
        ]
        return [String(PayloadSourceType.manifest.rawValue) : payloadTypeSettings]
    }
    
    func payloadTypeSettings(type: PayloadSourceType) -> Dictionary<String, Any> {
        return self.payloadSettings[String(type.rawValue)] as? Dictionary<String, Any> ?? Dictionary<String, Any>()
    }
    
    func setPayloadTypeSettings(settings: Dictionary<String, Any>, type: PayloadSourceType) {
        self.payloadSettings[String(type.rawValue)] = settings
    }
    
    func updatePayloadSettings(value: Any?, subkey: PayloadSourceSubkey, updateComplete: @escaping (Bool, Error?) -> ()) {
        self.updatePayloadSettings(value: value, key: subkey.keyPath, domain: subkey.domain, type: subkey.payloadSourceType, updateComplete: updateComplete)
    }
    
    func getPayloadSetting(key: String, domain: String, type: PayloadSourceType) -> Any? {
        var typeSettings = self.payloadTypeSettings(type: type)
        var domainSettings = typeSettings[domain] as? Dictionary<String, Any> ?? Dictionary<String, Any>()
        return domainSettings[key]
    }
    
    func updatePayloadSettings(value: Any?, key: String, domain: String, type: PayloadSourceType, updateComplete: @escaping (Bool, Error?) -> ()) {
        
        // ---------------------------------------------------------------------
        //  Get the current domain settings or create an empty set if they doesn't exist
        // ---------------------------------------------------------------------
        var typeSettings = self.payloadTypeSettings(type: type)
        var domainSettings = typeSettings[domain] as? Dictionary<String, Any> ?? Dictionary<String, Any>()
        
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
            Swift.print("Setting title: \(self.title)")
            self.title = title
            Swift.print("Setting title AFTER: \(self.title)")
        }
        
        // ---------------------------------------------------------------------
        //  Using closure for the option of a longer save time if needed in the future for more checking etc.
        // ---------------------------------------------------------------------
        updateComplete(true, nil)
    }
}
