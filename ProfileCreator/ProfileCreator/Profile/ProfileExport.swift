//
//  ProfileExport.swift
//  ProfileCreator
//
//  Created by Erik Berglund on 2017-11-08.
//  Copyright © 2018 Erik Berglund. All rights reserved.
//

import Foundation
import ProfilePayloads

class ProfileExport {
    
    var ignoreErrorInvalidValue = false
    var ignoreSave = false
    
    var profileIdentifier: String?
    
    func export(profile: Profile, profileURL: URL) throws -> Void {
        
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
                
                // Create a new PayloadContent dictionary
                var payloadContent = Dictionary<String, Any>()
                
                // Populate the PayloadContent dictionary
                try self.export(profile: profile, domain: domain, type: type, domainSettings: domainSettings, typeSettings: typeSettingsDict, payloadContent: &payloadContent)
                
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
        Swift.print("lastPayloadHash: \(lastPayloadHash)")
        if lastPayloadHash == -1 {
            
            // ---------------------------------------------------------------------
            //  Update Payload Hash
            // ---------------------------------------------------------------------
            profile.updateViewSettings(value: payloadHash, key: SettingsKey.hash, keyPath: nil, domain: domain, type: type, updateComplete: { (success, error) in
                if success, !self.ignoreSave { profile.save(self) }
            })
        } else if payloadHash != lastPayloadHash {
            
            // ---------------------------------------------------------------------
            //  Update Payload Version
            // ---------------------------------------------------------------------
            let newPayloadVersion = lastPayloadVersion + 1
            payloadContent[PayloadKey.payloadVersion] = newPayloadVersion
            profile.updatePayloadSettings(value: newPayloadVersion, key: PayloadKey.payloadVersion, domain: domain, type: type, updateComplete: { (success, error) in
                if success, !self.ignoreSave { profile.save(self) }
            })
            
            // ---------------------------------------------------------------------
            //  Update Payload Hash
            // ---------------------------------------------------------------------
            let newPayloadData = NSKeyedArchiver.archivedData(withRootObject: payloadContent)
            let newPayloadHash = newPayloadData.hashValue
            profile.updateViewSettings(value: newPayloadHash, key: SettingsKey.hash, keyPath: nil, domain: domain, type: type, updateComplete: { (success, error) in
                if success, !self.ignoreSave { profile.save(self) }
            })
        }
    }
    
    func export(profile: Profile,
                domain: String,
                type: PayloadSourceType,
                domainSettings: Dictionary<String, Any>,
                typeSettings: Dictionary<String, Any>,
                payloadContent: inout Dictionary<String, Any>) throws {
        
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
                            typeSettings: typeSettings,
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
            if self.shouldExport(subkey: subkey, typeSettings: typeSettings, domainSettings: domainSettings, viewTypeSettings: viewTypeSettings, viewDomainSettings: viewDomainSettings) {
                
                // ---------------------------------------------------------------------
                //  If this is an array, then move to the next subkey as the contents will be set by the "lowest" ( or highest? ) key in the tree
                // ---------------------------------------------------------------------
                if subkey.type == .array, !subkey.subkeys.isEmpty {
                    try self.export(subkeys: subkey.subkeys,
                                    domainSettings: domainSettings,
                                    typeSettings: typeSettings,
                                    viewDomainSettings: viewDomainSettings,
                                    viewTypeSettings: viewTypeSettings,
                                    payloadContent: &payloadContent)
                    continue
                } else if let parentSubkey = subkey.parentSubkey, parentSubkey.type == .array, !subkey.subkeys.isEmpty {
                    try self.export(subkeys: subkey.subkeys,
                                    domainSettings: domainSettings,
                                    typeSettings: typeSettings,
                                    viewDomainSettings: viewDomainSettings,
                                    viewTypeSettings: viewTypeSettings,
                                    payloadContent: &payloadContent)
                    continue
                }
                
                // ---------------------------------------------------------------------
                //  Update the payload contents with this subkeys value
                // ---------------------------------------------------------------------
                try self.updatePayloadContent(subkey: subkey, typeSettings: typeSettings, domainSettings: domainSettings, payloadContent: &payloadContent)
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
    
    // MARK: -
    // MARK: Verify
    
    func isEnabled(subkey: PayloadSourceSubkey, typeSettings: Dictionary<String, Any>, domainSettings: Dictionary<String, Any>, viewTypeSettings: Dictionary<String, Any>, viewDomainSettings: Dictionary<String, Any>) -> Bool {
        var enabled = false
        if subkey.require == .always {
            enabled = true
        } else if
            let viewSettings = viewDomainSettings[subkey.keyPath] as? Dictionary<String, Any> {
            if let isEnabled = viewSettings[SettingsKey.enabled] as? Bool { enabled = isEnabled }
        }
        return enabled
    }
    
    func isEnabledParents(subkey: PayloadSourceSubkey, typeSettings: Dictionary<String, Any>, domainSettings: Dictionary<String, Any>, viewTypeSettings: Dictionary<String, Any>, viewDomainSettings: Dictionary<String, Any>) -> Bool {
        guard let parentSubkeys = subkey.parentSubkeys else { return true }
                
        // FIXME: This requires some fixing depending on how the view settings will be saved
        
        // Default to true only for testing
        //var enabled = true
        //var parentViewDomainSettings: Any?
        for parentSubkey in parentSubkeys {
            if !self.isEnabled(subkey: parentSubkey, typeSettings: typeSettings, domainSettings: domainSettings, viewTypeSettings: viewTypeSettings, viewDomainSettings: viewDomainSettings) {
                return false
            }
        }
        
        return true
    }
    
    func shouldExport(subkey: PayloadSourceSubkey, typeSettings: Dictionary<String, Any>, domainSettings: Dictionary<String, Any>, viewTypeSettings: Dictionary<String, Any>, viewDomainSettings: Dictionary<String, Any>) -> Bool {
        
        // ---------------------------------------------------------------------
        //  Verify this subkey and it's parents are enabled
        // ---------------------------------------------------------------------
        if self.isEnabled(subkey: subkey, typeSettings: typeSettings, domainSettings: domainSettings, viewTypeSettings: viewTypeSettings, viewDomainSettings: viewDomainSettings) {
            return self.isEnabledParents(subkey: subkey, typeSettings: typeSettings, domainSettings: domainSettings, viewTypeSettings: viewTypeSettings, viewDomainSettings: viewDomainSettings)
        }
        
        return false
    }
    
    
    
    // MARK: -
    // MARK: Value: Get
    
    func getValue(forSubkey subkey: PayloadSourceSubkey,
                  parentSubkey pSubkey: PayloadSourceSubkey?,
                  typeSettings: Dictionary<String, Any>,
                  domainSettings: Dictionary<String, Any>,
                  parentSettings: Any?,
                  payloadContent: Dictionary<String, Any>,
                  parentPayloadContent pPayloadContent: Any?) throws -> Any? {
        
        // ---------------------------------------------------------------------
        //  Check if we got a parent subkey
        // ---------------------------------------------------------------------
        if let parentSubkey = pSubkey {
            
            // ---------------------------------------------------------------------
            //  Get it's child subkey
            // ---------------------------------------------------------------------
            var childSubkey: PayloadSourceSubkey?
            if let parentSubkeys = subkey.parentSubkeys,
                let parentSubkeyIndex = parentSubkeys.index(where: {$0.keyPath == parentSubkey.keyPath}),
                (parentSubkeyIndex + 2) <= parentSubkeys.count {
                childSubkey = parentSubkeys[(parentSubkeyIndex + 1)]
            }
            
            // ---------------------------------------------------------------------
            //  Get the settings for the parent subkey
            // ---------------------------------------------------------------------
            switch parentSubkey.type {
            case .array:
                
                // ---------------------------------------------------------------------
                //  Get the parent subkey settings
                // ---------------------------------------------------------------------
                guard let parentSubkeySettings = domainSettings[parentSubkey.keyPath] as? [Any] else {
                    throw ProfileExportError.invalid(value: domainSettings[parentSubkey.keyPath],
                                                     forKey: parentSubkey.keyPath,
                                                     inDomain: parentSubkey.domain,
                                                     ofType: parentSubkey.payloadSourceType)
                }
                Swift.print("parentSubkeySettings: \(parentSubkeySettings)")
                
                // ---------------------------------------------------------------------
                //  Get the parent subkey payload content
                // ---------------------------------------------------------------------
                var parentPayloadContent = pPayloadContent as? [Any] ?? [Any]()
                Swift.print("parentPayloadContent: \(parentPayloadContent)")
                
                // ---------------------------------------------------------------------
                //  Loop over all parent settings to get each setting for subkey
                // ---------------------------------------------------------------------
                for (index, childSettings) in parentSubkeySettings.enumerated() {
                    Swift.print("Parent Subkey Settings at index: \(index): settings: \(childSettings)")
                    
                    var childPayloadContent: Any?
                    if (index + 1) <= parentPayloadContent.count {
                        childPayloadContent = parentPayloadContent[index]
                    }
                    Swift.print("childPayloadContent: \(String(describing: childPayloadContent))")
                    
                    if let subkeyValue = try self.getValue(forSubkey: subkey,
                                                           parentSubkey: childSubkey,
                                                           typeSettings: typeSettings,
                                                           domainSettings: domainSettings,
                                                           parentSettings: childSettings,
                                                           payloadContent: payloadContent,
                                                           parentPayloadContent: childPayloadContent) {
                        parentPayloadContent.insert(subkeyValue, at: index)
                    }
                }
                
                return parentPayloadContent
            case .dictionary:
                
                // ---------------------------------------------------------------------
                //  Get the parent subkey settings
                // ---------------------------------------------------------------------
                guard let parentSubkeySettings = parentSettings as? Dictionary<String, Any> else {
                    throw ProfileExportError.invalid(value: domainSettings[parentSubkey.keyPath],
                                                     forKey: parentSubkey.keyPath,
                                                     inDomain: parentSubkey.domain,
                                                     ofType: parentSubkey.payloadSourceType)
                }
                Swift.print("parentSubkeySettings: \(parentSubkeySettings)")
                
                // ---------------------------------------------------------------------
                //  Get the parent subkey payload content
                // ---------------------------------------------------------------------
                var parentPayloadContent = pPayloadContent as? Dictionary<String, Any> ?? Dictionary<String, Any>()
                Swift.print("parentPayloadContent: \(parentPayloadContent)")
                
                
                var childSettings: Any?
                var childPayloadContent: Any?
                if let theChildSubkey = childSubkey {
                    childSettings = parentSubkeySettings[theChildSubkey.keyPath]
                    Swift.print("childSettings: \(String(describing: childSettings))")
                    
                    childPayloadContent = parentPayloadContent[theChildSubkey.key]
                    Swift.print("childPayloadContent: \(String(describing: childPayloadContent))")
                    
                    if let subkeyValue = try self.getValue(forSubkey: subkey,
                                                           parentSubkey: childSubkey,
                                                           typeSettings: typeSettings,
                                                           domainSettings: domainSettings,
                                                           parentSettings: childSettings,
                                                           payloadContent: payloadContent,
                                                           parentPayloadContent: childPayloadContent) {
                        if let theChildSubkey = childSubkey {
                            parentPayloadContent[theChildSubkey.key] = subkeyValue
                        } else {
                            parentPayloadContent[subkey.key] = subkeyValue
                        }
                    }
                } else if let value = try self.getValue(forSubkey: subkey, typeSettings: typeSettings, domainSettings: domainSettings, parentDomainSettings: parentSettings) {
                    parentPayloadContent[subkey.key] = value
                } else {
                    // FIXME: Add correct error
                    throw ProfileExportError.unknownError
                }
                Swift.print("parentPayloadContent: \(String(describing: parentPayloadContent))")
                return parentPayloadContent
            default:
                Swift.print("Type: \(parentSubkey.type) should not be possible to be a parent key. Ignored.")
                return nil
            }
        } else {
            return try self.getValue(forSubkey: subkey, typeSettings: typeSettings, domainSettings: domainSettings, parentDomainSettings: parentSettings)
        }
    }
    
    func getValue(forSubkey subkey: PayloadSourceSubkey, typeSettings: Dictionary<String, Any>, domainSettings: Dictionary<String, Any>, parentDomainSettings parentSettings: Any?) throws -> Any? {
        var value: Any?
        
        if
            let parentDomainSettings = parentSettings as? Dictionary<String, Any>,
            let userValue = parentDomainSettings[subkey.keyPath] {
            value = userValue
        }
        
        if value == nil, let userValue = domainSettings[subkey.keyPath] {
            value = userValue
        }
        
        // If no user value was found, get default value or use an empty value
        if value == nil {
            value = subkey.valueDefault ?? PayloadUtility.emptyValue(valueType: subkey.type)
        }
        
        // Verify the value is valid for the subkey
        try self.verify(value: value, forSubkey: subkey)
        
        return value
    }
    
    // MARK: -
    // MARK: Value: Verify
    
    func verify(value: Any?, forSubkey subkey: PayloadSourceSubkey) throws {
        
        // ---------------------------------------------------------------------
        //  If variable ignoreErrorInvalidValue is set to true, don't verify the value
        // ---------------------------------------------------------------------
        if self.ignoreErrorInvalidValue { return }
        
        // ---------------------------------------------------------------------
        //  Create the error to return if any check fails
        // ---------------------------------------------------------------------
        let errorInvalid = ProfileExportError.invalid(value: value, forKey: subkey.key, inDomain: subkey.domain, ofType: subkey.payloadSourceType)
        
        // ---------------------------------------------------------------------
        //  Verify the value type matches the defined type in the subkey
        // ---------------------------------------------------------------------
        if PayloadUtility.valueType(value: value, type: subkey.type) != subkey.type {
            throw errorInvalid
        }
        
        // ---------------------------------------------------------------------
        //  Get if this subkey is required
        // ---------------------------------------------------------------------
        let isRequired = (subkey.require == .always) ? true : false
        
        // ---------------------------------------------------------------------
        //  Get if this subkey is required
        // ---------------------------------------------------------------------
        switch subkey.type {
        case .string:
            guard let valueString = value as? String else {
                throw errorInvalid
            }
            
            if isRequired, valueString.isEmpty {
                throw errorInvalid
            } else if let format = subkey.format, !valueString.matches(format) {
                // FIXME: Add correct error here
                throw errorInvalid
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
            guard let valueInt = value as? Int else {
                throw errorInvalid
            }
        }
    }
    
    // MARK: -
    // MARK: PayloadContent: Set
    
    func updatePayloadContent(subkey: PayloadSourceSubkey, typeSettings: Dictionary<String, Any>, domainSettings: Dictionary<String, Any>, payloadContent: inout Dictionary<String, Any>) throws {
        
        // ---------------------------------------------------------------------
        //  If subkey has parents, need to update to parent settings
        // ---------------------------------------------------------------------
        if let rootSubkey = subkey.rootSubkey {
            if let rootSubkeyValue = try self.getValue(forSubkey: subkey,
                                                       parentSubkey: rootSubkey,
                                                       typeSettings: typeSettings,
                                                       domainSettings: domainSettings,
                                                       parentSettings: domainSettings[rootSubkey.keyPath],
                                                       payloadContent: payloadContent,
                                                       parentPayloadContent: payloadContent[rootSubkey.key]) {
                payloadContent[rootSubkey.key] = rootSubkeyValue
            } else {
                // FIXME: Add Correct Error
                Swift.print("Got nothing for the root subkey!")
                throw ProfileExportError.unknownError
            }
        } else if let value = try self.getValue(forSubkey: subkey, typeSettings: typeSettings, domainSettings: domainSettings, parentDomainSettings: nil) {
            
            // ---------------------------------------------------------------------
            //  Payload Identifier
            // ---------------------------------------------------------------------
            if subkey.key == PayloadKey.payloadIdentifier, let profileIdentifier = self.profileIdentifier {
                var payloadIdentifier: String
                if let payloadUUID = domainSettings[PayloadKey.payloadUUID] as? String {
                    payloadIdentifier = profileIdentifier + ".\(value).\(payloadUUID)"
                } else {
                    payloadIdentifier = profileIdentifier + ".\(value)"
                }
                Swift.print("Setting: \(subkey.key) = \(payloadIdentifier)")
                payloadContent[subkey.key] = payloadIdentifier
                
                // ---------------------------------------------------------------------
                //  All Other
                // ---------------------------------------------------------------------
            } else {
                Swift.print("Setting: \(subkey.key) = \(value)")
                payloadContent[subkey.key] = value
            }
        } else {
            // FIXME: Add correct error
            throw ProfileExportError.unknownError
        }
    }
}
