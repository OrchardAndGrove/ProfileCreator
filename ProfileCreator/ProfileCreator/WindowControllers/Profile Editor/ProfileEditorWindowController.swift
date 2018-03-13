//
//  ProfileEditor.swift
//  ProfileCreator
//
//  Created by Erik Berglund on 2017-07-21.
//  Copyright © 2017 Erik Berglund. All rights reserved.
//

import Cocoa

public class ProfileEditorWindowController: NSWindowController {
    
    // MARK: -
    // MARK: Static Variables
    
    let profile: Profile
    let splitView: ProfileEditorSplitView
    let toolbar = NSToolbar(identifier: NSToolbar.Identifier(rawValue: "MainWindowToolbar"))
    let toolbarItemIdentifiers: [NSToolbarItem.Identifier] = [.editorSettings,
                                                              NSToolbarItem.Identifier.flexibleSpace,
                                                              .editorTitle,
                                                              NSToolbarItem.Identifier.flexibleSpace,
                                                              .editorView]
    
    // MARK: -
    // MARK: Variables
    
    var toolbarItemTitle: ProfileEditorWindowToolbarItemTitle?
    var toolbarItemSettings: ProfileEditorWindowToolbarItemSettings?
    var toolbarItemView: ProfileEditorWindowToolbarItemView?
    var windowShouldClose = false
    
    // MARK: -
    // MARK: Initialization
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init(profile: Profile) {
        
        // ---------------------------------------------------------------------
        //  Setup Variables
        // ---------------------------------------------------------------------
        self.profile = profile
        self.splitView = ProfileEditorSplitView(profile: profile)
        
        // ---------------------------------------------------------------------
        //  Setup editor window
        // ---------------------------------------------------------------------
        let rect = NSRect(x: 0, y: 0, width: 801, height: 700) // 801 because if 800 the text appears blurry when first loaded
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
        window.identifier = NSUserInterfaceItemIdentifier(rawValue: "ProfileCreatorEditorWindow-\(profile.identifier.uuidString)")
        window.contentMinSize = NSSize(width: 600, height: 400)
        window.backgroundColor = .white
        window.autorecalculatesKeyViewLoop = false
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
        //  Set the window delegate to self
        // ---------------------------------------------------------------------
        self.window?.delegate = self
        
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
        
        // ---------------------------------------------------------------------
        // Update the Key View Loop and set first responder
        // ---------------------------------------------------------------------
        self.splitView.editor?.updateKeyViewLoop(window: self.window!)
        
        // ---------------------------------------------------------------------
        // Set the initial position of the library SplitView
        // NOTE: This has to be called twice, probably because of using AutoLayout.
        // ---------------------------------------------------------------------
        self.splitView.librarySplitView?.setPosition(250.0, ofDividerAt: 0)
        self.splitView.librarySplitView?.setPosition(250.0, ofDividerAt: 0)
        
        // ---------------------------------------------------------------------
        // Set the initial position of the main SplitView
        // ---------------------------------------------------------------------
        self.splitView.setPosition(190.0, ofDividerAt: 0)
    }
    
    deinit {
        
        // ---------------------------------------------------------------------
        //  Deregister as toolbar delegate
        // ---------------------------------------------------------------------
        self.toolbar.delegate = nil
    }
    
    func setTitle(string: String) {
        if let toolbarItemTitle = self.toolbarItemTitle {
            toolbarItemTitle.selectionTitle = string
            toolbarItemTitle.updateTitle()
        }
    }
}

// MARK: -
// MARK: NSWindowDelegate

extension ProfileEditorWindowController: NSWindowDelegate {
    
    public func windowShouldClose(_ sender: NSWindow) -> Bool {
        if self.windowShouldClose {
            return true
        } else if self.profile.title != StringConstant.defaultProfileName && self.profile.isSaved() {
            return true
        } else {
            self.profile.showAlertUnsaved(closeWindow: true)
        }
        return false
    }
    
    @objc func windowClose() {
        self.window?.close()
    }
    
}


// MARK: -
// MARK: NSToolbarDelegate

extension ProfileEditorWindowController: NSToolbarDelegate {
    
    public func toolbarAllowedItemIdentifiers(_ toolbar: NSToolbar) -> [NSToolbarItem.Identifier] {
        return self.toolbarItemIdentifiers
    }
    
    public func toolbarDefaultItemIdentifiers(_ toolbar: NSToolbar) -> [NSToolbarItem.Identifier] {
        return self.toolbarItemIdentifiers
    }
    
    public func toolbar(_ toolbar: NSToolbar, itemForItemIdentifier itemIdentifier: NSToolbarItem.Identifier, willBeInsertedIntoToolbar flag: Bool) -> NSToolbarItem? {
        if let toolbarItem = toolbarItem(identifier: itemIdentifier) {
            return toolbarItem
        }
        return nil
    }
    
    func toolbarItem(identifier: NSToolbarItem.Identifier) -> NSToolbarItem? {
        switch identifier {
        case .editorTitle:
            if self.toolbarItemTitle == nil {
                self.toolbarItemTitle = ProfileEditorWindowToolbarItemTitle(profile: self.profile)
            }
            
            if let toolbarView = self.toolbarItemTitle {
                return toolbarView.toolbarItem
            }
        case .editorSettings:
            if self.toolbarItemSettings == nil, let profileEditor = self.splitView.editor {
                self.toolbarItemSettings = ProfileEditorWindowToolbarItemSettings(profile: self.profile, profileEditorSettings: profileEditor.settings)
            }
            
            if let toolbarView = self.toolbarItemSettings {
                return toolbarView.toolbarItem
            }
        case .editorView:
            if self.toolbarItemView == nil, let profileEditor = self.splitView.editor {
                self.toolbarItemView = ProfileEditorWindowToolbarItemView(profile: self.profile, profileEditor: profileEditor)
            }
            
            if let toolbarView = self.toolbarItemView {
                return toolbarView.toolbarItem
            }
        default:
            Swift.print("Unknown Toolbar Identifier: \(identifier)")
        }
        return nil
    }
}
