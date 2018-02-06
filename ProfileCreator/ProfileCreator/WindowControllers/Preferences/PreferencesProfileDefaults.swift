//
//  PreferencesViewProfileDefaults.swift
//  ProfileCreator
//
//  Created by Erik Berglund on 2017-07-16.
//  Copyright © 2017 Erik Berglund. All rights reserved.
//

import Cocoa

class PreferencesProfileDefaults: PreferencesItem {
    
    // MARK: -
    // MARK: Variables
    
    let identifier: NSToolbarItem.Identifier = .preferencesProfileDefaults
    let toolbarItem: NSToolbarItem
    let view: NSView
    
    // MARK: -
    // MARK: Initialization
    
    init(sender: PreferencesWindowController) {
        
        // ---------------------------------------------------------------------
        //  Create the toolbar item
        // ---------------------------------------------------------------------
        self.toolbarItem = NSToolbarItem(itemIdentifier: identifier)
        self.toolbarItem.image = NSImage(named: NSImage.Name.homeTemplate)
        self.toolbarItem.label = NSLocalizedString("Profile Defaults", comment: "")
        self.toolbarItem.paletteLabel = self.toolbarItem.label
        self.toolbarItem.toolTip = self.toolbarItem.label
        self.toolbarItem.target = sender
        self.toolbarItem.action = #selector(sender.toolbarItemSelected(_:))
        
        // ---------------------------------------------------------------------
        //  Create the preferences view
        // ---------------------------------------------------------------------
        self.view = PreferencesProfileDefaultsView()
    }
}

class PreferencesProfileDefaultsView: NSView {
    
    // MARK: -
    // MARK: Initialization
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init() {
        super.init(frame: NSZeroRect)
        
        // ---------------------------------------------------------------------
        //  Setup Variables
        // ---------------------------------------------------------------------
        var constraints = [NSLayoutConstraint]()
        var frameHeight: CGFloat = 0.0
        var lastSubview: NSView?
        
        // ---------------------------------------------------------------------
        //  Add Preferences "Default Profile Settings"
        // ---------------------------------------------------------------------
        lastSubview = addHeader(title: "Default Profile Settings",
                                withSeparator: true,
                                toView: self,
                                lastSubview: nil,
                                height: &frameHeight,
                                constraints: &constraints)
        
        lastSubview = addTextField(placeholderValue: "Pretendco",
                                   keyPath: PreferenceKey.defaultOrganization,
                                   toView: self,
                                   lastSubview: lastSubview,
                                   height: &frameHeight,
                                   constraints: &constraints)
        
        lastSubview = addTextField(placeholderValue: "com.pretendco",
                                   keyPath: PreferenceKey.defaultOrganizationIdentifier,
                                   toView: self,
                                   lastSubview: lastSubview,
                                   height: &frameHeight,
                                   constraints: &constraints)
        
        // ---------------------------------------------------------------------
        //  Add constraints to last view
        // ---------------------------------------------------------------------
        
        // Bottom
        constraints.append(NSLayoutConstraint(
            item: self,
            attribute: .bottom,
            relatedBy: .equal,
            toItem: lastSubview,
            attribute: .bottom,
            multiplier: 1,
            constant: 20))
        
        frameHeight = frameHeight + 20.0
        
        // ---------------------------------------------------------------------
        //  Activate Layout Constraints
        // ---------------------------------------------------------------------
        NSLayoutConstraint.activate(constraints)
        
        // ---------------------------------------------------------------------
        //  Set the view frame for use when switching between preference views
        // ---------------------------------------------------------------------
        self.frame = NSRect(x: 0.0, y: 0.0, width: preferencesWindowWidth, height: frameHeight)
    }
    
}
