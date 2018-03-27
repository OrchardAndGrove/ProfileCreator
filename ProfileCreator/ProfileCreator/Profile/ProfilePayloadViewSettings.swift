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
    // MARK: Payload View Settings: Get
    
    func getPayloadViewTypeSettings(type: PayloadSourceType) -> Dictionary<String, Any> {
        return self.viewSettings[String(type.rawValue)] as? Dictionary<String, Any> ?? Dictionary<String, Any>()
    }
    
    func getPayloadViewDomainSettings(domain: String, type: PayloadSourceType) -> Dictionary<String, Any>? {
        let payloadViewTypeSettings = self.getPayloadViewTypeSettings(type: type)
        if let payloadViewDomainSettings = payloadViewTypeSettings[domain] as? Dictionary<String, Any> {
            return payloadViewDomainSettings
        } else { return nil }
    }
    
    // MARK: -
    // MARK: Payload View Settings: Set
    
    func setPayloadViewTypeSettings(settings: Dictionary<String, Any>, type: PayloadSourceType) {
        self.viewSettings[String(type.rawValue)] = settings
    }
    
    // MARK: -
    // MARK: Payload View Settings: Update
    // FIXME: Change to throws
    func updateViewSettings(value: Any?, key: String, subkey: PayloadSourceSubkey, updateComplete: @escaping (Bool, Error?) -> ()) {
        self.updateViewSettings(value: value, key: key, keyPath: subkey.keyPath, domain: subkey.domain, type: subkey.payloadSourceType, updateComplete: updateComplete)
    }
    
    // FIXME: Change to throws
    func updateViewSettings(value: Any?, key: String, keyPath: String?, domain: String, type: PayloadSourceType, updateComplete: @escaping (Bool, Error?) -> ()) {
        
        // ---------------------------------------------------------------------
        //  Get the current domain settings or create an empty set if they doesn't exist
        // ---------------------------------------------------------------------
        var typeSettings = self.getPayloadViewTypeSettings(type: type)
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
