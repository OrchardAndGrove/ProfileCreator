//
//  AppDelegate.swift
//  ProfileCreator
//
//  Created by Erik Berglund on 2017-07-06.
//  Copyright © 2018 Erik Berglund. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    // MARK: -
    // MARK: Variables
    
    let mainWindowController = MainWindowController()
    let preferencesWindowController = PreferencesWindowController()
    
    // MARK: -
    // MARK: NSApplicationDelegate Methods
    
    func applicationWillFinishLaunching(_ notification: Notification) {
        
        // ---------------------------------------------------------------------
        //  Register user defaults
        // ---------------------------------------------------------------------
        registerDefaults()
        
        // ---------------------------------------------------------------------
        //  Initialize application menus
        // ---------------------------------------------------------------------
        configureMenuItems()
        
        // ---------------------------------------------------------------------
        //  Show main window
        // ---------------------------------------------------------------------
        self.mainWindowController.window?.makeKeyAndOrderFront(self)
    }
    
    // MARK: -
    // MARK: Initialization
    
    func registerDefaults() {

        // ---------------------------------------------------------------------
        //  Get URL to application default settings
        // ---------------------------------------------------------------------
        guard let defaultSettingsURL = Bundle.main.url(forResource: "Defaults", withExtension: "plist") else {
            Log.shared.error(message: "No bundle defaults file found")
            return
        }
        
        // ---------------------------------------------------------------------
        //  Register default settings with UserDefaults
        // ---------------------------------------------------------------------
        if let defaultSettings = NSDictionary(contentsOf: defaultSettingsURL) as? [String : Any] {
            UserDefaults.standard.register(defaults: defaultSettings)
        }
    }
    
    func configureMenuItems() {
        
        // ---------------------------------------------------------------------
        //  Get main menu
        // ---------------------------------------------------------------------
        guard let mainMenu = NSApplication.shared.mainMenu else { return }
        
        // ---------------------------------------------------------------------
        //  Get application menu item submenu
        // ---------------------------------------------------------------------
        if let applicationMenu = mainMenu.item(at: 0)?.submenu {
            
            // -----------------------------------------------------------------
            //  Set action for menu item "Preferences…"
            // -----------------------------------------------------------------
            if let preferencesMenuItem = applicationMenu.item(withTitle: "Preferences\u{2026}") {
                preferencesMenuItem.target = self
                preferencesMenuItem.action = #selector(menuItemPreferences(_:))
            }
        }
        
        // ---------------------------------------------------------------------
        //  Get window menu item submenu
        // ---------------------------------------------------------------------
        if let windowMenu = mainMenu.item(at: 5)?.submenu {
            
            // -----------------------------------------------------------------
            //  Set action for menu item "Main Window"
            // -----------------------------------------------------------------
            if let mainWindowMenuItem = windowMenu.item(withTitle: "Main Window") {
                mainWindowMenuItem.target = self
                mainWindowMenuItem.action = #selector(menuItemMainWindow(_:))
            }
        }
    }
    
    // MARK: -
    // MARK: NSMenuItem Functions
    
    @objc func menuItemMainWindow(_ menuItem: NSMenuItem?) {
        self.mainWindowController.window?.makeKeyAndOrderFront(self)
    }
    
    @objc func menuItemPreferences(_ menuItem: NSMenuItem?) {
        self.preferencesWindowController.window?.makeKeyAndOrderFront(self)
    }
}

