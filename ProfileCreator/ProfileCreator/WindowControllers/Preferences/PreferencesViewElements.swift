//
//  PreferencesViewElements.swift
//  ProfileCreator
//
//  Created by Erik Berglund on 2017-07-17.
//  Copyright © 2018 Erik Berglund. All rights reserved.
//

import Cocoa

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
    textFieldTitle.textColor = .labelColor
    textFieldTitle.alignment = .left
    textFieldTitle.stringValue = title
    toView.addSubview(textFieldTitle)
    
    // -------------------------------------------------------------------------
    //  Add Constraints
    // -------------------------------------------------------------------------
    
    // Top
    constraints.append(NSLayoutConstraint(item: textFieldTitle,
                                          attribute: .top,
                                          relatedBy: .equal,
                                          toItem: lastSubview ?? toView,
                                          attribute: (lastSubview != nil) ? .bottom : .top,
                                          multiplier: 1,
                                          constant: 20))
    
    // Leading
    constraints.append(NSLayoutConstraint(item: textFieldTitle,
                                          attribute: .leading,
                                          relatedBy: .equal,
                                          toItem: toView,
                                          attribute: .leading,
                                          multiplier: 1,
                                          constant: 20))
    
    // Trailing
    constraints.append(NSLayoutConstraint(item: toView,
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
        let separator = NSBox(frame: NSRect(x: 250.0, y: 15.0, width: preferencesWindowWidth - (20.0 * 2), height: 250.0))
        separator.translatesAutoresizingMaskIntoConstraints = false
        separator.boxType = .separator
        toView.addSubview(separator)
        
        // ---------------------------------------------------------------------
        //  Add Constraints
        // ---------------------------------------------------------------------
        
        // Top
        constraints.append(NSLayoutConstraint(item: separator,
                                              attribute: .top,
                                              relatedBy: .equal,
                                              toItem: textFieldTitle,
                                              attribute: .bottom,
                                              multiplier: 1,
                                              constant: 8))
        
        // Leading
        constraints.append(NSLayoutConstraint(item: separator,
                                              attribute: .leading,
                                              relatedBy: .equal,
                                              toItem: toView,
                                              attribute: .leading,
                                              multiplier: 1,
                                              constant: 20))
        
        // Trailing
        constraints.append(NSLayoutConstraint(item: toView,
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

func setupLabel(string: String?, toView: NSView, indent: CGFloat, constraints: inout [NSLayoutConstraint]) -> NSTextField? {
    
    guard var labelString = string else { return nil }
    
    if !labelString.hasSuffix(":") {
        labelString.append(":")
    }
    
    // -------------------------------------------------------------------------
    //  Create and add TextField Label
    // -------------------------------------------------------------------------
    let textFieldLabel = NSTextField()
    textFieldLabel.translatesAutoresizingMaskIntoConstraints = false
    textFieldLabel.lineBreakMode = .byTruncatingTail
    textFieldLabel.isBordered = false
    textFieldLabel.isBezeled = false
    textFieldLabel.drawsBackground = false
    textFieldLabel.isEditable = false
    textFieldLabel.isSelectable = true
    textFieldLabel.font = NSFont.systemFont(ofSize: NSFont.systemFontSize(for: .regular))
    textFieldLabel.textColor = .labelColor
    textFieldLabel.alignment = .right
    textFieldLabel.stringValue = labelString
    toView.addSubview(textFieldLabel)
    
    // Leading
    constraints.append(NSLayoutConstraint(item: textFieldLabel,
                                          attribute: .leading,
                                          relatedBy: .equal,
                                          toItem: toView,
                                          attribute: .leading,
                                          multiplier: 1,
                                          constant: indent))
    
    return textFieldLabel
}

public func addPopUpButton(label: String?,
                           titles: [String],
                           bindTo: Any?,
                           bindKeyPath: String,
                           toView: NSView,
                           lastSubview: NSView?,
                           lastTextField: NSView?,
                           height: inout CGFloat,
                           indent: CGFloat,
                           constraints: inout [NSLayoutConstraint]) -> NSView? {
    
    // -------------------------------------------------------------------------
    //  Create and add Label if label string was passed
    // -------------------------------------------------------------------------
    let textFieldLabel = setupLabel(string: label, toView: toView, indent: indent, constraints: &constraints)
    
    // -------------------------------------------------------------------------
    //  Create and add PopUpButton
    // -------------------------------------------------------------------------
    let popUpButton = NSPopUpButton()
    popUpButton.translatesAutoresizingMaskIntoConstraints = false
    popUpButton.addItems(withTitles: titles)
    toView.addSubview(popUpButton)
    
    // ---------------------------------------------------------------------
    //  Bind PopUpButton to keyPath
    // ---------------------------------------------------------------------
    popUpButton.bind(NSBindingName.selectedValue, to: bindTo ?? UserDefaults.standard, withKeyPath: bindKeyPath, options: [NSBindingOption.continuouslyUpdatesValue: true])
    
    // -------------------------------------------------------------------------
    //  Add Constraints
    // -------------------------------------------------------------------------
    
    if let label = textFieldLabel {
        
        // Leading
        constraints.append(NSLayoutConstraint(item: popUpButton,
                                              attribute: .leading,
                                              relatedBy: .equal,
                                              toItem: label,
                                              attribute: .trailing,
                                              multiplier: 1,
                                              constant: 6.0))
        
        // Baseline
        constraints.append(NSLayoutConstraint(item: popUpButton,
                                              attribute: .firstBaseline,
                                              relatedBy: .equal,
                                              toItem: label,
                                              attribute: .firstBaseline,
                                              multiplier: 1,
                                              constant: 0.0))
    } else {
        
        // Leading
        constraints.append(NSLayoutConstraint(item: popUpButton,
                                              attribute: .leading,
                                              relatedBy: .equal,
                                              toItem: toView,
                                              attribute: .leading,
                                              multiplier: 1,
                                              constant: indent))
    }
    
    if lastTextField != nil {
        
        // Leading
        constraints.append(NSLayoutConstraint(item: popUpButton,
                                              attribute: .leading,
                                              relatedBy: .equal,
                                              toItem: lastTextField,
                                              attribute: .leading,
                                              multiplier: 1,
                                              constant: 0.0))
    }
    
    // Top
    constraints.append(NSLayoutConstraint(item: popUpButton,
                                          attribute: .top,
                                          relatedBy: .equal,
                                          toItem: lastSubview ?? toView,
                                          attribute: (lastSubview != nil) ? .bottom : .top,
                                          multiplier: 1,
                                          constant: 8))
    
    
    
    // Trailing
    constraints.append(NSLayoutConstraint(item: toView,
                                          attribute: .trailing,
                                          relatedBy: .greaterThanOrEqual,
                                          toItem: popUpButton,
                                          attribute: .trailing,
                                          multiplier: 1,
                                          constant: 20))
    
    // Width
    constraints.append(NSLayoutConstraint(item: popUpButton,
                                          attribute: .width,
                                          relatedBy: .equal,
                                          toItem: nil,
                                          attribute: .notAnAttribute,
                                          multiplier: 1,
                                          constant: popUpButton.intrinsicContentSize.width))
    
    // -------------------------------------------------------------------------
    //  Update height value
    // -------------------------------------------------------------------------
    height = height + 8.0 + popUpButton.intrinsicContentSize.height
    
    return popUpButton
}

public func addCheckbox(label: String?,
                        title: String,
                        bindTo: Any?,
                        bindKeyPath: String,
                        toView: NSView,
                        lastSubview: NSView?,
                        lastTextField: NSView?,
                        height: inout CGFloat,
                        indent: CGFloat,
                        constraints: inout [NSLayoutConstraint]) -> NSView? {
    
    // -------------------------------------------------------------------------
    //  Create and add Label if label string was passed
    // -------------------------------------------------------------------------
    let textFieldLabel = setupLabel(string: label, toView: toView, indent: indent, constraints: &constraints)
    
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
    checkbox.bind(NSBindingName.value, to: bindTo ?? UserDefaults.standard, withKeyPath: bindKeyPath, options: [NSBindingOption.continuouslyUpdatesValue: true])
    
    // -------------------------------------------------------------------------
    //  Add Constraints
    // -------------------------------------------------------------------------
    
    if let label = textFieldLabel {
        
        // Top
        constraints.append(NSLayoutConstraint(item: checkbox,
                                              attribute: .top,
                                              relatedBy: .equal,
                                              toItem: lastSubview ?? toView,
                                              attribute: (lastSubview != nil) ? .bottom : .top,
                                              multiplier: 1,
                                              constant: 18.0))
        
        // Leading
        constraints.append(NSLayoutConstraint(item: checkbox,
                                              attribute: .leading,
                                              relatedBy: .equal,
                                              toItem: label,
                                              attribute: .trailing,
                                              multiplier: 1,
                                              constant: 6.0))
        
        // Baseline
        constraints.append(NSLayoutConstraint(item: checkbox,
                                              attribute: .firstBaseline,
                                              relatedBy: .equal,
                                              toItem: label,
                                              attribute: .firstBaseline,
                                              multiplier: 1,
                                              constant: 0.0))
    } else {
        
        // Top
        constraints.append(NSLayoutConstraint(item: checkbox,
                                              attribute: .top,
                                              relatedBy: .equal,
                                              toItem: lastSubview ?? toView,
                                              attribute: (lastSubview != nil) ? .bottom : .top,
                                              multiplier: 1,
                                              constant: 6.0))
        
    }
    
    if lastTextField != nil {
        
        // Leading
        constraints.append(NSLayoutConstraint(item: checkbox,
                                              attribute: .leading,
                                              relatedBy: .equal,
                                              toItem: lastTextField,
                                              attribute: .leading,
                                              multiplier: 1,
                                              constant: 0.0))
    } else if textFieldLabel == nil {
        
        // Leading
        constraints.append(NSLayoutConstraint(item: checkbox,
                                              attribute: .leading,
                                              relatedBy: .equal,
                                              toItem: toView,
                                              attribute: .leading,
                                              multiplier: 1,
                                              constant: indent))
        
    }

    // Trailing
    constraints.append(NSLayoutConstraint(item: toView,
                                          attribute: .trailing,
                                          relatedBy: .greaterThanOrEqual,
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

public func addTextField(label: String?,
                         placeholderValue: String,
                         keyPath: String,
                         toView: NSView,
                         lastSubview: NSView?,
                         lastTextField: NSView?,
                         height: inout CGFloat,
                         constraints: inout [NSLayoutConstraint]) -> NSView? {
    
    let textFieldLabel = NSTextField()
    if let labelString = label {
        
        // -------------------------------------------------------------------------
        //  Create and add TextField Label
        // -------------------------------------------------------------------------
        textFieldLabel.translatesAutoresizingMaskIntoConstraints = false
        textFieldLabel.lineBreakMode = .byTruncatingTail
        textFieldLabel.isBordered = false
        textFieldLabel.isBezeled = false
        textFieldLabel.drawsBackground = false
        textFieldLabel.isEditable = false
        textFieldLabel.isSelectable = true
        textFieldLabel.font = NSFont.systemFont(ofSize: NSFont.systemFontSize(for: .regular))
        textFieldLabel.textColor = .labelColor
        textFieldLabel.alignment = .right
        textFieldLabel.stringValue = labelString
        toView.addSubview(textFieldLabel)
        
        // Leading
        constraints.append(NSLayoutConstraint(item: textFieldLabel,
                                              attribute: .leading,
                                              relatedBy: .equal,
                                              toItem: toView,
                                              attribute: .leading,
                                              multiplier: 1,
                                              constant: preferencesIndent))
    }
    
    // -------------------------------------------------------------------------
    //  Create and add TextField
    // -------------------------------------------------------------------------
    let textField = NSTextField()
    textField.translatesAutoresizingMaskIntoConstraints = false
    textField.lineBreakMode = .byTruncatingTail
    textField.isBordered = true
    textField.isBezeled = true
    textField.bezelStyle = .squareBezel
    textField.drawsBackground = false
    textField.isEditable = true
    textField.isSelectable = true
    textField.font = NSFont.systemFont(ofSize: NSFont.systemFontSize(for: .regular))
    textField.textColor = .labelColor
    textField.alignment = .left
    textField.placeholderString = placeholderValue
    toView.addSubview(textField)
    
    // ---------------------------------------------------------------------
    //  Bind TextField to keyPath
    // ---------------------------------------------------------------------
    textField.bind(NSBindingName.value, to: UserDefaults.standard, withKeyPath: keyPath, options: [NSBindingOption.continuouslyUpdatesValue: true, NSBindingOption.nullPlaceholder: placeholderValue])
    
    // -------------------------------------------------------------------------
    //  Add Constraints
    // -------------------------------------------------------------------------
    // Top
    constraints.append(NSLayoutConstraint(item: textField,
                                          attribute: .top,
                                          relatedBy: .equal,
                                          toItem: lastSubview ?? toView,
                                          attribute: (lastSubview != nil) ? .bottom : .top,
                                          multiplier: 1,
                                          constant: 8))
    
    if label != nil {
        
        // Leading
        constraints.append(NSLayoutConstraint(item: textField,
                                              attribute: .leading,
                                              relatedBy: .equal,
                                              toItem: textFieldLabel,
                                              attribute: .trailing,
                                              multiplier: 1,
                                              constant: 6.0))
        
        // Baseline
        constraints.append(NSLayoutConstraint(item: textField,
                                              attribute: .firstBaseline,
                                              relatedBy: .equal,
                                              toItem: textFieldLabel,
                                              attribute: .firstBaseline,
                                              multiplier: 1,
                                              constant: 0.0))
    } else {
        
        // Leading
        constraints.append(NSLayoutConstraint(item: textField,
                                              attribute: .leading,
                                              relatedBy: .equal,
                                              toItem: toView,
                                              attribute: .leading,
                                              multiplier: 1,
                                              constant: preferencesIndent))
    }
    
    if lastTextField != nil {
        
        // Leading
        constraints.append(NSLayoutConstraint(item: textField,
                                              attribute: .leading,
                                              relatedBy: .equal,
                                              toItem: lastTextField,
                                              attribute: .leading,
                                              multiplier: 1,
                                              constant: 0.0))
    }
    
    // Trailing
    constraints.append(NSLayoutConstraint(item: toView,
                                          attribute: .trailing,
                                          relatedBy: .equal,
                                          toItem: textField,
                                          attribute: .trailing,
                                          multiplier: 1,
                                          constant: 20))
    
    // -------------------------------------------------------------------------
    //  Update height value
    // -------------------------------------------------------------------------
    height = height + 20.0 + textField.intrinsicContentSize.height
    
    return textField
}
