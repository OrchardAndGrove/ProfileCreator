//
//  ProfilePayloadViewSettings.swift
//  ProfileCreator
//
//  Created by Erik Berglund on 2018-03-27.
//  Copyright © 2018 Erik Berglund. All rights reserved.
//

import Foundation
import ProfilePayloads

extension Profile {
    
    // MARK: -
    // MARK: Payload View Settings: Domain Enabled
    
    func isEnabled(payloadSource: PayloadSource) -> Bool {
        return self.isEnabled(domain: payloadSource.domain, type: payloadSource.type)
    }
    
    func isEnabled(domain: String, type: PayloadSourceType) -> Bool {
        let viewDomainSettings = self.getViewDomainSettings(domain: domain, type: type)
        if let enabled = viewDomainSettings[SettingsKey.enabled] as? Bool {
            return enabled
        } else { return false }
    }
    
    func setEnabled(domain: String, enabled: Bool, type: PayloadSourceType) {
        #if DEBUGISENABLED
        Log.shared.debug(message: "Setting enabled: \(enabled) for domain: \(domain) of type: \(type)", category: String(describing: self))
        #endif
        
        var viewDomainSettings = self.getViewDomainSettings(domain: domain, type: type)
        if !enabled {
            // FIXME: Check if we can remove the setting here if it's not enabled
            viewDomainSettings[SettingsKey.enabled] = enabled
        } else {
            viewDomainSettings[SettingsKey.enabled] = enabled
        }
        self.setViewDomainSettings(settings: viewDomainSettings, domain: domain, type: type)
    }
    
    func setEnabled(subkey: PayloadSourceSubkey, enabled: Bool) {
        
    }
    
    // MARK: -
    // MARK: Payload View Settings: Domain Selected Index
    
    func getPayloadIndex(domain: String, type: PayloadSourceType) -> Int {
        let viewDomainSettings = self.getViewDomainSettings(domain: domain, type: type)
        if let payloadIndex = viewDomainSettings[SettingsKey.payloadIndex] as? Int {
            return payloadIndex
        } else { return 0 }
    }
    
    func setPayloadIndex(index: Int, domain: String, type: PayloadSourceType) {
        #if DEBUGSETTINGS
        Log.shared.debug(message: "Setting payload index: \(index) for domain: \(domain) of type: \(type)", category: String(describing: self))
        #endif
        
        var viewDomainSettings = self.getViewDomainSettings(domain: domain, type: type)
        viewDomainSettings[SettingsKey.payloadIndex] = index
        self.setViewDomainSettings(settings: viewDomainSettings, domain: domain, type: type)
    }
    
    // MARK: -
    // MARK: Payload View Settings: Get
        
    func getViewSetting(key: String, domain: String, type: PayloadSourceType, payloadIndex: Int) -> Any? {
        let viewDomainSettings = self.getViewDomainSettings(domain: domain, type: type, payloadIndex: payloadIndex)
        return viewDomainSettings[key]
    }
    
    func getViewTypeSettings(type: PayloadSourceType) -> Dictionary<String, Any> {
        return self.viewSettings[String(type.rawValue)] as? Dictionary<String, Any> ?? Dictionary<String, Any>()
    }
    
    func getViewDomainSettings(domain: String, type: PayloadSourceType) -> Dictionary<String, Any> {
        let viewTypeSettings = self.getViewTypeSettings(type: type)
        return viewTypeSettings[domain] as? Dictionary<String, Any> ?? Dictionary<String, Any>()
    }
    
    func getViewDomainSettings(domain: String, type: PayloadSourceType, payloadIndex: Int) -> Dictionary<String, Any> {
        let viewDomainSettingsArray = self.getViewDomainSettingsArray(domain: domain, type: type)
        if payloadIndex < viewDomainSettingsArray.count {
            return viewDomainSettingsArray[payloadIndex]
        } else { return Dictionary<String, Any>() }
    }
    
    func getViewDomainSettingsArray(domain: String, type: PayloadSourceType) -> [Dictionary<String, Any>] {
        let viewDomainSettings = self.getViewDomainSettings(domain: domain, type: type)
        return viewDomainSettings[SettingsKey.settings] as? [Dictionary<String, Any>] ?? [Dictionary<String, Any>]()
    }

    // MARK: -
    // MARK: Payload View Settings: Set
    
    func setViewTypeSettings(settings: Dictionary<String, Any>, type: PayloadSourceType) {
        self.viewSettings[String(type.rawValue)] = settings
        
        // ---------------------------------------------------------------------
        //  Reset any cached condition results as updated settings might change those
        // ---------------------------------------------------------------------
        self.resetCache()
    }
    
    func setViewDomainSettings(settings: Dictionary<String, Any>, domain: String, type: PayloadSourceType) {
        var viewTypeSettings = self.getViewTypeSettings(type: type)
        viewTypeSettings[domain] = settings
        self.setViewTypeSettings(settings: viewTypeSettings, type: type)
    }
    
    func setViewDomainSettings(settings: Dictionary<String, Any>, domain: String, type: PayloadSourceType, payloadIndex: Int) {
        var viewDomainSettingsArray = self.getViewDomainSettingsArray(domain: domain, type: type)
        if payloadIndex < viewDomainSettingsArray.count {
            viewDomainSettingsArray[payloadIndex] = settings
        } else if payloadIndex == viewDomainSettingsArray.count {
            viewDomainSettingsArray.append(settings)
        } else {
            Log.shared.error(message: "Payload index: \(payloadIndex) is too high, \(viewDomainSettingsArray.count) is the last index. Will not add settings", category: String(describing: self))
            return
        }
        self.setViewDomainSettingsArray(settings: viewDomainSettingsArray, domain: domain, type: type)
    }
    
    func setViewDomainSettingsArray(settings: [Dictionary<String, Any>], domain: String, type: PayloadSourceType) {
        var viewDomainSettings = self.getViewDomainSettings(domain: domain, type: type)
        viewDomainSettings[SettingsKey.settings] = settings
        self.setViewDomainSettings(settings: viewDomainSettings, domain: domain, type: type)
    }
    
    // MARK: -
    // MARK: Payload View Settings: Update
    func updateViewSettings(value: Any?, key: String, subkey: PayloadSourceSubkey, payloadIndex: Int) {
        self.updateViewSettings(value: value, key: key, keyPath: subkey.keyPath, domain: subkey.domain, type: subkey.payloadSourceType, payloadIndex: payloadIndex)
    }
    
    func updateViewSettings(value: Any?, key: String, keyPath: String?, domain: String, type: PayloadSourceType, payloadIndex: Int) {
        
        // ---------------------------------------------------------------------
        //  Get the current domain settings or create an empty set if they doesn't exist
        // ---------------------------------------------------------------------
        var viewDomainSettings = self.getViewDomainSettings(domain: domain, type: type, payloadIndex: payloadIndex)
        
        // ---------------------------------------------------------------------
        //  Set the new value
        // ---------------------------------------------------------------------
        if let payloadKeyPath = keyPath {
            var keySettings = viewDomainSettings[payloadKeyPath] as? Dictionary<String, Any> ?? Dictionary<String, Any>()
            keySettings[key] = value
            viewDomainSettings[payloadKeyPath] = keySettings
        } else {
            viewDomainSettings[key] = value
        }
        
        // ---------------------------------------------------------------------
        //  Save the the changes to the current settings
        // ---------------------------------------------------------------------
        self.setViewDomainSettings(settings: viewDomainSettings, domain: domain, type: type, payloadIndex: payloadIndex)
    }
    
    // MARK: -
    // MARK: Payload View Settings: Default
    
    class func defaultViewSettings() -> Dictionary<String, Any> {
        return [ PreferenceKey.editorDistributionMethod : UserDefaults.standard.string(forKey: PreferenceKey.editorDistributionMethod) ?? DistributionString.any,
                 PreferenceKey.editorDisableOptionalKeys : UserDefaults.standard.bool(forKey: PreferenceKey.editorDisableOptionalKeys),
                 PreferenceKey.editorColumnEnable : UserDefaults.standard.bool(forKey: PreferenceKey.editorColumnEnable),
                 PreferenceKey.editorShowDisabledKeys : UserDefaults.standard.bool(forKey: PreferenceKey.editorShowDisabledKeys),
                 PreferenceKey.editorShowHiddenKeys : UserDefaults.standard.bool(forKey: PreferenceKey.editorShowHiddenKeys),
                 PreferenceKey.editorShowSupervisedKeys : UserDefaults.standard.bool(forKey: PreferenceKey.editorShowSupervisedKeys),
                 PreferenceKey.editorShowMacOS : UserDefaults.standard.bool(forKey: PreferenceKey.editorShowMacOS),
                 PreferenceKey.editorShowIOS : UserDefaults.standard.bool(forKey: PreferenceKey.editorShowIOS),
                 PreferenceKey.editorShowTvOS : UserDefaults.standard.bool(forKey: PreferenceKey.editorShowTvOS),
                 PreferenceKey.editorShowScopeUser : UserDefaults.standard.bool(forKey: PreferenceKey.editorShowScopeUser),
                 PreferenceKey.editorShowScopeSystem : UserDefaults.standard.bool(forKey: PreferenceKey.editorShowScopeSystem) ]
    }
}
