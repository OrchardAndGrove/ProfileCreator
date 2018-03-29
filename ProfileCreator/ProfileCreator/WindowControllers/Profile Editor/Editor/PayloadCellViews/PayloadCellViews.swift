//
//  PayloadCellViews.swift
//  ProfileCreator
//
//  Created by Erik Berglund on 2017-08-20.
//  Copyright © 2018 Erik Berglund. All rights reserved.
//

import Foundation
import ProfilePayloads

class PayloadCellViews {
    
    // FIXME: Don't know what the best method for storing this is. Using dict for now.
    // FIXME: This variable is supposed to do caching, where if nothung has change in the settings or view settings, then use the same array again.
    var allCellViews = Dictionary<String, Array<NSTableCellView>>()
    
    func cellViews(payloadPlaceholder: PayloadPlaceholder, profileEditor: ProfileEditor) -> [NSTableCellView] {
        // var cellViews = allCellViews[payloadPlaceholder.domain] ?? [NSTableCellView]()
        var cellViews = [NSTableCellView]()
        
        // Verify we have a profile
        guard let profile = profileEditor.profile else { return [NSTableCellView]() }
        
        // Add CellViews
        self.addCellViews(profile: profile,
                          subkeys: payloadPlaceholder.payloadSource.subkeys,
                          profileEditor: profileEditor,
                          cellViews: &cellViews)
        
        // Sort Enabled at top
        if let payloadCellViews = cellViews as? [PayloadCellView] {
            
            // Sort cellViews with enabled subkeys at the top
            let sortedCellViews = payloadCellViews.sorted(by: { profile.isEnabled(subkey: $0.subkey!, onlyByUser: false) && !profile.isEnabled(subkey: $1.subkey!, onlyByUser: false) })
            
            // Get the index of the first disabled subkey
            if let indexDisabled = sortedCellViews.index(where: { !profile.isEnabled(subkey: $0.subkey!, onlyByUser: false) } ) {
                cellViews = sortedCellViews
                
                let cellView = PayloadCellViewTitle(title: "Disabled Keys", description: "The payload keys below will not be included in the exported profile")
                cellViews.insert(cellView, at: indexDisabled)
            }
            
            if payloadPlaceholder.domain != ManifestDomain.general {
                // Get all SHOWN enabled cellViews. (This works because the root manifest subkeys are all required and will always be enabled, even if they aren't shown.
                let enabledCellViewKeys = sortedCellViews.flatMap({ profile.isEnabled(subkey: $0.subkey!, onlyByUser: false) ? $0.subkey!.key : nil })
                
                if enabledCellViewKeys.count == 0 || Array(Set(enabledCellViewKeys).subtracting(manifestSubkeysIgnored)).count == 0 {
                    let cellView = PayloadCellViewNoKeys(title: "No Payload Keys Enabled", description: "", profile: profile)
                    cellViews.insert(cellView, at: 0)
                }
            }
        }
        
        if !cellViews.isEmpty {
            cellViews.insert(PayloadCellViewPadding(), at: 0)
            cellViews.insert(PayloadCellViewPadding(), at: cellViews.count)
        }
        
        return cellViews
    }
    
    func cellView(profile: Profile,
                  subkey: PayloadSourceSubkey,
                  profileEditor: ProfileEditor) -> NSTableCellView? {
        
        // Check if subkey is hidden
        // FIXME: This default false should
        if !profile.editorShowHidden, (subkey.hiddenDefault ?? false || ( subkey.domain != ManifestDomain.general && manifestSubkeysIgnored.contains(subkey.key) ) ) {
            return nil
        }
        
        // Check if subkey is enabled
        if !profile.editorShowDisabled, !profile.isEnabled(subkey: subkey, onlyByUser: false) {
            return nil
        }
        
        // Check if subkey is only available on supervised devices
        if !profile.editorShowSupervised, subkey.supervised {
            return nil
        }
        
        // Check if subkey is available in the selected platforms
        if let platforms = subkey.platforms, platforms.isDisjoint(with: profile.selectedPlatforms) {
                return nil
        } else if
            let notPlatforms = subkey.notPlatforms, let payloadSourcePlatforms = subkey.payloadSource?.platforms.subtracting(notPlatforms),
            profile.selectedPlatforms.isDisjoint(with: payloadSourcePlatforms) {
                return nil
        }
        
        // Get the current settings, should be better handled if an error getting the settings is presented
        let typeSettings = profile.getPayloadTypeSettings(type: subkey.payloadSourceType)
        
        // If both range min and max are specified, and the range isn't more that 19, then use a popUpButton instead
        if let rangeList = subkey.rangeList, rangeList.count <= 20 {
            return PayloadCellViewPopUpButton(subkey: subkey, editor: profileEditor, settings: typeSettings)
        }
        
        switch subkey.typeInput {
        case .array:
            return PayloadCellViewTableView(subkey: subkey, editor: profileEditor, settings: typeSettings)
        case .string:
            return PayloadCellViewTextField(subkey: subkey, editor: profileEditor, settings: typeSettings)
        case .bool:
            return PayloadCellViewCheckbox(subkey: subkey, editor: profileEditor, settings: typeSettings)
        case .integer, .float:
            return PayloadCellViewTextFieldNumber(subkey: subkey, editor: profileEditor, settings: typeSettings)
        case .date:
            return PayloadCellViewDatePicker(subkey: subkey, editor: profileEditor, settings: typeSettings)
        case .data:
            return PayloadCellViewFile(subkey: subkey, editor: profileEditor, settings: typeSettings)
        case .dictionary:
            if subkey.subkeys.contains(where: { $0.key == ManifestKeyPlaceholder.key }) {
                return PayloadCellViewTableView(subkey: subkey, editor: profileEditor, settings: typeSettings)
            } else {
                return PayloadCellViewDictionary(subkey: subkey, editor: profileEditor, settings: typeSettings)
            }
        default:
            Swift.print("Class: \(self.self), Function: \(#function), Unknown Manifest Type: \(subkey.typeInput)")
        }
        return nil
    }
    
    // FIXME: Create overrides that catch specific scenarios, should be called
    
    // MARK: -
    // MARK: Payload Application Subkey
    
    func addCellViews(profile: Profile,
                      subkeys: [PayloadSourceSubkey],
                      profileEditor: ProfileEditor,
                      cellViews: inout [NSTableCellView] ) {
        
        for subkey in subkeys {
            
            if let parentSubkeys = subkey.parentSubkeys, parentSubkeys.contains(where: {$0.type == .array }) {
                continue
            }
  
            // If root dictionary is a single dictionary, ignore that in the UI
            if !(subkey.rootSubkey == nil && subkey.type == .dictionary && Array(Set(subkeys.map({$0.key})).subtracting(manifestSubkeysIgnored)).count == 1) {
                if let cellView = self.cellView(profile: profile,
                                                subkey: subkey,
                                                profileEditor: profileEditor) {
                    cellViews.append(cellView)
                }
            }
            
            if !subkey.subkeys.contains(where: {$0.key == ManifestKeyPlaceholder.key}) {
                self.addCellViews(profile: profile,
                                  subkeys: subkey.subkeys,
                                  profileEditor: profileEditor,
                                  cellViews: &cellViews)
            }
        }
    }
}
