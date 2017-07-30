//
//  LibraryCellViewItemTextField.swift
//  ProfileCreator
//
//  Created by Erik Berglund on 2017-07-29.
//  Copyright © 2017 Erik Berglund. All rights reserved.
//

import Cocoa

class LibraryTextField {
    
    class func description(string: String?,
                           constraints: inout [NSLayoutConstraint],
                           cellView: PayloadLibraryCellView) -> NSTextField? {
        
        guard let textFieldTitle = cellView.textFieldTitle else {
            // TODO: Proper Loggin
            return nil
        }
        
        // ---------------------------------------------------------------------
        //  Create and setup TextField
        // ---------------------------------------------------------------------
        let textField = NSTextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.lineBreakMode = .byTruncatingTail
        textField.isBordered = false
        textField.isBezeled = false
        textField.drawsBackground = false
        textField.isEditable = false
        textField.isSelectable = false
        textField.controlSize = .regular
        textField.textColor = NSColor.controlTextColor
        textField.alignment = .left
        textField.font = NSFont.systemFont(ofSize: 10)
        textField.stringValue = string ?? ""
        
        // ---------------------------------------------------------------------
        //  Add TextField to cell view
        // ---------------------------------------------------------------------
        cellView.addSubview(textField)
        
        // -------------------------------------------------------------------------
        //  Setup Layout Constraings for TextField
        // -------------------------------------------------------------------------
        // Top
        constraints.append(NSLayoutConstraint(item: textField,
                                              attribute: .top,
                                              relatedBy: .equal,
                                              toItem: textFieldTitle,
                                              attribute: .bottom,
                                              multiplier: 1.0,
                                              constant: 1.0))
        
        // Leading
        constraints.append(NSLayoutConstraint(item: textField,
                                              attribute: .leading,
                                              relatedBy: .equal,
                                              toItem: textFieldTitle,
                                              attribute: .leading,
                                              multiplier: 1.0,
                                              constant: 0.0))
        
        // Trailing
        constraints.append(NSLayoutConstraint(item: textField,
                                              attribute: .trailing,
                                              relatedBy: .equal,
                                              toItem: textFieldTitle,
                                              attribute: .trailing,
                                              multiplier: 1.0,
                                              constant: 0.0))
        
        return textField
    }
    
    class func title(string: String?,
                     fontSize: CGFloat,
                     fontWeight: CGFloat,
                     indent: CGFloat,
                     constraints: inout [NSLayoutConstraint],
                     cellView: PayloadLibraryCellView) -> NSTextField? {
        
        guard let imageView = cellView.imageViewIcon else {
            // TODO: Proper Loggin
            return nil
        }
        
        // ---------------------------------------------------------------------
        //  Create and setup TextField
        // ---------------------------------------------------------------------
        let textField = NSTextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.lineBreakMode = .byTruncatingTail
        textField.isBordered = false
        textField.isBezeled = false
        textField.drawsBackground = false
        textField.isEditable = false
        textField.isSelectable = false
        textField.controlSize = .regular
        textField.textColor = NSColor.controlTextColor
        textField.alignment = .left
        textField.font = NSFont.systemFont(ofSize: fontSize, weight: fontWeight)
        textField.stringValue = string ?? ""
        
        // ---------------------------------------------------------------------
        //  Add TextField to cell view
        // ---------------------------------------------------------------------
        cellView.addSubview(textField)
        
        // -------------------------------------------------------------------------
        //  Setup Layout Constraings for TextField
        // -------------------------------------------------------------------------
        // Leading
        constraints.append(NSLayoutConstraint(item: textField,
                                              attribute: .leading,
                                              relatedBy: .equal,
                                              toItem: imageView,
                                              attribute: .trailing,
                                              multiplier: 1.0,
                                              constant: indent))
        
        // Trailing
        constraints.append(NSLayoutConstraint(item: textField,
                                              attribute: .trailing,
                                              relatedBy: .equal,
                                              toItem: cellView,
                                              attribute: .trailing,
                                              multiplier: 1.0,
                                              constant: indent))
        
        return textField
    }
}

