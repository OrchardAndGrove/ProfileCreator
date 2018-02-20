//
//  PayloadCellViews.swift
//  ProfileCreator
//
//  Created by Erik Berglund on 2017-08-20.
//  Copyright © 2017 Erik Berglund. All rights reserved.
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
        
        var hiddenCount = 0
        var disabledCount = 0
        
        // Verify we have a profile
        guard let profile = profileEditor.profile else { return [NSTableCellView]() }
        
        switch payloadPlaceholder.payloadSourceType {
        case .application:
            if let payloadApplication = payloadPlaceholder.payloadSource as? PayloadApplication, let payloadSubkeys = payloadApplication.subkeys as? [PayloadApplicationSubkey] {
                for subkey in payloadSubkeys {
                    if let cellView = cellView(profile: profile,
                                               applicationSubkey: subkey,
                                               profileEditor: profileEditor,
                                               showDisabled: profile.editorShowDisabled,
                                               showHidden: profile.editorShowHidden,
                                               showSupervised: profile.editorShowSupervised,
                                               hiddenCount: &hiddenCount,
                                               disabledCount: &disabledCount) { cellViews.append(cellView) }
                }
            }
            break
        case .collection:
            if let payloadCollection = payloadPlaceholder.payloadSource as? PayloadCollection, let payloadSubkeys = payloadCollection.subkeys as? [PayloadCollectionSubkey] {
                for subkey in payloadSubkeys {
                    if let cellView = cellView(profile: profile,
                                               collectionSubkey: subkey,
                                               profileEditor: profileEditor,
                                               showDisabled: profile.editorShowDisabled,
                                               showHidden: profile.editorShowHidden,
                                               showSupervised: profile.editorShowSupervised,
                                               hiddenCount: &hiddenCount,
                                               disabledCount: &disabledCount) { cellViews.append(cellView) }
                }
            }
            break
        case .developer:
            break
        case .manifest:
            if let payloadManifest = payloadPlaceholder.payloadSource as? PayloadManifest, let payloadSubkeys = payloadManifest.subkeys as? [PayloadManifestSubkey] {
                for subkey in payloadSubkeys {
                    if let cellView = cellView(profile: profile,
                                               manifestSubkey: subkey,
                                               profileEditor: profileEditor,
                                               showDisabled: profile.editorShowDisabled,
                                               showHidden: profile.editorShowHidden,
                                               showSupervised: profile.editorShowSupervised,
                                               hiddenCount: &hiddenCount,
                                               disabledCount: &disabledCount) { cellViews.append(cellView) }
                }
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
                cellViews = sortedCellViews as! [NSTableCellView]
                
                let cellView = PayloadCellViewTitle(title: "Disabled Keys", description: "The payload keys below will not be included in the exported profile")
                cellViews.insert(cellView, at: indexDisabled)
            }
        }
        
        // TODO: This is for adding a note that x keys have been disabled, hidden etc.
        if 0 < hiddenCount + disabledCount {
            var row2String = ""
            if 0 < hiddenCount {
                row2String = "\(hiddenCount) Hidden."
            }
            if 0 < disabledCount {
                if row2String.isEmpty {
                    row2String = "\(disabledCount) Disabled."
                } else {
                    row2String = row2String + " \(disabledCount) Disabled"
                }
            }
            let cellViewFooter = PayloadCellViewFooter(row1: "\(hiddenCount + disabledCount) payload keys are not shown. ( \(row2String) )", row2: nil)
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
                  hiddenCount: inout Int,
                  disabledCount: inout Int) -> NSTableCellView? {
        
        // FIXME: Currently just ignore the static payload keys that normally aren't changed.
        //        This should be added as a setting
        if subkey.domain != ManifestDomain.general {
            if manifestSubkeysIgnored.contains(subkey.key) { return nil }
        }
        
        // Check if subkey is hidden
        // FIXME: This default false should
        if !showHidden, subkey.hiddenDefault ?? false {
            hiddenCount += 1
            return nil
        }
        
        // Check if subkey is enabled
        if !showDisabled, !profile.subkeyIsEnabled(subkey: subkey) {
            disabledCount += 1
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
            Swift.print("DICT!")
        default:
            Swift.print("Class: \(self.self), Function: \(#function), Unknown Manifest Type: \(subkey.type)")
        }
        return nil
    }
    
    // FIXME: Create overrides that catch specific scenarios, should be called
    
    func cellView(profile: Profile,
                  applicationSubkey: PayloadApplicationSubkey,
                  profileEditor: ProfileEditor,
                  showDisabled: Bool,
                  showHidden: Bool,
                  showSupervised: Bool,
                  hiddenCount: inout Int,
                  disabledCount: inout Int) -> NSTableCellView? {
        //Swift.print("Class: \(self.self), Function: \(#function), Adding PayloadCollectionSubkey: \(applicationSubkey)")
        return self.cellView(profile: profile,
                             subkey: applicationSubkey,
                             profileEditor: profileEditor,
                             showDisabled: showDisabled,
                             showHidden: showHidden,
                             showSupervised: showSupervised,
                             hiddenCount: &hiddenCount,
                             disabledCount: &disabledCount)
    }
    
    func cellView(profile: Profile, collectionSubkey: PayloadCollectionSubkey, profileEditor: ProfileEditor, showDisabled: Bool, showHidden: Bool, showSupervised: Bool, hiddenCount: inout Int, disabledCount: inout Int) -> NSTableCellView? {
        //Swift.print("Class: \(self.self), Function: \(#function), Adding PayloadCollectionSubkey: \(collectionSubkey)")
        return self.cellView(profile: profile, subkey: collectionSubkey, profileEditor: profileEditor, showDisabled: showDisabled, showHidden: showHidden, showSupervised: showSupervised, hiddenCount: &hiddenCount,
                             disabledCount: &disabledCount)
    }
    
    func cellView(profile: Profile, manifestSubkey: PayloadManifestSubkey, profileEditor: ProfileEditor, showDisabled: Bool, showHidden: Bool, showSupervised: Bool, hiddenCount: inout Int, disabledCount: inout Int) -> NSTableCellView? {
        //Swift.print("Class: \(self.self), Function: \(#function), Adding PayloadCollectionSubkey: \(manifestSubkey)")
        return self.cellView(profile: profile, subkey: manifestSubkey, profileEditor: profileEditor, showDisabled: showDisabled, showHidden: showHidden, showSupervised: showSupervised, hiddenCount: &hiddenCount,
                             disabledCount: &disabledCount)
    }
}
