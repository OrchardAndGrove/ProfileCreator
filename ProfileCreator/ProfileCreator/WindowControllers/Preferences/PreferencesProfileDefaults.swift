//
//  PreferencesViewProfileDefaults.swift
//  ProfileCreator
//
//  Created by Erik Berglund on 2017-07-16.
//  Copyright © 2018 Erik Berglund. All rights reserved.
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
        self.toolbarItem.image = NSImage(named: .homeTemplate)
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
        var lastTextField: NSView?
        
        // ---------------------------------------------------------------------
        //  Add Preferences "Default Profile Settings"
        // ---------------------------------------------------------------------
        lastSubview = addHeader(title: "Default Profile Settings",
                                withSeparator: true,
                                toView: self,
                                lastSubview: nil,
                                height: &frameHeight,
                                constraints: &constraints)
        
        lastSubview = addTextField(label: "Organization Name",
                                   placeholderValue: "ProfileCreator",
                                   keyPath: PreferenceKey.defaultOrganization,
                                   toView: self,
                                   lastSubview: lastSubview,
                                   lastTextField: nil,
                                   height: &frameHeight,
                                   constraints: &constraints)
        lastTextField = lastSubview
        
        lastSubview = addTextField(label: "Organization Identifier",
                                   placeholderValue: StringConstant.domain,
                                   keyPath: PreferenceKey.defaultOrganizationIdentifier,
                                   toView: self,
                                   lastSubview: lastSubview,
                                   lastTextField: lastTextField,
                                   height: &frameHeight,
                                   constraints: &constraints)
        lastTextField = lastSubview
        
        lastSubview = addHeader(title: "Payload Keys",
                                withSeparator: true,
                                toView: self,
                                lastSubview: lastSubview,
                                height: &frameHeight,
                                constraints: &constraints)
        
        lastSubview = addCheckbox(title: "Disable Optional Keys",
                                  bindTo: UserDefaults.standard,
                                  bindKeyPath: PreferenceKey.editorDisableOptionalKeys,
                                  toView: self,
                                  lastSubview: lastSubview,
                                  height: &frameHeight,
                                  indent: preferencesIndent,
                                  constraints: &constraints)
        
        lastSubview = addCheckbox(title: "Show Hidden",
                                  bindTo: UserDefaults.standard,
                                  bindKeyPath: PreferenceKey.editorShowHiddenKeys,
                                  toView: self,
                                  lastSubview: lastSubview,
                                  height: &frameHeight,
                                  indent: preferencesIndent,
                                  constraints: &constraints)
        
        lastSubview = addCheckbox(title: "Show Disabled",
                                  bindTo: UserDefaults.standard,
                                  bindKeyPath: PreferenceKey.editorShowDisabledKeys,
                                  toView: self,
                                  lastSubview: lastSubview,
                                  height: &frameHeight,
                                  indent: preferencesIndent,
                                  constraints: &constraints)
        
        lastSubview = addCheckbox(title: "Show Supervised",
                                  bindTo: UserDefaults.standard,
                                  bindKeyPath: PreferenceKey.editorShowSupervisedKeys,
                                  toView: self,
                                  lastSubview: lastSubview,
                                  height: &frameHeight,
                                  indent: preferencesIndent,
                                  constraints: &constraints)
        
        lastSubview = addHeader(title: "Editor Rows",
                                withSeparator: true,
                                toView: self,
                                lastSubview: lastSubview,
                                height: &frameHeight,
                                constraints: &constraints)
        
        lastSubview = addCheckbox(title: "Show Enable/Disable",
                                  bindTo: UserDefaults.standard,
                                  bindKeyPath: PreferenceKey.editorColumnEnable,
                                  toView: self,
                                  lastSubview: lastSubview,
                                  height: &frameHeight,
                                  indent: preferencesIndent,
                                  constraints: &constraints)
        
        lastSubview = addHeader(title: "Platform",
                                withSeparator: true,
                                toView: self,
                                lastSubview: lastSubview,
                                height: &frameHeight,
                                constraints: &constraints)
        
        lastSubview = addCheckbox(title: "iOS",
                                  bindTo: UserDefaults.standard,
                                  bindKeyPath: PreferenceKey.editorShowIOS,
                                  toView: self,
                                  lastSubview: lastSubview,
                                  height: &frameHeight,
                                  indent: preferencesIndent,
                                  constraints: &constraints)
        
        lastSubview = addCheckbox(title: "macOS",
                                  bindTo: UserDefaults.standard,
                                  bindKeyPath: PreferenceKey.editorShowMacOS,
                                  toView: self,
                                  lastSubview: lastSubview,
                                  height: &frameHeight,
                                  indent: preferencesIndent,
                                  constraints: &constraints)
        
        lastSubview = addCheckbox(title: "tvOS",
                                  bindTo: UserDefaults.standard,
                                  bindKeyPath: PreferenceKey.editorShowTvOS,
                                  toView: self,
                                  lastSubview: lastSubview,
                                  height: &frameHeight,
                                  indent: preferencesIndent,
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
