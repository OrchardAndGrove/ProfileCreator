//
//  TableCellViewTextField.swift
//  ProfileCreator
//
//  Created by Erik Berglund on 2017-07-25.
//  Copyright © 2018 Erik Berglund. All rights reserved.
//

import Cocoa
import ProfilePayloads

class PayloadCellViewDictionary: PayloadCellView, ProfileCreatorCellView {
    
    // MARK: -
    // MARK: Instance Variables
    
    var valueDefault: Dictionary<String, Any>?
    
    // MARK: -
    // MARK: Initialization
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    required init(subkey: PayloadSourceSubkey, editor: ProfileEditor, settings: Dictionary<String, Any>) {
        super.init(subkey: subkey, editor: editor, settings: settings)
        
        // ---------------------------------------------------------------------
        //  Create and add vertical separator bottom
        // ---------------------------------------------------------------------
        let separatorBottom = NSBox(frame: NSRect(x: 250.0, y: 15.0, width: preferencesWindowWidth - (20.0 + 20.0), height: 250.0))
        separatorBottom.translatesAutoresizingMaskIntoConstraints = false
        separatorBottom.boxType = .separator
        self.setup(separatorBottom: separatorBottom)
        
        // ---------------------------------------------------------------------
        //  Setup Custom View Content
        // ---------------------------------------------------------------------
        //self.textFieldInput = EditorTextField.input(defaultString: "", placeholderString: "", constraints: &constraints, cellView: self)
        //setupTextFieldInput(constraints: &constraints)
        
        // ---------------------------------------------------------------------
        //  Set Default Value
        // ---------------------------------------------------------------------
        if let valueDefault = subkey.valueDefault as? Dictionary<String, Any> {
            self.valueDefault = valueDefault
        }
        
        // ---------------------------------------------------------------------
        //  Setup KeyView Loop Items
        // ---------------------------------------------------------------------
        self.leadingKeyView = nil
        self.trailingKeyView = nil
        
        // ---------------------------------------------------------------------
        //  Activate Layout Constraints
        // ---------------------------------------------------------------------
        NSLayoutConstraint.activate(self.cellViewConstraints)
    }
    
    // MARK: -
    // MARK: PayloadCellView Functions
    
    override func enable(_ enable: Bool) {
        self.isEnabled = enable
    }
}
    
// MARK: -
// MARK: Setup NSLayoutConstraints
    
extension PayloadCellViewDictionary {
    
    private func setup(separatorBottom: NSBox) {
        
        // ---------------------------------------------------------------------
        //  Add TextField to TableCellView
        // ---------------------------------------------------------------------
        self.addSubview(separatorBottom)
        
        // ---------------------------------------------------------------------
        //  Add constraints
        // ---------------------------------------------------------------------
        // Leading
        self.addConstraints(forViewLeading: separatorBottom)
        
        // Trailing
        self.addConstraints(forViewTrailing: separatorBottom)
        
        // Top
        let textField: NSTextField
        if let textFieldDescription = self.textFieldDescription {
            textField = textFieldDescription
        } else if let textFieldTitle = self.textFieldTitle {
            textField = textFieldTitle
        } else {
            return
        }
        
        self.cellViewConstraints.append(NSLayoutConstraint(item: separatorBottom,
                                              attribute: .top,
                                              relatedBy: .equal,
                                              toItem: textField,
                                              attribute: .bottom,
                                              multiplier: 1,
                                              constant: 10.0))

        self.updateHeight(10 + separatorBottom.intrinsicContentSize.height)
    }
}
