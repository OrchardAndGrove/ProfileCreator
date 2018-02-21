//
//  ProfileExport.swift
//  ProfileCreator
//
//  Created by Erik Berglund on 2017-11-08.
//  Copyright © 2017 Erik Berglund. All rights reserved.
//

import Foundation
import ProfilePayloads

class ProfileExport {
    
    class func export(profile: Profile, profileURL: URL) throws -> Void {
        
        var profileContentExported = Dictionary<String, Any>()
        
        do {
            profileContentExported = try self.profileContent(profile: profile)
            profileContentExported[PayloadKey.payloadContent] = try self.payloadContent(profile: profile)
        } catch let error {
            Swift.print("Profile Export Error: \(error)")
            throw error
        }
        
        Swift.print("Finished Profile: \(profileContentExported)")
        if #available(OSX 10.13, *) {
            do {
                try NSDictionary(dictionary: profileContentExported).write(to: profileURL)
            } catch let error {
                Swift.print("Failed to write")
                throw error
            }
        } else {
            if !NSDictionary(dictionary: profileContentExported).write(to: profileURL, atomically: true) {
                // FIXME: Correct Error
                throw ProfileExportError.unknownError
            }
        }
    }
    
    
    class func profileContent(profile: Profile) throws -> Dictionary<String, Any> {
        
        var profileContent = Dictionary<String, Any>()
        
        if let payloadSource = ProfilePayloads.shared.payloadSource(domain: ManifestDomain.general, type: .manifest) {
            
            // ---------------------------------------------------------------------
            //  Get the type settings for the current domain
            // ---------------------------------------------------------------------
            let typeSettings = profile.payloadTypeSettings(type: .manifest)
            let domainSettings = typeSettings[ManifestDomain.general] ?? Dictionary<String, Any>()
            
            // ---------------------------------------------------------------------
            //  Get the view settings for the current domain
            // ---------------------------------------------------------------------
            let viewTypeSettings = profile.payloadViewTypeSettings(type: .manifest)
            let viewDomainSettings = viewTypeSettings[ManifestDomain.general] as? Dictionary<String, Any> ?? Dictionary<String, Any>()
            
            // ---------------------------------------------------------------------
            //  Export the general domain
            // ---------------------------------------------------------------------
            self.export(subkeys: payloadSource.subkeys,
                        domainSettings: domainSettings,
                        typeSettings: typeSettings,
                        viewDomainSettings: viewDomainSettings,
                        viewTypeSettings: viewTypeSettings,
                        payloadContent: &profileContent)
        } else {
            throw ProfileExportError.noPayloadSource(forDomain: ManifestDomain.general, ofType: .manifest)
        }
        
        // ---------------------------------------------------------------------
        //  Verify Required Settings
        // ---------------------------------------------------------------------
        
        // PayloadType
        // ---------------------------------------------------------------------
        // Currently the only supported value is "Configuration"
        guard let payloadType = profileContent[PayloadKey.payloadType] as? String, payloadType == "Configuration" else {
            throw ProfileExportError.invalid(value: profileContent[PayloadKey.payloadType],
                                             forKey: PayloadKey.payloadType,
                                             inDomain: ManifestDomain.general,
                                             ofType: .manifest)
        }
        
        // PayloadVersion
        // ---------------------------------------------------------------------
        // Version of the profile format, currently the only supported value is 1
        guard let payloadVersion = profileContent[PayloadKey.payloadVersion] as? Int, payloadVersion == 1 else {
            throw ProfileExportError.invalid(value: profileContent[PayloadKey.payloadVersion],
                                             forKey: PayloadKey.payloadVersion,
                                             inDomain: ManifestDomain.general,
                                             ofType: .manifest)
        }
        
        // PayloadIdentifier
        // ---------------------------------------------------------------------
        // A non-empty identifier has to be set
        guard let payloadIdentifier = profileContent[PayloadKey.payloadIdentifier] as? String, !payloadIdentifier.isEmpty else {
            throw ProfileExportError.invalid(value: profileContent[PayloadKey.payloadIdentifier],
                                             forKey: PayloadKey.payloadIdentifier,
                                             inDomain: ManifestDomain.general,
                                             ofType: .manifest)
        }
        
        // PayloadUUID
        // ---------------------------------------------------------------------
        // A non-empty UUID has to be set
        guard let payloadUUID = profileContent[PayloadKey.payloadUUID] as? String, !payloadUUID.isEmpty else {
            throw ProfileExportError.invalid(value: profileContent[PayloadKey.payloadUUID],
                                             forKey: PayloadKey.payloadUUID,
                                             inDomain: ManifestDomain.general,
                                             ofType: .manifest)
        }
        
        return profileContent
    }
    
    class func payloadContent(profile: Profile) throws -> [Dictionary<String, Any>] {
        
        var allPayloadContent = [Dictionary<String, Any>]()
        
        for (typeRawValue, typeSettingsDict) in profile.payloadSettings {
            
            // ---------------------------------------------------------------------
            //  Verify we got a valid type and a non empty settings dict
            // ---------------------------------------------------------------------
            guard
                let typeInt = Int(typeRawValue),
                let type = PayloadSourceType(rawValue: typeInt) else {
                    continue
            }
            
            // ---------------------------------------------------------------------
            //  Loop through all domains and settings for the current type
            // ---------------------------------------------------------------------
            for (domain, domainSettings) in typeSettingsDict {
                
                // Ignore the General settings of type "Manifest"
                if type == .manifest, domain == ManifestDomain.general { continue }
                
                var payloadContent = Dictionary<String, Any>()
                
                if let payloadSource = ProfilePayloads.shared.payloadSource(domain: domain, type: type) {
                    
                    // ---------------------------------------------------------------------
                    //  Get the view settings for the current domain
                    // ---------------------------------------------------------------------
                    let viewTypeSettings = profile.payloadViewTypeSettings(type: type)
                    let viewDomainSettings = viewTypeSettings[domain] as? Dictionary<String, Any> ?? Dictionary<String, Any>()
                    
                    // ---------------------------------------------------------------------
                    //  Export the current domain
                    // ---------------------------------------------------------------------
                    self.export(subkeys: payloadSource.subkeys, domainSettings: domainSettings, typeSettings: typeSettingsDict, viewDomainSettings: viewDomainSettings, viewTypeSettings: viewTypeSettings, payloadContent: &payloadContent)
                    
                    // ---------------------------------------------------------------------
                    //  Update the payload version (and hash) if anything has changed
                    // ---------------------------------------------------------------------
                    self.updatePayloadVersion(profile: profile, type: type, domain: domain, viewDomainSettings: viewDomainSettings, payloadContent: &payloadContent)
                    
                } else {
                    Swift.print("Failed to get a payloadSource for domain: \(domain) of type: \(type)")
                }
                
                // ---------------------------------------------------------------------
                //  If payload is not empty, add to all payloads
                // ---------------------------------------------------------------------
                if !payloadContent.isEmpty { allPayloadContent.append(payloadContent) }
            }
        }
        
        return allPayloadContent
    }
    
    class func updatePayloadVersion(profile: Profile, type: PayloadSourceType, domain: String, viewDomainSettings: Dictionary<String, Any>, payloadContent: inout Dictionary<String, Any>) {
        
        // ---------------------------------------------------------------------
        //  Get the current payload hash
        // ---------------------------------------------------------------------
        let payloadData = NSKeyedArchiver.archivedData(withRootObject: payloadContent)
        let payloadHash = payloadData.hashValue
        
        // ---------------------------------------------------------------------
        //  Get the last payload hash and version
        // ---------------------------------------------------------------------
        let lastPayloadHash = viewDomainSettings[SettingsKey.hash] as? Int ?? -1
        let lastPayloadVersion = payloadContent[PayloadKey.payloadVersion] as? Int ?? 1
        
        if lastPayloadHash == -1 {
            
            // ---------------------------------------------------------------------
            //  Update Payload Hash
            // ---------------------------------------------------------------------
            profile.updateViewSettings(value: payloadHash, key: SettingsKey.hash, keyPath: nil, domain: domain, type: type, updateComplete: { (success, error) in
                if success { profile.save(self) }
            })
        } else if payloadHash != lastPayloadHash {
            
            // ---------------------------------------------------------------------
            //  Update Payload Version
            // ---------------------------------------------------------------------
            let newPayloadVersion = lastPayloadVersion + 1
            payloadContent[PayloadKey.payloadVersion] = newPayloadVersion
            profile.updatePayloadSettings(value: newPayloadVersion, key: PayloadKey.payloadVersion, domain: domain, type: type, updateComplete: { (success, error) in
                if success { profile.save(self) }
            })
            
            // ---------------------------------------------------------------------
            //  Update Payload Hash
            // ---------------------------------------------------------------------
            let newPayloadData = NSKeyedArchiver.archivedData(withRootObject: payloadContent)
            let newPayloadHash = newPayloadData.hashValue
            profile.updateViewSettings(value: newPayloadHash, key: SettingsKey.hash, keyPath: nil, domain: domain, type: type, updateComplete: { (success, error) in
                if success { profile.save(self) }
            })
        }
    }
    
    class func export(subkeys: [PayloadSourceSubkey], domainSettings: Dictionary<String, Any>, typeSettings: Dictionary<String, Any>, viewDomainSettings: Dictionary<String, Any>, viewTypeSettings: Dictionary<String, Any>, payloadContent: inout Dictionary<String, Any>) {
        for subkey in subkeys {
            
            // Verify that this subkey should be exported
            if !self.shouldExport(subkey: subkey, domainSettings: domainSettings) {
                Swift.print("This subkey was excluded from the export: \(subkey.keyPath)")
                continue
            }
            
            // Get and set all view settings
            var enabled = false
            if subkey.require == .always {
                enabled = true
            } else if
                let viewSettings = viewDomainSettings[subkey.keyPath] as? Dictionary<String, Any> {
                
                // Enabled
                if let isEnabled = viewSettings[SettingsKey.enabled] as? Bool {
                    enabled = isEnabled
                }
            }
            
            // Only export enabled payloads
            if enabled {
                
                // Inintialize the value
                var value: Any?
                
                if let userValue = domainSettings[subkey.keyPath] {
                    if PayloadUtility.valueType(value: userValue, type: subkey.type) == subkey.type {
                        value = userValue
                    } else {
                        Swift.print("User value: \(userValue) did not match value type: \(PayloadUtility.valueType(value: userValue)) != \(subkey.type) for key: \(subkey.key)")
                    }
                }
                
                // If no user value was found, get default value or use an empty value
                if value == nil {
                    value = subkey.valueDefault ?? PayloadUtility.emptyValue(valueType: subkey.type)
                }
                
                if let keyValue = value {
                    Swift.print("Setting: \(subkey.key) = \(keyValue)")
                    payloadContent[subkey.key] = keyValue
                } else {
                    Swift.print("ERROR: NO VALUE!")
                }
            }
            
            // Continue through all subkeys
            if !subkey.subkeys.isEmpty { self.export(subkeys: subkey.subkeys, domainSettings: domainSettings, typeSettings: typeSettings, viewDomainSettings: viewDomainSettings, viewTypeSettings: viewTypeSettings, payloadContent: &payloadContent) }
        }
    }
    
    class func shouldExport(subkey: PayloadSourceSubkey, domainSettings: Dictionary<String, Any>) -> Bool {
        return true
    }
}
