//
//  PayloadLibraryCellViewProfile.swift
//  ProfileCreator
//
//  Created by Erik Berglund on 2017-07-29.
//  Copyright © 2017 Erik Berglund. All rights reserved.
//

import Cocoa

class PayloadLibraryCellViewProfile: NSTableCellView, PayloadLibraryCellView {
    
    // MARK: -
    // MARK: PayloadLibraryCellView Variables

    var row = -1
    var isMovable = true
    var constraintImageViewLeading: NSLayoutConstraint?
    
    var textFieldTitle: NSTextField?
    var textFieldDescription: NSTextField?
    var imageViewIcon: NSImageView?
    var buttonToggle: NSButton?
    var buttonToggleIndent: CGFloat = 24
    
    // MARK: -
    // MARK: Initialization
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init(payloadPlaceholder: PayloadPlaceholder) {
        super.init(frame: NSZeroRect)
        
        // ---------------------------------------------------------------------
        //  Setup Variables
        // ---------------------------------------------------------------------
        var constraints = [NSLayoutConstraint]()
        
        // ---------------------------------------------------------------------
        //  Setup Static View Content
        // ---------------------------------------------------------------------
        self.imageViewIcon = LibraryImageView.icon(image: NSImage(named: NSImage.Name.preferencesGeneral), width: 31.0, indent: 4.0, constraints: &constraints, cellView: self)
        self.buttonToggle = LibraryButton.toggle(image: NSImage(named: NSImage.Name.removeTemplate), width: 14.0, indent: 5.0, constraints: &constraints, cellView: self)
        self.textFieldTitle = LibraryTextField.title(string: payloadPlaceholder.title, fontSize: 12, fontWeight: NSFont.Weight.bold.rawValue, indent: 6.0, constraints: &constraints, cellView: self)
        self.textFieldDescription = LibraryTextField.description(string: "1 Payload", constraints: &constraints, cellView: self)
        
        // ---------------------------------------------------------------------
        //  Setup Static View Content
        // ---------------------------------------------------------------------
        // ImageView Leading
        self.constraintImageViewLeading = NSLayoutConstraint(item: self.imageViewIcon!,
                                                                 attribute: .leading,
                                                                 relatedBy: .equal,
                                                                 toItem: self,
                                                                 attribute: .leading,
                                                                 multiplier: 1.0,
                                                                 constant: 5.0)
        
        constraints.append(self.constraintImageViewLeading!)
        
        // TextFieldTitle Top
        constraints.append(NSLayoutConstraint(item: self.textFieldTitle!,
                                              attribute: .top,
                                              relatedBy: .equal,
                                              toItem: self,
                                              attribute: .top,
                                              multiplier: 1.0,
                                              constant: 4.5))
        
        // ---------------------------------------------------------------------
        //  Activate Layout Constraints
        // ---------------------------------------------------------------------
        NSLayoutConstraint.activate(constraints)
    }
    
    func togglePayload(_ button: NSButton?) {
        Swift.print("toggle: \(String(describing: button))")
    }
}
