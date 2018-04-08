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
    func getPayloadSetting(key: String, domain: String, type: PayloadSourceType, payloadIndex: Int) -> Any? {
        let domainSettings = self.getPayloadDomainSettings(domain: domain, type: type, payloadIndex: payloadIndex)
        return domainSettings[key]
    }
    
    func getPayloadTypeSettings(type: PayloadSourceType) -> Dictionary<String, [Dictionary<String, Any>]> {
        return self.payloadSettings[String(type.rawValue)] ?? Dictionary<String, [Dictionary<String, Any>]>()
    }
    
    func getPayloadDomainSettings(domain: String, type: PayloadSourceType) -> [Dictionary<String, Any>] {
        let payloadTypeSettings = self.getPayloadTypeSettings(type: type)
        return payloadTypeSettings[domain] ?? [Dictionary<String, Any>]()
    }
    
    func getPayloadDomainSettingsCount(domain: String, type: PayloadSourceType) -> Int {
        return self.getPayloadDomainSettings(domain: domain, type: type).count
    }
    
    func getPayloadDomainSettingsEmptyCount(domain: String, type: PayloadSourceType) -> Int {
        var emptyCount = 0
        for domainSettings in self.getPayloadDomainSettings(domain: domain, type: type) {
            if Array(Set(domainSettings.keys).subtracting([PayloadKey.payloadVersion, PayloadKey.payloadUUID])).count == 0 {
                emptyCount += 1
            }
        }
        return emptyCount
    }
    
    func getPayloadDomainSettings(domain: String, type: PayloadSourceType, payloadIndex: Int) -> Dictionary<String, Any> {
        let payloadDomainSettings = self.getPayloadDomainSettings(domain: domain, type: type)
        if payloadIndex < payloadDomainSettings.count {
            return payloadDomainSettings[payloadIndex]
        } else { return Dictionary<String, Any>() }
    }
    
    // MARK: -
    // MARK: Payload Settings: Set
    
    func setPayloadTypeSettings(settings: Dictionary<String, [Dictionary<String, Any>]>, type: PayloadSourceType) {
        self.payloadSettings[String(type.rawValue)] = settings
        
        // ---------------------------------------------------------------------
        //  Reset any cached condition results as updated settings might change those
        // ---------------------------------------------------------------------
        self.resetCache()
    }
    
    private func setPayloadDomainSettings(settings: [Dictionary<String, Any>], domain: String, type: PayloadSourceType) {
        var payloadTypeSettings = self.getPayloadTypeSettings(type: type)
        payloadTypeSettings[domain] = settings
        self.setPayloadTypeSettings(settings: payloadTypeSettings, type: type)
    }
    
    func setPayloadDomainSettings(settings: Dictionary<String, Any>, domain: String, type: PayloadSourceType, payloadIndex: Int) {
        var payloadDomainSettings = self.getPayloadDomainSettings(domain: domain, type: type)
        if payloadIndex < payloadDomainSettings.count {
            payloadDomainSettings[payloadIndex] = settings
        } else if payloadIndex == payloadDomainSettings.count {
            payloadDomainSettings.append(settings)
        } else {
            Log.shared.error(message: "Payload index: \(payloadIndex) is too high, \(payloadDomainSettings.count) is the last index. Will not add settings", category: String(describing: self))
            return
        }
        self.setPayloadDomainSettings(settings: payloadDomainSettings, domain: domain, type: type)
    }
    
    // MARK: -
    // MARK: Payload Settings: Update
    
    func updatePayloadSettingsDistribution() {
        let newSelectedDistribution = Distribution(string: self.editorDistributionMethod)
        if self.selectedDistribution != newSelectedDistribution {
            #if DEBUG
            Log.shared.debug(message: "Updating selected distribution method to: \(newSelectedDistribution)", category: String(describing: self))
            #endif
            
            self.selectedDistribution = newSelectedDistribution
            self.resetCache()
            self.setValue(!self.selectedDistributionUpdated, forKeyPath: self.editorSelectedDistributionUpdatedSelector)
        }
    }
    
    func updatePayloadSettingsScope() {
        var newSelectedScope: Targets = []
        if self.editorShowScopeUser { newSelectedScope.insert(.user) }
        if self.editorShowScopeSystem { newSelectedScope.insert(.system) }
        if self.selectedScope != newSelectedScope {
            #if DEBUG
            Log.shared.debug(message: "Updating selected scope to: \(PayloadUtility.string(fromTargets: newSelectedScope))", category: String(describing: self))
            #endif
            
            self.selectedScope = newSelectedScope
            self.resetCache()
            self.setValue(!self.selectedScopeUpdated, forKeyPath: self.editorSelectedScopeUpdatedSelector)
        }
    }
    
    func updatePayloadSettingsPlatforms() {
        var newSelectedPlatforms: Platforms = []
        if self.editorShowIOS { newSelectedPlatforms.insert(.iOS) }
        if self.editorShowMacOS { newSelectedPlatforms.insert(.macOS) }
        if self.editorShowTvOS { newSelectedPlatforms.insert(.tvOS) }
        if self.selectedPlatforms != newSelectedPlatforms {
            #if DEBUG
            Log.shared.debug(message: "Updating selected platforms to: \(PayloadUtility.string(fromPlatforms: newSelectedPlatforms))", category: String(describing: self))
            #endif
            
            self.selectedPlatforms = newSelectedPlatforms
            self.resetCache()
            self.setValue(!self.selectedPlatformsUpdated, forKeyPath: self.editorSelectedPlatformsUpdatedSelector)
        }
    }
    
    func updatePayloadSettings(value: Any?, subkey: PayloadSourceSubkey, payloadIndex: Int) {
        self.updatePayloadSettings(value: value, key: subkey.keyPath, domain: subkey.domain, type: subkey.payloadSourceType, payloadIndex: payloadIndex)
    }
    
    func updatePayloadSettings(value: Any?, key: String, subkey: PayloadSourceSubkey, payloadIndex: Int) {
        var keyPath = key
        var subkeyPathArray = subkey.keyPath.components(separatedBy: ".")
        if 1 < subkeyPathArray.count {
            subkeyPathArray.removeLast()
            keyPath = "\(subkeyPathArray.joined(separator: ".")).\(key)"
        }
        self.updatePayloadSettings(value: value, key: keyPath, domain: subkey.domain, type: subkey.payloadSourceType, payloadIndex: payloadIndex)
    }
    
    func updatePayloadSettings(value: Any?, key: String, domain: String, type: PayloadSourceType, payloadIndex: Int) {
        
        // ---------------------------------------------------------------------
        //  Get the current domain settings or create an empty set if they doesn't exist
        // ---------------------------------------------------------------------
        var domainSettings = self.getPayloadDomainSettings(domain: domain, type: type, payloadIndex: payloadIndex)
        
        // ---------------------------------------------------------------------
        //  Set the new value
        // ---------------------------------------------------------------------
        domainSettings[key] = value
        
        // ---------------------------------------------------------------------
        //  Verify the domain has the required settings
        // ---------------------------------------------------------------------
        self.updatePayloadDomainSettings(&domainSettings)
        
        // ---------------------------------------------------------------------
        // Save the the changes to the current settings
        // ---------------------------------------------------------------------
        self.setPayloadDomainSettings(settings: domainSettings, domain: domain, type: type, payloadIndex: payloadIndex)
        
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
    
    func updatePayloadDomainSettings(_ domainSettings: inout Dictionary<String, Any>) {
        
        // Verify PayloadUUID
        if domainSettings[PayloadKey.payloadUUID] == nil { domainSettings[PayloadKey.payloadUUID] = UUID().uuidString }
        
        // Verify PayloadVersion
        if domainSettings[PayloadKey.payloadVersion] == nil { domainSettings[PayloadKey.payloadVersion] = 1 }
    }
    
    // MARK: -
    // MARK: Payload Settings: Remove
    
    func removePayloadSettings(domain: String, type: PayloadSourceType, payloadIndex: Int) {
        var domainSettings = self.getPayloadDomainSettings(domain: domain, type: type)
        if payloadIndex < domainSettings.count {
            domainSettings.remove(at: payloadIndex)
        }
        self.setPayloadDomainSettings(settings: domainSettings, domain: domain, type: type)
    }
    
    // MARK: -
    // MARK: Payload Settings: Default
    
    func addDefaultPayloadDomainSettings(domain: String, type: PayloadSourceType) {
        var domainSettings = Dictionary<String, Any>()
        self.updatePayloadDomainSettings(&domainSettings)
        self.setPayloadDomainSettings(settings: domainSettings, domain: domain, type: type, payloadIndex: self.getPayloadDomainSettingsCount(domain: domain, type: type))
    }
        
    class func defaultPayloadSettings(uuid: UUID) -> Dictionary<String, Dictionary<String, [Dictionary<String, Any>]>> {
        
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
        
        let payloadTypeSettings: Dictionary<String, [Dictionary<String, Any>]> = [
             ManifestDomain.general : [ payloadDomainSettings ]
        ]
        
        return [String(PayloadSourceType.manifest.rawValue) : payloadTypeSettings]
    }
    
    // MARK: -
    // MARK: Payload Saved Settings: Get
    
    func getSavedPayloadSetting(key: String, domain: String, type: PayloadSourceType, payloadIndex: Int) -> Any? {
        let savedDomainSettings = self.getSavedPayloadDomainSettings(domain: domain, type: type, payloadIndex: payloadIndex)
        return savedDomainSettings[key]
    }

    func getSavedPayloadTypeSettings(type: PayloadSourceType) -> Dictionary<String, [Dictionary<String, Any>]> {
        let savedPayloadSettings = self.savedSettings[SettingsKey.payloadSettings] as? Dictionary<String, Dictionary<String, [Dictionary<String, Any>]>> ?? Dictionary<String, Dictionary<String, [Dictionary<String, Any>]>>()
        return savedPayloadSettings[String(type.rawValue)] ?? Dictionary<String, [Dictionary<String, Any>]>()
    }
    
    func getSavedPayloadDomainSettings(domain: String, type: PayloadSourceType) -> [Dictionary<String, Any>] {
        let savedPayloadTypeSettings = self.getSavedPayloadTypeSettings(type: type)
        return savedPayloadTypeSettings[domain] ?? [Dictionary<String, Any>]()
    }
    
    func getSavedPayloadDomainSettings(domain: String, type: PayloadSourceType, payloadIndex: Int) -> Dictionary<String, Any> {
        let savedPayloadDomainSettings = self.getSavedPayloadDomainSettings(domain: domain, type: type)
        if payloadIndex < savedPayloadDomainSettings.count {
            return savedPayloadDomainSettings[payloadIndex]
        } else { return Dictionary<String, Any>() }
    }

    
    
    // MARK: -
    // MARK: Payload Saved Settings: Reset
    
    func resetSavedPayloadSettings(domain: String, type: PayloadSourceType) {
        let savedPayloadDomainSettings = self.getSavedPayloadDomainSettings(domain: domain, type: type)
        self.setPayloadDomainSettings(settings: savedPayloadDomainSettings, domain: domain, type: type)
    }
}
