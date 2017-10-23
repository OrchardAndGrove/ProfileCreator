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
    
    func cellViews(payloadPlaceholder: PayloadPlaceholder) -> [NSTableCellView] {
        var cellViews = allCellViews[payloadPlaceholder.domain] ?? [NSTableCellView]()
        if cellViews.isEmpty {
            switch payloadPlaceholder.payloadSourceType {
            case .application:
                if let payloadApplication = payloadPlaceholder.payloadSource as? PayloadApplication, let payloadSubkeys = payloadApplication.subkeys as? [PayloadApplicationSubkey] {
                    for subkey in payloadSubkeys {
                        if let cellView = cellView(applicationSubkey: subkey) { cellViews.append(cellView) }
                    }
                }
                break
            case .collection:
                if let payloadCollection = payloadPlaceholder.payloadSource as? PayloadCollection, let payloadSubkeys = payloadCollection.subkeys as? [PayloadCollectionSubkey] {
                    for subkey in payloadSubkeys {
                        if let cellView = cellView(collectionSubkey: subkey) { cellViews.append(cellView) }
                    }
                }
                break
            case .developer:
                break
            case .manifest:
                if let payloadManifest = payloadPlaceholder.payloadSource as? PayloadManifest, let payloadSubkeys = payloadManifest.subkeys as? [PayloadManifestSubkey] {
                    for subkey in payloadSubkeys {
                        if let cellView = cellView(manifestSubkey: subkey) { cellViews.append(cellView) }
                    }
                }
                break
            case .preference:
                Swift.print("Preferences")
                break
            }
        }
        
        //if !cellViews.isEmpty {
            cellViews.insert(PayloadCellViewTitle(payloadSource: payloadPlaceholder.payloadSource), at: 0)
            cellViews.insert(PayloadCellViewPadding(), at: cellViews.count)
        //}
        
        return cellViews
    }
    
    // FIXME: Again, should just sublcass and do most of the work on a single class here
    
    func cellView(applicationSubkey: PayloadApplicationSubkey) -> NSTableCellView? {
        
        // FIXME: Currently just ignore the static payload keys that normally aren't changed.
        //        This should be added as a setting
        if manifestSubkeysIgnored.contains(applicationSubkey.key) { return nil }
        
        switch applicationSubkey.type {
        case .array:
            return PayloadCellViewTableView(subkey: applicationSubkey, settings: Dictionary<String, Any>())
        case .string:
            return PayloadCellViewTextField(subkey: applicationSubkey, settings: Dictionary<String, Any>())
        case .bool:
            return PayloadCellViewCheckbox(subkey: applicationSubkey, settings: Dictionary<String, Any>())
        case .integer:
            return PayloadCellViewTextFieldNumber(subkey: applicationSubkey, settings: Dictionary<String, Any>())
        case .data:
            return PayloadCellViewFile(subkey: applicationSubkey, settings: Dictionary<String, Any>())
        default:
            Swift.print("FIXME: Unknown Manifest Type: \(applicationSubkey.type)")
        }
        return nil
    }
    
    func cellView(collectionSubkey: PayloadCollectionSubkey) -> NSTableCellView? {
        Swift.print("Adding PayloadCollectionSubkey: \(collectionSubkey)")
        return nil
    }
    
    func cellView(manifestSubkey: PayloadManifestSubkey) -> NSTableCellView? {
        
        // FIXME: Currently just ignore the static payload keys that normally aren't changed.
        //        This should be added as a setting
        if manifestSubkeysIgnored.contains(manifestSubkey.key) { return nil }
        
        switch manifestSubkey.type {
        case .array:
            return PayloadCellViewTableView(subkey: manifestSubkey, settings: Dictionary<String, Any>())
        case .string:
            return PayloadCellViewTextField(subkey: manifestSubkey, settings: Dictionary<String, Any>())
        case .bool:
            return PayloadCellViewCheckbox(subkey: manifestSubkey, settings: Dictionary<String, Any>())
        case .integer:
            return PayloadCellViewTextFieldNumber(subkey: manifestSubkey, settings: Dictionary<String, Any>())
        case .data:
            return PayloadCellViewFile(subkey: manifestSubkey, settings: Dictionary<String, Any>())
        default:
            Swift.print("FIXME: Unknown Manifest Type: \(manifestSubkey.type)")
        }
        return nil
    }
}
