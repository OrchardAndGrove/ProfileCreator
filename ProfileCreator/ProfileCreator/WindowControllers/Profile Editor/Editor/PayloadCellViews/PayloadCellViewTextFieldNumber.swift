//
//  TableCellViewTextField.swift
//  ProfileCreator
//
//  Created by Erik Berglund on 2017-07-25.
//  Copyright © 2017 Erik Berglund. All rights reserved.
//

import Cocoa
import ProfilePayloads

class PayloadCellViewTextFieldNumber: NSTableCellView, ProfileCreatorCellView, PayloadCellView, NSTextFieldDelegate {
    
    // MARK: -
    // MARK: PayloadCellView Variables
    
    var height: CGFloat = 0.0
    var row = -1
    
    weak var subkey: PayloadSourceSubkey?
    weak var editor: ProfileEditor?
    
    var textFieldTitle: NSTextField?
    var textFieldDescription: NSTextField?
    var textFieldMinMax: NSTextField?
    var leadingKeyView: NSView?
    var trailingKeyView: NSView?
    
    // MARK: -
    // MARK: Instance Variables
    
    var textFieldInput: PayloadTextField?
    var valueDefault: String?
    @objc private var value: Any?
    
    var isEditing: Bool = false
    var valueBeginEditing: String?
    
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
        //  Setup Static View Content
        // ---------------------------------------------------------------------
        if let textFieldTitle = EditorTextField.title(subkey: subkey, fontWeight: nil, leadingItem: nil, constraints: &constraints, cellView: self) {
            self.textFieldTitle = textFieldTitle
        }
        
        if let textFieldDescription = EditorTextField.description(subkey: subkey, constraints: &constraints, cellView: self) {
            self.textFieldDescription = textFieldDescription
        }
        
        // ---------------------------------------------------------------------
        //  Setup Custom View Content
        // ---------------------------------------------------------------------
        self.textFieldInput = EditorTextField.input(defaultString: "", placeholderString: "", constraints: &constraints, cellView: self)
        setupTextFieldInput(constraints: &constraints)
        
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
            self.textFieldMinMax = EditorTextField.label(string: "(\(rangeString))", fontWeight: NSFont.Weight.regular, leadingItem: self.textFieldInput, leadingConstant: 7.0, trailingItem: nil, constraints: &constraints, cellView: self)
            setupTextFieldMinMax(constraints: &constraints)
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
        if let valuePlaceholder = subkey.valuePlaceholder as? String {
            self.textFieldInput?.placeholderString = valuePlaceholder
        } else if subkey.require == .always {
            self.textFieldInput?.placeholderString = NSLocalizedString("Required", comment: "")
        }
        
        // ---------------------------------------------------------------------
        //  Set Value
        // ---------------------------------------------------------------------
        if
            let domainSettings = settings[subkey.domain] as? Dictionary<String, Any>,
            let value = domainSettings[subkey.keyPath] {
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
    
    internal override func controlTextDidBeginEditing(_ obj: Notification) {
        self.isEditing = true
        if
            let userInfo = obj.userInfo,
            let fieldEditor = userInfo["NSFieldEditor"] as? NSTextView,
            let originalString = fieldEditor.textStorage?.string {
            self.valueBeginEditing = originalString
        }
    }
    
    internal override func controlTextDidEndEditing(_ obj: Notification) {
        
        guard let subkey = self.subkey else { return }
        
        if
            isEditing,
            let userInfo = obj.userInfo,
            let fieldEditor = userInfo["NSFieldEditor"] as? NSTextView,
            let newString = fieldEditor.textStorage?.string,
            newString != self.valueBeginEditing {
            self.editor?.updatePayloadSettings(value: newString, subkey: subkey)
        }
        self.isEditing = false
    }
    
    // MARK: -
    // MARK: Setup Layout Constraints
    
    private func setupTextFieldInput(constraints: inout [NSLayoutConstraint]) {
        
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
        if 0 < valueMaxWidth, valueMaxWidth < (editorTableViewColumnPayloadWidth - 16.0) {
            // Width
            constraints.append(NSLayoutConstraint(item: textFieldInput,
                                              attribute: .width,
                                              relatedBy: .equal,
                                              toItem: nil,
                                              attribute: .notAnAttribute,
                                              multiplier: 1.0,
                                              constant: valueMaxWidth))
        } else {
            // Trailing
            constraints.append(NSLayoutConstraint(item: self,
                                                  attribute: .trailing,
                                                  relatedBy: .equal,
                                                  toItem: textFieldInput,
                                                  attribute: .trailing,
                                                  multiplier: 1.0,
                                                  constant: 8.0))
        }
        
        // Leading
        constraints.append(NSLayoutConstraint(item: textFieldInput,
                                              attribute: .leading,
                                              relatedBy: .equal,
                                              toItem: self,
                                              attribute: .leading,
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
    
    private func setupTextFieldMinMax(constraints: inout [NSLayoutConstraint]) {
        
        // ---------------------------------------------------------------------
        //  Add TextField to TableCellView
        // ---------------------------------------------------------------------
        guard let textFieldMinMax = self.textFieldMinMax else { return }
        
        textFieldMinMax.textColor = NSColor.controlShadowColor
    }
}
