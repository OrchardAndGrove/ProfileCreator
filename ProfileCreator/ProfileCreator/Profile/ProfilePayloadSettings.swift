//
//  ProfileSettings.swift
//  ProfileCreator
//
//  Created by Erik Berglund on 2018-03-27.
//  Copyright © 2018 Erik Berglund. All rights reserved.
//

import Foundation
import ProfilePayloads

extension Profile {
    
    // MARK: -
    // MARK: Payload Settings: Get
    
    // For getting the currently in memory value
    func getPayloadSetting(key: String, domain: String, type: PayloadSourceType) -> Any? {
        var typeSettings = self.getPayloadTypeSettings(type: type)
        var domainSettings = typeSettings[domain] ?? Dictionary<String, Any>()
        return domainSettings[key]
    }
    
    func getPayloadTypeSettings(type: PayloadSourceType) -> Dictionary<String, Dictionary<String, Any>> {
        return self.payloadSettings[String(type.rawValue)] ?? Dictionary<String, Dictionary<String, Any>>()
    }
    
    func getPayloadDomainSettings(domain: String, type: PayloadSourceType) -> Dictionary<String, Any> {
        let payloadTypeSettings = self.getPayloadTypeSettings(type: type)
        return payloadTypeSettings[domain] ?? Dictionary<String, Any>()
    }
    
    // MARK: -
    // MARK: Payload Settings: Set
    
    func setPayloadTypeSettings(settings: Dictionary<String, Dictionary<String, Any>>, type: PayloadSourceType) {
        self.payloadSettings[String(type.rawValue)] = settings
        
        // ---------------------------------------------------------------------
        //  Reset any cached condition results as updated settings might change those
        // ---------------------------------------------------------------------
        self.resetCache()
    }
    
    // MARK: -
    // MARK: Payload Settings: Update
    
    func updatePayloadSettingsPlatforms() -> Bool {
        var newSelectedPlatforms: Platforms = []
        
        if self.editorShowIOS {
            newSelectedPlatforms.insert(.iOS)
        }
        
        if self.editorShowMacOS {
            newSelectedPlatforms.insert(.macOS)
        }
        
        if self.editorShowTvOS {
            newSelectedPlatforms.insert(.tvOS)
        }
        
        if self.selectedPlatforms != newSelectedPlatforms {
            #if DEBUG
                Log.shared.debug(message: "Updating selected platforms to: \(PayloadUtility.string(fromPlatforms: newSelectedPlatforms))", category: String(describing: self))
            #endif
            self.selectedPlatforms = newSelectedPlatforms
            return true
        } else { return false }
    }
    
    func updatePayloadSettings(value: Any?, subkey: PayloadSourceSubkey) {
        self.updatePayloadSettings(value: value, key: subkey.keyPath, domain: subkey.domain, type: subkey.payloadSourceType)
    }
    
    func updatePayloadSettings(value: Any?, key: String, subkey: PayloadSourceSubkey) {
        var keyPath = key
        var subkeyPathArray = subkey.keyPath.components(separatedBy: ".")
        if 1 < subkeyPathArray.count {
            subkeyPathArray.removeLast()
            keyPath = "\(subkeyPathArray.joined(separator: ".")).\(key)"
        }
        self.updatePayloadSettings(value: value, key: keyPath, domain: subkey.domain, type: subkey.payloadSourceType)
    }
    
    func updatePayloadSettings(value: Any?, key: String, domain: String, type: PayloadSourceType) {
        
        // ---------------------------------------------------------------------
        //  Get the current domain settings or create an empty set if they doesn't exist
        // ---------------------------------------------------------------------
        var typeSettings = self.getPayloadTypeSettings(type: type)
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
        //  Reset any cached condition results as updated settings might change those
        // ---------------------------------------------------------------------
        self.resetCache()
    }
    
    // MARK: -
    // MARK: Payload Settings: Default
    
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
    
    // MARK: -
    // MARK: Payload Saved Settings: Get
    
    func getSavedPayloadTypeSettings(type: PayloadSourceType) -> Dictionary<String, Any> {
        let savedPayloadSettings = self.savedSettings[SettingsKey.payloadSettings] as? Dictionary<String, Any> ?? Dictionary<String, Any>()
        return savedPayloadSettings[String(type.rawValue)] as? Dictionary<String, Any> ?? Dictionary<String, Any>()
    }
    
    // For getting the currently saved on disk value
    func getSavedPayloadSetting(key: String, domain: String, type: PayloadSourceType) -> Any? {
        var typeSettings = self.getSavedPayloadTypeSettings(type: type)
        var domainSettings = typeSettings[domain] as? Dictionary<String, Any> ?? Dictionary<String, Any>()
        return domainSettings[key]
    }
}
