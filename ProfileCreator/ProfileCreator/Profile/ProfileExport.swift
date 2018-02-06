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
    
    class func export(profile: Profile, completionHandler: @escaping (_ error: Error?) -> Void) {
        
        var profileContentExported = Dictionary<String, Any>()
        self.profileContent(profile: profile) { (profileContent, error) in
            Swift.print("This is the Profile Content: \(profileContent)")
            
            // Verify the content was exported correctly, No error
            if profileContent.isEmpty || error != nil {
                completionHandler(error)
                return
            } else {
                profileContentExported = profileContent
                Swift.print("Profile Content Export Complete")
            }
        }
        
        self.payloadContent(profile: profile) { (payloadContent, error) in
            Swift.print("This is the Payload Content: \(payloadContent)")
            
            // Verify the content was exported correctly, No error
            if payloadContent.isEmpty || error != nil {
                completionHandler(error)
                return
            } else {
                profileContentExported["PayloadContent"] = payloadContent
                Swift.print("Payload Content Export Complete")
            }
        }
        
        Swift.print("Finished Profile: \(profileContentExported)")
        if !NSDictionary(dictionary: profileContentExported).write(toFile: "/Users/eriber2/Desktop/test.mobileconfig", atomically: true) {
            Swift.print("Failed to write")
        }
        
        completionHandler(nil)
    }

    
    class func profileContent(profile: Profile, completionHandler: (_ profileContent: Dictionary<String, Any>, _ error: Error?) -> Void) {
        
        var profileContent = Dictionary<String, Any>()
        
        // Static
        profileContent[PayloadKey.payloadType] = "Configuration" // Currently the only supported value is "Configuration"
        profileContent[PayloadKey.payloadVersion] = 1 // Version of the profile format, currently the only supported value is 1
        
        // Required
        // If a unique identifier is required, have that as a setting maybe and check it here.
        profileContent[PayloadKey.payloadIdentifier] = UserDefaults.standard.string(forKey: PreferenceKey.defaultOrganizationIdentifier) ?? "com.profilecreator.\(profile.uuid.uuidString)"
        profileContent[PayloadKey.payloadUUID] = profile.uuid.uuidString
        
        // Optional
        profileContent[PayloadKey.payloadDescription] = "Placeholder Description"
        profileContent[PayloadKey.payloadDisplayName] = "Placeholder Display Name"
        //profileContent[PayloadKey.payloadExpirationDate] = Date() // Optional. A date on which a profile is considered to have expired and can be updated over the air. This key is only used if the profile is delivered via over-the-air profile delivery.
        
        // PayloadOrganization
        if let defaultOrganization = UserDefaults.standard.string(forKey: PreferenceKey.defaultOrganization) {
            profileContent[PayloadKey.payloadOrganization] = defaultOrganization
        }
        
        // PayloadRemovalDisallowed
        // Check if supervised
        
        profileContent[PayloadKey.payloadScope] = PayloadScope.user
        
        completionHandler(profileContent, nil)
    }
    
    class func payloadContent(profile: Profile, completionHandler: (_ payloadContent: [Dictionary<String, Any>], _ error: Error?) -> Void) {
        
        var payloadContent = Dictionary<String, Any>()
        
        for (typeRawValue, typeSettingsDict) in profile.payloadSettings {
            
            // ---------------------------------------------------------------------
            //  Verify we got a valid type and a non empty settings dict
            // ---------------------------------------------------------------------
            guard
                let typeInt = Int(typeRawValue),
                let type = PayloadSourceType(rawValue: typeInt),
                let typeSettings = typeSettingsDict as? Dictionary<String, Dictionary<String, Any>> else {
                    continue
            }
            
            // ---------------------------------------------------------------------
            //  Loop through all domains and settings for the current type
            // ---------------------------------------------------------------------
            for (domain, domainSettings) in typeSettings {
                if let payloadSource = ProfilePayloads.shared.payloadSource(domain: domain, type: type) {
                    self.export(subkeys: payloadSource.subkeys, domainSettings: domainSettings, typeSettings: typeSettings, payloadContent: &payloadContent)
                } else {
                    Swift.print("Failed to get a payloadSource for domain: \(domain) of type: \(type)")
                }
            }
        }
        
        completionHandler([payloadContent], nil)
    }
    
    class func export(subkeys: [PayloadSourceSubkey], domainSettings: Dictionary<String, Any>, typeSettings: Dictionary<String, Any>, payloadContent: inout Dictionary<String, Any>) {
        for subkey in subkeys {
            
            // Verify that this subkey should be exported
            if !self.shouldExport(subkey: subkey, domainSettings: domainSettings) {
                Swift.print("This subkey was excluded from the export: \(subkey.keyPath)")
                continue
            }
            
            // Inintialize the value
            var value: Any?
            
            if let userValue = domainSettings[subkey.keyPath] {
                if PayloadUtility.valueType(value: userValue) == subkey.type {
                    value = userValue
                } else {
                    Swift.print("User value did not match value type: \(PayloadUtility.valueType(value: userValue)) != \(subkey.type)")
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
            
            // Continue throuch all subkeys
            if !subkey.subkeys.isEmpty { self.export(subkeys: subkey.subkeys, domainSettings: domainSettings, typeSettings: typeSettings, payloadContent: &payloadContent) }
        }
    }
    
    class func shouldExport(subkey: PayloadSourceSubkey, domainSettings: Dictionary<String, Any>) -> Bool {
        return true
    }
}
