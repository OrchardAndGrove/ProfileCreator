//
//  ProfileEditor.swift
//  ProfileCreator
//
//  Created by Erik Berglund on 2017-07-21.
//  Copyright © 2017 Erik Berglund. All rights reserved.
//

import Cocoa

public class ProfileEditorController: NSWindowController {

    // MARK: -
    // MARK: Variables
    
    let splitView = ProfileEditorSplitView(frame: NSZeroRect)
    
    let profile: Profile
    let toolbar = NSToolbar(identifier: "MainWindowToolbar")
    let toolbarItemIdentifiers = [NSToolbarFlexibleSpaceItemIdentifier,
                                  ToolbarIdentifier.profileEditorTitle,
                                  NSToolbarFlexibleSpaceItemIdentifier]
    var toolbarItemTitle: ProfileEditorToolbarItemTitle?
    
    // MARK: -
    // MARK: Initialization
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init(profile: Profile) {
        
        self.profile = profile
        
        // ---------------------------------------------------------------------
        //  Setup editor window
        // ---------------------------------------------------------------------
        let rect = NSRect(x: 0, y: 0, width: 801, height: 700) // 801 because if 800 the text appears blurry when first loaded
        let styleMask = NSWindowStyleMask(rawValue: (
            NSWindowStyleMask.fullSizeContentView.rawValue |
                NSWindowStyleMask.titled.rawValue |
                NSWindowStyleMask.unifiedTitleAndToolbar.rawValue |
                NSWindowStyleMask.closable.rawValue |
                NSWindowStyleMask.miniaturizable.rawValue |
                NSWindowStyleMask.resizable.rawValue
        ))
        let window = NSWindow(contentRect: rect, styleMask: styleMask, backing: NSBackingStoreType.buffered, defer: false)
        window.titleVisibility = .hidden
        window.isReleasedWhenClosed = false
        window.isRestorable = true
        window.identifier = "ProfileCreatorEditorWindow-\(profile.identifier.uuidString)"
        window.contentMinSize = NSSize.init(width: 600, height: 400)
        window.backgroundColor = NSColor.white
        window.autorecalculatesKeyViewLoop = true
        // window.delegate = self
        window.center()
        
        // ---------------------------------------------------------------------
        //  Add splitview as window content view
        // ---------------------------------------------------------------------
        window.contentView = self.splitView
        
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
        self.toolbar.displayMode = .iconOnly
        self.toolbar.delegate = self
        
        // ---------------------------------------------------------------------
        // Add toolbar to window
        // ---------------------------------------------------------------------
        self.window?.toolbar = self.toolbar
    }
    
    deinit {
        
        // ---------------------------------------------------------------------
        //  Deregister as toolbar delegate
        // ---------------------------------------------------------------------
        self.toolbar.delegate = nil
    }
}

// MARK: -
// MARK: NSToolbarDelegate

extension ProfileEditorController: NSToolbarDelegate {
    
    public func toolbarAllowedItemIdentifiers(_ toolbar: NSToolbar) -> [String] {
        return self.toolbarItemIdentifiers
    }
    
    public func toolbarDefaultItemIdentifiers(_ toolbar: NSToolbar) -> [String] {
        return self.toolbarItemIdentifiers
    }
    
    public func toolbar(_ toolbar: NSToolbar, itemForItemIdentifier itemIdentifier: String, willBeInsertedIntoToolbar flag: Bool) -> NSToolbarItem? {
        if let toolbarItem = toolbarItem(identifier: itemIdentifier) {
            return toolbarItem
        }
        return nil
    }
    
    func toolbarItem(identifier: String) -> NSToolbarItem? {
        if identifier == ToolbarIdentifier.profileEditorTitle {
            if self.toolbarItemTitle == nil {
                self.toolbarItemTitle = ProfileEditorToolbarItemTitle(profile: self.profile)
            }
            
            if let toolbarView = self.toolbarItemTitle {
                return toolbarView.toolbarItem
            }
        }
        return nil
    }
}
