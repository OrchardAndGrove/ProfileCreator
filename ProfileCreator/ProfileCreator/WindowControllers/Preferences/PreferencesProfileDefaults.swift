//
//  PreferencesViewProfileDefaults.swift
//  ProfileCreator
//
//  Created by Erik Berglund on 2017-07-16.
//  Copyright © 2017 Erik Berglund. All rights reserved.
//

import Cocoa

class PreferencesProfileDefaults: NSView {
    
    // MARK: -
    // MARK: Variables
    
    let toolbarItem: NSToolbarItem
    
    // MARK: -
    // MARK: Initialization
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init(sender: PreferencesWindowController) {
        
        // ---------------------------------------------------------------------
        //  Create the actual toolbar item
        // ---------------------------------------------------------------------
        self.toolbarItem = NSToolbarItem(itemIdentifier: ToolbarIdentifier.preferencesWindowProfileDefaults)
        self.toolbarItem.image = NSImage(named: NSImageNameHomeTemplate)
        self.toolbarItem.label = NSLocalizedString("Profile Defaults", comment: "")
        self.toolbarItem.paletteLabel = self.toolbarItem.label
        self.toolbarItem.toolTip = self.toolbarItem.label
        self.toolbarItem.target = sender
        self.toolbarItem.action = #selector(sender.toolbarItemSelected(_:))
        
        // ---------------------------------------------------------------------
        //  Initialize self after the class variables have been instantiated
        // ---------------------------------------------------------------------
        super.init(frame: NSZeroRect)
    }
}
