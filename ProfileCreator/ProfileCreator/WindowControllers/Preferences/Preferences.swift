//
//  Preferences.swift
//  ProfileCreator
//
//  Created by Erik Berglund on 2017-07-15.
//  Copyright © 2017 Erik Berglund. All rights reserved.
//

import Cocoa

protocol PreferencesItem {
    var identifier: NSToolbarItem.Identifier { get }
    var toolbarItem: NSToolbarItem { get }
    var view: NSView { get }
}

class PreferencesWindowController: NSWindowController {
    
    // MARK: -
    // MARK: Variables
    
    let toolbar = NSToolbar(identifier: NSToolbar.Identifier(rawValue: "PreferencesWindowToolbar"))
    let toolbarItemIdentifiers: [NSToolbarItem.Identifier] = [.preferencesGeneral,
                                                              .preferencesEditor,
                                                              .preferencesProfileDefaults,
                                                              NSToolbarItem.Identifier.flexibleSpace]
    var preferencesGeneral: PreferencesGeneral?
    var preferencesEditor: PreferencesEditor?
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
        let rect = NSRect(x: 0, y: 0, width: preferencesWindowWidth, height: 200)
        let styleMask = NSWindow.StyleMask(rawValue: (
            NSWindow.StyleMask.titled.rawValue |
                NSWindow.StyleMask.closable.rawValue |
                NSWindow.StyleMask.miniaturizable.rawValue
        ))
        let window = NSWindow(contentRect: rect, styleMask: styleMask, backing: NSWindow.BackingStoreType.buffered, defer: false)
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
        
        // ---------------------------------------------------------------------
        // Show "General" Preferences
        // ---------------------------------------------------------------------
        self.showPreferencesView(identifier: .preferencesGeneral)
    }
    
    // MARK: -
    // MARK: Public Functions
    
    @objc public func toolbarItemSelected(_ toolbarItem: NSToolbarItem) {
        self.showPreferencesView(identifier: toolbarItem.itemIdentifier)
    }
    
    // MARK: -
    // MARK: Private Functions
    
    private func showPreferencesView(identifier: NSToolbarItem.Identifier) {
        if let preferencesItem = preferencesItem(identifier: identifier) {
            
            // -----------------------------------------------------------------
            //  Update window title
            // -----------------------------------------------------------------
            // FIXME: Get title from a function
            self.window?.title = preferencesItem.identifier.rawValue
            
            // -----------------------------------------------------------------
            //  Remove current view and add the selected view, animating the transition
            // -----------------------------------------------------------------
            self.window?.contentView?.removeFromSuperview()
            
            var frame = self.window?.frame
            let oldView = self.window?.contentView?.frame
            let newView = preferencesItem.view.frame
            
            if let windowFrame = frame, let oldViewFrame = oldView {
                frame!.origin.y = windowFrame.origin.y + (oldViewFrame.size.height - newView.size.height)
                frame!.size.height = ((windowFrame.size.height - oldViewFrame.size.height) + newView.size.height)
                self.window?.setFrame(frame!, display: true, animate: true)
            }
            
            self.window?.contentView = preferencesItem.view
            
            // -----------------------------------------------------------------
            //  Add constraint to set window width
            // -----------------------------------------------------------------
            NSLayoutConstraint.activate([ NSLayoutConstraint(item: self.window?.contentView ?? preferencesItem.view,
                                                             attribute: .width,
                                                             relatedBy: .equal,
                                                             toItem: nil,
                                                             attribute: .notAnAttribute,
                                                             multiplier: 1.0,
                                                             constant: preferencesWindowWidth) ])
        }
    }
    
    fileprivate func preferencesItem(identifier: NSToolbarItem.Identifier) -> PreferencesItem? {
        if identifier == .preferencesGeneral {
            if self.preferencesGeneral == nil { self.preferencesGeneral = PreferencesGeneral(sender: self) }
            return self.preferencesGeneral
            
        } else if identifier == .preferencesEditor {
            if self.preferencesEditor == nil { self.preferencesEditor = PreferencesEditor(sender: self) }
            return self.preferencesEditor
            
        } else if identifier == .preferencesProfileDefaults {
            if self.preferencesProfileDefaults == nil { self.preferencesProfileDefaults = PreferencesProfileDefaults(sender: self) }
            return self.preferencesProfileDefaults
        }
        return nil
    }
}

// MARK: -
// MARK: NSToolbarDelegate

extension PreferencesWindowController: NSToolbarDelegate {
    
    func toolbarAllowedItemIdentifiers(_ toolbar: NSToolbar) -> [NSToolbarItem.Identifier] {
        return self.toolbarItemIdentifiers
    }
    
    func toolbarDefaultItemIdentifiers(_ toolbar: NSToolbar) -> [NSToolbarItem.Identifier] {
        return self.toolbarItemIdentifiers
    }
    
    func toolbar(_ toolbar: NSToolbar, itemForItemIdentifier itemIdentifier: NSToolbarItem.Identifier, willBeInsertedIntoToolbar flag: Bool) -> NSToolbarItem? {
        if let preferencesItem = preferencesItem(identifier: itemIdentifier) {
            return preferencesItem.toolbarItem
        }
        return nil
    }
}
