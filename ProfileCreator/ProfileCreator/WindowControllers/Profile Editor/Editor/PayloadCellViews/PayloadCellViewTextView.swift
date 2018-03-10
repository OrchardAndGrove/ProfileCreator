//
//  PayloadCellViewTextView.swift
//  ProfileCreator
//
//  Created by Erik Berglund on 2017-08-12.
//  Copyright © 2017 Erik Berglund. All rights reserved.
//

import Cocoa
import ProfilePayloads

class PayloadCellViewTextView: NSTableCellView, ProfileCreatorCellView, PayloadCellView, NSTextFieldDelegate {
    
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
    var isEnabled: Bool { return false } // FIXME: This needs fixing!
    
    // MARK: -
    // MARK: Instance Variables
    
    var valueDefault: String?
    var scrollView: NSScrollView?
    var textView: NSTextView?
    
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
        self.scrollView = EditorTextView.scrollView(string: "", visibleRows: 4, constraints: &constraints, cellView: self)
        self.textView = self.scrollView?.documentView as? NSTextView
        setupScrollView(constraints: &constraints)
        
        // ---------------------------------------------------------------------
        //  Setup Constraints
        // ---------------------------------------------------------------------
        addConstraintsFor(item: self.scrollView!, orientation: .below, constraints: &constraints, cellView: self)
        
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
            self.textView?.string = valuePlaceholder
        } else if subkey.require == .always {
            self.textView?.string = NSLocalizedString("Required", comment: "")
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
        self.textView?.string = valueString
        
        // ---------------------------------------------------------------------
        //  Set TextColor (red if not matching format)
        // ---------------------------------------------------------------------
        if let format = subkey.format, !valueString.matches(format) {
            self.textView?.textColor = NSColor.red
        } else {
            self.textView?.textColor = NSColor.black
        }
        
        // ---------------------------------------------------------------------
        //  Setup KeyView Loop Items
        // ---------------------------------------------------------------------
        self.leadingKeyView = self.scrollView
        self.trailingKeyView = self.scrollView
        
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
        // FIXME: Fix the isEnabled variable aswell!
        Swift.print("TextView Enable: \(enable)")
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
                self.textView?.textColor = NSColor.red
            } else {
                self.textView?.textColor = NSColor.black
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
    
    private func setupScrollView(constraints: inout [NSLayoutConstraint]) {
        
        // ---------------------------------------------------------------------
        //  Add TextField to TableCellView
        // ---------------------------------------------------------------------
        guard let scrollView = self.scrollView else { return }
        self.addSubview(scrollView)
        
        // ---------------------------------------------------------------------
        //  Add constraints
        // ---------------------------------------------------------------------
        
        // Leading
        constraints.append(NSLayoutConstraint(item: scrollView,
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
                                              toItem: scrollView,
                                              attribute: .trailing,
                                              multiplier: 1.0,
                                              constant: 8.0))
    }
}

extension PayloadCellViewTextView: NSTextViewDelegate {
    
    func textDidChange(_ notification: Notification) {
        Swift.print("Class: \(self.self), Function: \(#function), textDidChange: \(notification)")
    }
    
    func textDidEndEditing(_ notification: Notification) {
        Swift.print("Class: \(self.self), Function: \(#function), textDidEndEditing: \(notification)")
    }
    
    /*
    func textView(_ textView: NSTextView, doCommandBy commandSelector: Selector) -> Bool {
        if commandSelector == #selector(insertTab(_:)) {
            textView.window?.selectNextKeyView(nil)
            return true
        }
        return false
    }
 */
}
