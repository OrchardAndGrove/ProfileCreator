//
//  ProfileEditorSettingsPopOver.swift
//  ProfileCreator
//
//  Created by Erik Berglund on 2018-02-16.
//  Copyright © 2018 Erik Berglund. All rights reserved.
//

import Cocoa
import ProfilePayloads

class ProfileEditorSettingsViewController: NSViewController {
    
    // MARK: -
    // MARK: Variables
    
    weak var profile: Profile?
    
    // MARK: -
    // MARK: Initialization
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init(profile: Profile) {
        self.profile = profile
        super.init(nibName: nil, bundle: nil)
    }
    
    // MARK: -
    // MARK: NSViewController Overrides
    
    override func loadView() {
        if let profile = self.profile {
            self.view = ProfileEditorSettigsView(profile: profile)
        } else { self.view = NSView() }
    }
}

class ProfileEditorSettigsView: NSView {
    
    // MARK: -
    // MARK: Variables
    
    weak var profile: Profile?
    
    // MARK: -
    // MARK: Initialization
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init(profile: Profile) {
        super.init(frame: NSZeroRect)
        
        self.translatesAutoresizingMaskIntoConstraints = false
        
        // ---------------------------------------------------------------------
        //  Setup Variables
        // ---------------------------------------------------------------------
        self.profile = profile
        var constraints = [NSLayoutConstraint]()
        var frameHeight: CGFloat = 0.0
        var lastSubview: NSView?
        var lastTextField: NSView?
        
        // ---------------------------------------------------------------------
        //  Add Preferences "Sidebar"
        // ---------------------------------------------------------------------
        lastSubview = addHeader(title: "Profile Settings",
                                withSeparator: true,
                                toView: self,
                                lastSubview: nil,
                                height: &frameHeight,
                                constraints: &constraints)
        
        lastSubview = addCheckbox(label: "Disable Optional Keys",
                                  title: "",
                                  bindTo: profile,
                                  bindKeyPath: "editorDisableOptionalKeys",
                                  toView: self,
                                  lastSubview: lastSubview,
                                  lastTextField: nil,
                                  height: &frameHeight,
                                  indent: editorPreferencesIndent,
                                  constraints: &constraints)
        
        lastSubview = addPopUpButton(label: "Distribution:",
                                     titles: [DistributionString.any, DistributionString.manual, DistributionString.push],
                                     bindTo: profile,
                                     bindKeyPath: "editorDistributionMethod",
                                     toView: self,
                                     lastSubview: lastSubview,
                                     lastTextField: lastSubview,
                                     height: &frameHeight,
                                     indent: editorPreferencesIndent,
                                     constraints: &constraints)
        lastTextField = lastSubview

        lastSubview = addHeader(title: "Profile Display Settings",
                                withSeparator: true,
                                toView: self,
                                lastSubview: lastSubview,
                                height: &frameHeight,
                                constraints: &constraints)
        
        lastSubview = addCheckbox(label: "Show Editor Rows",
                                  title: "Enable/Disable",
                                  bindTo: profile,
                                  bindKeyPath: "editorColumnEnable",
                                  toView: self,
                                  lastSubview: lastSubview,
                                  lastTextField: lastTextField,
                                  height: &frameHeight,
                                  indent: editorPreferencesIndent,
                                  constraints: &constraints)
        
        lastSubview = addCheckbox(label: "Show Payload Keys",
                                  title: "Hidden",
                                  bindTo: profile,
                                  bindKeyPath: "editorShowHidden",
                                  toView: self,
                                  lastSubview: lastSubview,
                                  lastTextField: lastSubview,
                                  height: &frameHeight,
                                  indent: editorPreferencesIndent,
                                  constraints: &constraints)
        
        
        lastSubview = addCheckbox(label: nil,
                                  title: "Disabled",
                                  bindTo: profile,
                                  bindKeyPath: "editorShowDisabled",
                                  toView: self,
                                  lastSubview: lastSubview,
                                  lastTextField: lastSubview,
                                  height: &frameHeight,
                                  indent: editorPreferencesIndent,
                                  constraints: &constraints)
    
        lastSubview = addCheckbox(label: nil,
                                  title: "Supervised",
                                  bindTo: profile,
                                  bindKeyPath: "editorShowSupervised",
                                  toView: self,
                                  lastSubview: lastSubview,
                                  lastTextField: lastSubview,
                                  height: &frameHeight,
                                  indent: editorPreferencesIndent,
                                  constraints: &constraints)
        
        lastSubview = addCheckbox(label: "Show Platform",
                                  title: "iOS",
                                  bindTo: profile,
                                  bindKeyPath: "editorShowIOS",
                                  toView: self,
                                  lastSubview: lastSubview,
                                  lastTextField: lastSubview,
                                  height: &frameHeight,
                                  indent: editorPreferencesIndent,
                                  constraints: &constraints)
        
        lastSubview = addCheckbox(label: nil,
                                  title: "macOS",
                                  bindTo: profile,
                                  bindKeyPath: "editorShowMacOS",
                                  toView: self,
                                  lastSubview: lastSubview,
                                  lastTextField: lastSubview,
                                  height: &frameHeight,
                                  indent: editorPreferencesIndent,
                                  constraints: &constraints)
        
        lastSubview = addCheckbox(label: nil,
                                  title: "tvOS",
                                  bindTo: profile,
                                  bindKeyPath: "editorShowTvOS",
                                  toView: self,
                                  lastSubview: lastSubview,
                                  lastTextField: lastSubview,
                                  height: &frameHeight,
                                  indent: editorPreferencesIndent,
                                  constraints: &constraints)
        
        lastSubview = addCheckbox(label: "Show Scope",
                                  title: "User",
                                  bindTo: profile,
                                  bindKeyPath: "editorShowScopeUser",
                                  toView: self,
                                  lastSubview: lastSubview,
                                  lastTextField: lastSubview,
                                  height: &frameHeight,
                                  indent: editorPreferencesIndent,
                                  constraints: &constraints)
        
        lastSubview = addCheckbox(label: nil,
                                  title: "System",
                                  bindTo: profile,
                                  bindKeyPath: "editorShowScopeSystem",
                                  toView: self,
                                  lastSubview: lastSubview,
                                  lastTextField: lastSubview,
                                  height: &frameHeight,
                                  indent: editorPreferencesIndent,
                                  constraints: &constraints)
        
        // ---------------------------------------------------------------------
        //  Add constraints to last view
        // ---------------------------------------------------------------------
        
        // Bottom
        constraints.append(NSLayoutConstraint(item: self,
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
        self.frame = NSRect(x: 0.0, y: 0.0, width: editorPreferencesWindowWidth, height: frameHeight)
    }
}
