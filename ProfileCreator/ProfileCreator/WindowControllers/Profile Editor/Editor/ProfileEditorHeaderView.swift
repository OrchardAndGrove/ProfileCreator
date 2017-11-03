//
//  ProfileEditorHeaderView.swift
//  ProfileCreator
//
//  Created by Erik Berglund on 2017-10-27.
//  Copyright © 2017 Erik Berglund. All rights reserved.
//

import Foundation
import ProfilePayloads

class ProfileEditorHeaderView: NSObject {
    
    // MARK: -
    // MARK: Variables
    
    let headerView = NSView()
    let textFieldTitle = NSTextField()
    let textFieldTitleTopIndent: CGFloat = 28.0
    let textFieldDescription = NSTextField()
    let textFieldDescriptionTopIndent: CGFloat = 6.0
    let imageViewIcon = NSImageView()
    
    var height: CGFloat = 0.0
    var layoutConstraintHeight: NSLayoutConstraint?
    
    weak var selectedPayloadPlaceholder: PayloadPlaceholder?
    weak var profileEditor: ProfileEditor?
    
    // MARK: -
    // MARK: Initialization
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init() {
        super.init()
        
        // ---------------------------------------------------------------------
        //  Setup Variables
        // ---------------------------------------------------------------------
        var constraints = [NSLayoutConstraint]()
        
        // ---------------------------------------------------------------------
        //  Add subviews to headerView
        // ---------------------------------------------------------------------
        self.setupHeaderView(constraints: &constraints)
        self.setupTextFieldTitle(constraints: &constraints)
        self.setupTextFieldDescription(constraints: &constraints)
        
        // ---------------------------------------------------------------------
        //  Activate layout constraints
        // ---------------------------------------------------------------------
        NSLayoutConstraint.activate(constraints)
    }
    
    // MARK: -
    // MARK: Private Functions
    
    private func updateHeight(_ h: CGFloat) {
        self.height += h
    }
    
    // MARK: -
    // MARK: Functions
    
    func select(payloadPlaceholder: PayloadPlaceholder) {
        if self.selectedPayloadPlaceholder != payloadPlaceholder {
            self.selectedPayloadPlaceholder = payloadPlaceholder
            
            guard let layoutConstraintHeight = self.layoutConstraintHeight else {
                Swift.print("Class: \(self.self), Function: \(#function), layoutConstraintHeight is not set")
                return
            }
            
            self.height = 0.0
            self.textFieldTitle.stringValue = payloadPlaceholder.title
            self.updateHeight(self.textFieldTitleTopIndent + self.textFieldTitle.intrinsicContentSize.height)
            
            self.textFieldDescription.stringValue = payloadPlaceholder.description
            if 0 < self.textFieldDescription.intrinsicContentSize.height {
                self.updateHeight(self.textFieldDescriptionTopIndent + self.textFieldDescription.intrinsicContentSize.height)
            }
            
            // Add spacing
            self.updateHeight(12.0)
            layoutConstraintHeight.constant = self.height
        }
    }
    
    // MARK: -
    // MARK: Setup Layout Constraints
    
    private func setupHeaderView(constraints: inout [NSLayoutConstraint]) {
        self.headerView.translatesAutoresizingMaskIntoConstraints = false
    }
    
    private func setupTextFieldTitle(constraints: inout [NSLayoutConstraint]) {
        self.textFieldTitle.translatesAutoresizingMaskIntoConstraints = false
        self.textFieldTitle.lineBreakMode = .byWordWrapping
        self.textFieldTitle.isBordered = false
        self.textFieldTitle.isBezeled = false
        self.textFieldTitle.drawsBackground = false
        self.textFieldTitle.isEditable = false
        self.textFieldTitle.isSelectable = false
        self.textFieldTitle.textColor = NSColor.labelColor
        self.textFieldTitle.preferredMaxLayoutWidth = editorTableViewColumnPayloadWidth
        self.textFieldTitle.alignment = .left
        self.textFieldTitle.stringValue = "Title"
        self.textFieldTitle.font = NSFont.systemFont(ofSize: 24, weight: NSFont.Weight.heavy)
        
        // ---------------------------------------------------------------------
        //  Add TextField to TableCellView
        // ---------------------------------------------------------------------
        self.headerView.addSubview(self.textFieldTitle)
        
        // ---------------------------------------------------------------------
        //  Add constraints
        // ---------------------------------------------------------------------
        // Height
        self.layoutConstraintHeight = NSLayoutConstraint(item: self.headerView,
                                                         attribute: .height,
                                                         relatedBy: .equal,
                                                         toItem: nil,
                                                         attribute: .notAnAttribute,
                                                         multiplier: 1.0,
                                                         constant: 0.0)
        constraints.append(self.layoutConstraintHeight!)
        
        // Top
        constraints.append(NSLayoutConstraint(item: self.textFieldTitle,
                                              attribute: .top,
                                              relatedBy: .equal,
                                              toItem: self.headerView,
                                              attribute: .top,
                                              multiplier: 1.0,
                                              constant: self.textFieldTitleTopIndent))
        
        // Leading
        constraints.append(NSLayoutConstraint(item: self.textFieldTitle,
                                              attribute: .leading,
                                              relatedBy: .equal,
                                              toItem: self.headerView,
                                              attribute: .leading,
                                              multiplier: 1.0,
                                              constant: 24.0))
        
        // Trailing
        constraints.append(NSLayoutConstraint(item: self.headerView,
                                              attribute: .trailing,
                                              relatedBy: .equal,
                                              toItem: self.textFieldTitle,
                                              attribute: .trailing,
                                              multiplier: 1.0,
                                              constant: 24.0))
    }
    
    private func setupTextFieldDescription(constraints: inout [NSLayoutConstraint]) {
        self.textFieldDescription.translatesAutoresizingMaskIntoConstraints = false
        self.textFieldDescription.lineBreakMode = .byWordWrapping
        self.textFieldDescription.isBordered = false
        self.textFieldDescription.isBezeled = false
        self.textFieldDescription.drawsBackground = false
        self.textFieldDescription.isEditable = false
        self.textFieldDescription.isSelectable = false
        self.textFieldDescription.textColor = NSColor.labelColor
        self.textFieldDescription.preferredMaxLayoutWidth = editorTableViewColumnPayloadWidth
        self.textFieldDescription.alignment = .left
        self.textFieldDescription.stringValue = "Description"
        self.textFieldDescription.font = NSFont.systemFont(ofSize: 17, weight: NSFont.Weight.ultraLight)
        
        // ---------------------------------------------------------------------
        //  Add TextField to TableCellView
        // ---------------------------------------------------------------------
        self.headerView.addSubview(self.textFieldDescription)
        
        // ---------------------------------------------------------------------
        //  Add constraints
        // ---------------------------------------------------------------------
        // Top
        constraints.append(NSLayoutConstraint(item: self.textFieldDescription,
                                              attribute: .top,
                                              relatedBy: .equal,
                                              toItem: self.textFieldTitle,
                                              attribute: .bottom,
                                              multiplier: 1.0,
                                              constant: self.textFieldDescriptionTopIndent))
        
        // Leading
        constraints.append(NSLayoutConstraint(item: self.textFieldDescription,
                                              attribute: .leading,
                                              relatedBy: .equal,
                                              toItem: self.headerView,
                                              attribute: .leading,
                                              multiplier: 1.0,
                                              constant: 24.0))
        
        // Trailing
        constraints.append(NSLayoutConstraint(item: self.headerView,
                                              attribute: .trailing,
                                              relatedBy: .equal,
                                              toItem: self.textFieldDescription,
                                              attribute: .trailing,
                                              multiplier: 1.0,
                                              constant: 24.0))
        
        //self.updateHeight(description.intrinsicContentSize.height)
    }
}
