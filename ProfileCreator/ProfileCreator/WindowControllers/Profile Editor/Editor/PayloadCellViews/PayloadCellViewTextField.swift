//
//  TableCellViewTextField.swift
//  ProfileCreator
//
//  Created by Erik Berglund on 2017-07-25.
//  Copyright © 2017 Erik Berglund. All rights reserved.
//

import Cocoa

class PayloadCellViewTextField: NSTableCellView, PayloadCellView {
    
    // MARK: -
    // MARK: PayloadCellView Variables
    
    var height: CGFloat = 0.0
    var row = -1
    
    var textFieldTitle: NSTextField?
    var textFieldDescription: NSTextField?
    var leadingKeyView: NSView?
    var trailingKeyView: NSView?
    
    // MARK: -
    // MARK: Instance Variables
    
    var textFieldInput: NSTextField?
    
    // MARK: -
    // MARK: Initialization
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    required init(key: String, settings: Dictionary<String , Any>) {
        
        super.init(frame: NSZeroRect)
        
        // ---------------------------------------------------------------------
        //  Setup Variables
        // ---------------------------------------------------------------------
        var constraints = [NSLayoutConstraint]()
        
        // ---------------------------------------------------------------------
        //  Setup Static View Content
        // ---------------------------------------------------------------------
        self.textFieldTitle = TextField.title(string: key, fontWeight: NSFontWeightBold, leadingItem: nil, constraints: &constraints, cellView: self)
        self.textFieldDescription = TextField.description(string: key + "DESCRIPTION", constraints: &constraints, cellView: self)
        
        // ---------------------------------------------------------------------
        //  Setup Custom View Content
        // ---------------------------------------------------------------------
        self.textFieldInput = TextField.input(defaultString: "", placeholderString: "TextPlaceholder", constraints: &constraints, cellView: self)
        self.setupTextFieldInput(constraints: &constraints)
        
        // ---------------------------------------------------------------------
        //  Set text field input as the only keyView
        // ---------------------------------------------------------------------
        self.leadingKeyView = self.textFieldInput
        self.trailingKeyView = self.textFieldInput
        
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
    // MARK: Setup Layout Constraints
    
    private func setupTextFieldInput(constraints: inout [NSLayoutConstraint]) {
        
        guard let textFieldInput = self.textFieldInput else {
            // TODO: Proper Logging
            return
        }
        
        // ---------------------------------------------------------------------
        //  Add TextField to TableCellView
        // ---------------------------------------------------------------------
        self.addSubview(textFieldInput)
        
        // ---------------------------------------------------------------------
        //  Add constraints
        // ---------------------------------------------------------------------
        
        // Leading
        constraints.append(NSLayoutConstraint(item: textFieldInput,
                                              attribute: .leading,
                                              relatedBy: .equal,
                                              toItem: self,
                                              attribute: .leading,
                                              multiplier: 1.0,
                                              constant: 8.0))
        
        // Trailing
        constraints.append(NSLayoutConstraint(item: self,
                                              attribute: .trailing,
                                              relatedBy: .equal,
                                              toItem: textFieldInput,
                                              attribute: .trailing,
                                              multiplier: 1.0,
                                              constant: 8.0))
        
        // Top
        constraints.append(NSLayoutConstraint(item: textFieldInput,
                                              attribute: .top,
                                              relatedBy: .equal,
                                              toItem: self.textFieldDescription,
                                              attribute: .bottom,
                                              multiplier: 1.0,
                                              constant: 7.0))
        
        self.updateHeight(7.0 + textFieldInput.intrinsicContentSize.height)
    }
}

/*
extension PayloadCellViewTextField: NSTextFieldDelegate {
    
    override func controlTextDidEndEditing(_ obj: Notification) {
        Swift.print("nextKeyView: \(self.nextKeyView)")
        Swift.print("previousKeyView: \(self.previousKeyView)")
    }
    
}
 */
