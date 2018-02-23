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
    
    var profileIdentifier: String?
    
    func export(profile: Profile) throws -> Dictionary<String, Any>? {
        
        var profileContentExported = Dictionary<String, Any>()
        
        do {
            profileContentExported = try self.profileContent(profile: profile)
            profileContentExported[PayloadKey.payloadContent] = try self.payloadContent(profile: profile)
        } catch let error {
            Swift.print("Profile Export Error: \(error)")
            throw error
        }
        
        return profileContentExported
    }
    
    
    func profileContent(profile: Profile) throws -> Dictionary<String, Any> {
        
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
            try self.export(subkeys: payloadSource.subkeys,
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
        self.profileIdentifier = payloadIdentifier
        
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
    
    func payloadContent(profile: Profile) throws -> [Dictionary<String, Any>] {
        
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
                
                // Ignore not enabled Payloads
                if let enabled = domainSettings[SettingsKey.enabled] as? Bool, !enabled { continue }
                
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
                    try self.export(subkeys: payloadSource.subkeys,
                                    domainSettings: domainSettings,
                                    typeSettings: typeSettingsDict,
                                    viewDomainSettings: viewDomainSettings,
                                    viewTypeSettings: viewTypeSettings,
                                    payloadContent: &payloadContent)
                    
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
    
    func updatePayloadVersion(profile: Profile, type: PayloadSourceType, domain: String, viewDomainSettings: Dictionary<String, Any>, payloadContent: inout Dictionary<String, Any>) {
        
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
    
    func export(subkeys: [PayloadSourceSubkey],
                domainSettings: Dictionary<String, Any>,
                typeSettings: Dictionary<String, Any>,
                viewDomainSettings: Dictionary<String, Any>,
                viewTypeSettings: Dictionary<String, Any>,
                payloadContent: inout Dictionary<String, Any>) throws {
        for subkey in subkeys {
            
            // ---------------------------------------------------------------------
            //  Verify the subkey should be exported
            // ---------------------------------------------------------------------
            if !self.shouldExport(subkey: subkey, domainSettings: domainSettings) {
                Swift.print("This subkey was excluded from the export: \(subkey.keyPath)")
                continue
            }
            
            // ---------------------------------------------------------------------
            //  Get all view settings (Enabled)
            // ---------------------------------------------------------------------
            var enabled = false
            if subkey.require == .always {
                enabled = true
            } else if
                let viewSettings = viewDomainSettings[subkey.keyPath] as? Dictionary<String, Any> {
                
                // Enabled
                if let isEnabled = viewSettings[SettingsKey.enabled] as? Bool { enabled = isEnabled }
            }
            
            // ---------------------------------------------------------------------
            //  Only export enabled payloads
            // ---------------------------------------------------------------------
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
                
                // ---------------------------------------------------------------------
                //  Verify the value is valid
                // ---------------------------------------------------------------------
                if !self.shouldExport(value: value, subkey: subkey) {
                    if subkey.require == .always {
                        Swift.print("The value: \(String(describing: value)) is not valid for export for subkey: \(subkey.domain)")
                        throw ProfileExportError.invalid(value: value, forKey: subkey.key, inDomain: subkey.domain, ofType: subkey.payloadSourceType)
                    }
                    continue
                }
                
                
                if let keyValue = value {
                    
                    // ---------------------------------------------------------------------
                    //  Payload Identifier
                    // ---------------------------------------------------------------------
                    if subkey.key == PayloadKey.payloadIdentifier, let profileIdentifier = self.profileIdentifier {
                        var payloadIdentifier: String
                        if let payloadUUID = domainSettings[PayloadKey.payloadUUID] as? String {
                            payloadIdentifier = profileIdentifier + ".\(keyValue).\(payloadUUID)"
                        } else {
                            payloadIdentifier = profileIdentifier + ".\(keyValue)"
                        }
                        Swift.print("Setting: \(subkey.key) = \(payloadIdentifier)")
                        payloadContent[subkey.key] = payloadIdentifier
                        
                        // ---------------------------------------------------------------------
                        //  All Other
                        // ---------------------------------------------------------------------
                    } else {
                        Swift.print("Setting: \(subkey.key) = \(keyValue)")
                        payloadContent[subkey.key] = keyValue
                    }
                } else {
                    Swift.print("ERROR: NO VALUE!")
                }
            }
            
            // Continue through all subkeys
            if !subkey.subkeys.isEmpty {
                try self.export(subkeys: subkey.subkeys,
                                domainSettings: domainSettings,
                                typeSettings: typeSettings,
                                viewDomainSettings: viewDomainSettings,
                                viewTypeSettings: viewTypeSettings,
                                payloadContent: &payloadContent)
            }
        }
    }
    
    func shouldExport(value: Any?, subkey: PayloadSourceSubkey) -> Bool {
        if subkey.require == .always {
            Swift.print("This key is required: \(subkey.key)")
            Swift.print("This key has value: \(String(describing: value))")
            
            switch subkey.type {
            case .string:
                guard let valueString = value as? String else { return false }
                if valueString.isEmpty {
                    return false
                } else if
                    let format = subkey.format,
                    !valueString.matches(format) {
                    return false
                }
            case .undefined:
                Swift.print("undefined")
            case .array:
                Swift.print("array")
            case .bool:
                Swift.print("bool")
            case .date:
                Swift.print("date")
            case .data:
                Swift.print("data")
            case .dictionary:
                Swift.print("dictionary")
            case .float:
                Swift.print("float")
            case .integer:
                Swift.print("integer")
            }
            if value == nil { return false }
        }
        return true
    }
    
    func shouldExport(subkey: PayloadSourceSubkey, domainSettings: Dictionary<String, Any>) -> Bool {
        return true
    }
}
