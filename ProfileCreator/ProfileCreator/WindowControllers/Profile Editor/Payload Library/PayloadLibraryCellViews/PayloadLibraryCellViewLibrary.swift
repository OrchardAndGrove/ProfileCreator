//
//  PayloadLibraryCellViewLibrary.swift
//  ProfileCreator
//
//  Created by Erik Berglund on 2017-07-29.
//  Copyright © 2018 Erik Berglund. All rights reserved.
//

import Cocoa
import ProfilePayloads

class PayloadLibraryCellViewLibrary: NSTableCellView, PayloadLibraryCellView {
    
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
        self.imageViewIcon = LibraryImageView.icon(image: payloadPlaceholder.icon, width: 28.0, indent: 2.0, constraints: &constraints, cellView: self)
        self.buttonToggle = LibraryButton.toggle(image: NSImage(named: .addTemplate), width: 14.0, indent: 5.0, constraints: &constraints, cellView: self)
        self.textFieldTitle = LibraryTextField.title(string: payloadPlaceholder.title, fontSize: 11, fontWeight: NSFont.Weight.semibold.rawValue, indent: 4.0, constraints: &constraints, cellView: self)
        
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
        
        // TextFieldTitle Center Y
        constraints.append(NSLayoutConstraint(item: self.textFieldTitle!,
                                              attribute: .centerY,
                                              relatedBy: .equal,
                                              toItem: self,
                                              attribute: .centerY,
                                              multiplier: 1.0,
                                              constant: 0.0))
        
        // ---------------------------------------------------------------------
        //  Activate Layout Constraints
        // ---------------------------------------------------------------------
        NSLayoutConstraint.activate(constraints)
    }
    
    func togglePayload(_ button: NSButton?) {
        Swift.print("Class: \(self.self), Function: \(#function), togglePayload: \(String(describing: button))")
    }
}
