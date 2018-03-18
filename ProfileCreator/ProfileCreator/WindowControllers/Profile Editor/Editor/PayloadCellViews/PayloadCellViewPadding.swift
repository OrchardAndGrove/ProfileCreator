//
//  PayloadCellViewPadding.swift
//  ProfileCreator
//
//  Created by Erik Berglund on 2017-07-29.
//  Copyright © 2018 Erik Berglund. All rights reserved.
//

import Cocoa

class PayloadCellViewPadding: NSTableCellView, ProfileCreatorCellView {
    
    // MARK: -
    // MARK: PayloadCellView Variables
    
    var height: CGFloat = 20.0
    var row = -1
    
    // MARK: -
    // MARK: Initialization
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init(height: CGFloat? = 20.0) {
        super.init(frame: NSZeroRect)
        
        if let h = height {
            self.height = h
        }
    }
}
