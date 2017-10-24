//
//  PayloadCellViewTextView.swift
//  ProfileCreator
//
//  Created by Erik Berglund on 2017-08-12.
//  Copyright © 2017 Erik Berglund. All rights reserved.
//

import Cocoa
import ProfilePayloads

class PayloadCellViewTextView: NSTableCellView, ProfileCreatorCellView, PayloadCellView {
    
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
    
    var valueDefault: String?
    var scrollView: NSScrollView?
    var textView: NSTextView?
    
    // MARK: -
    // MARK: Initialization
    
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
        //  Setup Static View Content
        // ---------------------------------------------------------------------
        if let title = subkey.title {
            self.textFieldTitle = EditorTextField.title(string: title, fontWeight: nil, leadingItem: nil, constraints: &constraints, cellView: self)
        }
        
        if let description = subkey.description {
            self.textFieldDescription = EditorTextField.description(string: description, constraints: &constraints, cellView: self)
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
            self.textView?.string = valueDefault
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
