//
//  TableCellViewTextField.swift
//  ProfileCreator
//
//  Created by Erik Berglund on 2017-07-25.
//  Copyright © 2017 Erik Berglund. All rights reserved.
//

import Cocoa
import ProfilePayloads

class PayloadCellViewDictionary: NSTableCellView, ProfileCreatorCellView, PayloadCellView {
    
    // MARK: -
    // MARK: PayloadCellView Variables
    
    var height: CGFloat = 0.0
    var row = -1
    
    weak var subkey: PayloadSourceSubkey?
    weak var editor: ProfileEditor?
    
    var textFieldTitle: NSTextField?
    var textFieldDescription: NSTextField?
    var leadingKeyView: NSView?
    var trailingKeyView: NSView?
    var isEnabled: Bool { return false }
    
    // MARK: -
    // MARK: Instance Variables
    
    var valueDefault: Dictionary<String, Any>?
    
    // MARK: -
    // MARK: Initialization
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    required init(subkey: PayloadSourceSubkey, editor: ProfileEditor, settings: Dictionary<String, Any>) {
        
        self.subkey = subkey
        self.editor = editor
        
        super.init(frame: NSZeroRect)
        
        // ---------------------------------------------------------------------
        //  Setup Variables
        // ---------------------------------------------------------------------
        var constraints = [NSLayoutConstraint]()
        
        // ---------------------------------------------------------------------
        //  Get Indent
        // ---------------------------------------------------------------------
        let indent = subkey.parentSubkeys?.filter({$0.type == PayloadValueType.dictionary}).count ?? 0
        
        // ---------------------------------------------------------------------
        //  Setup Static View Content
        // ---------------------------------------------------------------------
        if let textFieldTitle = EditorTextField.title(subkey: subkey, fontWeight: nil, indent: indent, leadingItem: nil, constraints: &constraints, cellView: self) {
            self.textFieldTitle = textFieldTitle
        }
        
        if let textFieldDescription = EditorTextField.description(subkey: subkey, indent: indent, constraints: &constraints, cellView: self) {
            self.textFieldDescription = textFieldDescription
        }
        
        // ---------------------------------------------------------------------
        //  Create and add vertical separator bottom
        // ---------------------------------------------------------------------
        let separatorBottom = NSBox(frame: NSRect(x: 250.0, y: 15.0, width: preferencesWindowWidth - (20.0 + 20.0), height: 250.0))
        separatorBottom.translatesAutoresizingMaskIntoConstraints = false
        separatorBottom.boxType = .separator
        self.setup(separatorBottom: separatorBottom, indent: indent, constraints: &constraints)
        
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
    
    func enable(_ enable: Bool) {
        
    }
    
    // MARK: -
    // MARK: Setup Layout Constraints
    
    private func setup(separatorBottom: NSBox, indent: Int, constraints: inout [NSLayoutConstraint]) {
        
        // ---------------------------------------------------------------------
        //  Add Constraints
        // ---------------------------------------------------------------------
        
        // Top
        let textField: NSTextField
        if let textFieldDescription = self.textFieldDescription {
            textField = textFieldDescription
        } else if let textFieldTitle = self.textFieldTitle {
            textField = textFieldTitle
        } else {
            return
        }
        
        // -------------------------------------------------------------------------
        //  Calculate Indent
        // -------------------------------------------------------------------------
        let indentValue: CGFloat = 8.0 + (16.0 * CGFloat(indent))
        
        // ---------------------------------------------------------------------
        //  Add TextField to TableCellView
        // ---------------------------------------------------------------------
        self.addSubview(separatorBottom)
        
        // Top
        constraints.append(NSLayoutConstraint(item: separatorBottom,
                                              attribute: .top,
                                              relatedBy: .equal,
                                              toItem: textField,
                                              attribute: .bottom,
                                              multiplier: 1,
                                              constant: 10.0))
        
        // Leading
        constraints.append(NSLayoutConstraint(item: separatorBottom,
                                              attribute: .leading,
                                              relatedBy: .equal,
                                              toItem: self,
                                              attribute: .leading,
                                              multiplier: 1,
                                              constant: indentValue))
        
        // Trailing
        constraints.append(NSLayoutConstraint(item: self,
                                              attribute: .trailing,
                                              relatedBy: .equal,
                                              toItem: separatorBottom,
                                              attribute: .trailing,
                                              multiplier: 1,
                                              constant: 8.0))
        
        self.updateHeight(10 + separatorBottom.intrinsicContentSize.height)
    }
}
