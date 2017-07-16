//
//  Preferences.swift
//  ProfileCreator
//
//  Created by Erik Berglund on 2017-07-15.
//  Copyright © 2017 Erik Berglund. All rights reserved.
//

import Cocoa

class PreferencesWindowController: NSWindowController {
    
    // MARK: -
    // MARK: Variables
    
    private let windowWidth = 450
    
    let toolbar = NSToolbar(identifier: "PreferencesWindowToolbar")
    let toolbarItemIdentifiers = [ToolbarIdentifier.preferencesWindowGeneral,
                                  ToolbarIdentifier.preferencesWindowProfileDefaults,
                                  NSToolbarFlexibleSpaceItemIdentifier]
    var preferencesGeneral: PreferencesGeneral?
    var preferencesProfileDefaults: PreferencesProfileDefaults?
    
    // MARK: -
    // MARK: Initialization
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init() {
        
        // ---------------------------------------------------------------------
        //  Setup preferences window
        // ---------------------------------------------------------------------
        let rect = NSRect(x: 0, y: 0, width: windowWidth, height: 200)
        let styleMask = NSWindowStyleMask(rawValue: (
                NSWindowStyleMask.titled.rawValue |
                NSWindowStyleMask.closable.rawValue |
                NSWindowStyleMask.miniaturizable.rawValue
        ))
        let window = NSWindow(contentRect: rect, styleMask: styleMask, backing: NSBackingStoreType.buffered, defer: false)
        window.isReleasedWhenClosed = false
        window.isRestorable = true
        window.center()
        
        // ---------------------------------------------------------------------
        //  Initialize self after the class variables have been instantiated
        // ---------------------------------------------------------------------
        super.init(window: window)
        
        // ---------------------------------------------------------------------
        //  Setup toolbar
        // ---------------------------------------------------------------------
        self.toolbar.isVisible = true
        self.toolbar.showsBaselineSeparator = true
        self.toolbar.allowsUserCustomization = false
        self.toolbar.autosavesConfiguration = false
        self.toolbar.sizeMode = .regular
        self.toolbar.displayMode = .iconAndLabel
        self.toolbar.delegate = self
        
        // ---------------------------------------------------------------------
        // Add toolbar to window
        // ---------------------------------------------------------------------
        self.window?.toolbar = self.toolbar
    }
    
    public func toolbarItemSelected(_ toolbarItem: NSToolbarItem) {
        Swift.print("toolbarItemSelected: \(toolbarItem)")
    }
}

// MARK: -
// MARK: NSToolbarDelegate

extension PreferencesWindowController: NSToolbarDelegate {
    
    func toolbarAllowedItemIdentifiers(_ toolbar: NSToolbar) -> [String] {
        return self.toolbarItemIdentifiers
    }
    
    func toolbarDefaultItemIdentifiers(_ toolbar: NSToolbar) -> [String] {
        return self.toolbarItemIdentifiers
    }
    
    func toolbar(_ toolbar: NSToolbar, itemForItemIdentifier itemIdentifier: String, willBeInsertedIntoToolbar flag: Bool) -> NSToolbarItem? {
        if let toolbarItem = toolbarItem(identifier: itemIdentifier) {
            return toolbarItem
        }
        return nil
    }
    
    func toolbarItem(identifier: String) -> NSToolbarItem? {
        if identifier == ToolbarIdentifier.preferencesWindowGeneral {
            if self.preferencesGeneral == nil { self.preferencesGeneral = PreferencesGeneral(sender: self) }
            return self.preferencesGeneral?.toolbarItem
            
        } else if identifier == ToolbarIdentifier.preferencesWindowProfileDefaults {
            if self.preferencesProfileDefaults == nil { self.preferencesProfileDefaults = PreferencesProfileDefaults(sender: self) }
            return self.preferencesProfileDefaults?.toolbarItem
        }
        return nil
    }
}
