//
//  PayloadLibraryNoPayloadsView.swift
//  ProfileCreator
//
//  Created by Erik Berglund on 2017-07-30.
//  Copyright © 2017 Erik Berglund. All rights reserved.
//

import Cocoa

struct PayloadLibraryNoPayloads {
    
    // MARK: -
    // MARK: Variables
    
    let view = ViewWhite()
    let textField = NSTextField()
    
    init() {
        
        // ---------------------------------------------------------------------
        //  Setup Variables
        // ---------------------------------------------------------------------
        var constraints = [NSLayoutConstraint]()
        
        // ---------------------------------------------------------------------
        //  Setup View
        // ---------------------------------------------------------------------
        self.view.translatesAutoresizingMaskIntoConstraints = false
        
        // ---------------------------------------------------------------------
        //  Setup TextField
        // ---------------------------------------------------------------------
        self.textField.translatesAutoresizingMaskIntoConstraints = false
        self.textField.lineBreakMode = .byWordWrapping
        self.textField.isBordered = false
        self.textField.isBezeled = false
        self.textField.drawsBackground = false
        self.textField.isEditable = false
        self.textField.isSelectable = false
        self.textField.stringValue = NSLocalizedString("No Payloads", comment: "")
        self.textField.textColor = NSColor.tertiaryLabelColor
        self.textField.font = NSFont.systemFont(ofSize: 14, weight: NSFontWeightMedium)
        self.textField.alignment = .center
        setupTextField(constraints: &constraints)
        
        // ---------------------------------------------------------------------
        //  Activate layout constraints
        // ---------------------------------------------------------------------
        NSLayoutConstraint.activate(constraints)
    }
    
    private func setupTextField(constraints: inout [NSLayoutConstraint]) {
        
        self.view.addSubview(self.textField)
        
        // Leading
        constraints.append(NSLayoutConstraint(item: self.textField,
                                              attribute: .leading,
                                              relatedBy: .equal,
                                              toItem: self.view,
                                              attribute: .leading,
                                              multiplier: 1.0,
                                              constant: 0))
        
        // Trailing
        constraints.append(NSLayoutConstraint(item: self.textField,
                                              attribute: .trailing,
                                              relatedBy: .equal,
                                              toItem: self.view,
                                              attribute: .trailing,
                                              multiplier: 1.0,
                                              constant: 0))
        
        // Center Y
        constraints.append(NSLayoutConstraint(item: self.textField,
                                              attribute: .centerY,
                                              relatedBy: .equal,
                                              toItem: self.view,
                                              attribute: .centerY,
                                              multiplier: 1.0,
                                              constant: 0))
    }
    
}
