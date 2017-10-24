//
//  PayloadCellViewPopUpButton.swift
//  ProfileCreator
//
//  Created by Erik Berglund on 2017-08-12.
//  Copyright © 2017 Erik Berglund. All rights reserved.
//

import Cocoa
import ProfilePayloads

class PayloadCellViewPopUpButton: NSTableCellView, ProfileCreatorCellView, PayloadCellView, PopUpButtonCellView {
    
    // MARK: -
    // MARK: PayloadCellView Variables
    
    var height: CGFloat = 0.0
    var row = -1
    
    weak var subkey: PayloadSourceSubkey?
    var textFieldTitle: NSTextField?
    var textFieldDescription: NSTextField?
    var leadingKeyView: NSView?
    var trailingKeyView: NSView?
    
    // MARK: -
    // MARK: Instance Variables
    
    var popUpButton: NSPopUpButton?
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
     required init(subkey: PayloadSourceSubkey, settings: Dictionary<String, Any>) {
        
        self.subkey = subkey
        
        super.init(frame: NSZeroRect)
        
        // ---------------------------------------------------------------------
        //  Setup Variables
        // ---------------------------------------------------------------------
        var constraints = [NSLayoutConstraint]()
        
        // ---------------------------------------------------------------------
        //  Setup Custom View Content
        // ---------------------------------------------------------------------
        self.popUpButton = EditorPopUpButton.withTitles(titles: ["Test1", "Test2"], constraints: &constraints, cellView: self)
        setupPopUpButton(constraints: &constraints)
        
        // ---------------------------------------------------------------------
        //  Setup Static View Content
        // ---------------------------------------------------------------------
        if let title = subkey.title {
            self.textFieldTitle = EditorTextField.title(string: title, fontWeight: nil, leadingItem: nil, constraints: &constraints, cellView: self)
        }
        
        if let description = subkey.description {
            self.textFieldDescription = EditorTextField.description(string: description, constraints: &constraints, cellView: self)
        }
        
        // ---------------------------------------------------------------------
        //  Setup Constraints
        // ---------------------------------------------------------------------
        addConstraintsFor(item: self.popUpButton!, orientation: .below, constraints: &constraints, cellView: self)
        
        // ---------------------------------------------------------------------
        //  Setup KeyView Loop Items
        // ---------------------------------------------------------------------
        self.leadingKeyView = self.popUpButton
        self.trailingKeyView = self.popUpButton
        
        // ---------------------------------------------------------------------
        //  Add spacing to bottom
        // ---------------------------------------------------------------------
        self.updateHeight(3.0)
        
        // ---------------------------------------------------------------------
        //  Activate Layout Constraints
        // ---------------------------------------------------------------------
        NSLayoutConstraint.activate(constraints)
    }
    
    func updateHeight(_ h: CGFloat) {
        self.height += h
    }
    
    // MARK: -
    // MARK: PopUpButton Functions
    
    func selected(_ popUpButton: NSPopUpButton) {
        Swift.print("Class: \(self.self), Function: \(#function), selected: \(String(describing: popUpButton.titleOfSelectedItem))")
    }
    
    // MARK: -
    // MARK: Setup Layout Constraints
    
    private func setupPopUpButton(constraints: inout [NSLayoutConstraint]) {
        
        // ---------------------------------------------------------------------
        //  Add PopUpButton to TableCellView
        // ---------------------------------------------------------------------
        guard let popUpButton = self.popUpButton else { return }
        self.addSubview(popUpButton)
        
        // ---------------------------------------------------------------------
        //  Add constraints
        // ---------------------------------------------------------------------
        
        // Leading
        constraints.append(NSLayoutConstraint(item: popUpButton,
                                              attribute: .leading,
                                              relatedBy: .equal,
                                              toItem: self,
                                              attribute: .leading,
                                              multiplier: 1.0,
                                              constant: 8))
        
        // Leading
        constraints.append(NSLayoutConstraint(item: self,
                                              attribute: .trailing,
                                              relatedBy: .equal,
                                              toItem: popUpButton,
                                              attribute: .trailing,
                                              multiplier: 1.0,
                                              constant: 8))
    }
}
