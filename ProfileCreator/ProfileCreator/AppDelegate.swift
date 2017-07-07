//
//  AppDelegate.swift
//  ProfileCreator
//
//  Created by Erik Berglund on 2017-07-06.
//  Copyright © 2017 Erik Berglund. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    // MARK: -
    // MARK: Variables
    
    let mainWindowController = MainWindowController()

    // MARK: -
    // MARK: NSApplicationDelegate Methods
    
    func applicationWillFinishLaunching(_ notification: Notification) {
        
        // ---------------------------------------------------------------------
        //  Register user defaults
        // ---------------------------------------------------------------------
        registerDefaults()
        
        // ---------------------------------------------------------------------
        //  Show main window
        // ---------------------------------------------------------------------
        mainWindowController.window?.makeKeyAndOrderFront(self)
    }
    
    func registerDefaults() {
        
        // ---------------------------------------------------------------------
        //  Get URL to application default settings
        // ---------------------------------------------------------------------
        guard let defaultSettingsURL = Bundle.main.url(forResource: "Defaults", withExtension: "plist") else {
            // TODO: Proper logging
            print("No Defaults file found!")
            return
        }
        
        // ---------------------------------------------------------------------
        //  Register default settings with UserDefaults
        // ---------------------------------------------------------------------
        if  let defaultSettingsDict = NSDictionary(contentsOf: defaultSettingsURL),
            let defaultSettings = defaultSettingsDict as? [String : Any] {
            UserDefaults.standard.register(defaults: defaultSettings)
        }
    }
}

