//
//  ProfileEditorSettingsPopOver.swift
//  ProfileCreator
//
//  Created by Erik Berglund on 2018-02-16.
//  Copyright © 2018 Erik Berglund. All rights reserved.
//

import Cocoa

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
        
        // ---------------------------------------------------------------------
        //  Add Preferences "Sidebar"
        // ---------------------------------------------------------------------
        lastSubview = addHeader(title: "Payload Keys",
                                withSeparator: true,
                                toView: self,
                                lastSubview: nil,
                                height: &frameHeight,
                                constraints: &constraints)
        
        lastSubview = addCheckbox(title: "Show Hidden",
                                  bindTo: profile,
                                  bindKeyPath: "editorShowHidden",
                                  toView: self,
                                  lastSubview: lastSubview,
                                  height: &frameHeight,
                                  indent: editorPreferencesIndent,
                                  constraints: &constraints)
        
        
        lastSubview = addCheckbox(title: "Show Disabled",
                                  bindTo: profile,
                                  bindKeyPath: "editorShowDisabled",
                                  toView: self,
                                  lastSubview: lastSubview,
                                  height: &frameHeight,
                                  indent: editorPreferencesIndent,
                                  constraints: &constraints)
        
        lastSubview = addCheckbox(title: "Show Supervised",
                                  bindTo: profile,
                                  bindKeyPath: "editorShowSupervised",
                                  toView: self,
                                  lastSubview: lastSubview,
                                  height: &frameHeight,
                                  indent: editorPreferencesIndent,
                                  constraints: &constraints)
        
        lastSubview = addHeader(title: "Editor Rows",
                                withSeparator: true,
                                toView: self,
                                lastSubview: lastSubview,
                                height: &frameHeight,
                                constraints: &constraints)
        
        lastSubview = addCheckbox(title: "Show Enable/Disable",
                                  bindTo: profile,
                                  bindKeyPath: "editorColumnEnable",
                                  toView: self,
                                  lastSubview: lastSubview,
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
        self.frame = NSRect.init(x: 0.0, y: 0.0, width: editorPreferencesWindowWidth, height: frameHeight)
    }
}
