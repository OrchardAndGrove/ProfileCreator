//
//  ProfileExport.swift
//  ProfileCreator
//
//  Created by Erik Berglund.
//  Copyright © 2018 Erik Berglund. All rights reserved.
//

import Foundation
import ProfilePayloads

class ProfileExport {
    
    // MARK: -
    // MARK: Variables
    
    var ignoreErrorInvalidValue = false
    var ignoreSave = false
    
    weak var profile: Profile?
    
    // MARK: -
    // MARK: Functions Export
    
    func export(profile: Profile, profileURL: URL) throws -> Void {
        Log.shared.info(message: "Exporting profile with identifier: \(profile.identifier) to path: \(profileURL.path)")
        
        self.profile = profile
        var profileContent = Dictionary<String, Any>()
        
        do {
            
            // ---------------------------------------------------------------------
            //  Get the profile root content
            // ---------------------------------------------------------------------
            profileContent = try self.profileContent(profile: profile)
            
            // ---------------------------------------------------------------------
            //  Get the profile payload content
            // ---------------------------------------------------------------------
            profileContent[PayloadKey.payloadContent] = try self.payloadContent(profile: profile)
        } catch {
            Log.shared.error(message: "Failed to generate profile content with error: \(error.localizedDescription)")
            throw error
        }
        
        #if DEBUG
            Log.shared.debug(message: "Profile Content: \(profileContent)")
        #endif
        
        if #available(OSX 10.13, *) {
            do {
                try NSDictionary(dictionary: profileContent).write(to: profileURL)
            } catch {
                Log.shared.error(message: "Failed to write profile to path: \(profileURL.path) with error: \(error.localizedDescription)")
                throw error
            }
        } else {
            if !NSDictionary(dictionary: profileContent).write(to: profileURL, atomically: true) {
                // FIXME: Correct Error
                throw ProfileExportError.unknownError
            }
        }
    }
    
    func export(profile: Profile,
                domain: String,
                type: PayloadSourceType,
                domainSettings: Dictionary<String, Any>,
                typeSettings: Dictionary<String, Any>,
                payloadContent: inout Dictionary<String, Any>) throws {
        Log.shared.debug(message: "Generating payload content for domain: \(domain)")
        
        if let payloadSource = ProfilePayloads.shared.payloadSource(domain: domain, type: type) {
            
            // ---------------------------------------------------------------------
            //  Get the view settings for the current domain
            // ---------------------------------------------------------------------
            let viewTypeSettings = profile.getPayloadViewTypeSettings(type: type)
            let viewDomainSettings = viewTypeSettings[domain] as? Dictionary<String, Any> ?? Dictionary<String, Any>()
            
            // ---------------------------------------------------------------------
            //  Export the current domain
            // ---------------------------------------------------------------------
            try self.export(profile: profile,
                            subkeys: payloadSource.subkeys,
                            domainSettings: domainSettings,
                            typeSettings: typeSettings,
                            viewDomainSettings: viewDomainSettings,
                            viewTypeSettings: viewTypeSettings,
                            payloadContent: &payloadContent)
            
            // ---------------------------------------------------------------------
            //  Update the payload version (and hash) if anything has changed and if a payloaduuid exists
            // ---------------------------------------------------------------------
            if let payloadUUID = domainSettings[PayloadKey.payloadUUID] as? String, !payloadUUID.isEmpty {
                self.updatePayloadVersion(profile: profile, type: type, domain: domain, viewDomainSettings: viewDomainSettings, payloadContent: &payloadContent)
            } else { Log.shared.debug(message: "No PayloadUUID is set, will not update the payload version") }
        } else { Log.shared.error(message: "Failed to get a payloadSource for domain: \(domain) of type: \(type)") }
    }
    
    func export(profile: Profile,
                subkeys: [PayloadSourceSubkey],
                domainSettings: Dictionary<String, Any>,
                typeSettings: Dictionary<String, Any>,
                viewDomainSettings: Dictionary<String, Any>,
                viewTypeSettings: Dictionary<String, Any>,
                payloadContent: inout Dictionary<String, Any>) throws {
        
        for subkey in subkeys {
            
            // ---------------------------------------------------------------------
            //  Verify the subkey should be exported
            // ---------------------------------------------------------------------
            if self.shouldExport(profile: profile, subkey: subkey, typeSettings: typeSettings, domainSettings: domainSettings, viewTypeSettings: viewTypeSettings, viewDomainSettings: viewDomainSettings) {
                
                #if DEBUG
                    Log.shared.debug(message: "Should export subkey: \(subkey.keyPath) of type: \(subkey.type): true", category: String(describing: self))
                #endif
                
                // ---------------------------------------------------------------------
                //  If this is an array, then move to the next subkey as the contents will be set by the "lowest" ( or highest? ) key in the tree
                // ---------------------------------------------------------------------
                if subkey.type == .array, !subkey.subkeys.isEmpty {
                    
                    #if DEBUG
                        Log.shared.debug(message: "Subkey is an array, will ignore this subkey and continue with it's subkeys", category: String(describing: self))
                    #endif
                    
                    try self.export(profile: profile,
                                    subkeys: subkey.subkeys,
                                    domainSettings: domainSettings,
                                    typeSettings: typeSettings,
                                    viewDomainSettings: viewDomainSettings,
                                    viewTypeSettings: viewTypeSettings,
                                    payloadContent: &payloadContent)
                    continue
                } else if let parentSubkey = subkey.parentSubkey, (parentSubkey.type == .array || parentSubkey.type == .dictionary), !subkey.subkeys.isEmpty {
                    
                    #if DEBUG
                        Log.shared.debug(message: "Subkey parent is an array or dictionary, will ignore this subkey and continue with it's subkeys", category: String(describing: self))
                    #endif
                    
                    try self.export(profile: profile,
                                    subkeys: subkey.subkeys,
                                    domainSettings: domainSettings,
                                    typeSettings: typeSettings,
                                    viewDomainSettings: viewDomainSettings,
                                    viewTypeSettings: viewTypeSettings,
                                    payloadContent: &payloadContent)
                    continue
                } else if subkey.type == .dictionary, subkey.subkeys.contains(where: { $0.key == ManifestKeyPlaceholder.key }) {
                    
                    #if DEBUG
                        Log.shared.debug(message: "Subkey is a dictinoary with dynamic key/values, will ignore this subkey and continue with it's subkeys", category: String(describing: self))
                    #endif
                    
                    try self.export(profile: profile,
                                    subkeys: subkey.subkeys,
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
            } else {
                #if DEBUG
                    Log.shared.debug(message: "Should export subkey: \(subkey.keyPath) of type: \(subkey.type): false", category: String(describing: self))
                #endif
            }
            
            // Continue through all subkeys
            if !subkey.subkeys.isEmpty {
                try self.export(profile: profile,
                                subkeys: subkey.subkeys,
                                domainSettings: domainSettings,
                                typeSettings: typeSettings,
                                viewDomainSettings: viewDomainSettings,
                                viewTypeSettings: viewTypeSettings,
                                payloadContent: &payloadContent)
            }
        }
    }
    
    // MARK: -
    // MARK: Functions Profile/Payload Content
    
    func profileContent(profile: Profile) throws -> Dictionary<String, Any> {
        Log.shared.log(message: "Generating profile content for profile with identifier: \(profile.identifier)")
        
        var profileContent = Dictionary<String, Any>()
        
        if let payloadSource = ProfilePayloads.shared.payloadSource(domain: ManifestDomain.general, type: .manifest) {
            
            // ---------------------------------------------------------------------
            //  Get the type settings for the current domain
            // ---------------------------------------------------------------------
            let typeSettings = profile.getPayloadTypeSettings(type: .manifest)
            let domainSettings = typeSettings[ManifestDomain.general] ?? Dictionary<String, Any>()
            
            // ---------------------------------------------------------------------
            //  Get the view settings for the current domain
            // ---------------------------------------------------------------------
            let viewTypeSettings = profile.getPayloadViewTypeSettings(type: .manifest)
            let viewDomainSettings = viewTypeSettings[ManifestDomain.general] as? Dictionary<String, Any> ?? Dictionary<String, Any>()
            
            // ---------------------------------------------------------------------
            //  Export the general domain
            // ---------------------------------------------------------------------
            try self.export(profile: profile,
                            subkeys: payloadSource.subkeys,
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
    
    func payloadContent(profile: Profile) throws -> [Dictionary<String, Any>] {
        Log.shared.log(message: "Generating payload content for profile with identifier: \(profile.identifier)")
        
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
        Log.shared.debug(message: "Verifying payload version for domain: \(domain)")
        
        // ---------------------------------------------------------------------
        //  Get the current payload hash
        // ---------------------------------------------------------------------
        let payloadData = NSKeyedArchiver.archivedData(withRootObject: payloadContent)
        let payloadHash = payloadData.hashValue
        
        // ---------------------------------------------------------------------
        //  Get the last payload hash and version
        // ---------------------------------------------------------------------
        let payloadHashSaved = viewDomainSettings[SettingsKey.hash] as? Int ?? -1
        let lastPayloadVersion = payloadContent[PayloadKey.payloadVersion] as? Int ?? 1
        
        #if DEBUG
            Log.shared.debug(message: "Payload content: \(payloadContent)")
            Log.shared.debug(message: "Payload hash: \(payloadHash)")
            Log.shared.debug(message: "Payload hash saved: \(payloadHashSaved)")
        #endif
        
        if payloadHashSaved == -1 {
            
            // ---------------------------------------------------------------------
            //  Update Payload Hash
            // ---------------------------------------------------------------------
            if !self.ignoreSave {
                profile.updateViewSettings(value: payloadHash, key: SettingsKey.hash, keyPath: nil, domain: domain, type: type, updateComplete: { (success, error) in
                    if success { profile.save(self) }
                    
                })
            }
        } else if payloadHash != payloadHashSaved {
            
            // ---------------------------------------------------------------------
            //  Update Payload Version
            // ---------------------------------------------------------------------
            let newPayloadVersion = lastPayloadVersion + 1
            payloadContent[PayloadKey.payloadVersion] = newPayloadVersion
            if !self.ignoreSave {
                profile.updatePayloadSettings(value: newPayloadVersion, key: PayloadKey.payloadVersion, domain: domain, type: type)
                
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
    }

    func shouldExport(profile: Profile, subkey: PayloadSourceSubkey, typeSettings: Dictionary<String, Any>, domainSettings: Dictionary<String, Any>, viewTypeSettings: Dictionary<String, Any>, viewDomainSettings: Dictionary<String, Any>) -> Bool {
        
        if !profile.isEnabled(subkey: subkey, onlyByUser: false) { return false }
        
        // Special case for dynamic dictionaries
        if subkey.key == ManifestKeyPlaceholder.key { return false }
        
        // profile.subkeyIsExcluded
        
        return true
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
        
        #if DEBUG
            Log.shared.debug(message: "Getting value for subkey: \(subkey.keyPath) of type: \(subkey.type)", category: String(describing: self))
        #endif
        
        // ---------------------------------------------------------------------
        //  Check if we got a parent subkey
        // ---------------------------------------------------------------------
        if let parentSubkey = pSubkey {
            
            #if DEBUG
                Log.shared.debug(message: "Subkey: \(subkey.keyPath) has parent subkey: \(parentSubkey.keyPath) of type: \(parentSubkey.type)", category: String(describing: self))
            #endif
            
            // ---------------------------------------------------------------------
            //  Get it's child subkey
            // ---------------------------------------------------------------------
            var childSubkey: PayloadSourceSubkey?
            if let parentSubkeys = subkey.parentSubkeys,
                let parentSubkeyIndex = parentSubkeys.index(where: {$0.keyPath == parentSubkey.keyPath}),
                (parentSubkeyIndex + 2) <= parentSubkeys.count {
                childSubkey = parentSubkeys[(parentSubkeyIndex + 1)]
            }
            
            #if DEBUG
                if let cSubkey = childSubkey {
                    Log.shared.debug(message: "Parent subkey: \(parentSubkey.keyPath) has child subkey: \(cSubkey.keyPath) of type: \(cSubkey.type)", category: String(describing: self))
                }
            #endif
            
            // ---------------------------------------------------------------------
            //  Get the settings for the parent subkey
            // ---------------------------------------------------------------------
            switch parentSubkey.type {
            case .array:
                
                // ---------------------------------------------------------------------
                //  Get the parent subkey payload content
                // ---------------------------------------------------------------------
                var parentPayloadContent = pPayloadContent as? [Any] ?? [Any]()
                
                #if DEBUG
                    Log.shared.debug(message: "Parent subkey: \(parentSubkey.keyPath) has payloadContent: \(parentPayloadContent)", category: String(describing: self))
                #endif
                
                if let pSettings = parentSettings as? Dictionary<String, Any> {
                    if let value = try self.getValue(forSubkey: subkey, typeSettings: typeSettings, domainSettings: domainSettings, parentDomainSettings: pSettings) {
                        parentPayloadContent.append(value)
                    }
                    return parentPayloadContent
                }
                
                // ---------------------------------------------------------------------
                //  Get the parent subkey settings
                // ---------------------------------------------------------------------
                guard let parentSubkeySettings = domainSettings[parentSubkey.keyPath] as? [Any] else {
                    throw ProfileExportError.invalid(value: domainSettings[parentSubkey.keyPath],
                                                     forKey: parentSubkey.keyPath,
                                                     inDomain: parentSubkey.domain,
                                                     ofType: parentSubkey.payloadSourceType)
                }
                
                // ---------------------------------------------------------------------
                //  Loop over all parent settings to get each setting for subkey
                // ---------------------------------------------------------------------
                for (index, childSettings) in parentSubkeySettings.enumerated() {
                    
                    #if DEBUG
                        Log.shared.debug(message: "Parent subkey: \(parentSubkey.keyPath) has settings: \(childSettings) at index: \(index)", category: String(describing: self))
                        Log.shared.debug(message: "Parent subkey: \(parentSubkey.keyPath) has payloadContent: \(parentPayloadContent) at index: \(index)", category: String(describing: self))
                    #endif
                    
                    var childPayloadContent: Any?
                    if (index + 1) <= parentPayloadContent.count {
                        childPayloadContent = parentPayloadContent[index]
                    }
                    
                    #if DEBUG
                        Log.shared.debug(message: "Child subkey: \(childSubkey?.keyPath ?? "nil") has payloadContent: \(childPayloadContent ?? "nil") at index: \(index)", category: String(describing: self))
                    #endif
                    
                    if let subkeyValue = try self.getValue(forSubkey: subkey,
                                                           parentSubkey: childSubkey,
                                                           typeSettings: typeSettings,
                                                           domainSettings: domainSettings,
                                                           parentSettings: childSettings,
                                                           payloadContent: payloadContent,
                                                           parentPayloadContent: childPayloadContent) {
                        
                        #if DEBUG
                            Log.shared.debug(message: "Setting: \(subkeyValue) at index: \(index)", category: String(describing: self))
                        #endif
                        if childPayloadContent == nil {
                            parentPayloadContent.insert(subkeyValue, at: index)
                        } else if (index + 1) <= parentPayloadContent.count {
                            parentPayloadContent[index] = subkeyValue
                        } else {
                            Log.shared.error(message: "Failed to update parent payload content for subkey: \(parentSubkey.keyPath) at index: \(index)", category: String(describing: self))
                        }
                    }
                }
                
                return parentPayloadContent
            case .dictionary:
                
                // ---------------------------------------------------------------------
                //  Get the parent subkey payload content
                // ---------------------------------------------------------------------
                var parentPayloadContent = pPayloadContent as? Dictionary<String, Any> ?? Dictionary<String, Any>()
                
                // FIXME: This needs checking for every different possibility. Currently it's not really used. Need to really look into this and clear it up with better comments
                
                var childSettings: Any?
                var childPayloadContent: Any?
                if let theChildSubkey = childSubkey {
                    childSettings = domainSettings[theChildSubkey.keyPath]
                    
                    childPayloadContent = parentPayloadContent[theChildSubkey.key]
                    Swift.print("childPayloadContent: \(String(describing: childPayloadContent))")
                    
                    if let subkeyValue = try self.getValue(forSubkey: subkey,
                                                           parentSubkey: childSubkey,
                                                           typeSettings: typeSettings,
                                                           domainSettings: domainSettings,
                                                           parentSettings: childSettings,
                                                           payloadContent: payloadContent,
                                                           parentPayloadContent: childPayloadContent) {
                        Swift.print("Child subkeyValue: \(subkeyValue)")
                        if let theChildSubkey = childSubkey {
                            parentPayloadContent[theChildSubkey.key] = subkeyValue
                        } else {
                            parentPayloadContent[subkey.key] = subkeyValue
                        }
                    }
                } else if let value = try self.getValue(forSubkey: subkey, typeSettings: typeSettings, domainSettings: domainSettings, parentDomainSettings: parentSettings) {
                    if subkey.key == ManifestKeyPlaceholder.value {
                        if let valueArray = value as? [Any], let parentSubkeySettings = parentSettings as? [Dictionary<String, Any>] {
                            for (index, valueItem) in valueArray.enumerated() {
                                // Get the key
                                guard let key = parentSubkeySettings[index]["\(parentSubkey.key).\(ManifestKeyPlaceholder.key)"] as? String, !key.isEmpty else { continue }
                                Swift.print("Adding this to parent payload: \(key): \(valueItem)")
                            
                                parentPayloadContent[key] = valueItem
                            }
                        }
                    } else {
                        Swift.print("Adding this to parent payload: \(subkey.key): \(value)")
                        parentPayloadContent[subkey.key] = value
                    }
                } else {
                    #if DEBUG
                    #endif
                    
                    throw ProfileExportError.unknownError // FIXME: Add Correct Error
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
        } else if let parentDomainSettingsArray = parentSettings as? [Dictionary<String, Any>] {
            value = parentDomainSettingsArray.map({$0[subkey.keyPath]})
        }
        
        if value == nil {
            if let userValue = domainSettings[subkey.keyPath] {
                value = userValue
            } else {
                if let valueDefault = subkey.valueDefault {
                    value = valueDefault
                } else if let valueRangeList = subkey.rangeList?.first {
                    value = valueRangeList
                } else {
                    value = PayloadUtility.emptyValue(valueType: subkey.typeInput)
                }
                
                // Special case when the PayloadIdentifier isn't manually entered
                if subkey.key == PayloadKey.payloadIdentifier, let payloadIdentifier = value as? String {
                    value = self.payloadIdentifier(payloadIdentifier: payloadIdentifier, typeSettings: typeSettings, domainSettings: domainSettings)
                }
            }
        }
        
        // Check if the value should be processed
        if let valueProcessorIdentifier = subkey.valueProcessor, let valueToProcess = value {
            let valueProcessor = PayloadValueProcessors.shared.processor(withIdentifier: valueProcessorIdentifier, inputType: subkey.typeInput, outputType: subkey.type)
            if let valueProcessed = valueProcessor.process(value: valueToProcess) {
                value = valueProcessed
            }
        } else if subkey.typeInput != subkey.type, let valueToProcess = value {
            let valueProcessor = PayloadValueProcessors.shared.processor(inputType: subkey.typeInput, outputType: subkey.type)
            if let valueProcessed = valueProcessor.process(value: valueToProcess) {
                value = valueProcessed
            }
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
        // FIXME: This is just a quick solution for dynamic dictionaries, should probably do a more robust thing that doesn't have to check for this when exporting every key and value
        if self.ignoreErrorInvalidValue || subkey.key == ManifestKeyPlaceholder.value { return }
        
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
        guard let profile = self.profile else { return }
        let isRequired = profile.isRequired(subkey: subkey) ? true : false
        
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
                throw errorInvalid // FIXME: Add Correct Error
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
            
            if let rangeMin = subkey.rangeMin as? Int, valueInt < rangeMin {
                throw errorInvalid
            }
            
            if let rangeMax = subkey.rangeMax as? Int, rangeMax < valueInt {
                throw errorInvalid
            }
        }
    }
    
    // MARK: -
    // MARK: PayloadContent: Set
    
    func updatePayloadContent(subkey: PayloadSourceSubkey, typeSettings: Dictionary<String, Any>, domainSettings: Dictionary<String, Any>, payloadContent: inout Dictionary<String, Any>) throws {
        
        #if DEBUG
            Log.shared.debug(message: "Updating payload content for subkey: \(subkey.keyPath) of type: \(subkey.type)", category: String(describing: self))
        #endif
        
        // ---------------------------------------------------------------------
        //  If subkey has parents, need to update to parent settings
        // ---------------------------------------------------------------------
        if let rootSubkey = subkey.rootSubkey {
            
            #if DEBUG
                Log.shared.debug(message: "Subkey: \(subkey.keyPath) has root subkey: \(rootSubkey.keyPath)", category: String(describing: self))
            #endif
            if let rootSubkeyValue = try self.getValue(forSubkey: subkey,
                                                       parentSubkey: rootSubkey,
                                                       typeSettings: typeSettings,
                                                       domainSettings: domainSettings,
                                                       parentSettings: domainSettings[rootSubkey.keyPath],
                                                       payloadContent: payloadContent,
                                                       parentPayloadContent: payloadContent[rootSubkey.key]) {
                #if DEBUG
                    Log.shared.debug(message: "Setting: \(rootSubkey.key) = \(rootSubkeyValue)", category: String(describing: self))
                #endif
                
                payloadContent[rootSubkey.key] = rootSubkeyValue
            } else {
                Log.shared.error(message: "No value returned for the root subkey: \(rootSubkey.keyPath)", category: String(describing: self))
                throw ProfileExportError.unknownError // FIXME: Add Correct Error
            }
        } else if let value = try self.getValue(forSubkey: subkey, typeSettings: typeSettings, domainSettings: domainSettings, parentDomainSettings: nil) {
            
            #if DEBUG
                Log.shared.debug(message: "Setting: \(subkey.key) = \(value)", category: String(describing: self))
            #endif
            
            payloadContent[subkey.key] = value
        } else {
            Log.shared.error(message: "No value returned for the subkey: \(subkey.keyPath)", category: String(describing: self))
            throw ProfileExportError.unknownError // FIXME: Add Correct Error
        }
    }
    
    func payloadIdentifier(payloadIdentifier identifier: String, typeSettings: Dictionary<String, Any>, domainSettings: Dictionary<String, Any>) -> String? {
        
        var payloadIdentifier = identifier
        
        if let payloadUUID = domainSettings[PayloadKey.payloadUUID] as? String {
            payloadIdentifier = payloadIdentifier + ".\(payloadUUID)"
        }
        
        if
            let generalSettings = typeSettings[ManifestDomain.general] as? Dictionary<String, Any>,
            let profilePayloadIdentifier = generalSettings[PayloadKey.payloadIdentifier] as? String {
            payloadIdentifier = profilePayloadIdentifier + ".\(payloadIdentifier)"
        }
        
        return payloadIdentifier
    }
}
