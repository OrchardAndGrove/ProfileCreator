//
//  MainWindowAllProfiles.swift
//  ProfileCreator
//
//  Created by Erik Berglund on 2017-07-09.
//  Copyright © 2017 Erik Berglund. All rights reserved.
//

import Cocoa

class MainWindowAllProfiles: NSObject, OutlineViewParentItem {

    // MARK: -
    // MARK: Variables
    
    var isEditable = false
    var title = "All Profiles"
    var children = [OutlineViewChildItem]()
    var cellView: OutlineViewParentCellView?
    
    // MARK: -
    // MARK: Initialization
    
    override init() {        
        super.init()
        
        // ---------------------------------------------------------------------
        //  Setup the cell view for this outline view item
        // ---------------------------------------------------------------------
        self.cellView = OutlineViewParentCellView(parent: self)
        
        // ---------------------------------------------------------------------
        //  Setup the single outline view child group for this parent
        // ---------------------------------------------------------------------
        let group = MainWindowAllProfilesGroup.init(title: self.title, identifier: nil, parent: self)
        // TODO: When profile controller is added, add all profile identifiers here
        
        // ---------------------------------------------------------------------
        //  Add the group to this parent's childen
        // ---------------------------------------------------------------------
        self.children.append(group)
    }
    
    func addChild() {
        fatalError("This parent item is not editable, this should net be called")
    }
}

class MainWindowAllProfilesGroup: NSObject, OutlineViewChildItem {
    
    // MARK: -
    // MARK: Variables
    
    var isEditable = false
    var icon: NSImage?
    var identifier: UUID
    var title: String
    var children = [OutlineViewChildItem]()
    var profileIdentifiers = [UUID]()
    var cellView: OutlineViewChildCellView?
    
    // MARK: -
    // MARK: Initialization
    
    init(title: String, identifier: UUID?, parent: OutlineViewParentItem) {
        
        self.title = title
        self.identifier = (identifier != nil) ? identifier! : UUID()
        
        super.init()
        
        // ---------------------------------------------------------------------
        //  Setup the cell view for this outline view item
        // ---------------------------------------------------------------------
        self.cellView = OutlineViewChildCellView(child: self)

        // ---------------------------------------------------------------------
        //  Setup Notification Observers
        // ---------------------------------------------------------------------
        NotificationCenter.default.addObserver(self, selector: #selector(didRemoveProfiles(notification:)), name: .didRemoveProfile, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: .didRemoveProfile, object: nil)
    }
    
    func addChild() {
        fatalError("This parent item is not editable, this should net be called")
    }
    
    // MARK: -
    // MARK: Notification Functions
    
    func didRemoveProfiles(notification: NSNotification) {
        Swift.print("didRemoveProfiles")
    }
    
    
    // MARK: -
    // MARK: OutlineViewChildItem Functions
    
    func addProfiles(identifiers: [String]) {
        //TODO: Implement
    }
    
    // MARK: -
    // MARK: MainWindowOutlineViewDelegate Functions
    //TODO: Implement
}
