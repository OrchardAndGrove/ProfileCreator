//
//  PreferencesViewElements.swift
//  ProfileCreator
//
//  Created by Erik Berglund on 2017-07-17.
//  Copyright © 2017 Erik Berglund. All rights reserved.
//

import Cocoa

public func addCheckbox(title: String,
                        keyPath: String,
                        toView: NSView,
                        lastSubview: NSView?,
                        height: inout CGFloat,
                        constraints: inout [NSLayoutConstraint]) -> NSView? {
    
    // -------------------------------------------------------------------------
    //  Create and add Checkbox
    // -------------------------------------------------------------------------
    let checkbox = NSButton()
    checkbox.translatesAutoresizingMaskIntoConstraints = false
    checkbox.setButtonType(.switch)
    checkbox.font = NSFont.systemFont(ofSize: NSFont.systemFontSize(for: .regular))
    checkbox.title = title
    toView.addSubview(checkbox)
    
    // ---------------------------------------------------------------------
    //  Bind checkbox to keyPath
    // ---------------------------------------------------------------------
    checkbox.bind(NSValueBinding, to: UserDefaults.standard, withKeyPath: keyPath, options: [NSContinuouslyUpdatesValueBindingOption: true])
    
    // -------------------------------------------------------------------------
    //  Add Constraints
    // -------------------------------------------------------------------------
    
    // Top
    constraints.append(NSLayoutConstraint(
        item: checkbox,
        attribute: .top,
        relatedBy: .equal,
        toItem: lastSubview ?? toView,
        attribute: (lastSubview != nil) ? .bottom : .top,
        multiplier: 1,
        constant: 8))
    
    // Leading
    constraints.append(NSLayoutConstraint(
        item: checkbox,
        attribute: .leading,
        relatedBy: .equal,
        toItem: toView,
        attribute: .leading,
        multiplier: 1,
        constant: preferencesIndent))
    
    // Trailing
    constraints.append(NSLayoutConstraint(
        item: toView,
        attribute: .trailing,
        relatedBy: .equal,
        toItem: checkbox,
        attribute: .trailing,
        multiplier: 1,
        constant: 20))
    
    // -------------------------------------------------------------------------
    //  Update height value
    // -------------------------------------------------------------------------
    height = height + 8.0 + checkbox.intrinsicContentSize.height
    
    return checkbox
}

public func addHeader(title: String,
                      withSeparator: Bool,
                      toView: NSView,
                      lastSubview: NSView?,
                      height: inout CGFloat,
                      constraints: inout [NSLayoutConstraint]) -> NSView? {
    
    // -------------------------------------------------------------------------
    //  Create and add TextField title
    // -------------------------------------------------------------------------
    let textFieldTitle = NSTextField()
    textFieldTitle.translatesAutoresizingMaskIntoConstraints = false
    textFieldTitle.lineBreakMode = .byTruncatingTail
    textFieldTitle.isBordered = false
    textFieldTitle.isBezeled = false
    textFieldTitle.drawsBackground = false
    textFieldTitle.isEditable = false
    textFieldTitle.isSelectable = false
    textFieldTitle.font = NSFont.systemFont(ofSize: NSFont.systemFontSize(for: .regular))
    textFieldTitle.textColor = NSColor.labelColor
    textFieldTitle.alignment = .left
    textFieldTitle.stringValue = title
    toView.addSubview(textFieldTitle)
    
    // -------------------------------------------------------------------------
    //  Add Constraints
    // -------------------------------------------------------------------------
    
    // Top
    constraints.append(NSLayoutConstraint(
        item: textFieldTitle,
        attribute: .top,
        relatedBy: .equal,
        toItem: lastSubview ?? toView,
        attribute: (lastSubview != nil) ? .bottom : .top,
        multiplier: 1,
        constant: 20))
    
    // Leading
    constraints.append(NSLayoutConstraint(
        item: textFieldTitle,
        attribute: .leading,
        relatedBy: .equal,
        toItem: toView,
        attribute: .leading,
        multiplier: 1,
        constant: 20))
    
    // Trailing
    constraints.append(NSLayoutConstraint(
        item: toView,
        attribute: .trailing,
        relatedBy: .equal,
        toItem: textFieldTitle,
        attribute: .trailing,
        multiplier: 1,
        constant: 20))
    
    // -------------------------------------------------------------------------
    //  Update height value
    // -------------------------------------------------------------------------
    height = height + 20.0 + textFieldTitle.intrinsicContentSize.height
    
    if withSeparator {
        
        // ---------------------------------------------------------------------
        //  Create and add vertical separator
        // ---------------------------------------------------------------------
        let separator = NSBox(frame: NSRect(x: 250.0, y: 15.0, width: preferencesWindowWidth - (20.0 + 20.0), height: 250.0))
        separator.translatesAutoresizingMaskIntoConstraints = false
        separator.boxType = .separator
        toView.addSubview(separator)
        
        // ---------------------------------------------------------------------
        //  Add Constraints
        // ---------------------------------------------------------------------
        
        // Top
        constraints.append(NSLayoutConstraint(
            item: separator,
            attribute: .top,
            relatedBy: .equal,
            toItem: textFieldTitle,
            attribute: .bottom,
            multiplier: 1,
            constant: 8))
        
        // Leading
        constraints.append(NSLayoutConstraint(
            item: separator,
            attribute: .leading,
            relatedBy: .equal,
            toItem: toView,
            attribute: .leading,
            multiplier: 1,
            constant: 20))
        
        // Trailing
        constraints.append(NSLayoutConstraint(
            item: toView,
            attribute: .trailing,
            relatedBy: .equal,
            toItem: separator,
            attribute: .trailing,
            multiplier: 1,
            constant: 20))
        
        // ---------------------------------------------------------------------
        //  Update height value
        // ---------------------------------------------------------------------
        height = height + 8.0 + separator.intrinsicContentSize.height
        
        return separator
    } else {
        return textFieldTitle
    }
}
