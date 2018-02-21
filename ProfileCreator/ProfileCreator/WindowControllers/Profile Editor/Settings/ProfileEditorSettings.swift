//
//  ProfileEditorSettings.swift
//  ProfileCreator
//
//  Created by Erik Berglund on 2018-02-16.
//  Copyright © 2018 Erik Berglund. All rights reserved.
//

import Cocoa

class ProfileEditorSettings {
    
    // MARK: -
    // MARK: Static Variables
    
    weak var profile: Profile?
    
    // MARK: -
    // MARK: Variables
    
    let popOver = NSPopover()
    let viewControllerSettings: ProfileEditorSettingsViewController
    
    // MARK: -
    // MARK: Initialization
    
    init(profile: Profile) {
        self.profile = profile
        
        self.viewControllerSettings = ProfileEditorSettingsViewController(profile: profile)
        
        self.popOver.contentSize = self.viewControllerSettings.view.frame.size
        self.popOver.behavior = .transient
        self.popOver.animates = true
        self.popOver.contentViewController = self.viewControllerSettings
    }
}