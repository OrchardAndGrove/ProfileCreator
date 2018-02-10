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
    @objc public var title: String?
    
    public var payloadSettings: Dictionary<String, Any>
    private var savedPayloadSettings: Dictionary<String, Any>
    
    public var profilePayloads: String? // Change to payloads framework class. Unsure if it should be used like this.
    
    // View Settings
    public var viewSettings: Dictionary<String, Any>
    public var scope: String? // Change to scope enum
    public var distribution: String? // Change to distribution enum
    public var sign = false
    public var showHidden = false
    public var showSupervised = false
    public var showDisabled = false
    
    // MARK: -
    // MARK: Initialization
    
    override convenience init() {
        self.init(title: nil, identifier: nil, payloadSettings: nil, viewSettings: nil)
    }
    
    init(title: String?, identifier: UUID?, payloadSettings: Dictionary<String, Any>?, viewSettings: Dictionary<String, Any>?) {

        self.identifier = identifier ?? UUID()
        self.savedPayloadSettings = payloadSettings ?? Profile.defaultPayloadSettings()
        self.payloadSettings = self.savedPayloadSettings
        self.uuid = identifier ?? UUID()
        self.viewSettings = viewSettings ?? Profile.defaultViewSettings()
        
        // ---------------------------------------------------------------------
        //  Initialize Self
        // ---------------------------------------------------------------------
        super.init()
        
        // ---------------------------------------------------------------------
        //  Initialize General Settings
        // ---------------------------------------------------------------------
        self.title = title ?? StringConstant.defaultProfileName
        
        // ---------------------------------------------------------------------
        //  Initialize View Settings
        // ---------------------------------------------------------------------
        // FIXME: View Settings!
    }
    
    // MARK: -
    // MARK: Private Functions
    
    private func saveDict() -> [String : Any]? {
        
        // ---------------------------------------------------------------------
        //  Create dict to save
        // ---------------------------------------------------------------------
        return [SettingsKey.title : self.title ?? StringConstant.defaultProfileName,
                SettingsKey.identifier : self.identifier.uuidString,
                SettingsKey.sign : self.sign,
                SettingsKey.payloadSettings : self.payloadSettings,
                SettingsKey.viewSettings : self.viewSettings]
        
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
            if saveError != nil {
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
        
        if let profileDict = self.saveDict() {
            do {
                let profileData = try PropertyListSerialization.data(fromPropertyList: profileDict, format: .xml, options: 0)
                return profileData
            } catch {
                // TODO: Proper Logging
            }
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
                
                self.identifier = identifier
                self.title = profileDict[SettingsKey.title] as? String
                self.payloadSettings = profileDict[SettingsKey.payloadSettings] as? Dictionary<String, Any> ?? Dictionary<String, Any>()
                self.viewSettings = profileDict[SettingsKey.viewSettings] as? Dictionary<String, Any> ?? Dictionary<String, Any>()
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
    
    public func updatePayloadSelection(selected: Bool, payloadSource: PayloadSource, updateComplete: @escaping (Bool, Error?) -> ()) {
        
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
    
    public func updateDomainSettings(_ domainSettings: inout Dictionary<String, Any>) {
        
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
    
    public func save(operationType: NSDocument.SaveOperationType, completionHandler: @escaping (Error?) -> Void) {
        
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
    
    public func update(title: String) {
        
        // TODO: Update title and displayname in settings
        
        self.title = title
    }
    
    // MARK: -
    // MARK: View Settings
    
    class func defaultViewSettings() -> Dictionary<String, Any> {
        let viewSettings = Dictionary<String, Any>()
        return viewSettings
    }
    
    public func payloadViewTypeSettings(type: PayloadSourceType) -> Dictionary<String, Any> {
        return self.viewSettings[String(type.rawValue)] as? Dictionary<String, Any> ?? Dictionary<String, Any>()
    }
    
    public func setPayloadViewTypeSettings(settings: Dictionary<String, Any>, type: PayloadSourceType) {
        self.viewSettings[String(type.rawValue)] = settings
    }
    
    public func updateViewSettings(value: Any?, key: String, subkey: PayloadSourceSubkey, updateComplete: @escaping (Bool, Error?) -> ()) {
        self.updateViewSettings(value: value, key: key, keyPath: subkey.keyPath, domain: subkey.domain, type: subkey.payloadSourceType, updateComplete: updateComplete)
    }
    
    public func updateViewSettings(value: Any?, key: String, keyPath: String?, domain: String, type: PayloadSourceType, updateComplete: @escaping (Bool, Error?) -> ()) {
        
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
    
    class func defaultPayloadSettings() -> Dictionary<String, Any> {
        var payloadSettings = Dictionary<String, Any>()
        payloadSettings[PayloadKey.payloadVersion] = 1
        payloadSettings[PayloadKey.payloadUUID] = UUID().uuidString
        return payloadSettings
    }
    
    public func payloadTypeSettings(type: PayloadSourceType) -> Dictionary<String, Any> {
        return self.payloadSettings[String(type.rawValue)] as? Dictionary<String, Any> ?? Dictionary<String, Any>()
    }
    
    public func setPayloadTypeSettings(settings: Dictionary<String, Any>, type: PayloadSourceType) {
        self.payloadSettings[String(type.rawValue)] = settings
    }
    
    public func updatePayloadSettings(value: Any?, subkey: PayloadSourceSubkey, updateComplete: @escaping (Bool, Error?) -> ()) {
        self.updatePayloadSettings(value: value, key: subkey.keyPath, domain: subkey.domain, type: subkey.payloadSourceType, updateComplete: updateComplete)
    }
    
    public func updatePayloadSettings(value: Any?, key: String, domain: String, type: PayloadSourceType, updateComplete: @escaping (Bool, Error?) -> ()) {
        
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
        //  Using closure for the option of a longer save time if needed in the future for more checking etc.
        // ---------------------------------------------------------------------
        updateComplete(true, nil)
    }
}
