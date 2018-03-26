//
//  TableCellViewTextField.swift
//  ProfileCreator
//
//  Created by Erik Berglund on 2017-07-25.
//  Copyright © 2018 Erik Berglund. All rights reserved.
//

import Cocoa
import ProfilePayloads

class PayloadCellViewTextField: PayloadCellView, ProfileCreatorCellView, NSTextFieldDelegate {
    
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
        super.init(subkey: subkey, editor: editor, settings: settings)
        
        // ---------------------------------------------------------------------
        //  Setup Custom View Content
        // ---------------------------------------------------------------------
        self.textFieldInput = EditorTextField.input(defaultString: "", placeholderString: "", cellView: self)
        self.setupTextFieldInput()
        
        // ---------------------------------------------------------------------
        //  Setup Message if it is set
        // ---------------------------------------------------------------------
        if let textFieldMessage = self.textFieldMessage {
            super.setup(textFieldMessage: textFieldMessage, belowView: self.textFieldInput!)
        }
        
        // ---------------------------------------------------------------------
        //  Set Default Value
        // ---------------------------------------------------------------------
        if let valueDefault = subkey.valueDefault as? String {
            self.valueDefault = valueDefault
        }
        
        // ---------------------------------------------------------------------
        //  Set Placeholder Value
        // ---------------------------------------------------------------------
        self.textFieldInput?.placeholderString = editor.profile?.subkeyPlaceholderString(subkey: subkey) ?? ""
        
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
            self.textFieldInput?.textColor = .red
        } else {
            self.textFieldInput?.textColor = .black
        }
        
        // ---------------------------------------------------------------------
        //  Setup KeyView Loop Items
        // ---------------------------------------------------------------------
        self.leadingKeyView = self.textFieldInput
        self.trailingKeyView = self.textFieldInput
        
        // ---------------------------------------------------------------------
        //  Activate Layout Constraints
        // ---------------------------------------------------------------------
        NSLayoutConstraint.activate(self.cellViewConstraints)
    }
    
    // MARK: -
    // MARK: PayloadCellView Functions
    
    override func enable(_ enable: Bool) {
        self.isEnabled = enable
        self.textFieldInput?.isEnabled = enable
        self.textFieldInput?.isSelectable = enable
    }
}

// MARK: -
// MARK: NSControl Functions

extension PayloadCellViewTextField {
    
    internal override func controlTextDidChange(_ obj: Notification) {
        guard let subkey = self.subkey else { return }
        self.isEditing = true
        if
            let userInfo = obj.userInfo,
            let fieldEditor = userInfo["NSFieldEditor"] as? NSTextView,
            let newString = fieldEditor.textStorage?.string {
            if let format = subkey.format, !newString.matches(format) {
                self.textFieldInput?.textColor = .red
            } else {
                self.textFieldInput?.textColor = .black
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
}
    
// MARK: -
// MARK: Setup NSLayoutConstraints

extension PayloadCellViewTextField {
    
    private func setupTextFieldInput() {
        
        // ---------------------------------------------------------------------
        //  Add TextField to TableCellView
        // ---------------------------------------------------------------------
        guard let textFieldInput = self.textFieldInput else { return }
        textFieldInput.target = self
        self.addSubview(textFieldInput)
        
        // ---------------------------------------------------------------------
        //  Add constraints
        // ---------------------------------------------------------------------
        // Below
        self.addConstraints(forViewBelow: textFieldInput)
        
        // Leading
        self.addConstraints(forViewLeading: textFieldInput)
        
        // Trailing
        self.addConstraints(forViewTrailing: textFieldInput)
    }
}
