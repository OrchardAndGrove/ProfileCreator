//
//  MainWindowController.swift
//  ProfileCreator
//
//  Created by Erik Berglund on 2017-07-07.
//  Copyright © 2017 Erik Berglund. All rights reserved.
//

import Cocoa

class MainWindowController: NSWindowController {
    
    // MARK: -
    // MARK: Variables
    
    let splitView = MainWindowSplitView(frame: NSZeroRect)
    
    let toolbar = NSToolbar(identifier: NSToolbar.Identifier(rawValue: "MainWindowToolbar"))
    let toolbarItemIdentifiers: [NSToolbarItem.Identifier] = [.mainWindowAdd,
                                                              .mainWindowExport,
                                                              NSToolbarItem.Identifier.flexibleSpace]
    var toolbarItemAdd: MainWindowToolbarItemAdd?
    var toolbarItemExport: MainWindowToolbarItemExport?
    
    // MARK: -
    // MARK: Initialization
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init() {
        
        // ---------------------------------------------------------------------
        //  Setup main window
        // ---------------------------------------------------------------------
        let rect = NSRect(x: 0, y: 0, width: 750, height: 550)
        let styleMask = NSWindow.StyleMask(rawValue: (
            NSWindow.StyleMask.fullSizeContentView.rawValue |
                NSWindow.StyleMask.titled.rawValue |
                NSWindow.StyleMask.unifiedTitleAndToolbar.rawValue |
                NSWindow.StyleMask.closable.rawValue |
                NSWindow.StyleMask.miniaturizable.rawValue |
                NSWindow.StyleMask.resizable.rawValue
        ))
        let window = NSWindow(contentRect: rect, styleMask: styleMask, backing: NSWindow.BackingStoreType.buffered, defer: false)
        window.titleVisibility = .hidden
        window.isReleasedWhenClosed = false
        window.isRestorable = true
        window.identifier = NSUserInterfaceItemIdentifier(rawValue: "ProfileCreatorMainWindow-ID")
        window.setFrameAutosaveName(NSWindow.FrameAutosaveName(rawValue: "ProfileCreatorMainWindow-AS"))
        window.contentMinSize = NSSize.init(width: 600, height: 400)
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
}

// MARK: -
// MARK: NSToolbarDelegate

extension MainWindowController: NSToolbarDelegate {
    
    func toolbarAllowedItemIdentifiers(_ toolbar: NSToolbar) -> [NSToolbarItem.Identifier] {
        return self.toolbarItemIdentifiers
    }
    
    func toolbarDefaultItemIdentifiers(_ toolbar: NSToolbar) -> [NSToolbarItem.Identifier] {
        return self.toolbarItemIdentifiers
    }
    
    func toolbar(_ toolbar: NSToolbar, itemForItemIdentifier itemIdentifier: NSToolbarItem.Identifier, willBeInsertedIntoToolbar flag: Bool) -> NSToolbarItem? {
        if let toolbarItem = toolbarItem(identifier: itemIdentifier) {
            return toolbarItem
        }
        return nil
    }
    
    func toolbarItem(identifier: NSToolbarItem.Identifier) -> NSToolbarItem? {
        if identifier == .mainWindowAdd {
            if self.toolbarItemAdd == nil {
                self.toolbarItemAdd = MainWindowToolbarItemAdd()
            }
            
            if let toolbarView = self.toolbarItemAdd {
                return toolbarView.toolbarItem
            }
        } else if identifier == .mainWindowExport {
            if self.toolbarItemExport == nil {
                self.toolbarItemExport = MainWindowToolbarItemExport()
            }
            
            if let toolbarView = self.toolbarItemExport {
                return toolbarView.toolbarItem
            }
        }
        return nil
    }
}
