//
//  TableCellViewTextField.swift
//  ProfileCreator
//
//  Created by Erik Berglund on 2017-07-25.
//  Copyright © 2017 Erik Berglund. All rights reserved.
//

import Cocoa
import ProfilePayloads

class PayloadCellViewTextField: NSTableCellView, ProfileCreatorCellView, PayloadCellView, NSTextFieldDelegate {
    
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
    var isEnabled: Bool { return self.textFieldInput?.isEnabled ?? false }
    
    // MARK: -
    // MARK: Instance Variables
    
    var textFieldInput: PayloadTextField?
    var valueDefault: String?
    
    var isEditing = false
    
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
        //  Setup Custom View Content
        // ---------------------------------------------------------------------
        self.textFieldInput = EditorTextField.input(defaultString: "", placeholderString: "", constraints: &constraints, cellView: self)
        setupTextFieldInput(constraints: &constraints, indent: indent)
        
        // ---------------------------------------------------------------------
        //  Set Default Value
        // ---------------------------------------------------------------------
        if let valueDefault = subkey.valueDefault as? String {
            self.valueDefault = valueDefault
        }
        
        // ---------------------------------------------------------------------
        //  Set Placeholder Value
        // ---------------------------------------------------------------------
        if let valuePlaceholder = subkey.valuePlaceholder as? String {
            self.textFieldInput?.placeholderString = valuePlaceholder
        } else if subkey.require == .always {
            self.textFieldInput?.placeholderString = NSLocalizedString("Required", comment: "")
        }
        
        // ---------------------------------------------------------------------
        //  Set Value
        // ---------------------------------------------------------------------
        var valueString = ""
        if
            let domainSettings = settings[subkey.domain] as? Dictionary<String, Any>,
            let value = domainSettings[subkey.keyPath] as? String {
            valueString = value
        } else if let valueDefault = self.valueDefault {
            valueString = valueDefault
        }
        self.textFieldInput?.stringValue = valueString
        
        // ---------------------------------------------------------------------
        //  Set TextColor (red if not matching format)
        // ---------------------------------------------------------------------
        if let format = subkey.format, !valueString.matches(format) {
            self.textFieldInput?.textColor = NSColor.red
        } else {
            self.textFieldInput?.textColor = NSColor.black
        }
        
        // ---------------------------------------------------------------------
        //  Setup KeyView Loop Items
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
    
    func enable(_ enable: Bool) {
        self.textFieldInput?.isEnabled = enable
        self.textFieldInput?.isSelectable = enable
    }
    
    // MARK: -
    // MARK: NSControl Functions
    
    internal override func controlTextDidChange(_ obj: Notification) {
        guard let subkey = self.subkey else { return }
        self.isEditing = true
        if
            let userInfo = obj.userInfo,
            let fieldEditor = userInfo["NSFieldEditor"] as? NSTextView,
            let newString = fieldEditor.textStorage?.string {
            if let format = subkey.format, !newString.matches(format) {
                self.textFieldInput?.textColor = NSColor.red
            } else {
                self.textFieldInput?.textColor = NSColor.black
            }
            self.editor?.updatePayloadSettings(value: newString, subkey: subkey)
        }
    }
    
    internal override func controlTextDidEndEditing(_ obj: Notification) {
        guard let subkey = self.subkey else { return }
        if self.isEditing {
            self.isEditing = false
            if
                let userInfo = obj.userInfo,
                let fieldEditor = userInfo["NSFieldEditor"] as? NSTextView,
                let newString = fieldEditor.textStorage?.string {
                self.editor?.updatePayloadSettings(value: newString, subkey: subkey)
            }
        }
    }
    
    // MARK: -
    // MARK: Setup Layout Constraints
    
    private func setupTextFieldInput(constraints: inout [NSLayoutConstraint], indent: Int) {
        
        // ---------------------------------------------------------------------
        //  Add TextField to TableCellView
        // ---------------------------------------------------------------------
        guard let textFieldInput = self.textFieldInput else { return }
        textFieldInput.target = self
        self.addSubview(textFieldInput)
        
        // -------------------------------------------------------------------------
        //  Calculate Indent
        // -------------------------------------------------------------------------
        let indentValue: CGFloat = 8.0 + (16.0 * CGFloat(indent))
        
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
                                              constant: indentValue))
        
        // Trailing
        constraints.append(NSLayoutConstraint(item: self,
                                              attribute: .trailing,
                                              relatedBy: .equal,
                                              toItem: textFieldInput,
                                              attribute: .trailing,
                                              multiplier: 1.0,
                                              constant: 8.0))
        
        var textFieldAbove: NSTextField?
        if let textFieldDescription = self.textFieldDescription {
            textFieldAbove = textFieldDescription
        } else if let textFieldTitle = self.textFieldTitle {
            textFieldAbove = textFieldTitle
        }
        
        if let textField = textFieldAbove {
            // Top
            constraints.append(NSLayoutConstraint(item: textFieldInput,
                                                  attribute: .top,
                                                  relatedBy: .equal,
                                                  toItem: textField,
                                                  attribute: .bottom,
                                                  multiplier: 1.0,
                                                  constant: 7.0))
            self.updateHeight(7.0 + textFieldInput.intrinsicContentSize.height)
        } else {
            // Top
            constraints.append(NSLayoutConstraint(item: textFieldInput,
                                                  attribute: .top,
                                                  relatedBy: .equal,
                                                  toItem: self,
                                                  attribute: .top,
                                                  multiplier: 1.0,
                                                  constant: 8.0))
            self.updateHeight(8.0 + textFieldInput.intrinsicContentSize.height)
        }
    }
}
