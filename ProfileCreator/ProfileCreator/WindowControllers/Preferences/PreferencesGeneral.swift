//
//  PreferencesToolbarItemGeneral.swift
//  ProfileCreator
//
//  Created by Erik Berglund on 2017-07-16.
//  Copyright © 2017 Erik Berglund. All rights reserved.
//

import Cocoa

class PreferencesGeneral: PreferencesItem {
    
    // MARK: -
    // MARK: Variables
    
    let identifier: NSToolbarItem.Identifier = .preferencesGeneral
    let toolbarItem: NSToolbarItem
    let view: NSView
    
    // MARK: -
    // MARK: Initialization
    
    init(sender: PreferencesWindowController) {
        
        // ---------------------------------------------------------------------
        //  Create the toolbar item
        // ---------------------------------------------------------------------
        self.toolbarItem = NSToolbarItem(itemIdentifier: identifier)
        self.toolbarItem.image = NSImage(named: NSImage.Name.preferencesGeneral)
        self.toolbarItem.label = NSLocalizedString("General", comment: "")
        self.toolbarItem.paletteLabel = self.toolbarItem.label
        self.toolbarItem.toolTip = self.toolbarItem.label
        self.toolbarItem.target = sender
        self.toolbarItem.action = #selector(sender.toolbarItemSelected(_:))
        
        // ---------------------------------------------------------------------
        //  Create the preferences view
        // ---------------------------------------------------------------------
        self.view = PreferencesGeneralView()
    }
}

class PreferencesGeneralView: NSView {
    
    // MARK: -
    // MARK: Initialization
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init() {
        super.init(frame: NSZeroRect)
        
        self.translatesAutoresizingMaskIntoConstraints = false
        
        // ---------------------------------------------------------------------
        //  Setup Variables
        // ---------------------------------------------------------------------
        var constraints = [NSLayoutConstraint]()
        var frameHeight: CGFloat = 0.0
        var lastSubview: NSView?
        
        // ---------------------------------------------------------------------
        //  Add Preferences "Sidebar"
        // ---------------------------------------------------------------------
        lastSubview = addHeader(title: "Sidebar",
                                withSeparator: true,
                                toView: self,
                                lastSubview: nil,
                                height: &frameHeight,
                                constraints: &constraints)
        
        lastSubview = addCheckbox(title: "Show Profile Count",
                                  keyPath: PreferenceKey.showProfileCount,
                                  toView: self,
                                  lastSubview: lastSubview,
                                  height: &frameHeight,
                                  constraints: &constraints)
        
        lastSubview = addCheckbox(title: "Show Group Icons",
                                  keyPath: PreferenceKey.showGroupIcons,
                                  toView: self,
                                  lastSubview: lastSubview,
                                  height: &frameHeight,
                                  constraints: &constraints)
        
        // ---------------------------------------------------------------------
        //  Add Preferences "Logging"
        // ---------------------------------------------------------------------
        
        lastSubview = addHeader(title: "Logging",
                                withSeparator: true,
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
        self.frame = NSRect.init(x: 0.0, y: 0.0, width: preferencesWindowWidth, height: frameHeight)
    }
}
