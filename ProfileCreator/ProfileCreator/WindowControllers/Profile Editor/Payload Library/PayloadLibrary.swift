//
//  PayloadLibrary.swift
//  ProfileCreator
//
//  Created by Erik Berglund on 2017-07-28.
//  Copyright © 2017 Erik Berglund. All rights reserved.
//

import Cocoa

class PayloadLibrary: NSObject {
    
    // MARK: -
    // MARK: Variables
    
    private weak var profile: Profile?
    
    let splitView: PayloadLibrarySplitView
    
    init(profile: Profile, editor: ProfileEditor) {
        
        self.splitView = PayloadLibrarySplitView(profile: profile, editor: editor)
        
        super.init()
        
        // ---------------------------------------------------------------------
        //  Setup Variables
        // ---------------------------------------------------------------------
        self.profile = profile
        
    }
}