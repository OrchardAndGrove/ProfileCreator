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
                                                              NSToolbarItem.Identifier.flexibleSpace]
    
    // MARK: -
    // MARK: Variables
    
    var toolbarItemTitle: ProfileEditorWindowToolbarItemTitle?
    var toolbarItemSettings: ProfileEditorWindowToolbarItemSettings?
    var alert: Alert?
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
        window.contentMinSize = NSSize.init(width: 600, height: 400)
        window.backgroundColor = NSColor.white
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
        
        if windowShouldClose {
            Swift.print("Closing Window!")
            // Unsure if this needs to be reset?
            // self.windowShouldClose = false
            return true
        }
        
        if self.profile.isSaved() {
            Swift.print("Profile Saved, Closing Window!")
            // Unsure if this needs to be reset?
            // self.windowShouldClose = false
            return true
        } else {
            let alert = Alert()
            self.alert = alert
            
            let alertMessage = NSLocalizedString("Unsaved Settings", comment: "")
            let alertInformativeText = NSLocalizedString("If you close this window, all unsaved settings will be lost. Are you sure you want to close the window?", comment: "")
            
            if self.profile.title == StringConstant.defaultProfileName {
                
                let informativeText = alertInformativeText + "\n\nYou need to give your profile a name before it can be saved."
                
                // ---------------------------------------------------------------------
                //  Show unnamed and unsaved settings alert to user
                // ---------------------------------------------------------------------
                alert.showAlert(message: alertMessage,
                                informativeText: informativeText,
                                window: sender,
                                defaultString: StringConstant.defaultProfileName,
                                placeholderString: "Name",
                                firstButtonTitle: ButtonTitle.saveAndClose,
                                secondButtonTitle: ButtonTitle.close,
                                thirdButtonTitle: ButtonTitle.cancel,
                                firstButtonState: true,
                                sender: self,
                                returnValue: { (newProfileName, response) in
                                    switch response {
                                    case .alertFirstButtonReturn:
                                        self.profile.updatePayloadSettings(value: newProfileName,
                                                                           key: "PayloadDisplayName",
                                                                           domain: ManifestDomain.general,
                                                                           type: .manifest, updateComplete: { (success, error) in
                                                                            if success {
                                                                                self.profile.save(operationType: .saveOperation, completionHandler: { (saveError) in
                                                                                    if saveError == nil {
                                                                                        self.profile.title = newProfileName
                                                                                        self.performSelector(onMainThread: #selector(self.windowClose), with: self, waitUntilDone: false)
                                                                                        Swift.print("Class: \(self.self), Function: \(#function), Save Successful!")
                                                                                    } else {
                                                                                        Swift.print("Class: \(self.self), Function: \(#function), Error: \(String(describing: saveError))")
                                                                                    }
                                                                                })
                                                                            }
                                        })
                                        Swift.print("Save & Clsoe with the name: \(newProfileName)")
                                    case .alertSecondButtonReturn:
                                        self.performSelector(onMainThread: #selector(self.windowClose), with: self, waitUntilDone: false)
                                    case .alertThirdButtonReturn:
                                        Swift.print("Cancel")
                                    default:
                                        Swift.print("Unknown")
                                    }
                })
                
                // ---------------------------------------------------------------------
                //  Select the text field in the alert sheet
                // ---------------------------------------------------------------------
                if let textFieldInput = alert.textFieldInput {
                    textFieldInput.selectText(self)
                    alert.firstButton?.isEnabled = false
                }
            } else {
                
                // ---------------------------------------------------------------------
                //  Show unsaved settings alert to user
                // ---------------------------------------------------------------------
                self.alert?.showAlert(message: alertMessage,
                                      informativeText: alertInformativeText,
                                      window: sender,
                                      firstButtonTitle: ButtonTitle.saveAndClose,
                                      secondButtonTitle: ButtonTitle.close,
                                      thirdButtonTitle: ButtonTitle.cancel,
                                      firstButtonState: true,
                                      sender: self,
                                      returnValue: { response  in
                                        
                                        switch response {
                                        case .alertFirstButtonReturn:
                                            self.profile.save(operationType: .saveOperation, completionHandler: { (saveError) in
                                                if saveError == nil {
                                                    self.performSelector(onMainThread: #selector(self.windowClose), with: self, waitUntilDone: false)
                                                    Swift.print("Class: \(self.self), Function: \(#function), Save Successful!")
                                                } else {
                                                    Swift.print("Class: \(self.self), Function: \(#function), Error: \(String(describing: saveError))")
                                                }
                                            })
                                            Swift.print("Save & Clsoe")
                                        case .alertSecondButtonReturn:
                                            self.performSelector(onMainThread: #selector(self.windowClose), with: self, waitUntilDone: false)
                                        case .alertThirdButtonReturn:
                                            Swift.print("Cancel")
                                        default:
                                            Swift.print("Unknown")
                                        }
                })
            }
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
        default:
            Swift.print("Unknown Toolbar Identifier: \(identifier)")
        }
        return nil
    }
}

// MARK: -
// MARK: NSTextFieldDelegate Functions
extension ProfileEditorWindowController: NSTextFieldDelegate {
    
    // -------------------------------------------------------------------------
    //  Used when selecting a new profile name to not allow default or empty name
    // -------------------------------------------------------------------------
    override public func controlTextDidChange(_ notification: Notification) {
        
        // ---------------------------------------------------------------------
        //  Get current text in the text field
        // ---------------------------------------------------------------------
        guard let userInfo = notification.userInfo,
            let fieldEditor = userInfo["NSFieldEditor"] as? NSTextView,
            let string = fieldEditor.textStorage?.string else {
                return
        }
        
        // ---------------------------------------------------------------------
        //  If current text in the text field is either:
        //   * Empty
        //   * Matches the default profile name
        //  Disable the OK button.
        // ---------------------------------------------------------------------
        if let alert = self.alert {
            if alert.firstButton!.isEnabled && (string.isEmpty || string == StringConstant.defaultProfileName) {
                alert.firstButton!.isEnabled = false
            } else {
                alert.firstButton!.isEnabled = true
            }
        }
    }
}
