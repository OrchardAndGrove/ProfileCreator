//
//  PayloadCellViewPadding.swift
//  ProfileCreator
//
//  Created by Erik Berglund on 2017-07-29.
//  Copyright © 2017 Erik Berglund. All rights reserved.
//

import Cocoa
import ProfilePayloads

class PayloadCellViewTitle: NSTableCellView, ProfileCreatorCellView {
    
    // MARK: -
    // MARK: PayloadCellView Variables
    
    var height: CGFloat = 0.0
    var textFieldTitle: NSTextField?
    var textFieldDescription: NSTextField?
    var separatorTop: NSBox?
    
    // MARK: -
    // MARK: Initialization
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init(title titleString: String?, description descriptionString: String?) {
        super.init(frame: NSZeroRect)
        
        // ---------------------------------------------------------------------
        //  Setup Variables
        // ---------------------------------------------------------------------
        var constraints = [NSLayoutConstraint]()
        
        // ---------------------------------------------------------------------
        //  Create and add vertical separator bottom
        // ---------------------------------------------------------------------
        let separatorTop = NSBox(frame: NSRect(x: 250.0, y: 15.0, width: preferencesWindowWidth - (20.0 + 20.0), height: 250.0))
        separatorTop.translatesAutoresizingMaskIntoConstraints = false
        separatorTop.boxType = .separator
        self.separatorTop = separatorTop
        self.setup(separatorTop: separatorTop, constraints: &constraints)
        
        // ---------------------------------------------------------------------
        //  Setup Static View Content
        // ---------------------------------------------------------------------
        if let title = titleString, !title.isEmpty {
            self.textFieldTitle = NSTextField()
            self.textFieldTitle?.translatesAutoresizingMaskIntoConstraints = false
            self.textFieldTitle?.lineBreakMode = .byWordWrapping
            self.textFieldTitle?.isBordered = false
            self.textFieldTitle?.isBezeled = false
            self.textFieldTitle?.drawsBackground = false
            self.textFieldTitle?.isEditable = false
            self.textFieldTitle?.isSelectable = false
            self.textFieldTitle?.textColor = NSColor.labelColor
            self.textFieldTitle?.preferredMaxLayoutWidth = editorTableViewColumnPayloadWidth
            self.textFieldTitle?.stringValue = title
            self.textFieldTitle?.alignment = .center
            self.textFieldTitle?.font = NSFont.systemFont(ofSize: 20, weight: .bold)
            self.setupTextField(title: self.textFieldTitle!, constraints: &constraints)
        }
        
        if let description = descriptionString, !description.isEmpty {
            self.textFieldDescription = NSTextField()
            self.textFieldDescription?.translatesAutoresizingMaskIntoConstraints = false
            self.textFieldDescription?.lineBreakMode = .byWordWrapping
            self.textFieldDescription?.isBordered = false
            self.textFieldDescription?.isBezeled = false
            self.textFieldDescription?.drawsBackground = false
            self.textFieldDescription?.isEditable = false
            self.textFieldDescription?.isSelectable = false
            self.textFieldDescription?.textColor = NSColor.labelColor
            self.textFieldDescription?.preferredMaxLayoutWidth = editorTableViewColumnPayloadWidth
            self.textFieldDescription?.stringValue = description
            self.textFieldDescription?.alignment = .center
            self.textFieldDescription?.font = NSFont.systemFont(ofSize: 15, weight: NSFont.Weight.ultraLight)
            self.setupTextField(description: self.textFieldDescription!, constraints: &constraints)
        }
        
        // ---------------------------------------------------------------------
        //  Create and add vertical separator bottom
        // ---------------------------------------------------------------------
        let separatorBottom = NSBox(frame: NSRect(x: 250.0, y: 15.0, width: preferencesWindowWidth - (20.0 + 20.0), height: 250.0))
        separatorBottom.translatesAutoresizingMaskIntoConstraints = false
        separatorBottom.boxType = .separator
        self.setup(separatorBottom: separatorBottom, constraints: &constraints)
        
        // ---------------------------------------------------------------------
        //  Add spacing to bottom
        // ---------------------------------------------------------------------
        self.updateHeight(34.0)
        
        // ---------------------------------------------------------------------
        //  Activate Layout Constraints
        // ---------------------------------------------------------------------
        NSLayoutConstraint.activate(constraints)
    }
    
    convenience init(payloadSource: PayloadSource) {
        self.init(title: payloadSource.title, description: payloadSource.description)
    }
    
    func updateHeight(_ h: CGFloat) {
        self.height += h
    }
    
    // MARK: -
    // MARK: Setup Layout Constraints
    
    private func setupTextField(title: NSTextField, constraints: inout [NSLayoutConstraint]) {
        
        // ---------------------------------------------------------------------
        //  Add TextField to TableCellView
        // ---------------------------------------------------------------------
        self.addSubview(title)
        
        // ---------------------------------------------------------------------
        //  Add constraints
        // ---------------------------------------------------------------------
        // Top
        constraints.append(NSLayoutConstraint(item: title,
                                              attribute: .top,
                                              relatedBy: .equal,
                                              toItem: self.separatorTop,
                                              attribute: .bottom,
                                              multiplier: 1.0,
                                              constant: 8.0))
        self.updateHeight(8 + title.intrinsicContentSize.height)
        
        // Leading
        constraints.append(NSLayoutConstraint(item: title,
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
                                              toItem: title,
                                              attribute: .trailing,
                                              multiplier: 1.0,
                                              constant: 8.0))
    }
    
    
    private func setupTextField(description: NSTextField, constraints: inout [NSLayoutConstraint]) {
        
        // ---------------------------------------------------------------------
        //  Add TextField to TableCellView
        // ---------------------------------------------------------------------
        self.addSubview(description)
        
        // ---------------------------------------------------------------------
        //  Add constraints
        // ---------------------------------------------------------------------
        // Top
        if let textFieldTitle = self.textFieldTitle {
            constraints.append(NSLayoutConstraint(item: description,
                                                  attribute: .top,
                                                  relatedBy: .equal,
                                                  toItem: textFieldTitle,
                                                  attribute: .bottom,
                                                  multiplier: 1.0,
                                                  constant: 6.0))
            self.updateHeight(6 + description.intrinsicContentSize.height)
        } else {
            constraints.append(NSLayoutConstraint(item: description,
                                                  attribute: .top,
                                                  relatedBy: .equal,
                                                  toItem: self.separatorTop,
                                                  attribute: .bottom,
                                                  multiplier: 1.0,
                                                  constant: 8.0))
            self.updateHeight(8 + description.intrinsicContentSize.height)
        }
        
        // Leading
        constraints.append(NSLayoutConstraint(item: description,
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
                                              toItem: description,
                                              attribute: .trailing,
                                              multiplier: 1.0,
                                              constant: 8.0))
    }
    
    private func setup(separatorTop: NSBox, constraints: inout [NSLayoutConstraint]) {
        
        // ---------------------------------------------------------------------
        //  Add TextField to TableCellView
        // ---------------------------------------------------------------------
        self.addSubview(separatorTop)
        
        // Top
        constraints.append(NSLayoutConstraint(item: separatorTop,
                                              attribute: .top,
                                              relatedBy: .equal,
                                              toItem: self,
                                              attribute: .top,
                                              multiplier: 1.0,
                                              constant: 14.0))
        
        // Leading
        constraints.append(NSLayoutConstraint(item: separatorTop,
                                              attribute: .leading,
                                              relatedBy: .equal,
                                              toItem: self,
                                              attribute: .leading,
                                              multiplier: 1,
                                              constant: 8.0))
        
        // Trailing
        constraints.append(NSLayoutConstraint(item: self,
                                              attribute: .trailing,
                                              relatedBy: .equal,
                                              toItem: separatorTop,
                                              attribute: .trailing,
                                              multiplier: 1,
                                              constant: 8.0))
        
        self.updateHeight(14 + separatorTop.intrinsicContentSize.height)
    }
    
    private func setup(separatorBottom: NSBox, constraints: inout [NSLayoutConstraint]) {
        
        // ---------------------------------------------------------------------
        //  Add Constraints
        // ---------------------------------------------------------------------
        
        // Top
        let textField: NSTextField
        if let textFieldDescription = self.textFieldDescription {
            textField = textFieldDescription
        } else if let textFieldTitle = self.textFieldTitle {
            textField = textFieldTitle
        } else {
            return
        }
        
        // ---------------------------------------------------------------------
        //  Add TextField to TableCellView
        // ---------------------------------------------------------------------
        self.addSubview(separatorBottom)
        
        // Top
        constraints.append(NSLayoutConstraint(item: separatorBottom,
                                              attribute: .top,
                                              relatedBy: .equal,
                                              toItem: textField,
                                              attribute: .bottom,
                                              multiplier: 1,
                                              constant: 10.0))
        
        // Leading
        constraints.append(NSLayoutConstraint(item: separatorBottom,
                                              attribute: .leading,
                                              relatedBy: .equal,
                                              toItem: self,
                                              attribute: .leading,
                                              multiplier: 1,
                                              constant: 8.0))
        
        // Trailing
        constraints.append(NSLayoutConstraint(item: self,
                                              attribute: .trailing,
                                              relatedBy: .equal,
                                              toItem: separatorBottom,
                                              attribute: .trailing,
                                              multiplier: 1,
                                              constant: 8.0))
        
    }
}
