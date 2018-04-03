//
//  TableCellViewTextField.swift
//  ProfileCreator
//
//  Created by Erik Berglund on 2017-07-25.
//  Copyright © 2018 Erik Berglund. All rights reserved.
//

import Cocoa
import ProfilePayloads

class PayloadCellViewTextFieldNumber: PayloadCellView, ProfileCreatorCellView, NSTextFieldDelegate {
    
    // MARK: -
    // MARK: Instance Variables
    
    var textFieldInput: PayloadTextField?
    var textFieldMinMax: NSTextField?
    var textFieldUnit: NSTextField?
    
    var valueDefault: String?
    @objc private var value: Any?

    // MARK: -
    // MARK: Initialization
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    required init(subkey: PayloadSourceSubkey, payloadIndex: Int, settings: Dictionary<String, Any>, editor: ProfileEditor) {
        super.init(subkey: subkey, payloadIndex: payloadIndex, settings: settings,  editor: editor)
        
        var leadingTextField: NSTextField
        
        // ---------------------------------------------------------------------
        //  Setup Custom View Content
        // ---------------------------------------------------------------------
        self.textFieldInput = EditorTextField.input(defaultString: "", placeholderString: "", cellView: self)
        self.setupTextFieldInput()
        
        leadingTextField = self.textFieldInput!
        
        // If a min and/or max value is set, then show that trailing the input field
        var rangeString = ""
        if let rangeMin = subkey.rangeMin {
            rangeString.append("\(String(describing: rangeMin))")
        }
        
        if let rangeMax = subkey.rangeMax {
            if rangeString.isEmpty {
                rangeString.append("< ")
            } else {
                rangeString = "\(rangeString) - "
            }
            
            rangeString.append("\(String(describing: rangeMax))")
        } else if !rangeString.isEmpty {
            rangeString.append(" <")
        }
        
        if !rangeString.isEmpty {
            self.textFieldMinMax = EditorTextField.label(string: "(\(rangeString))",
                fontWeight: .regular,
                leadingItem: leadingTextField,
                leadingConstant: 7.0,
                trailingItem: nil,
                constraints: &self.cellViewConstraints,
                cellView: self)
            self.setupTextFieldMinMax()
            leadingTextField = self.textFieldMinMax!
        }
        
        if let valueUnit = subkey.valueUnit {
            self.textFieldUnit = EditorTextField.label(string: valueUnit, fontWeight: .regular, leadingItem: leadingTextField, leadingConstant: 7.0, trailingItem: nil, constraints: &self.cellViewConstraints, cellView: self)
            self.setupTextFieldUnit()
            
        }
        
        // ---------------------------------------------------------------------
        //  Set Default Value
        // ---------------------------------------------------------------------
        if let valueDefault = subkey.valueDefault as? NSNumber {
            self.valueDefault = valueDefault.stringValue
        }
        
        // ---------------------------------------------------------------------
        //  Set Placeholder Value
        // ---------------------------------------------------------------------
        if let valuePlaceholder = subkey.valuePlaceholder as? NSNumber {
            self.textFieldInput?.placeholderString = valuePlaceholder.stringValue
        } else if editor.profile?.isRequired(subkey: subkey) ?? false {
            self.textFieldInput?.placeholderString = NSLocalizedString("Required", comment: "")
        }
        
        // ---------------------------------------------------------------------
        //  Set Value
        // ---------------------------------------------------------------------
        if let value = profile?.getPayloadSetting(key: subkey.keyPath, domain: subkey.domain, type: subkey.payloadSourceType, payloadIndex: payloadIndex) {
            self.textFieldInput?.stringValue = String(describing: value)
        } else if let valueDefault = self.valueDefault {
            self.textFieldInput?.stringValue = String(describing: valueDefault)
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

extension PayloadCellViewTextFieldNumber {
    
    internal override func controlTextDidChange(_ obj: Notification) {
        guard
            let subkey = self.subkey,
            let profile = self.profile else { return }
        
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
            profile.updatePayloadSettings(value: newString, subkey: subkey, payloadIndex: self.payloadIndex)
        }
    }
    
    internal override func controlTextDidEndEditing(_ obj: Notification) {
        guard
            let subkey = self.subkey,
            let profile = self.profile else { return }
        
        if self.isEditing {
            self.isEditing = false
            if
                let userInfo = obj.userInfo,
                let fieldEditor = userInfo["NSFieldEditor"] as? NSTextView,
                let newString = fieldEditor.textStorage?.string {
                profile.updatePayloadSettings(value: newString, subkey: subkey, payloadIndex: self.payloadIndex)
            }
        }
    }
}

// MARK: -
// MARK: Setup NSLayoutConstraints

extension PayloadCellViewTextFieldNumber {
    
    private func setupTextFieldInput() {
        
        // ---------------------------------------------------------------------
        //  Add TextField to TableCellView
        // ---------------------------------------------------------------------
        guard let textFieldInput = self.textFieldInput else { return }
        self.addSubview(textFieldInput)
        
        // ---------------------------------------------------------------------
        //  Add Number Formatter to TextField
        // ---------------------------------------------------------------------
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .none
        
        if let rangeMax = self.subkey?.rangeMax as? NSNumber {
            numberFormatter.maximum = rangeMax
        } else {
            numberFormatter.maximum = Int.max as NSNumber
        }
        
        if let rangeMin = self.subkey?.rangeMin as? NSNumber {
            numberFormatter.minimum = rangeMin
        } else {
            numberFormatter.minimum = Int.min as NSNumber
        }
        
        textFieldInput.formatter = numberFormatter
        textFieldInput.bind(.value, to: self, withKeyPath: "value", options: [NSBindingOption.nullPlaceholder: "", NSBindingOption.continuouslyUpdatesValue: true])
        
        // ---------------------------------------------------------------------
        //  Get TextField Number Maximum Width
        // ---------------------------------------------------------------------
        var valueMaxWidth: CGFloat = 0
        if let valueMaxString = numberFormatter.maximum?.stringValue {
            textFieldInput.stringValue = valueMaxString
            textFieldInput.sizeToFit()
            valueMaxWidth = NSWidth(textFieldInput.frame) + 2.0
            textFieldInput.stringValue = ""
        }
        
        // ---------------------------------------------------------------------
        //  Add constraints
        // ---------------------------------------------------------------------
        // Below
        self.addConstraints(forViewBelow: textFieldInput)
        
        // Leading
        self.addConstraints(forViewLeading: textFieldInput)
        
        // Trailing
        if 0 < valueMaxWidth, valueMaxWidth < (editorTableViewColumnPayloadWidth - 16.0) {
            // Width
            self.cellViewConstraints.append(NSLayoutConstraint(item: textFieldInput,
                                                               attribute: .width,
                                                               relatedBy: .equal,
                                                               toItem: nil,
                                                               attribute: .notAnAttribute,
                                                               multiplier: 1.0,
                                                               constant: valueMaxWidth))
        } else {
            self.addConstraints(forViewTrailing: textFieldInput)
        }
    }
    
    private func setupTextFieldMinMax() {
        
        // ---------------------------------------------------------------------
        //  Add TextField to TableCellView
        // ---------------------------------------------------------------------
        guard let textFieldMinMax = self.textFieldMinMax else { return }
        
        textFieldMinMax.textColor = .controlShadowColor
    }
    
    private func setupTextFieldUnit() {
        
        // ---------------------------------------------------------------------
        //  Add TextField to TableCellView
        // ---------------------------------------------------------------------
        guard let textFieldUnit = self.textFieldUnit else { return }
        
        textFieldUnit.textColor = .controlShadowColor
        
        // ---------------------------------------------------------------------
        //  Add TextField to TableCellView
        // ---------------------------------------------------------------------
        if let textFieldMinMax = self.textFieldMinMax {
            if let index = self.cellViewConstraints.index(where: {
                if let secondItem = $0.secondItem as? NSTextField, secondItem == textFieldMinMax, $0.secondAttribute == .trailing {
                    return true
                }
                return false
            }) {
                self.cellViewConstraints.remove(at: index)
                textFieldMinMax.setContentHuggingPriority(.defaultHigh, for: .horizontal)
            }
            
        }
    }
}
