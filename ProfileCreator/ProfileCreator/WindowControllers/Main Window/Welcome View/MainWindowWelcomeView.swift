//
//  MainWindowWelcomeView.swift
//  ProfileCreator
//
//  Created by Erik Berglund on 2017-07-09.
//  Copyright © 2018 Erik Berglund. All rights reserved.
//

import Cocoa

class MainWindowWelcomeViewController: NSObject {
    
    // MARK: -
    // MARK: Variables
    
    let view = ViewWhite(acceptsFirstResponder: false)
    let textFieldTitle = NSTextField()
    let textFieldInfo = NSTextField()
    let button = NSButton()
    
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
        //  Create and add TextField Title
        // ---------------------------------------------------------------------
        self.textFieldTitle.translatesAutoresizingMaskIntoConstraints = false
        self.textFieldTitle.lineBreakMode = .byWordWrapping
        self.textFieldTitle.isBordered = false
        self.textFieldTitle.isBezeled = false
        self.textFieldTitle.drawsBackground = false
        self.textFieldTitle.isEditable = false
        self.textFieldTitle.isSelectable = false
        self.textFieldTitle.stringValue = NSLocalizedString("Welcome to ProfileCreator", comment: "")
        self.textFieldTitle.textColor = .labelColor
        self.textFieldTitle.font = NSFont.boldSystemFont(ofSize: 28)
        self.textFieldTitle.alignment = .center
        setupTextFieldTitle(constraints: &constraints)
        
        // ---------------------------------------------------------------------
        //  Create and add TextField Information
        // ---------------------------------------------------------------------
        self.textFieldInfo.translatesAutoresizingMaskIntoConstraints = false
        self.textFieldInfo.lineBreakMode = .byWordWrapping
        self.textFieldInfo.isBordered = false
        self.textFieldInfo.isBezeled = false
        self.textFieldInfo.drawsBackground = false
        self.textFieldInfo.isEditable = false
        self.textFieldInfo.isSelectable = false
        self.textFieldInfo.stringValue = NSLocalizedString("To create your first profile, click the ", comment: "")
        self.textFieldInfo.textColor = .secondaryLabelColor
        self.textFieldInfo.font = NSFont.systemFont(ofSize: 16)
        self.textFieldInfo.alignment = .center
        setupTextFieldInfo(constraints: &constraints)
        
        // ---------------------------------------------------------------------
        //  Create and add Button "+"
        // ---------------------------------------------------------------------
        self.button.translatesAutoresizingMaskIntoConstraints = false
        self.button.bezelStyle = .texturedRounded
        self.button.image = NSImage(named: .addTemplate)
        self.button.target = self
        self.button.action = #selector(clicked(button:))
        self.button.imageScaling = .scaleProportionallyDown
        self.button.imagePosition = .imageOnly
        setupButton(constraints: &constraints)
        
        // ---------------------------------------------------------------------
        //  Activate Layout Constraints
        // ---------------------------------------------------------------------
        NSLayoutConstraint.activate(constraints)
    }
    
    // MARK: -
    // MARK: Button Actions
    
    @objc func clicked(button: NSButton) {
        NotificationCenter.default.post(name: .newProfile, object: self, userInfo: [NotificationKey.parentTitle : SidebarGroupTitle.library])
    }
    
    // MARK: -
    // MARK: Setup Layout Constraints
    
    private func setupTextFieldTitle(constraints: inout [NSLayoutConstraint]) {
        
        // ---------------------------------------------------------------------
        //  Add subview to main view
        // ---------------------------------------------------------------------
        self.view.addSubview(self.textFieldTitle)
        
        // ---------------------------------------------------------------------
        //  Add constraints
        // ---------------------------------------------------------------------
        
        // Center Horizontally
        constraints.append(NSLayoutConstraint(item: self.textFieldTitle,
                                              attribute: .centerX,
                                              relatedBy: .equal,
                                              toItem: self.view,
                                              attribute: .centerX,
                                              multiplier: 1,
                                              constant: 0))
        
        // Center Vertically
        constraints.append(NSLayoutConstraint(item: self.view,
                                              attribute: .centerY,
                                              relatedBy: .equal,
                                              toItem: self.textFieldTitle,
                                              attribute: .centerY,
                                              multiplier: 1,
                                              constant: 30))
    }
    
    private func setupTextFieldInfo(constraints: inout [NSLayoutConstraint]) {
        
        // ---------------------------------------------------------------------
        //  Add subview to main view
        // ---------------------------------------------------------------------
        self.view.addSubview(self.textFieldInfo)
        
        // ---------------------------------------------------------------------
        //  Add constraints
        // ---------------------------------------------------------------------
        
        // Top
        constraints.append(NSLayoutConstraint(item: self.textFieldInfo,
                                              attribute: .top,
                                              relatedBy: .equal,
                                              toItem: self.textFieldTitle,
                                              attribute: .bottom,
                                              multiplier: 1,
                                              constant: 13))
        
        // Center Horizontally
        constraints.append(NSLayoutConstraint(item: self.textFieldTitle,
                                              attribute: .centerX,
                                              relatedBy: .equal,
                                              toItem: self.textFieldInfo,
                                              attribute: .centerX,
                                              multiplier: 1,
                                              constant: 21))
    }
    
    private func setupButton(constraints: inout [NSLayoutConstraint]) {
        
        // ---------------------------------------------------------------------
        //  Add button to main view
        // ---------------------------------------------------------------------
        self.view.addSubview(self.button)
        
        // ---------------------------------------------------------------------
        //  Add constraints
        // ---------------------------------------------------------------------
        
        // Leading
        constraints.append(NSLayoutConstraint(item: self.button,
                                              attribute: .leading,
                                              relatedBy: .equal,
                                              toItem: self.textFieldInfo,
                                              attribute: .trailing,
                                              multiplier: 1,
                                              constant: 2))
        
        // Baseline
        constraints.append(NSLayoutConstraint(item: self.textFieldInfo,
                                              attribute: .centerY,
                                              relatedBy: .equal,
                                              toItem: self.button,
                                              attribute: .centerY,
                                              multiplier: 1,
                                              constant: 0))
        
        // Width
        constraints.append(NSLayoutConstraint(item: self.button,
                                              attribute: .width,
                                              relatedBy: .equal,
                                              toItem: nil,
                                              attribute: .notAnAttribute,
                                              multiplier: 1,
                                              constant: 40))
    }
}
