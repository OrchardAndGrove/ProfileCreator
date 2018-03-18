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
        
        var disabledCount = 0
        var hiddenCount = 0
        var supervisedCount = 0
        
        // Verify we have a profile
        guard let profile = profileEditor.profile else { return [NSTableCellView]() }
        
        switch payloadPlaceholder.payloadSourceType {
        case .application:
            if let payloadApplication = payloadPlaceholder.payloadSource as? PayloadApplication, let payloadSubkeys = payloadApplication.subkeys as? [PayloadApplicationSubkey] {
                self.addPayloadApplicationCellViews(profile: profile,
                                                    applicationSubkeys: payloadSubkeys,
                                                    profileEditor: profileEditor,
                                                    showDisabled: profile.editorShowDisabled,
                                                    showHidden: profile.editorShowHidden,
                                                    showSupervised: profile.editorShowSupervised,
                                                    disabledCount: &disabledCount,
                                                    hiddenCount: &hiddenCount,
                                                    supervisedCount: &supervisedCount,
                                                    cellViews: &cellViews)
            }
            break
        case .collection:
            if let payloadCollection = payloadPlaceholder.payloadSource as? PayloadCollection, let payloadSubkeys = payloadCollection.subkeys as? [PayloadCollectionSubkey] {
                self.addPayloadCollectionCellViews(profile: profile,
                                                   collectionSubkeys: payloadSubkeys,
                                                   profileEditor: profileEditor,
                                                   showDisabled: profile.editorShowDisabled,
                                                   showHidden: profile.editorShowHidden,
                                                   showSupervised: profile.editorShowSupervised,
                                                   disabledCount: &disabledCount,
                                                   hiddenCount: &hiddenCount,
                                                   supervisedCount: &supervisedCount,
                                                   cellViews: &cellViews)
            }
            break
        case .developer:
            break
        case .manifest:
            if let payloadManifest = payloadPlaceholder.payloadSource as? PayloadManifest, let payloadSubkeys = payloadManifest.subkeys as? [PayloadManifestSubkey] {
                self.addPayloadManifestCellViews(profile: profile,
                                                 manifestSubkeys: payloadSubkeys,
                                                 profileEditor: profileEditor,
                                                 showDisabled: profile.editorShowDisabled,
                                                 showHidden: profile.editorShowHidden,
                                                 showSupervised: profile.editorShowSupervised,
                                                 disabledCount: &disabledCount,
                                                 hiddenCount: &hiddenCount,
                                                 supervisedCount: &supervisedCount,
                                                 cellViews: &cellViews)
            }
            break
        case .preference:
            Swift.print("Class: \(self.self), Function: \(#function), Preferences")
            break
        }
        
        // Sort Enabled at top
        if let payloadCellViews = cellViews as? [PayloadCellView] {
            
            // Sort cellViews with enabled subkeys at the top
            let sortedCellViews = payloadCellViews.sorted(by: { profile.subkeyIsEnabled(subkey: $0.subkey!) && !profile.subkeyIsEnabled(subkey: $1.subkey!) })
            
            // Get the index of the first disabled subkey
            if let indexDisabled = sortedCellViews.index(where: { !profile.subkeyIsEnabled(subkey: $0.subkey!) } ) {
                cellViews = sortedCellViews
                
                let cellView = PayloadCellViewTitle(title: "Disabled Keys", description: "The payload keys below will not be included in the exported profile")
                cellViews.insert(cellView, at: indexDisabled)
            }
        }
        
        // TODO: This is for adding a note that x keys have been disabled, hidden etc.
        if 0 < hiddenCount + disabledCount + supervisedCount {
            /*
             var row2String = ""
             if 0 < hiddenCount {
             row2String = "\(hiddenCount) Hidden"
             }
             
             if 0 < disabledCount {
             if row2String.isEmpty {
             row2String = "\(disabledCount) Disabled."
             } else {
             row2String = row2String + ". \(disabledCount) Disabled."
             }
             }
             
             if 0 < supervisedCount {
             if row2String.isEmpty {
             row2String = "\(supervisedCount) Supervised."
             } else {
             row2String = row2String + ". \(supervisedCount) Supervised."
             }
             }
             
             let cellViewFooter = PayloadCellViewFooter(row1: "\(hiddenCount + disabledCount + supervisedCount) payload keys are not shown. ( \(row2String) )", row2: nil)
             */
            
            let cellViewFooter = PayloadCellViewFooter(row1: "\(hiddenCount + disabledCount + supervisedCount) payload keys are not shown", row2: nil)
            cellViews.append(cellViewFooter)
        }
        
        if !cellViews.isEmpty {
            cellViews.insert(PayloadCellViewPadding(), at: 0)
            cellViews.insert(PayloadCellViewPadding(), at: cellViews.count)
        }
        
        return cellViews
    }
    
    func cellView(profile: Profile,
                  subkey: PayloadSourceSubkey,
                  profileEditor: ProfileEditor,
                  showDisabled: Bool,
                  showHidden: Bool,
                  showSupervised: Bool,
                  disabledCount: inout Int,
                  hiddenCount: inout Int,
                  supervisedCount: inout Int) -> NSTableCellView? {
        
        // Check if subkey is hidden
        // FIXME: This default false should
        if !showHidden, (subkey.hiddenDefault ?? false || ( subkey.domain != ManifestDomain.general && manifestSubkeysIgnored.contains(subkey.key) ) ) {
            hiddenCount += 1
            return nil
        }
        
        // Check if subkey is enabled
        if !showDisabled, !profile.subkeyIsEnabled(subkey: subkey) {
            disabledCount += 1
            return nil
        }
        
        if !showSupervised, subkey.supervised {
            supervisedCount += 1
            return nil
        }
        
        // Get the current settings, should be better handled if an error getting the settings is presented
        let typeSettings = profile.payloadTypeSettings(type: subkey.payloadSourceType)
        
        // If both range min and max are specified, and the range isn't more that 19, then use a popUpButton instead
        if let rangeList = subkey.rangeList, rangeList.count <= 20 {
            return PayloadCellViewPopUpButton(subkey: subkey, editor: profileEditor, settings: typeSettings)
        }
        
        switch subkey.type {
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
            return PayloadCellViewDictionary(subkey: subkey, editor: profileEditor, settings: typeSettings)
        default:
            Swift.print("Class: \(self.self), Function: \(#function), Unknown Manifest Type: \(subkey.type)")
        }
        return nil
    }
    
    // FIXME: Create overrides that catch specific scenarios, should be called
    
    // MARK: -
    // MARK: Payload Application Subkey
    
    func addPayloadApplicationCellViews(profile: Profile,
                                        applicationSubkeys: [PayloadApplicationSubkey],
                                        profileEditor: ProfileEditor,
                                        showDisabled: Bool,
                                        showHidden: Bool,
                                        showSupervised: Bool,
                                        disabledCount: inout Int,
                                        hiddenCount: inout Int,
                                        supervisedCount: inout Int,
                                        cellViews: inout [NSTableCellView] ) {
        for subkey in applicationSubkeys {
            
            if let parentSubkeys = subkey.parentSubkeys, parentSubkeys.contains(where: {$0.type == .array }) {
                continue
            }
            
            if let cellView = self.cellView(profile: profile,
                                            subkey: subkey,
                                            profileEditor: profileEditor,
                                            showDisabled: showDisabled,
                                            showHidden: showHidden,
                                            showSupervised: showSupervised,
                                            disabledCount: &disabledCount,
                                            hiddenCount: &hiddenCount,
                                            supervisedCount: &supervisedCount) {
                cellViews.append(cellView)
            }
            
            if let subkeySubkeys = subkey.subkeys as? [PayloadApplicationSubkey] {
                self.addPayloadApplicationCellViews(profile: profile,
                                                    applicationSubkeys: subkeySubkeys,
                                                    profileEditor: profileEditor,
                                                    showDisabled: profile.editorShowDisabled,
                                                    showHidden: profile.editorShowHidden,
                                                    showSupervised: profile.editorShowSupervised,
                                                    disabledCount: &disabledCount,
                                                    hiddenCount: &hiddenCount,
                                                    supervisedCount: &supervisedCount,
                                                    cellViews: &cellViews)
            }
        }
    }
    
    // MARK: -
    // MARK: Payload Collection Subkey
    
    func addPayloadCollectionCellViews(profile: Profile,
                                       collectionSubkeys: [PayloadCollectionSubkey],
                                       profileEditor: ProfileEditor,
                                       showDisabled: Bool,
                                       showHidden: Bool,
                                       showSupervised: Bool,
                                       disabledCount: inout Int,
                                       hiddenCount: inout Int,
                                       supervisedCount: inout Int,
                                       cellViews: inout [NSTableCellView] ) {
        for subkey in collectionSubkeys {
            
            if let parentSubkeys = subkey.parentSubkeys, parentSubkeys.contains(where: {$0.type == .array }) {
                continue
            }
            
            if let cellView = self.cellView(profile: profile,
                                            subkey: subkey,
                                            profileEditor: profileEditor,
                                            showDisabled: showDisabled,
                                            showHidden: showHidden,
                                            showSupervised: showSupervised,
                                            disabledCount: &disabledCount,
                                            hiddenCount: &hiddenCount,
                                            supervisedCount: &supervisedCount) {
                cellViews.append(cellView)
            }
            
            if let subkeySubkeys = subkey.subkeys as? [PayloadCollectionSubkey] {
                self.addPayloadCollectionCellViews(profile: profile,
                                                   collectionSubkeys: subkeySubkeys,
                                                   profileEditor: profileEditor,
                                                   showDisabled: profile.editorShowDisabled,
                                                   showHidden: profile.editorShowHidden,
                                                   showSupervised: profile.editorShowSupervised,
                                                   disabledCount: &disabledCount,
                                                   hiddenCount: &hiddenCount,
                                                   supervisedCount: &supervisedCount,
                                                   cellViews: &cellViews)
            }
        }
    }
    
    // MARK: -
    // MARK: Payload Manifest Subkey
    
    func addPayloadManifestCellViews(profile: Profile,
                                     manifestSubkeys: [PayloadManifestSubkey],
                                     profileEditor: ProfileEditor,
                                     showDisabled: Bool,
                                     showHidden: Bool,
                                     showSupervised: Bool,
                                     disabledCount: inout Int,
                                     hiddenCount: inout Int,
                                     supervisedCount: inout Int,
                                     cellViews: inout [NSTableCellView] ) {
        
        for subkey in manifestSubkeys {
            
            if let parentSubkeys = subkey.parentSubkeys, parentSubkeys.contains(where: {$0.type == .array }) {
                continue
            }
            
            if let cellView = self.cellView(profile: profile,
                                            subkey: subkey,
                                            profileEditor: profileEditor,
                                            showDisabled: showDisabled,
                                            showHidden: showHidden,
                                            showSupervised: showSupervised,
                                            disabledCount: &disabledCount,
                                            hiddenCount: &hiddenCount,
                                            supervisedCount: &supervisedCount) {
                cellViews.append(cellView)
            }
            
            if let subkeySubkeys = subkey.subkeys as? [PayloadManifestSubkey] {
                self.addPayloadManifestCellViews(profile: profile,
                                                 manifestSubkeys: subkeySubkeys,
                                                 profileEditor: profileEditor,
                                                 showDisabled: profile.editorShowDisabled,
                                                 showHidden: profile.editorShowHidden,
                                                 showSupervised: profile.editorShowSupervised,
                                                 disabledCount: &disabledCount,
                                                 hiddenCount: &hiddenCount,
                                                 supervisedCount: &supervisedCount,
                                                 cellViews: &cellViews)
            }
        }
    }
}
