//
//  MainWindowController.swift
//  ProfileCreator
//
//  Created by Erik Berglund on 2017-07-07.
//  Copyright © 2017 Erik Berglund. All rights reserved.
//

import Cocoa

struct MainWindowToolbarIdentifier {
    static let add = "Add"
    static let export = "Export"
}

class MainWindowController: NSWindowController {
    
    // MARK: -
    // MARK: Variables
    
    let toolbar = NSToolbar(identifier: "MainWindowToolbar")
    let toolbarItemIdentifiers = [MainWindowToolbarIdentifier.add,
                                  MainWindowToolbarIdentifier.export,
                                  NSToolbarFlexibleSpaceItemIdentifier]
    
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
        window.identifier = "ProfileCreatorMainWindow-ID"
        window.setFrameAutosaveName("ProfileCreatorMainWindow-AS")
        window.contentMinSize = NSSize.init(width: 600, height: 400)
        window.center()
        
        // ---------------------------------------------------------------------
        //  Setup splitview
        // ---------------------------------------------------------------------
        // TODO: Add SplitView
        
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
        if identifier == MainWindowToolbarIdentifier.add {
            if self.toolbarItemAdd == nil {
                self.toolbarItemAdd = MainWindowToolbarItemAdd()
            }
            
            if let toolbarView = self.toolbarItemAdd {
                return toolbarView.toolbarItem
            }
        } else if identifier == MainWindowToolbarIdentifier.export {
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
