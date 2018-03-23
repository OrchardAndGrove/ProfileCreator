//
//  PreferencesViewProfileDefaults.swift
//  ProfileCreator
//
//  Created by Erik Berglund on 2017-07-16.
//  Copyright © 2018 Erik Berglund. All rights reserved.
//

import Cocoa
import ProfilePayloads

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
        
        lastSubview = addTextField(label: "Organization Name:",
                                   placeholderValue: "ProfileCreator",
                                   keyPath: PreferenceKey.defaultOrganization,
                                   toView: self,
                                   lastSubview: lastSubview,
                                   lastTextField: nil,
                                   height: &frameHeight,
                                   constraints: &constraints)
        lastTextField = lastSubview
        
        lastSubview = addTextField(label: "Organization Identifier:",
                                   placeholderValue: StringConstant.domain,
                                   keyPath: PreferenceKey.defaultOrganizationIdentifier,
                                   toView: self,
                                   lastSubview: lastSubview,
                                   lastTextField: lastTextField,
                                   height: &frameHeight,
                                   constraints: &constraints)
        lastTextField = lastSubview
        
        lastSubview = addPopUpButton(label: "Distribution:",
                                     titles: [DistributionString.any, DistributionString.manual, DistributionString.push],
                                     bindTo: UserDefaults.standard,
                                     bindKeyPath: PreferenceKey.editorDistributionMethod,
                                     toView: self,
                                     lastSubview: lastSubview,
                                     lastTextField: lastTextField,
                                     height: &frameHeight,
                                     indent: preferencesIndent,
                                     constraints: &constraints)
        
        lastSubview = addCheckbox(label: "Disable Optional Keys",
                                  title: "",
                                  bindTo: UserDefaults.standard,
                                  bindKeyPath: PreferenceKey.editorDisableOptionalKeys,
                                  toView: self,
                                  lastSubview: lastSubview,
                                  lastTextField: lastTextField,
                                  height: &frameHeight,
                                  indent: preferencesIndent,
                                  constraints: &constraints)
        
        // ---------------------------------------------------------------------
        //  Add Preferences "Default Profile Display Settings"
        // ---------------------------------------------------------------------
        lastSubview = addHeader(title: "Default Profile Display Settings",
                                withSeparator: true,
                                toView: self,
                                lastSubview: lastSubview,
                                height: &frameHeight,
                                constraints: &constraints)
        
        lastSubview = addCheckbox(label: "Show Editor Rows",
                                  title: "Enable/Disable",
                                  bindTo: UserDefaults.standard,
                                  bindKeyPath: PreferenceKey.editorColumnEnable,
                                  toView: self,
                                  lastSubview: lastSubview,
                                  lastTextField: lastTextField,
                                  height: &frameHeight,
                                  indent: preferencesIndent,
                                  constraints: &constraints)
        
        lastSubview = addCheckbox(label: "Show Payload Keys",
                                  title: "Hidden",
                                  bindTo: UserDefaults.standard,
                                  bindKeyPath: PreferenceKey.editorShowHiddenKeys,
                                  toView: self,
                                  lastSubview: lastSubview,
                                  lastTextField: lastTextField,
                                  height: &frameHeight,
                                  indent: preferencesIndent,
                                  constraints: &constraints)
        
        lastSubview = addCheckbox(label: nil,
                                  title: "Disabled",
                                  bindTo: UserDefaults.standard,
                                  bindKeyPath: PreferenceKey.editorShowDisabledKeys,
                                  toView: self,
                                  lastSubview: lastSubview,
                                  lastTextField: lastTextField,
                                  height: &frameHeight,
                                  indent: preferencesIndent,
                                  constraints: &constraints)
        
        lastSubview = addCheckbox(label: nil,
                                  title: "Supervised",
                                  bindTo: UserDefaults.standard,
                                  bindKeyPath: PreferenceKey.editorShowSupervisedKeys,
                                  toView: self,
                                  lastSubview: lastSubview,
                                  lastTextField: lastTextField,
                                  height: &frameHeight,
                                  indent: preferencesIndent,
                                  constraints: &constraints)
        
        lastSubview = addCheckbox(label: "Show Platform",
                                  title: "iOS",
                                  bindTo: UserDefaults.standard,
                                  bindKeyPath: PreferenceKey.editorShowIOS,
                                  toView: self,
                                  lastSubview: lastSubview,
                                  lastTextField: lastTextField,
                                  height: &frameHeight,
                                  indent: preferencesIndent,
                                  constraints: &constraints)
        
        lastSubview = addCheckbox(label: nil,
                                  title: "macOS",
                                  bindTo: UserDefaults.standard,
                                  bindKeyPath: PreferenceKey.editorShowMacOS,
                                  toView: self,
                                  lastSubview: lastSubview,
                                  lastTextField: lastTextField,
                                  height: &frameHeight,
                                  indent: preferencesIndent,
                                  constraints: &constraints)
        
        lastSubview = addCheckbox(label: nil,
                                  title: "tvOS",
                                  bindTo: UserDefaults.standard,
                                  bindKeyPath: PreferenceKey.editorShowTvOS,
                                  toView: self,
                                  lastSubview: lastSubview,
                                  lastTextField: lastTextField,
                                  height: &frameHeight,
                                  indent: preferencesIndent,
                                  constraints: &constraints)
        
        lastSubview = addCheckbox(label: "Show Scope",
                                  title: "User",
                                  bindTo: UserDefaults.standard,
                                  bindKeyPath: PreferenceKey.editorShowScopeUser,
                                  toView: self,
                                  lastSubview: lastSubview,
                                  lastTextField: lastTextField,
                                  height: &frameHeight,
                                  indent: preferencesIndent,
                                  constraints: &constraints)
        
        lastSubview = addCheckbox(label: nil,
                                  title: "System",
                                  bindTo: UserDefaults.standard,
                                  bindKeyPath: PreferenceKey.editorShowScopeSystem,
                                  toView: self,
                                  lastSubview: lastSubview,
                                  lastTextField: lastTextField,
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
