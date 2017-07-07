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
        //  Show main window
        // ---------------------------------------------------------------------
        mainWindowController.window?.makeKeyAndOrderFront(self)
    }
}

