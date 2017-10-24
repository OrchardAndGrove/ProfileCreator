//
//  PayloadCellViewCheckbox.swift
//  ProfileCreator
//
//  Created by Erik Berglund on 2017-08-02.
//  Copyright © 2017 Erik Berglund. All rights reserved.
//

import Cocoa
import ProfilePayloads

class PayloadCellViewCheckbox: NSTableCellView, ProfileCreatorCellView, PayloadCellView, CheckboxCellView {

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
    
    var checkbox: NSButton?
    var valueDefault: Bool = false
    
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
        self.checkbox = EditorCheckbox.noTitle(constraints: &constraints, cellView: self)
        setupCheckbox(constraints: &constraints)
        
        // ---------------------------------------------------------------------
        //  Setup Static View Content
        // ---------------------------------------------------------------------
        if let title = subkey.title {
            self.textFieldTitle = EditorTextField.title(string: title, fontWeight: nil, leadingItem: self.checkbox, constraints: &constraints, cellView: self)
        }
        
        if let description = subkey.description {
            self.textFieldDescription = EditorTextField.description(string: description, constraints: &constraints, cellView: self)
        }
        
        // ---------------------------------------------------------------------
        //  Set Default Value
        // ---------------------------------------------------------------------
        if let valueDefault = subkey.valueDefault as? Bool {
            self.valueDefault = valueDefault
            self.checkbox?.state = valueDefault ? .on : .off
        }
        
        // ---------------------------------------------------------------------
        //  Setup KeyView Loop Items
        // ---------------------------------------------------------------------
        self.leadingKeyView = self.checkbox
        self.trailingKeyView = self.checkbox
        
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
    // MARK: CheckboxCellView Functions
    
    func clicked(_ checkbox: NSButton) {
        Swift.print("Class: \(self.self), Function: \(#function), Checkbox Pressed!")
    }
    
    // MARK: -
    // MARK: Setup Layout Constraints
    
    private func setupCheckbox(constraints: inout [NSLayoutConstraint]) {
        
        // ---------------------------------------------------------------------
        //  Add Checkbox to TableCellView
        // ---------------------------------------------------------------------
        guard let checkbox = self.checkbox else { return }
        self.addSubview(checkbox)
        
        // ---------------------------------------------------------------------
        //  Add constraints
        // ---------------------------------------------------------------------
        
        // Width
        constraints.append(NSLayoutConstraint(item: checkbox,
                                              attribute: .width,
                                              relatedBy: .equal,
                                              toItem: nil,
                                              attribute: .notAnAttribute,
                                              multiplier: 1.0,
                                              constant: checkbox.intrinsicContentSize.width))
        
        // Leading
        constraints.append(NSLayoutConstraint(item: checkbox,
                                              attribute: .leading,
                                              relatedBy: .equal,
                                              toItem: self,
                                              attribute: .leading,
                                              multiplier: 1.0,
                                              constant: 8))
    }
}
