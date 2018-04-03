//
//  PayloadCellViewItems.swift
//  ProfileCreator
//
//  Created by Erik Berglund on 2017-07-27.
//  Copyright © 2018 Erik Berglund. All rights reserved.
//

import Cocoa
import ProfilePayloads

class EditorTextField {
    
    class func title(profile: Profile,
                     subkey: PayloadSourceSubkey,
                     indent: Int,
                     constraints: inout [NSLayoutConstraint],
                     cellView: PayloadCellView) -> NSTextField? {
        
        guard let title = profile.getTitleString(subkey: subkey), !title.isEmpty else {
            Log.shared.debug(message: "Subkey: \(subkey.keyPath) has no title", category: String(describing: self))
            return nil
        }
        
        // -------------------------------------------------------------------------
        //  Create and setup text field
        // -------------------------------------------------------------------------
        let textField = NSTextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.lineBreakMode = .byWordWrapping
        textField.isBordered = false
        textField.isBezeled = false
        textField.drawsBackground = false
        textField.isEditable = false
        textField.isSelectable = false
        textField.textColor = .labelColor
        textField.font = NSFont.systemFont(ofSize: NSFont.systemFontSize(for: .regular), weight: .bold)
        textField.preferredMaxLayoutWidth = editorTableViewColumnPayloadWidth
        textField.stringValue = title
        
        // -------------------------------------------------------------------------
        //  Add text field to cell view
        // -------------------------------------------------------------------------
        cellView.addSubview(textField)
        
        // -------------------------------------------------------------------------
        //  Setup Layout Constraings for text field
        // -------------------------------------------------------------------------
        
        // Top
        constraints.append(NSLayoutConstraint(item: textField,
                                              attribute: .top,
                                              relatedBy: .equal,
                                              toItem: cellView,
                                              attribute: .top,
                                              multiplier: 1.0,
                                              constant: 8.0))
        
        cellView.updateHeight(8.0 + textField.intrinsicContentSize.height)
        
        
        // -------------------------------------------------------------------------
        //  Calculate Indent
        // -------------------------------------------------------------------------
        let indentValue: CGFloat = 8.0 + (16.0 * CGFloat(indent))
        
        // Leading
        constraints.append(NSLayoutConstraint(item: textField,
                                              attribute: .leading,
                                              relatedBy: .equal,
                                              toItem: cellView,
                                              attribute: .leading,
                                              multiplier: 1.0,
                                              constant: indentValue))
        
        // Trailing
        constraints.append(NSLayoutConstraint(item: cellView,
                                              attribute: .trailing,
                                              relatedBy: .equal,
                                              toItem: textField,
                                              attribute: .trailing,
                                              multiplier: 1.0,
                                              constant: 8.0))
        
        return textField
    }
    
    class func description(subkey: PayloadSourceSubkey,
                           indent: Int,
                           constraints: inout [NSLayoutConstraint],
                           cellView: PayloadCellView) -> NSTextField? {
        
        guard let description = subkey.description, !description.isEmpty else { return nil }
        
        // ---------------------------------------------------------------------
        //  Create and setup TextField
        // ---------------------------------------------------------------------
        let textField = NSTextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.lineBreakMode = .byWordWrapping
        textField.isBordered = false
        textField.isBezeled = false
        textField.drawsBackground = false
        textField.isEditable = false
        textField.isSelectable = false
        textField.textColor = .controlShadowColor
        textField.font = NSFont.systemFont(ofSize: NSFont.systemFontSize(for: .regular))
        textField.preferredMaxLayoutWidth = editorTableViewColumnPayloadWidth
        textField.stringValue = description
        
        // ---------------------------------------------------------------------
        //  Add text field to cell view
        // ---------------------------------------------------------------------
        cellView.addSubview(textField)
        
        // ---------------------------------------------------------------------
        //  Setup Layout Constraings for TextField
        // ---------------------------------------------------------------------
        if cellView.textFieldTitle != nil {
            
            // Top
            constraints.append(NSLayoutConstraint(item: textField,
                                                  attribute: .top,
                                                  relatedBy: .equal,
                                                  toItem: cellView.textFieldTitle,
                                                  attribute: .bottom,
                                                  multiplier: 1.0,
                                                  constant: 2.0))
            
            cellView.updateHeight(2.0 + textField.intrinsicContentSize.height)
        } else {
            
            // Top
            constraints.append(NSLayoutConstraint(item: textField,
                                                  attribute: .top,
                                                  relatedBy: .equal,
                                                  toItem: cellView,
                                                  attribute: .top,
                                                  multiplier: 1.0,
                                                  constant: 8.0))
            
            cellView.updateHeight(8.0 + textField.intrinsicContentSize.height)
        }
        
        // -------------------------------------------------------------------------
        //  Calculate Indent
        // -------------------------------------------------------------------------
        let indentValue: CGFloat = 8.0 + (16.0 * CGFloat(indent))
        
        // Leading
        constraints.append(NSLayoutConstraint(item: textField,
                                              attribute: .leading,
                                              relatedBy: .equal,
                                              toItem: cellView,
                                              attribute: .leading,
                                              multiplier: 1.0,
                                              constant: indentValue))
        
        // Trailing
        constraints.append(NSLayoutConstraint(item: cellView,
                                              attribute: .trailing,
                                              relatedBy: .equal,
                                              toItem: textField,
                                              attribute: .trailing,
                                              multiplier: 1.0,
                                              constant: 8.0))
        
        return textField
    }
    
    class func message(profile: Profile,
                       subkey: PayloadSourceSubkey,
                       payloadIndex: Int,
                       indent: Int,
                       constraints: inout [NSLayoutConstraint],
                       cellView: PayloadCellView) -> NSTextField? {
        
        var message: String
        if let subkeyMessage = subkey.message {
            message = subkeyMessage
        } else if
            let sensitiveMessage = subkey.sensitiveMessage,
            profile.isEnabled(subkey: subkey, onlyByUser: false, payloadIndex: payloadIndex) {
            message = sensitiveMessage
        } else {
            return nil
        }
        
        // ---------------------------------------------------------------------
        //  Create and setup TextField
        // ---------------------------------------------------------------------
        let textField = NSTextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.lineBreakMode = .byWordWrapping
        textField.isBordered = false
        textField.isBezeled = false
        textField.drawsBackground = false
        textField.isEditable = false
        textField.isSelectable = false
        textField.textColor = .orange
        textField.font = NSFont.systemFont(ofSize: NSFont.systemFontSize(for: .regular))
        textField.preferredMaxLayoutWidth = editorTableViewColumnPayloadWidth
        textField.stringValue = message
        
        // ---------------------------------------------------------------------
        //  Add text field to cell view
        // ---------------------------------------------------------------------
        cellView.addSubview(textField)
        
        // -------------------------------------------------------------------------
        //  Calculate Indent
        // -------------------------------------------------------------------------
        let indentValue: CGFloat = 8.0 + (16.0 * CGFloat(indent))
        
        // Leading
        constraints.append(NSLayoutConstraint(item: textField,
                                              attribute: .leading,
                                              relatedBy: .equal,
                                              toItem: cellView,
                                              attribute: .leading,
                                              multiplier: 1.0,
                                              constant: indentValue))
        
        // Trailing
        constraints.append(NSLayoutConstraint(item: cellView,
                                              attribute: .trailing,
                                              relatedBy: .equal,
                                              toItem: textField,
                                              attribute: .trailing,
                                              multiplier: 1.0,
                                              constant: 8.0))
        
        return textField
    }
    
    class func input(defaultString: String?,
                     placeholderString: String?,
                     cellView: PayloadCellView) -> PayloadTextField {
        
        // -------------------------------------------------------------------------
        //  Create and setup text field
        // -------------------------------------------------------------------------
        let textField = PayloadTextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.lineBreakMode = .byClipping
        textField.isBordered = true
        textField.isBezeled = true
        textField.bezelStyle = .squareBezel
        textField.drawsBackground = false
        textField.isEditable = true
        textField.isSelectable = true
        textField.textColor = .controlTextColor
        textField.backgroundColor = .controlBackgroundColor
        textField.font = NSFont.systemFont(ofSize: NSFont.systemFontSize(for: .regular))
        textField.stringValue = defaultString ?? ""
        textField.placeholderString = placeholderString ?? ""
        textField.preferredMaxLayoutWidth = editorTableViewColumnPayloadWidth
        if cellView is NSTextFieldDelegate { textField.delegate = cellView as? NSTextFieldDelegate }
        
        // -------------------------------------------------------------------------
        //  Add text field to cell view
        // -------------------------------------------------------------------------
        cellView.addSubview(textField)
        
        return textField
    }
    
    class func label(string: String?,
                     fontWeight: NSFont.Weight?,
                     leadingItem: NSView?,
                     leadingConstant: CGFloat?,
                     trailingItem: NSView?,
                     constraints: inout [NSLayoutConstraint],
                     cellView: ProfileCreatorCellView) -> NSTextField {
        
        // -------------------------------------------------------------------------
        //  Create and setup text field
        // -------------------------------------------------------------------------
        let textField = NSTextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.lineBreakMode = .byWordWrapping
        textField.isBordered = false
        textField.isBezeled = false
        textField.drawsBackground = false
        textField.isEditable = false
        textField.isSelectable = false
        textField.textColor = .labelColor
        textField.font = NSFont.systemFont(ofSize: NSFont.systemFontSize(for: .regular), weight: fontWeight ?? .bold)
        textField.preferredMaxLayoutWidth = editorTableViewColumnPayloadWidth
        textField.stringValue = string ?? ""
        
        // -------------------------------------------------------------------------
        //  Add text field to cell view
        // -------------------------------------------------------------------------
        cellView.addSubview(textField)
        
        // -------------------------------------------------------------------------
        //  Setup Layout Constraings for text field
        // -------------------------------------------------------------------------
        
        if let leadingView = leadingItem {
            
            let leadingConstantValue: CGFloat
            if leadingView is NSPopUpButton, leadingView is NSTextField {
                leadingConstantValue = 6.0
            } else {
                leadingConstantValue = 2.0
            }
            
            // Leading
            constraints.append(NSLayoutConstraint(item: textField,
                                                  attribute: .leading,
                                                  relatedBy: .equal,
                                                  toItem: leadingView,
                                                  attribute: .trailing,
                                                  multiplier: 1.0,
                                                  constant: leadingConstant ?? leadingConstantValue))
            
            // Baseline
            constraints.append(NSLayoutConstraint(item: textField,
                                                  attribute: .firstBaseline,
                                                  relatedBy: .equal,
                                                  toItem: leadingView,
                                                  attribute: .firstBaseline,
                                                  multiplier: 1.0,
                                                  constant: 0.0))
        } else {
            
            // Leading
            constraints.append(NSLayoutConstraint(item: textField,
                                                  attribute: .leading,
                                                  relatedBy: .equal,
                                                  toItem: cellView,
                                                  attribute: .leading,
                                                  multiplier: 1.0,
                                                  constant: 8.0))
        }
        
        if let trailingView = trailingItem {
            
            let trailingConstant: CGFloat
            if trailingView is NSPopUpButton {
                trailingConstant = 6.0
            } else {
                trailingConstant = 2.0
            }
            
            // Trailing
            constraints.append(NSLayoutConstraint(item: trailingView,
                                                  attribute: .leading,
                                                  relatedBy: .equal,
                                                  toItem: textField,
                                                  attribute: .trailing,
                                                  multiplier: 1.0,
                                                  constant: trailingConstant))
            
            // Baseline
            constraints.append(NSLayoutConstraint(item: textField,
                                                  attribute: .firstBaseline,
                                                  relatedBy: .equal,
                                                  toItem: trailingView,
                                                  attribute: .firstBaseline,
                                                  multiplier: 1.0,
                                                  constant: 0.0))
        } else {
            
            // Trailing
            constraints.append(NSLayoutConstraint(item: cellView,
                                                  attribute: .trailing,
                                                  relatedBy: .equal,
                                                  toItem: textField,
                                                  attribute: .trailing,
                                                  multiplier: 1.0,
                                                  constant: 8.0))
        }
        
        return textField
        
    }
}
