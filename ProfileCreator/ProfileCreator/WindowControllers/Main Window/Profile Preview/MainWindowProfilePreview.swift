//
//  MainWindowProfilePreview.swift
//  ProfileCreator
//
//  Created by Erik Berglund on 2017-07-09.
//  Copyright © 2017 Erik Berglund. All rights reserved.
//

import Cocoa

class MainWindowProfilePreviewController: NSObject {

    // MARK: -
    // MARK: Variables
    
    let view = NSVisualEffectView()
    let infoViewController = MainWindowProfilePreviewInfoViewController()
    let previewViewController = MainWindowProfilePreviewViewController()
    
    // MARK: -
    // MARK: Initialization
    
    override init() {
        super.init()
        
        // ---------------------------------------------------------------------
        //  Setup Variables
        // ---------------------------------------------------------------------
        var constraints = [NSLayoutConstraint]()
        
        // ---------------------------------------------------------------------
        //  Setup Effect View (Background)
        // ---------------------------------------------------------------------
        self.view.translatesAutoresizingMaskIntoConstraints = false
        self.view.material = .light
        
        // ---------------------------------------------------------------------
        //  Setup Info View
        // ---------------------------------------------------------------------
        setupInfoView(constraints: &constraints)
        
        // ---------------------------------------------------------------------
        //  Activate Layout Constraints
        // ---------------------------------------------------------------------
        NSLayoutConstraint.activate(constraints)
    }
    
    // MARK: -
    // MARK: Setup Layout Constraints
    
    private func setupInfoView(constraints: inout [NSLayoutConstraint]) {
        
        // ---------------------------------------------------------------------
        //  Add subview to main view
        // ---------------------------------------------------------------------
        self.view.addSubview(self.infoViewController.view)
        
        // ---------------------------------------------------------------------
        //  Add constraints
        // ---------------------------------------------------------------------
        
        // Top
        constraints.append(NSLayoutConstraint(item: self.view,
                                              attribute: .top,
                                              relatedBy: .equal,
                                              toItem: self.infoViewController.view,
                                              attribute: .top,
                                              multiplier: 1,
                                              constant: 0))
        
        // Bottom
        constraints.append(NSLayoutConstraint(item: self.view,
                                              attribute: .bottom,
                                              relatedBy: .equal,
                                              toItem: self.infoViewController.view,
                                              attribute: .bottom,
                                              multiplier: 1,
                                              constant: 0))
        
        // Leading
        constraints.append(NSLayoutConstraint(item: self.view,
                                              attribute: .leading,
                                              relatedBy: .equal,
                                              toItem: self.infoViewController.view,
                                              attribute: .leading,
                                              multiplier: 1,
                                              constant: 0))
        
        // Trailing
        constraints.append(NSLayoutConstraint(item: self.view,
                                              attribute: .trailing,
                                              relatedBy: .equal,
                                              toItem: self.infoViewController.view,
                                              attribute: .trailing,
                                              multiplier: 1,
                                              constant: 0))
    }
}

class MainWindowProfilePreviewViewController: NSObject {

}

class MainWindowProfilePreviewInfoViewController: NSObject {
    
    // MARK: -
    // MARK: Variables
    
    let view = NSView()
    let textField = NSTextField()
    
    // MARK: -
    // MARK: Initialization
    
    override init() {
        super.init()
        
        // ---------------------------------------------------------------------
        //  Setup Variables
        // ---------------------------------------------------------------------
        var constraints = [NSLayoutConstraint]()
        
        // ---------------------------------------------------------------------
        //  Setup View
        // ---------------------------------------------------------------------
        self.view.translatesAutoresizingMaskIntoConstraints = false
        
        // ---------------------------------------------------------------------
        //  Create and add TextField
        // ---------------------------------------------------------------------
        self.textField.translatesAutoresizingMaskIntoConstraints = false
        self.textField.lineBreakMode = .byWordWrapping
        self.textField.isBordered = false
        self.textField.isBezeled = false
        self.textField.drawsBackground = false
        self.textField.isEditable = false
        self.textField.font = NSFont.systemFont(ofSize: 19)
        self.textField.textColor = NSColor.tertiaryLabelColor
        self.textField.alignment = .center
        setupTextField(constraints: &constraints)
        
        // ---------------------------------------------------------------------
        //  Activate Layout Constraints
        // ---------------------------------------------------------------------
        NSLayoutConstraint.activate(constraints)
        
        // ---------------------------------------------------------------------
        //  Set initial state to no profile selected
        // ---------------------------------------------------------------------
        updateSelection(count: 0)
    }
    
    // MARK: -
    // MARK: Public Functions
    
    public func updateSelection(count: Int) {
        switch count {
        case 0:
            self.textField.stringValue = NSLocalizedString("No Profile Selected", comment: "")
            break
        case 1:
            self.textField.stringValue = NSLocalizedString("\(count) Profile Selected", comment: "")
            break
        default:
            self.textField.stringValue = NSLocalizedString("\(count) Profiles Selected", comment: "")
            break
        }
    }
    
    // MARK: -
    // MARK: Setup Layout Constraints
    
    private func setupTextField(constraints: inout [NSLayoutConstraint]) {
        
        // ---------------------------------------------------------------------
        //  Add subview to main view
        // ---------------------------------------------------------------------
        self.view.addSubview(textField)
        
        // ---------------------------------------------------------------------
        //  Add constraints
        // ---------------------------------------------------------------------
        
        // Center Vertically
        constraints.append(NSLayoutConstraint(item: textField,
                                              attribute: .centerY,
                                              relatedBy: .equal,
                                              toItem: self.view,
                                              attribute: .centerY,
                                              multiplier: 1,
                                              constant: 0))
        
        // Leading
        constraints.append(NSLayoutConstraint(item: textField,
                                              attribute: .leading,
                                              relatedBy: .equal,
                                              toItem: self.view,
                                              attribute: .leading,
                                              multiplier: 1,
                                              constant: 0))
        
        // Trailing
        constraints.append(NSLayoutConstraint(item: textField,
                                              attribute: .trailing,
                                              relatedBy: .equal,
                                              toItem: self.view,
                                              attribute: .trailing,
                                              multiplier: 1,
                                              constant: 0))
    }
}
