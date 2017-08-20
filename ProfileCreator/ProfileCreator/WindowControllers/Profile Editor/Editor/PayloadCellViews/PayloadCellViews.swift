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
    
    func cellViews(payloadPlaceholder: PayloadPlaceholder) -> [NSTableCellView]? {
        var cellViews = allCellViews[payloadPlaceholder.domain] ?? [NSTableCellView]()
        if cellViews.isEmpty {
            
            // Create all cellViews and set them to the dict
            
        }
        return cellViews
    }
    
}
