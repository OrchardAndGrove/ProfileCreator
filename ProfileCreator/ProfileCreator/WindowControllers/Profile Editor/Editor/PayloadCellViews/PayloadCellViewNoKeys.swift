//
//  PayloadCellViewPadding.swift
//  ProfileCreator
//
//  Created by Erik Berglund on 2017-07-29.
//  Copyright © 2018 Erik Berglund. All rights reserved.
//

import Cocoa
import ProfilePayloads

class PayloadCellViewNoKeys: NSTableCellView, ProfileCreatorCellView {
    
    // MARK: -
    // MARK: PayloadCellView Variables
    
    var height: CGFloat = 0.0
    var textFieldTitle: NSTextField?
    var textFieldDescription: NSTextField?
    
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
        //  Setup Static View Content
        // ---------------------------------------------------------------------
        if let title = titleString, !title.isEmpty {
            self.setupTextField(title: title, constraints: &constraints)
        }
        
        if let description = descriptionString, !description.isEmpty {
            self.setupTextField(description: description, constraints: &constraints)
        }
        
        // ---------------------------------------------------------------------
        //  Add spacing to bottom
        // ---------------------------------------------------------------------
        self.updateHeight(20.0)
        
        // ---------------------------------------------------------------------
        //  Activate Layout Constraints
        // ---------------------------------------------------------------------
        NSLayoutConstraint.activate(constraints)
    }
    
    convenience init(payloadSource: PayloadSource) {
        self.init(title: payloadSource.title, description: payloadSource.description)
    }
    
    // MARK: -
    // MARK: PayloadCellView Functions
    
    func updateHeight(_ h: CGFloat) {
        self.height += h
    }
}

// MARK: -
// MARK: Setup NSLayoutConstraints

extension PayloadCellViewNoKeys {
    
    private func setupTextField(title: String, constraints: inout [NSLayoutConstraint]) {
        
        let textFieldTitle = NSTextField()
        textFieldTitle.translatesAutoresizingMaskIntoConstraints = false
        textFieldTitle.lineBreakMode = .byWordWrapping
        textFieldTitle.isBordered = false
        textFieldTitle.isBezeled = false
        textFieldTitle.drawsBackground = false
        textFieldTitle.isEditable = false
        textFieldTitle.isSelectable = false
        textFieldTitle.textColor = .tertiaryLabelColor
        textFieldTitle.preferredMaxLayoutWidth = editorTableViewColumnPayloadWidth
        textFieldTitle.stringValue = title
        textFieldTitle.alignment = .center
        textFieldTitle.font = NSFont.systemFont(ofSize: 20, weight: .bold)
        self.textFieldTitle = textFieldTitle
        
        // ---------------------------------------------------------------------
        //  Add TextField to TableCellView
        // ---------------------------------------------------------------------
        self.addSubview(textFieldTitle)
        
        // ---------------------------------------------------------------------
        //  Add constraints
        // ---------------------------------------------------------------------
        // Top
        constraints.append(NSLayoutConstraint(item: textFieldTitle,
                                              attribute: .top,
                                              relatedBy: .equal,
                                              toItem: self,
                                              attribute: .top,
                                              multiplier: 1.0,
                                              constant: 8.0))
        self.updateHeight(8 + textFieldTitle.intrinsicContentSize.height)
        
        // Leading
        constraints.append(NSLayoutConstraint(item: textFieldTitle,
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
                                              toItem: textFieldTitle,
                                              attribute: .trailing,
                                              multiplier: 1.0,
                                              constant: 8.0))
    }
    
    
    private func setupTextField(description: String, constraints: inout [NSLayoutConstraint]) {
        
        let textFieldDescription = NSTextField()
        textFieldDescription.translatesAutoresizingMaskIntoConstraints = false
        textFieldDescription.lineBreakMode = .byWordWrapping
        textFieldDescription.isBordered = false
        textFieldDescription.isBezeled = false
        textFieldDescription.drawsBackground = false
        textFieldDescription.isEditable = false
        textFieldDescription.isSelectable = false
        textFieldDescription.textColor = .labelColor
        textFieldDescription.preferredMaxLayoutWidth = editorTableViewColumnPayloadWidth
        textFieldDescription.stringValue = description
        textFieldDescription.alignment = .center
        textFieldDescription.font = NSFont.systemFont(ofSize: 15, weight: NSFont.Weight.ultraLight)
        self.textFieldDescription = textFieldDescription
        
        // ---------------------------------------------------------------------
        //  Add TextField to TableCellView
        // ---------------------------------------------------------------------
        self.addSubview(textFieldDescription)
        
        // ---------------------------------------------------------------------
        //  Add constraints
        // ---------------------------------------------------------------------
        // Top
        if let textFieldTitle = self.textFieldTitle {
            constraints.append(NSLayoutConstraint(item: textFieldDescription,
                                                  attribute: .top,
                                                  relatedBy: .equal,
                                                  toItem: textFieldTitle,
                                                  attribute: .bottom,
                                                  multiplier: 1.0,
                                                  constant: 6.0))
            self.updateHeight(6 + textFieldDescription.intrinsicContentSize.height)
        } else {
            constraints.append(NSLayoutConstraint(item: textFieldDescription,
                                                  attribute: .top,
                                                  relatedBy: .equal,
                                                  toItem: self,
                                                  attribute: .top,
                                                  multiplier: 1.0,
                                                  constant: 8.0))
            self.updateHeight(8 + textFieldDescription.intrinsicContentSize.height)
        }
        
        // Leading
        constraints.append(NSLayoutConstraint(item: textFieldDescription,
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
                                              toItem: textFieldDescription,
                                              attribute: .trailing,
                                              multiplier: 1.0,
                                              constant: 8.0))
    }
}
