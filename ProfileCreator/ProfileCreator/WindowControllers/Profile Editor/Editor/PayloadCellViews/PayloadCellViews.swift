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
    var allCellViews = Dictionary<String, Array<NSTableCellView>>()
    
    func cellViews(payloadPlaceholder: PayloadPlaceholder, profileEditor: ProfileEditor) -> [NSTableCellView] {
        var cellViews = allCellViews[payloadPlaceholder.domain] ?? [NSTableCellView]()
        if cellViews.isEmpty {
            switch payloadPlaceholder.payloadSourceType {
            case .application:
                if let payloadApplication = payloadPlaceholder.payloadSource as? PayloadApplication, let payloadSubkeys = payloadApplication.subkeys as? [PayloadApplicationSubkey] {
                    for subkey in payloadSubkeys {
                        if let cellView = cellView(applicationSubkey: subkey, profileEditor: profileEditor) { cellViews.append(cellView) }
                    }
                }
                break
            case .collection:
                if let payloadCollection = payloadPlaceholder.payloadSource as? PayloadCollection, let payloadSubkeys = payloadCollection.subkeys as? [PayloadCollectionSubkey] {
                    for subkey in payloadSubkeys {
                        if let cellView = cellView(collectionSubkey: subkey, profileEditor: profileEditor) { cellViews.append(cellView) }
                    }
                }
                break
            case .developer:
                break
            case .manifest:
                if let payloadManifest = payloadPlaceholder.payloadSource as? PayloadManifest, let payloadSubkeys = payloadManifest.subkeys as? [PayloadManifestSubkey] {
                    for subkey in payloadSubkeys {
                        if let cellView = cellView(manifestSubkey: subkey, profileEditor: profileEditor) { cellViews.append(cellView) }
                    }
                }
                break
            case .preference:
                Swift.print("Class: \(self.self), Function: \(#function), Preferences")
                break
            }
        }
        
        if !cellViews.isEmpty {
            cellViews.insert(PayloadCellViewPadding(), at: 0)
            cellViews.insert(PayloadCellViewPadding(), at: cellViews.count)
        }
        
        return cellViews
    }
    
    func cellView(subkey: PayloadSourceSubkey, profileEditor: ProfileEditor) -> NSTableCellView? {
        
        // FIXME: Currently just ignore the static payload keys that normally aren't changed.
        //        This should be added as a setting
        if manifestSubkeysIgnored.contains(subkey.key) { return nil }
        
        // Get the current settings, should be better handled if an error getting the settings is presented
        let payloadSettings = profileEditor.profile?.payloadSettings ?? Dictionary<String, Any>()
        
        // If both range min and max are specified, and the range isn't more that 19, then use a popUpButton instead
        if let rangeList = subkey.rangeList, rangeList.count <= 20 {
            return PayloadCellViewPopUpButton(subkey: subkey, editor: profileEditor, settings: payloadSettings)
        }
        
        switch subkey.type {
        case .array:
            return PayloadCellViewTableView(subkey: subkey, editor: profileEditor, settings: payloadSettings)
        case .string:
            return PayloadCellViewTextField(subkey: subkey, editor: profileEditor, settings: payloadSettings)
        case .bool:
            return PayloadCellViewCheckbox(subkey: subkey, editor: profileEditor, settings: payloadSettings)
        case .integer:
            return PayloadCellViewTextFieldNumber(subkey: subkey, editor: profileEditor, settings: payloadSettings)
        case .data:
            return PayloadCellViewFile(subkey: subkey, editor: profileEditor, settings: payloadSettings)
        default:
            Swift.print("Class: \(self.self), Function: \(#function), Unknown Manifest Type: \(subkey.type)")
        }
        return nil
    }
    
    // FIXME: Create overrides that catch specific scenarios, should be called
    
    func cellView(applicationSubkey: PayloadApplicationSubkey, profileEditor: ProfileEditor) -> NSTableCellView? {
        //Swift.print("Class: \(self.self), Function: \(#function), Adding PayloadCollectionSubkey: \(applicationSubkey)")
        return self.cellView(subkey: applicationSubkey, profileEditor: profileEditor)
    }
    
    func cellView(collectionSubkey: PayloadCollectionSubkey, profileEditor: ProfileEditor) -> NSTableCellView? {
        //Swift.print("Class: \(self.self), Function: \(#function), Adding PayloadCollectionSubkey: \(collectionSubkey)")
        return self.cellView(subkey: collectionSubkey, profileEditor: profileEditor)
    }
    
    func cellView(manifestSubkey: PayloadManifestSubkey, profileEditor: ProfileEditor) -> NSTableCellView? {
        //Swift.print("Class: \(self.self), Function: \(#function), Adding PayloadCollectionSubkey: \(manifestSubkey)")
        return self.cellView(subkey: manifestSubkey, profileEditor: profileEditor)
    }
}
