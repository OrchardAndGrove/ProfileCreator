//
//  PayloadCellViewTextView.swift
//  ProfileCreator
//
//  Created by Erik Berglund on 2017-08-12.
//  Copyright © 2018 Erik Berglund. All rights reserved.
//

import Cocoa
import ProfilePayloads

class PayloadCellViewTextView: PayloadCellView, ProfileCreatorCellView, NSTextFieldDelegate {
    
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
        super.init(subkey: subkey, editor: editor, settings: settings)
        
        // ---------------------------------------------------------------------
        //  Setup Custom View Content
        // ---------------------------------------------------------------------
        self.scrollView = EditorTextView.scrollView(string: "", visibleRows: 4, constraints: &self.cellViewConstraints, cellView: self)
        self.textView = self.scrollView?.documentView as? NSTextView
        self.setupScrollView()
                
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
        } else if editor.profile?.isRequired(subkey: subkey) ?? false {
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
            self.textView?.textColor = .red
        } else {
            self.textView?.textColor = .black
        }
        
        // ---------------------------------------------------------------------
        //  Setup KeyView Loop Items
        // ---------------------------------------------------------------------
        self.leadingKeyView = self.scrollView
        self.trailingKeyView = self.scrollView
        
        // ---------------------------------------------------------------------
        //  Activate Layout Constraints
        // ---------------------------------------------------------------------
        NSLayoutConstraint.activate(self.cellViewConstraints)
    }
    
    // MARK: -
    // MARK: PayloadCellView Functions
    
    override func enable(_ enable: Bool) {
        self.isEnabled = enable
        Swift.print("TextView Enable: \(enable)")
    }
}

// MARK: -
// MARK: NSControl Functions

extension PayloadCellViewTextView {
    
    internal override func controlTextDidChange(_ obj: Notification) {
        guard let subkey = self.subkey else { return }
        self.isEditing = true
        if
            let userInfo = obj.userInfo,
            let fieldEditor = userInfo["NSFieldEditor"] as? NSTextView,
            let newString = fieldEditor.textStorage?.string {
            if let format = subkey.format, !newString.matches(format) {
                self.textView?.textColor = .red
            } else {
                self.textView?.textColor = .black
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
// MARK: NSTextViewDelegate Functions

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

// MARK: -
// MARK: Setup NSLayoutConstraints

extension PayloadCellViewTextView {
    
    private func setupScrollView() {
        
        // ---------------------------------------------------------------------
        //  Add TextField to TableCellView
        // ---------------------------------------------------------------------
        guard let scrollView = self.scrollView else { return }
        self.addSubview(scrollView)
        
        // ---------------------------------------------------------------------
        //  Add constraints
        // ---------------------------------------------------------------------
        // Below
        self.addConstraints(forViewBelow: scrollView)
        
        // Leading
        self.addConstraints(forViewLeading: scrollView)
        
        // Trailing
        self.addConstraints(forViewTrailing: scrollView)
    }
}
